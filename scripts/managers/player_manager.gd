# /scripts/managers/player_manager.gd
extends Node

signal ship_arrived(ship_data: ShipData)
signal player_won_game
signal research_points_changed(new_points: int)

var research_points: int = 50
var research_per_turn: int = 10
var owned_ships: Dictionary = {}
var unlocked_techs: Dictionary = {}
var player_empire: Empire

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		_initialize_new_game_state()
	
	TurnManager.turn_ended.connect(_on_turn_ended)

func _initialize_new_game_state() -> void:
	_create_player_empire()
	_create_starting_ship()
	_colonize_home_planet()
	EmpireManager.initialize_diplomacy()

func _create_player_empire() -> void:
	player_empire = Empire.new()
	player_empire.id = &"player_1"
	player_empire.display_name = "Human Federation"
	player_empire.color = Color.CYAN
	player_empire.is_ai_controlled = false
	EmpireManager.register_empire(player_empire)

func _create_starting_ship() -> void:
	var starting_ship_data = ShipData.new()
	starting_ship_data.id = "scout_01"
	starting_ship_data.owner_id = player_empire.id
	starting_ship_data.current_system_id = "sol"
	owned_ships[starting_ship_data.id] = starting_ship_data

func _colonize_home_planet() -> void:
	var sol_system: StarSystem = GalaxyManager.star_systems.get("sol")
	if sol_system:
		for body in sol_system.celestial_bodies:
			if body is PlanetData and body.planet_type == PlanetData.PlanetType.TERRAN:
				body.owner_id = player_empire.id
				body.current_population = 10
				body.farmers = 3
				body.workers = 3
				body.scientists = 4
				print("PlayerManager: Home planet Sol III colonized with 10 population.")
				return

func can_research(tech_data: Technology) -> bool:
	if not tech_data: return false
	var is_already_unlocked = unlocked_techs.has(tech_data.id)
	var has_enough_points = research_points >= tech_data.research_cost
	return not is_already_unlocked and has_enough_points

func unlock_technology(tech_data: Technology) -> bool:
	if can_research(tech_data):
		research_points -= tech_data.research_cost
		unlocked_techs[tech_data.id] = TurnManager.current_turn
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

func _on_turn_ended(_new_turn_number: int) -> void:
	research_points += research_per_turn
	research_points_changed.emit(research_points)
	_process_ship_movement()

func _process_ship_movement() -> void:
	for ship_data in owned_ships.values():
		if ship_data.turns_to_arrival > 0:
			ship_data.turns_to_arrival -= 1
			if ship_data.turns_to_arrival == 0:
				ship_data.current_system_id = ship_data.destination_system_id
				ship_data.destination_system_id = &""
				ship_arrived.emit(ship_data)

func _on_save_data_loaded(data: Dictionary) -> void:
	owned_ships.clear()
	var player_data = data.get("player", {})
	research_points = player_data.get("research_points", 50)
	unlocked_techs = player_data.get("unlocked_techs", {})
	
	var loaded_ships = player_data.get("owned_ships", {})
	for ship_id in loaded_ships:
		var ship_data = loaded_ships[ship_id]
		var new_ship = ShipData.new()
		new_ship.id = ship_data.id
		new_ship.owner_id = ship_data.owner_id
		new_ship.current_system_id = ship_data.current_system_id
		new_ship.destination_system_id = ship_data.destination_system_id
		new_ship.turns_to_arrival = ship_data.turns_to_arrival
		owned_ships[ship_id] = new_ship
	print("PlayerManager: Loaded player state from save.")