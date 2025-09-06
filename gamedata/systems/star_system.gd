# /gamedata/systems/star_system.gd
# Defines the data for a single star system.
@tool
class_name StarSystem extends Resource

## The unique identifier for this system (e.g., "sol").
@export var id: StringName

## The player-facing name of the system (e.g., "Sol System").
@export var display_name: String

## The system's location in 2D galaxy coordinates.
@export var position: Vector2

## (Future) An array of planets within this system.
# @export var planets: Array[Planet]