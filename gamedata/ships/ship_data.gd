# /gamedata/ships/ship_data.gd
# A data resource that holds the state of a single ship.
class_name ShipData
extends Resource

## A unique identifier for this ship, e.g., "scout_01".
@export var id: StringName

## The ID of the player who owns this ship.
@export var owner_id: int = 1

## The ID of the star system where the ship is currently located.
@export var current_system_id: StringName

## (Future) The ID of the system the ship is traveling to.
# @export var destination_system_id: StringName