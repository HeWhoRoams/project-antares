class_name ShipHull
extends Resource

enum HullSize { FRIGATE, DESTROYER, CRUISER, BATTLESHIP, DREADNOUGHT }

@export var id: StringName
@export var display_name: String
@export var hull_size: HullSize
@export var base_armor: int = 10
@export var base_speed: int = 5
@export var base_cost: int = 50
@export var required_tech: StringName
