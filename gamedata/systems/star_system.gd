# /gamedata/systems/star_system.gd
@tool
class_name StarSystem
extends Resource

## The unique identifier for this system (e.g., "sol").
@export var id: StringName

## The player-facing name of the system (e.g., "Sol System").
@export var display_name: String

## The system's location in 2D galaxy coordinates.
@export var position: Vector2

## An array of celestial bodies within this system.
@export var celestial_bodies: Array[CelestialBodyData] = []
