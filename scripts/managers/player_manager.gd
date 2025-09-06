# /scripts/managers/player_manager.gd
# A global singleton to manage the player's empire-wide state.
extends Node

## The player's current total of research points.
var research_points: int = 0
var research_per_turn: int = 10

## A dictionary of all ships owned by the player, keyed by their unique ID.
var owned_ships: Dictionary = {}

func _ready() -> void:
	# For the MVP, we create a single starting ship for the player.
	_create_starting_ship()
	
	# Connect to the TurnManager's signal to receive turn updates.
	TurnManager.turn_ended.connect(_on_turn_ended)

func _create_starting_ship() -> void:
	var starting_ship_data = ShipData.new()
	starting_ship_data.id = "scout_01"
	starting_ship_data.owner_id = 1 # Player 1
	starting_ship_data.current_system_id = "sol" # Start in the Sol system
	
	owned_ships[starting_ship_data.id] = starting_ship_data
	print("PlayerManager: Created starting ship '%s' in system '%s'." % [starting_ship_data.id, starting_ship_data.current_system_id])

## This function runs every time the TurnManager emits the turn_ended signal.
func _on_turn_ended(new_turn_number: int) -> void:
	# Generate resources
	research_points += research_per_turn
	print("PlayerManager: Gained %s research. Total research: %s" % [research_per_turn, research_points])