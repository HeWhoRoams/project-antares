# /gamedata/colonies.gd
class_name ColonyData
extends Resource

@export var owner_id: StringName
@export var system_id: StringName
@export var orbital_slot: int
@export var current_population: int = 0
@export var workers: int = 0
@export var farmers: int = 0
@export var scientists: int = 0
