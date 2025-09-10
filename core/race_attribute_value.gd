# class_name RaceAttributeValue
extends RefCounted # Or Resource if you need to save them as standalone files

@export_range(1, 10, 1) var value: int = 5
@export_range(0, 5, 1) var variance: int = 0 # How much can this value deviate from base

func _init(p_value: int = 5, p_variance: int = 0):
	value = p_value
	variance = p_variance

func get_randomized_value() -> int:
	if variance == 0:
		return value
	var min_val = max(1, value - variance)
	var max_val = min(10, value + variance)
	return randi_range(min_val, max_val)
