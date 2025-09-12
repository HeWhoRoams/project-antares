# class_name RacePreset
extends Resource

@export var race_name: String
@export var description: String
@export var home_world_type: String # e.g., "Volcanic", "Terran"
@export var sprite_path: String # Path to race's icon/portrait

@export var base_attributes: Dictionary # String (attribute_id) -> RaceAttributeValue

func _init():
	base_attributes = {} # Initialize dictionary

# Helper to set attribute values in editor
func set_attribute(attr_id: String, value: int, variance: int = 0):
	base_attributes[attr_id] = RaceAttributeValue.new(value, variance)