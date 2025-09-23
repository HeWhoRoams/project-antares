class_name ShipModule
extends Resource

enum ModuleType { WEAPON, SHIELD, ENGINE, SPECIAL }

@export var id: StringName
@export var display_name: String
@export var module_type: ModuleType
@export var base_damage: int = 5
@export var base_shield: int = 10
@export var base_speed_bonus: int = 0
@export var base_cost: int = 25
@export var required_tech: StringName
