# class_name DialogGenerator
extends Node

# @onready var data_manager = %DataManager # Assuming DataManager has loaded all DialogPhrasePools

var phrase_pools: Dictionary # String (dialog_type_id) -> Dictionary (attribute_id -> DialogPhrasePool)

func _ready():
	# Example: Load phrase pools from DataManager.
	# For simplicity here, imagine DataManager has a method like `get_all_dialog_phrase_pools()`
	# self.phrase_pools = data_manager.get_all_dialog_phrase_pools_structured()
	# For now, manually load one for demonstration
	var eloquence_war_pool: DialogPhrasePool = load("res://data/dialog/dialog_eloquence_declare_war.tres")
	if not phrase_pools.has(eloquence_war_pool.dialog_type_id):
		phrase_pools[eloquence_war_pool.dialog_type_id] = {}
	phrase_pools[eloquence_war_pool.dialog_type_id][eloquence_war_pool.attribute_id] = eloquence_war_pool


static func generate(dialog_type: String, source_faction: FactionAI, target_faction: FactionAI = null) -> String:
	var instance = DialogGenerator.get_singleton("DialogGenerator") # Access the autoloaded singleton

	var base_phrase = "Placeholder Dialog."

	# --- Determine the primary attribute for this dialog type ---
	# This needs a mapping somewhere, e.g., a dictionary in DialogGenerator
	# `dialog_type_to_primary_attribute = {"DECLARE_WAR": "ELOQUENCE", "ALLIANCE_OFFER": "TRUST"}`
	var primary_attr_id = "ELOQUENCE" # For "DECLARE_WAR" as an example

	if instance.phrase_pools.has(dialog_type) and instance.phrase_pools[dialog_type].has(primary_attr_id):
		var pool: DialogPhrasePool = instance.phrase_pools[dialog_type][primary_attr_id]
		var score = source_faction.get_attribute_value(primary_attr_id)
		base_phrase = pool.get_phrase_for_score(score)

	# --- Apply Procedural Modifiers based on *other* attributes ---
	var final_dialog = base_phrase

	# Example: Formality modifier
	var formality_score = source_faction.get_attribute_value("FORMALITY")
	if formality_score <= 3:
		# Very low formality: make it blunt
		final_dialog = final_dialog.replace(".", "!") # Simple example
	elif formality_score >= 8:
		# Very high formality: add salutations
		final_dialog = "Esteemed " + target_faction.race_preset.race_name + " Representative, " + final_dialog

	# Example: Aggression modifier (for a DECLARE_WAR dialog)
	var aggression_score = source_faction.get_attribute_value("AGGRESSION")
	if dialog_type == "DECLARE_WAR":
		if aggression_score >= 8:
			final_dialog += " Prepare for annihilation!"
		elif aggression_score <= 3:
			final_dialog += " Though we regret this, it is necessary."


	# Example: Eloquence procedural modifiers (for DECLARE_WAR)
	var eloquence_score = source_faction.get_attribute_value("ELOQUENCE")
	if eloquence_score == 10:
		final_dialog = final_dialog.replace(".", ", " + _get_ornamentation_phrase() + ".")
	elif eloquence_score == 9:
		final_dialog = final_dialog.replace(".", ", " + _get_complex_phrase() + ".")
	elif eloquence_score == 2:
		final_dialog = final_dialog.replace("We", "Me").replace(".", "...") # Simple, broken speech

	return final_dialog

# Helper functions for procedural embellishments
static func _get_ornamentation_phrase() -> String:
	var phrases = [
		"a decision forged in the crucible of truth",
		"a declaration reverberating throughout the cosmos",
		"the only recourse left to rectify your boundless perfidy"
	]
	return phrases[randi() % phrases.size()]

static func _get_complex_phrase() -> String:
	var phrases = [
		"after much deliberation",
		"as the stars bear witness",
		"with an unyielding resolve"
	]
	return phrases[randi() % phrases.size()]
