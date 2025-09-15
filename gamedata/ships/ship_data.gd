# /gamedata/ships/ship_data.gd
class_name ShipData
extends Resource

@export var id: StringName
@export var owner_id: StringName # Changed from int to StringName
@export var current_system_id: StringName
@export var destination_system_id: StringName = &""
@export var turns_to_arrival: int = 0