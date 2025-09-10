# /scripts/managers/AIManager.gd
extends Node

# For now, we will manage one AI's ships here.
# This will be expanded later to handle multiple AI factions.
var owned_ships: Dictionary = {}

func _ready() -> void:
	_create_starting_fleet()

func _create_starting_fleet() -> void:
	var silicoid_ship_data = ShipData.new()
	silicoid_ship_data.id = "silicoid_scout_01"
	silicoid_ship_data.owner_id = 2 # A different ID from the player (1)
	silicoid_ship_data.current_system_id = "sirius" # Start in a different system
	owned_ships[silicoid_ship_data.id] = silicoid_ship_data
