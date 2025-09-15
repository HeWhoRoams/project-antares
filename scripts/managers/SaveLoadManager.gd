# /scripts/managers/SaveLoadManager.gd
extends Node

## Emitted after the save file has been read and parsed.
signal save_data_loaded(data: Dictionary)

const SAVE_PATH = "user://savegame.json"

var is_loading_game: bool = false

## Checks if a save file exists on disk.
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Gathers data from all managers and writes it to a JSON file.
func save_game() -> void:
	print("SaveLoadManager: Saving game state...")
	var save_data = {
		"turn": TurnManager.current_turn,
		"player": {
			"research_points": PlayerManager.research_points,
			"unlocked_techs": PlayerManager.unlocked_techs,
			"owned_ships": _serialize_ship_data(PlayerManager.owned_ships)
		},
		"ai": {
			"owned_ships": _serialize_ship_data(AIManager.owned_ships)
		},
		# We must save the entire galaxy state
		"galaxy": _serialize_galaxy_data(GalaxyManager.star_systems)
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	print("SaveLoadManager: Game saved successfully to %s" % SAVE_PATH)

## Sets the flag to load a game and changes to the starmap.
func load_game() -> void:
	if not has_save_file():
		printerr("SaveLoadManager: No save file found to load.")
		return
	
	is_loading_game = true
	# The managers will detect this flag in their _ready() functions
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")

## Called by the managers after the starmap scene is loaded.
func emit_load_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("SaveLoadManager: Failed to parse save file. Error: %s" % json.get_error_message())
		return

	var loaded_data = json.get_data()
	save_data_loaded.emit(loaded_data)
	print("SaveLoadManager: Save data loaded and emitted.")
	
	# Reset the flag after loading is done
	is_loading_game = false

## Helper functions to convert Godot Resources to dictionaries for JSON serialization.
func _serialize_ship_data(ships: Dictionary) -> Dictionary:
	var serialized_ships = {}
	for ship_id in ships:
		var ship: ShipData = ships[ship_id]
		serialized_ships[ship_id] = {
			"id": ship.id,
			"owner_id": ship.owner_id,
			"current_system_id": ship.current_system_id,
			"destination_system_id": ship.destination_system_id,
			"turns_to_arrival": ship.turns_to_arrival
		}
	return serialized_ships

func _serialize_galaxy_data(systems: Dictionary) -> Dictionary:
	var serialized_systems = {}
	for system_id in systems:
		var system: StarSystem = systems[system_id]
		var celestial_bodies_array = []
		for body in system.celestial_bodies:
			# This can be expanded to save more planet details later
			celestial_bodies_array.append({ "orbital_slot": body.orbital_slot, "body_type": body.body_type })
		
		serialized_systems[system_id] = {
			"id": system.id,
			"display_name": system.display_name,
			"position": [system.position.x, system.position.y],
			"celestial_bodies": celestial_bodies_array
		}
	return serialized_systems