# class_name FactionAI
extends RefCounted # Since it's not a node, RefCounted is good

var player_id: int
var race_preset: RacePreset
var attributes: Dictionary # String (attribute_id) -> int (randomized value 1-10)

func _init(p_player_id: int, p_race_preset: RacePreset):
	player_id = p_player_id
	race_preset = p_race_preset
	attributes = {}
	_randomize_attributes()

func _randomize_attributes():
	for attr_id in race_preset.base_attributes.keys():
		var attr_val_data: RaceAttributeValue = race_preset.base_attributes[attr_id]
		attributes[attr_id] = attr_val_data.get_randomized_value()

func get_attribute_value(attr_id: String) -> int:
	return attributes.get(attr_id, 5) # Default to 5 if not set

# --- Diplomacy Methods ---

func generate_dialog(dialog_type: String, target_faction_ai: FactionAI = null) -> String:
	var eloquence_score = get_attribute_value("ELOQUENCE")
	var aggression_score = get_attribute_value("AGGRESSION")
	var formality_score = get_attribute_value("FORMALITY")
	# ... other relevant attributes

	# This is where the DialogGenerator (see below) comes in
	return DialogGenerator.generate(dialog_type, self, target_faction_ai)

func consider_alliance_offer(proposing_faction: FactionAI) -> bool:
	var trust_score = get_attribute_value("TRUST")
	var honor_score = get_attribute_value("HONOR")
	var pragmatism_score = get_attribute_value("PRAGMATISM")
	var aggression_score = get_attribute_value("AGGRESSION")

	# Placeholder logic:
	var base_acceptance_chance = 0.5
	var modifier = 0.0

	# Trust: Higher trust increases chance
	modifier += (trust_score - 5) * 0.08 # Example: +8% per point above 5

	# Honor: If proposing faction has low honor history, reduce chance
	# (Requires game state tracking of honor violations)
	# if proposing_faction.get_historical_honor_violations(self) > 0:
	# 	modifier -= (honor_score - 1) * 0.1 # More honorable, more sensitive to past breaches

	# Aggression: Highly aggressive might prefer dominance over alliances
	modifier -= (aggression_score - 5) * 0.05 # Example: -5% per point above 5

	# Pragmatism: More pragmatic, more likely to accept if it sees benefit
	# (Requires evaluating game state, e.g., "proposing_faction_strength > my_strength")
	# if game_state_evaluator.is_stronger_than(proposing_faction, self):
	# 	modifier += (pragmatism_score - 5) * 0.07

	var final_chance = base_acceptance_chance + modifier
	final_chance = clamp(final_chance, 0.0, 1.0) # Ensure between 0 and 1

	return randf() < final_chance

func remember_betrayal(betrayer_faction: FactionAI, turn: int):
	var vindictiveness_score = get_attribute_value("VINDICTIVENESS")
	# Store betrayal in a history log for this faction
	# The duration and intensity of remembrance could be based on vindictiveness
	# e.g., `vindictiveness * 5` turns for a strong memory.
	print("%s remembers %s's betrayal (Vindictiveness: %d)" % [race_preset.race_name, betrayer_faction.race_preset.race_name, vindictiveness_score])

# ... other behavioral methods like declare_war_probability, offer_tech_chance, etc.
