# /scripts/managers/player_manager.gd
extends Node

signal ship_arrived(ship_data: ShipData)
## Emitted when the player researches the final technology.
signal player_won_game

var research_points: int = 50
var research_per_turn: int = 10
var owned_ships: Dictionary = {}
var unlocked_techs: Dictionary = {}

func _ready() -> void:
	_create_starting_ship()
	TurnManager.turn_ended.connect(_on_turn_ended)

func _create_starting_ship() -> void:
	var starting_ship_data = ShipData.new()
	starting_ship_data.id = "scout_01"
	starting_ship_data.owner_id = 1
	starting_ship_data.current_system_id = "sol"
	owned_ships[starting_ship_data.id] = starting_ship_data

func can_research(tech_data: Technology) -> bool:
	if not tech_data: return false
	var is_already_unlocked = unlocked_techs.has(tech_data.id)
	var has_enough_points = research_points >= tech_data.research_cost
	return not is_already_unlocked and has_enough_points

func unlock_technology(tech_data: Technology) -> bool:
	if can_research(tech_data):
		research_points -= tech_data.research_cost
		unlocked_techs[tech_data.id] = TurnManager.current_turn
		
		# --- CHECK FOR WIN CONDITION ---
		if tech_data.id == &"tech_victory":
			player_won_game.emit()
			
		return true
	return false

func set_ship_destination(ship_id: StringName, target_system_id: StringName):
	var ship_data: ShipData = owned_ships.get(ship_id)
	if not ship_data: return
	var start_system: StarSystem = GalaxyManager.star_systems.get(ship_data.current_system_id)
	var end_system: StarSystem = GalaxyManager.star_systems.get(target_system_id)
	if not start_system or not end_system or start_system == end_system: return
	var distance = start_system.position.distance_to(end_system.position)
	var turns_required = max(1, int(round(distance / 150.0))) 
	ship_data.destination_system_id = target_system_id
	ship_data.turns_to_arrival = turns_required

func _on_turn_ended(new_turn_number: int) -> void:
	research_points += research_per_turn
	_process_ship_movement()

func _process_ship_movement() -> void:
	for ship_data in owned_ships.values():
		if ship_data.turns_to_arrival > 0:
			ship_data.turns_to_arrival -= 1
			if ship_data.turns_to_arrival == 0:
				ship_data.current_system_id = ship_data.destination_system_id
				ship_data.destination_system_id = &""
				ship_arrived.emit(ship_data)
