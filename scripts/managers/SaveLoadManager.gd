# /scripts/managers/SaveLoadManager.gd
extends Node

## Emitted after the save file has been read and parsed.
signal save_data_loaded(data: Dictionary)

var is_loading_game: bool = false
var current_save_slot: String = ""

## Checks if a save file exists on disk.
func has_save_file(slot_name: String = "default") -> bool:
	var save_path = "user://savegame_%s.json" % slot_name
	return FileAccess.file_exists(save_path)

## Gathers data from all managers and writes it to a JSON file.
func save_game(slot_name: String = "default") -> void:
	print("SaveLoadManager: Saving game state to slot '%s'..." % slot_name)
	var save_data = {
		"turn": TurnManager.current_turn,
		"turn_order": TurnManager.turn_order,
		"current_empire_index": TurnManager.current_empire_index,
		"game_phase": GameManager.current_game_phase,
		"active_empires": GameManager.active_empires,
		"player": {
			"unlocked_techs": PlayerManager.unlocked_techs
		},
		"ai": {
			"owned_ships": _serialize_ship_data(AIManager.owned_ships)
		},
		# We must save the entire galaxy state
		"galaxy": _serialize_galaxy_data(GalaxyManager.star_systems),
		"galaxy_features": _serialize_galaxy_features_data(),
		"empires": _serialize_empires_data(EmpireManager.empires),
		"colonies": _serialize_colonies_data(ColonyManager.colonies)
	}

	var save_path = "user://savegame_%s.json" % slot_name
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	print("SaveLoadManager: Game saved successfully to %s" % save_path)

## Sets the flag to load a game and changes to the starmap.
func load_game(slot_name: String = "default") -> void:
	if not has_save_file(slot_name):
		printerr("SaveLoadManager: No save file found for slot '%s'." % slot_name)
		return
	
	current_save_slot = slot_name
	is_loading_game = true
	# The managers will detect this flag in their _ready() functions
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")

## Called by the managers after the starmap scene is loaded.
func emit_load_data() -> void:
	var save_path = "user://savegame_%s.json" % current_save_slot
	var file = FileAccess.open(save_path, FileAccess.READ)
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
	current_save_slot = ""

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
			var body_data = { "orbital_slot": body.orbital_slot, "body_type": body.body_type }
			if body is PlanetData:
				body_data["owner_id"] = body.owner_id
			celestial_bodies_array.append(body_data)
		
		serialized_systems[system_id] = {
			"id": system.id,
			"display_name": system.display_name,
			"position": [system.position.x, system.position.y],
			"celestial_bodies": celestial_bodies_array
		}
	return serialized_systems

func _serialize_empires_data(empires: Dictionary) -> Dictionary:
	var serialized_empires = {}
	for empire_id in empires:
		var empire: Empire = empires[empire_id]
		serialized_empires[empire_id] = {
			"id": empire.id,
			"display_name": empire.display_name,
			"color": [empire.color.r, empire.color.g, empire.color.b, empire.color.a],
			"treasury": empire.treasury,
			"income_per_turn": empire.income_per_turn,
			"research_points": empire.research_points,
			"research_per_turn": empire.research_per_turn,
			"diplomatic_statuses": empire.diplomatic_statuses,
			"is_ai_controlled": empire.is_ai_controlled,
			"home_system_id": empire.home_system_id,
			"owned_ships": empire.owned_ships,
			"owned_colonies": empire.owned_colonies
		}
	return serialized_empires

func _serialize_galaxy_features_data() -> Dictionary:
	var features = {
		"nebulae": [],
		"black_holes": [],
		"wormholes": []
	}

	for nebula in GalaxyManager.nebulae:
		features.nebulae.append({
			"position": [nebula.position.x, nebula.position.y],
			"size": nebula.size
		})

	for black_hole in GalaxyManager.black_holes:
		features.black_holes.append({
			"position": [black_hole.position.x, black_hole.position.y],
			"size": black_hole.size
		})

	for wormhole in GalaxyManager.wormholes:
		features.wormholes.append({
			"position": [wormhole.position.x, wormhole.position.y],
			"size": wormhole.size,
			"exit_position": [wormhole.exit_position.x, wormhole.exit_position.y]
		})

	return features

func _serialize_colonies_data(colonies: Dictionary) -> Dictionary:
	var serialized_colonies = {}
	for colony_key in colonies:
		var colony: ColonyData = colonies[colony_key]
		var queue_ids = []
		for item in colony.construction_queue:
			queue_ids.append(item.id)
		serialized_colonies[colony_key] = {
			"owner_id": colony.owner_id,
			"system_id": colony.system_id,
			"orbital_slot": colony.orbital_slot,
			"current_population": colony.current_population,
			"farmers": colony.farmers,
			"workers": colony.workers,
			"scientists": colony.scientists,
			"food_produced": colony.food_produced,
			"production_produced": colony.production_produced,
			"research_produced": colony.research_produced,
			"growth_progress": colony.growth_progress,
			"construction_queue": queue_ids
		}
	return serialized_colonies
