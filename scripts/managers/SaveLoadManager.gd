# /scripts/managers/SaveLoadManager.gd
extends Node

## Emitted after the save file has been read and parsed.
signal save_data_loaded(data: Dictionary)

# Save file versioning constants
const CURRENT_SAVE_VERSION = 2
const MIN_SUPPORTED_VERSION = 1

# Version history:
# Version 1: Initial save format (basic game state)
# Version 2: Added race presets, technology effects, AI personalities

var is_loading_game: bool = false
var current_save_slot: String = ""

## Checks if a save file exists on disk.
func has_save_file(slot_name: String = "default") -> bool:
	var save_path = "user://savegame_%s.json" % slot_name
	return FileAccess.file_exists(save_path)

## Gathers data from all managers and writes it to a JSON file.
func save_game(slot_name: String = "default") -> void:
	print("SaveLoadManager: Saving game state to slot '%s' (version %d)..." % [slot_name, CURRENT_SAVE_VERSION])
	var save_data = {
		"version": CURRENT_SAVE_VERSION,
		"turn": TurnManager.current_turn,
		"turn_order": TurnManager.turn_order,
		"current_empire_index": TurnManager.current_empire_index,
		"game_phase": GameManager.current_game_phase,
		"active_empires": GameManager.active_empires,
		"player": {
			"unlocked_techs": PlayerManager.unlocked_techs
		},
		"ai": {
			"owned_ships": _serialize_ship_data(AIManager.owned_ships),
			"empires": AIManager.ai_empires
		},
		# We must save the entire galaxy state
		"galaxy": _serialize_galaxy_data(GalaxyManager.star_systems),
		"galaxy_features": _serialize_galaxy_features_data(),
		"empires": _serialize_empires_data(EmpireManager.empires),
		"colonies": _serialize_colonies_data(ColonyManager.colonies),
		"technology_effects": TechnologyEffectManager.get_save_data()
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

	# Check save file version and migrate if necessary
	var save_version = loaded_data.get("version", 1)  # Default to version 1 for old saves
	print("SaveLoadManager: Loading save file version %d (current: %d)" % [save_version, CURRENT_SAVE_VERSION])

	if save_version < MIN_SUPPORTED_VERSION:
		printerr("SaveLoadManager: Save file version %d is too old. Minimum supported version is %d." % [save_version, MIN_SUPPORTED_VERSION])
		return
	elif save_version < CURRENT_SAVE_VERSION:
		print("SaveLoadManager: Migrating save file from version %d to %d..." % [save_version, CURRENT_SAVE_VERSION])
		loaded_data = _migrate_save_data(loaded_data, save_version, CURRENT_SAVE_VERSION)
		# Save the migrated data
		_save_migrated_data(save_path, loaded_data)

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
			var body_data = { "orbital_slot": body.orbital_slot, "body_type": body.body_type }
			if body is PlanetData:
				body_data.merge({
					"planet_type": body.planet_type,
					"planet_size": body.planet_size,
					"max_population": body.max_population,
					"mineral_richness": body.mineral_richness,
					"gravity": body.gravity,
					"moons": body.moons,
					"food_per_farmer": body.food_per_farmer,
					"production_per_worker": body.production_per_worker,
					"research_per_scientist": body.research_per_scientist,
					"owner_id": body.owner_id,
					"has_natives": body.has_natives,
					"has_artifacts": body.has_artifacts,
					"has_crashed_ship": body.has_crashed_ship,
					"is_abandoned": body.is_abandoned,
					"has_native_animals": body.has_native_animals,
					"has_thriving_fauna": body.has_thriving_fauna,
					"has_hostile_fauna": body.has_hostile_fauna
				})
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

## Migrates save data from an older version to the current version.
func _migrate_save_data(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	var migrated_data = data.duplicate(true)  # Deep copy

	# Apply migrations step by step
	for version in range(from_version + 1, to_version + 1):
		match version:
			2:
				migrated_data = _migrate_to_version_2(migrated_data)

	migrated_data["version"] = to_version
	return migrated_data

## Migration from version 1 to version 2.
## Adds race presets, technology effects, and AI personalities.
func _migrate_to_version_2(data: Dictionary) -> Dictionary:
	print("SaveLoadManager: Migrating to version 2...")

	# Add AI empires data if not present
	if not data.has("ai") or not data["ai"].has("empires"):
		if not data.has("ai"):
			data["ai"] = {}
		data["ai"]["empires"] = {}

		# Create default AI personalities based on existing empires
		var empires_data = data.get("empires", {})
		for empire_id in empires_data:
			var empire_data = empires_data[empire_id]
			if empire_data.get("is_ai_controlled", false):
				# Assign default AI personality and race
				var personality = AIManager.AIPersonality.BALANCED
				var race_preset = _get_race_for_personality(personality)

				data["ai"]["empires"][empire_id] = {
					"personality": personality,
					"weights": _get_personality_weights(personality),
					"home_system": empire_data.get("home_system_id", "sirius")
				}

	# Add race presets to empires
	for empire_id in data.get("empires", {}):
		var empire_data = data["empires"][empire_id]
		if not empire_data.has("race_preset"):
			# Assign default race based on AI control
			var is_ai = empire_data.get("is_ai_controlled", false)
			var race_type = RacePreset.RaceType.CONCORDIANS if is_ai else RacePreset.RaceType.SYNARI
			empire_data["race_preset"] = {
				"race_type": race_type
			}

	# Add technology effects data
	if not data.has("technology_effects"):
		data["technology_effects"] = {}

	# Initialize technology effects for existing empires
	for empire_id in data.get("empires", {}):
		if not data["technology_effects"].has(empire_id):
			data["technology_effects"][empire_id] = {}

	return data

## Saves migrated data back to the file.
func _save_migrated_data(save_path: String, data: Dictionary) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	print("SaveLoadManager: Migrated save data saved.")

## Helper function for AI personality weights (used in migration).
func _get_personality_weights(personality: int) -> Dictionary:
	match personality:
		AIManager.AIPersonality.AGGRESSIVE:
			return {
				"colony_expansion": 70,
				"military_buildup": 80,
				"research_focus": 30,
				"economic_growth": 40
			}
		AIManager.AIPersonality.DEFENSIVE:
			return {
				"colony_expansion": 40,
				"military_buildup": 70,
				"research_focus": 50,
				"economic_growth": 60
			}
		AIManager.AIPersonality.EXPANSIONIST:
			return {
				"colony_expansion": 90,
				"military_buildup": 40,
				"research_focus": 30,
				"economic_growth": 50
			}
		AIManager.AIPersonality.TECHNOLOGICAL:
			return {
				"colony_expansion": 50,
				"military_buildup": 30,
				"research_focus": 90,
				"economic_growth": 60
			}
		_:
			return {
				"colony_expansion": 60,
				"military_buildup": 50,
				"research_focus": 60,
				"economic_growth": 70
			}

## Helper function for race assignment (used in migration).
func _get_race_for_personality(personality: int) -> Dictionary:
	match personality:
		AIManager.AIPersonality.AGGRESSIVE:
			return {"race_type": RacePreset.RaceType.FELYARI}
		AIManager.AIPersonality.DEFENSIVE:
			return {"race_type": RacePreset.RaceType.LITHARI}
		AIManager.AIPersonality.EXPANSIONIST:
			return {"race_type": RacePreset.RaceType.ZHERIN}
		AIManager.AIPersonality.TECHNOLOGICAL:
			return {"race_type": RacePreset.RaceType.SYNARI}
		_:
			return {"race_type": RacePreset.RaceType.CONCORDIANS}
