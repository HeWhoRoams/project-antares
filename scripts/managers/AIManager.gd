# /scripts/managers/AIManager.gd
extends Node

var owned_ships: Dictionary = {}
var ai_empire: Empire

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		_initialize_new_game_state()

func _initialize_new_game_state() -> void:
	_create_ai_empire()
	_create_starting_fleet()

func _create_ai_empire() -> void:
	ai_empire = Empire.new()
	ai_empire.id = &"ai_silicoids"
	ai_empire.display_name = "Silicoid Imperium"
	ai_empire.color = Color.RED
	ai_empire.is_ai_controlled = true
	EmpireManager.register_empire(ai_empire)

func _create_starting_fleet() -> void:
	var silicoid_ship_data = ShipData.new()
	silicoid_ship_data.id = "silicoid_scout_01"
	silicoid_ship_data.owner_id = ai_empire.id
	silicoid_ship_data.current_system_id = "sirius"
	owned_ships[silicoid_ship_data.id] = silicoid_ship_data

func _on_save_data_loaded(data: Dictionary) -> void:
	owned_ships.clear()
	var ai_data = data.get("ai", {})
	var loaded_ships = ai_data.get("owned_ships", {})
	for ship_id in loaded_ships:
		var ship_data = loaded_ships[ship_id]
		var new_ship = ShipData.new()
		new_ship.id = ship_data.id
		new_ship.owner_id = ship_data.owner_id
		new_ship.current_system_id = ship_data.current_system_id
		new_ship.destination_system_id = ship_data.destination_system_id
		new_ship.turns_to_arrival = ship_data.turns_to_arrival
		owned_ships[ship_id] = new_ship
	print("AIManager: Loaded AI state from save.")