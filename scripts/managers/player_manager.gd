# /scripts/managers/player_manager.gd
extends Node

const Empire = preload("res://gamedata/empires/empire.gd")
const ShipData = preload("res://gamedata/ships/ship_data.gd")
const Technology = preload("res://gamedata/technologies/technology.gd")
const PlanetData = preload("res://gamedata/celestial_bodies/planet_data.gd")
const StarSystem = preload("res://gamedata/systems/star_system.gd")

signal ship_arrived(ship_data: ShipData)
signal player_won_game
signal research_points_changed(new_points: int)

# owned_ships moved to player_empire.owned_ships
var unlocked_techs: Dictionary = {}
var player_empire: Empire
var current_player_empire_id: StringName = &"empire_0"  # Default to first empire (player)

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		_initialize_new_game_state()

	TurnManager.start_of_turn.connect(_on_start_of_turn)
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
	player_empire.owned_ships[starting_ship_data.id] = starting_ship_data

func _colonize_home_planet() -> void:
	var sol_system: StarSystem = GalaxyManager.star_systems.get("sol")
	if sol_system:
		for body in sol_system.celestial_bodies:
			if body is PlanetData and body.planet_type == PlanetData.PlanetType.TERRAN:
				# Use the ColonyManager to establish the new colony
				var new_colony = ColonyManager.establish_colony(body, player_empire, 10)
				new_colony.farmers = 3
				new_colony.workers = 3
				new_colony.scientists = 4
				return

func calculate_research_per_turn() -> void:
	var total_research = 0
	for colony_key in player_empire.owned_colonies:
		var colony = ColonyManager.colonies.get(colony_key)
		if colony:
			total_research += colony.scientists
	player_empire.research_per_turn = total_research

func can_research(tech_data: Technology) -> bool:
	if not tech_data: return false
	var is_already_unlocked = unlocked_techs.has(tech_data.id)
	var has_enough_points = player_empire.research_points >= tech_data.research_cost
	return not is_already_unlocked and has_enough_points

func unlock_technology(tech_data: Technology) -> bool:
	if can_research(tech_data):
		player_empire.research_points -= tech_data.research_cost
		unlocked_techs[tech_data.id] = TurnManager.current_turn
		if tech_data.id == &"tech_victory":
			player_won_game.emit()
		return true
	return false

func set_ship_destination(ship_id: StringName, target_system_id: StringName):
	var ship_data: ShipData = player_empire.owned_ships.get(ship_id)
	if not ship_data: return
	var start_system: StarSystem = GalaxyManager.star_systems.get(ship_data.current_system_id)
	var end_system: StarSystem = GalaxyManager.star_systems.get(target_system_id)
	if not start_system or not end_system or start_system == end_system: return

	var distance = start_system.position.distance_to(end_system.position)
	var turns_required = max(1, int(round(distance / 150.0)))

	# Apply movement penalties for galaxy features
	turns_required = _calculate_movement_penalty(start_system.position, end_system.position, turns_required)

	ship_data.destination_system_id = target_system_id
	ship_data.turns_to_arrival = turns_required

func _on_start_of_turn(empire_id: StringName) -> void:
	if empire_id == player_empire.id:
		calculate_research_per_turn()

func _on_turn_ended(_new_turn_number: int) -> void:
	player_empire.research_points += player_empire.research_per_turn
	research_points_changed.emit(player_empire.research_points)
	_process_ship_movement()

func _process_ship_movement() -> void:
	for ship_data in player_empire.owned_ships.values():
		if ship_data.turns_to_arrival > 0:
			ship_data.turns_to_arrival -= 1
			if ship_data.turns_to_arrival == 0:
				ship_data.current_system_id = ship_data.destination_system_id
				ship_data.destination_system_id = &""
				ship_arrived.emit(ship_data)

func get_current_player_empire() -> Empire:
	return EmpireManager.get_empire_by_id(current_player_empire_id)

func spoof_as_empire(empire_id: StringName) -> void:
	if EmpireManager.empires.has(empire_id):
		current_player_empire_id = empire_id
		print("PlayerManager: Now spoofing as empire: %s" % empire_id)
	else:
		printerr("PlayerManager: Empire ID '%s' not found!" % empire_id)

func get_all_empires() -> Array:
	return EmpireManager.empires.values()

func _calculate_movement_penalty(start_pos: Vector2, end_pos: Vector2, base_turns: int) -> int:
	var penalty_multiplier = 1.0

	# Check for nebulae along the path
	for nebula in GalaxyManager.nebulae:
		if _is_feature_on_path(start_pos, end_pos, nebula.position, nebula.size):
			penalty_multiplier += 0.5  # 50% increase for nebulae

	# Check for black holes along the path
	for black_hole in GalaxyManager.black_holes:
		if _is_feature_on_path(start_pos, end_pos, black_hole.position, black_hole.size):
			penalty_multiplier += 2.0  # 200% increase for black holes (very dangerous)

	# Check for wormholes - they can reduce travel time
	for wormhole in GalaxyManager.wormholes:
		if _is_feature_on_path(start_pos, end_pos, wormhole.position, wormhole.size):
			penalty_multiplier *= 0.3  # 70% reduction for wormholes (fast travel)

	return max(1, int(round(base_turns * penalty_multiplier)))

func _is_feature_on_path(start_pos: Vector2, end_pos: Vector2, feature_pos: Vector2, feature_size: float) -> bool:
	# Simple check: if the feature is within a certain distance of the line segment
	var path_vector = end_pos - start_pos
	var feature_vector = feature_pos - start_pos

	# Project feature onto path
	var projection = feature_vector.dot(path_vector.normalized())
	if projection < 0 or projection > path_vector.length():
		return false  # Feature is not between start and end

	# Check perpendicular distance
	var closest_point = start_pos + path_vector.normalized() * projection
	var distance = closest_point.distance_to(feature_pos)

	return distance <= feature_size

func _on_save_data_loaded(data: Dictionary) -> void:
	var player_data = data.get("player", {})
	unlocked_techs = player_data.get("unlocked_techs", {})
	player_empire = EmpireManager.get_empire_by_id("player_1")
	print("PlayerManager: Loaded player state from save.")
