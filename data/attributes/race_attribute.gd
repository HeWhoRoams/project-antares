# class_name RaceAttribute
extends Resource

@export var attribute_id: String # Unique ID, e.g., "ELOQUENCE", "TRUST"
@export var attribute_name: String # Display name, e.g., "Eloquence", "Trust"
@export var description: String # For tooltip/UI explanation

# Optional: Min/Max for validation if not using 1-10 rigidly
# @export_range(1, 10, 1) var min_value: int = 1
# @export_range(1, 10, 1) var max_value: int = 10
