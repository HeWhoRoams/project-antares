# class_name DiplomacyManager
extends Node

# @onready var player_manager = %PlayerManager # Access player manager to get FactionAIs

# --- General Diplomacy Logic ---

func offer_alliance(proposing_faction_id: int, target_faction_id: int) -> bool:
	var proposing_ai: FactionAI = player_manager.get_faction_ai(proposing_faction_id)
	var target_ai: FactionAI = player_manager.get_faction_ai(target_faction_id)

	if not proposing_ai or not target_ai: return false

	# Target AI considers the offer based on its attributes
	var accepted = target_ai.consider_alliance_offer(proposing_ai)

	if accepted:
		# Create actual alliance in game state
		print("%s accepted alliance with %s!" % [target_ai.race_preset.race_name, proposing_ai.race_preset.race_name])
	else:
		print("%s rejected alliance with %s." % [target_ai.race_preset.race_name, proposing_ai.race_preset.race_name])

	# Generate dialog for response
	var response_dialog = target_ai.generate_dialog("ALLIANCE_RESPONSE", proposing_ai)
	print("Response: %s" % response_dialog)

	return accepted

func check_forgiveness(betrayer_faction: FactionAI, betrayed_faction: FactionAI) -> bool:
	var vindictiveness_score = betrayed_faction.get_attribute_value("VINDICTIVENESS")
	var turns_since_betrayal = get_turns_since_event(betrayer_faction, betrayed_faction, "betrayal") # Assumes game history log

	# Lower vindictiveness, quicker forgiveness
	# Higher vindictiveness, longer it takes
	var forgiveness_threshold_turns = (11 - vindictiveness_score) * 5 # Example: 50 turns for 1, 5 turns for 10

	return turns_since_betrayal > forgiveness_threshold_turns and randf() < (1.0 / vindictiveness_score) # Highly vindictive (10) means 10% chance
