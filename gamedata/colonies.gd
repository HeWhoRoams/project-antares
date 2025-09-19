# /gamedata/colonies/colony_data.gd
class_name ColonyData
extends Resource

## The ID of the empire that owns this colony.
@export var owner_id: StringName

## The unique ID of the system this colony is in.
@export var system_id: StringName

## The orbital slot of the planet this colony is on.
@export var orbital_slot: int

## The current number of population units.
@export var current_population: int = 0

## The number of population units assigned to farming.
@export var farmers: int = 0

## The number of population units assigned to industry.
@export var workers: int = 0

## The number of population units assigned to research.
@export var scientists: int = 0

## An array of BuildableItem IDs.
@export var construction_queue: Array[StringName] = []
@export var current_build_progress: float = 0.0