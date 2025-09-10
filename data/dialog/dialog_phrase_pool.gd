# class_name DialogPhrasePool
extends Resource

@export var dialog_type_id: String # e.g., "DECLARE_WAR", "ALLIANCE_OFFER", "GREETING"
@export var attribute_id: String # Which attribute influences this dialog, e.g., "ELOQUENCE"

# Dictionary to hold phrases for different score bands
# int (score band start, e.g., 1, 3, 5, 7, 9) -> Array[String] (phrases)
@export var phrase_bands: Dictionary

func _init():
	phrase_bands = {
		1: [], # Extreme Low
		3: [], # Low
		5: [], # Neutral
		7: [], # High
		9: []  # Extreme High
	}

func get_phrase_for_score(score: int) -> String:
	# Find the closest band
	var band_key = 1
	if score >= 9: band_key = 9
	elif score >= 7: band_key = 7
	elif score >= 5: band_key = 5
	elif score >= 3: band_key = 3
	# else band_key remains 1

	var phrases: Array[String] = phrase_bands.get(band_key, [])
	if phrases.is_empty():
		# Fallback to a default if band is empty, or raise error
		return "ERROR: No phrase for score %d in type %s" % [score, dialog_type_id]
	return phrases[randi() % phrases.size()]
