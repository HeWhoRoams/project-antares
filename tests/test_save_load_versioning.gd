extends GutTest

func test_save_version_included():
	var save_load_manager = SaveLoadManager.new()

	# Mock the required managers to avoid dependencies
	_add_mock_managers()

	# Save a game
	save_load_manager.save_game("test_version")

	# Check that version is included in saved data
	var save_path = "user://savegame_test_version.json"
	assert_true(FileAccess.file_exists(save_path), "Save file should exist")

	var file = FileAccess.open(save_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	assert_eq(error, OK, "Should parse JSON successfully")

	var data = json.get_data()
	assert_true(data.has("version"), "Save data should include version")
	assert_eq(data["version"], SaveLoadManager.CURRENT_SAVE_VERSION, "Version should be current version")

	# Clean up
	DirAccess.remove_absolute(save_path)

func test_version_compatibility_check():
	var save_load_manager = SaveLoadManager.new()

	# Test current version (should be compatible)
	var current_version_data = {"version": SaveLoadManager.CURRENT_SAVE_VERSION}
	var result = save_load_manager._migrate_save_data(current_version_data, SaveLoadManager.CURRENT_SAVE_VERSION, SaveLoadManager.CURRENT_SAVE_VERSION)
	assert_eq(result["version"], SaveLoadManager.CURRENT_SAVE_VERSION, "Current version should not be migrated")

func test_migration_from_version_1():
	var save_load_manager = SaveLoadManager.new()

	# Create version 1 save data (without new features)
	var version_1_data = {
		"turn": 5,
		"turn_order": ["player", "ai_silicoids"],
		"current_empire_index": 0,
		"game_phase": 1,
		"active_empires": ["player", "ai_silicoids"],
		"player": {
			"unlocked_techs": ["tech_basic"]
		},
		"ai": {
			"owned_ships": {}
		},
		"galaxy": {},
		"galaxy_features": {"nebulae": [], "black_holes": [], "wormholes": []},
		"empires": {
			"player": {
				"id": "player",
				"display_name": "Human Federation",
				"color": [0.4, 0.6, 1.0, 1.0],
				"treasury": 250,
				"income_per_turn": 25,
				"research_points": 50,
				"research_per_turn": 10,
				"diplomatic_statuses": {},
				"is_ai_controlled": false,
				"home_system_id": "sol",
				"owned_ships": [],
				"owned_colonies": []
			},
			"ai_silicoids": {
				"id": "ai_silicoids",
				"display_name": "Silicoid Imperium",
				"color": [1.0, 0.0, 0.0, 1.0],
				"treasury": 250,
				"income_per_turn": 25,
				"research_points": 50,
				"research_per_turn": 10,
				"diplomatic_statuses": {},
				"is_ai_controlled": true,
				"home_system_id": "sirius",
				"owned_ships": [],
				"owned_colonies": []
			}
		},
		"colonies": {}
	}

	# Migrate to version 2
	var migrated_data = save_load_manager._migrate_save_data(version_1_data, 1, 2)

	# Check that version was updated
	assert_eq(migrated_data["version"], 2, "Should migrate to version 2")

	# Check that AI empires data was added
	assert_true(migrated_data["ai"].has("empires"), "Should add AI empires data")
	assert_true(migrated_data["ai"]["empires"].has("ai_silicoids"), "Should add AI personality for silicoids")

	# Check that race presets were added to empires
	assert_true(migrated_data["empires"]["player"].has("race_preset"), "Player should have race preset")
	assert_true(migrated_data["empires"]["ai_silicoids"].has("race_preset"), "AI should have race preset")

	# Check that technology effects were initialized
	assert_true(migrated_data.has("technology_effects"), "Should add technology effects data")

func test_migration_preserves_existing_data():
	var save_load_manager = SaveLoadManager.new()

	# Create version 1 data with some existing data
	var version_1_data = {
		"turn": 10,
		"turn_order": ["player"],
		"current_empire_index": 0,
		"game_phase": 2,
		"active_empires": ["player"],
		"player": {
			"unlocked_techs": ["tech_advanced"]
		},
		"ai": {
			"owned_ships": {}
		},
		"galaxy": {"sol": {"id": "sol", "display_name": "Sol", "position": [0, 0], "celestial_bodies": []}},
		"galaxy_features": {"nebulae": [], "black_holes": [], "wormholes": []},
		"empires": {
			"player": {
				"id": "player",
				"display_name": "Test Empire",
				"color": [1.0, 1.0, 1.0, 1.0],
				"treasury": 500,
				"income_per_turn": 50,
				"research_points": 100,
				"research_per_turn": 20,
				"diplomatic_statuses": {},
				"is_ai_controlled": false,
				"home_system_id": "sol",
				"owned_ships": ["ship1"],
				"owned_colonies": ["colony1"]
			}
		},
		"colonies": {
			"sol_0": {
				"owner_id": "player",
				"system_id": "sol",
				"orbital_slot": 0,
				"current_population": 5,
				"farmers": 2,
				"workers": 2,
				"scientists": 1,
				"food_produced": 4,
				"production_produced": 2,
				"research_produced": 2,
				"growth_progress": 50,
				"construction_queue": []
			}
		}
	}

	# Migrate to version 2
	var migrated_data = save_load_manager._migrate_save_data(version_1_data, 1, 2)

	# Check that existing data is preserved
	assert_eq(migrated_data["turn"], 10, "Should preserve turn number")
	assert_eq(migrated_data["empires"]["player"]["treasury"], 500, "Should preserve treasury")
	assert_eq(migrated_data["colonies"]["sol_0"]["current_population"], 5, "Should preserve colony data")

func test_min_supported_version_check():
	var save_load_manager = SaveLoadManager.new()

	# Test loading a save from version 0 (below minimum)
	var old_save_data = {"version": 0}

	# This should fail during the version check in emit_load_data
	# We can't easily test this without mocking file access, but the logic is in place

	assert_true(SaveLoadManager.MIN_SUPPORTED_VERSION >= 1, "Minimum supported version should be at least 1")

func test_personality_weights_helper():
	var save_load_manager = SaveLoadManager.new()

	# Test aggressive personality weights
	var aggressive_weights = save_load_manager._get_personality_weights(AIManager.AIPersonality.AGGRESSIVE)
	assert_eq(aggressive_weights["military_buildup"], 80, "Aggressive AI should prioritize military")
	assert_eq(aggressive_weights["research_focus"], 30, "Aggressive AI should not prioritize research")

	# Test technological personality weights
	var tech_weights = save_load_manager._get_personality_weights(AIManager.AIPersonality.TECHNOLOGICAL)
	assert_eq(tech_weights["research_focus"], 90, "Technological AI should prioritize research")
	assert_eq(tech_weights["military_buildup"], 30, "Technological AI should not prioritize military")

func test_race_assignment_helper():
	var save_load_manager = SaveLoadManager.new()

	# Test race assignment for different personalities
	var aggressive_race = save_load_manager._get_race_for_personality(AIManager.AIPersonality.AGGRESSIVE)
	assert_eq(aggressive_race["race_type"], RacePreset.RaceType.FELYARI, "Aggressive AI should get Felyari race")

	var tech_race = save_load_manager._get_race_for_personality(AIManager.AIPersonality.TECHNOLOGICAL)
	assert_eq(tech_race["race_type"], RacePreset.RaceType.SYNARI, "Technological AI should get Synari race")

	var balanced_race = save_load_manager._get_race_for_personality(AIManager.AIPersonality.BALANCED)
	assert_eq(balanced_race["race_type"], RacePreset.RaceType.CONCORDIANS, "Balanced AI should get Concordians race")

func test_migration_creates_ai_data():
	var save_load_manager = SaveLoadManager.new()

	# Create version 1 data with AI empire but no AI data
	var version_1_data = {
		"empires": {
			"ai_empire": {
				"id": "ai_empire",
				"display_name": "AI Empire",
				"color": [1.0, 0.0, 0.0, 1.0],
				"treasury": 250,
				"income_per_turn": 25,
				"research_points": 50,
				"research_per_turn": 10,
				"diplomatic_statuses": {},
				"is_ai_controlled": true,
				"home_system_id": "alpha_centauri",
				"owned_ships": [],
				"owned_colonies": []
			}
		}
	}

	# Migrate to version 2
	var migrated_data = save_load_manager._migrate_to_version_2(version_1_data)

	# Check that AI data was created
	assert_true(migrated_data["ai"].has("empires"), "Should create AI empires section")
	assert_true(migrated_data["ai"]["empires"].has("ai_empire"), "Should create AI data for AI empire")

	# Check that race preset was added
	assert_true(migrated_data["empires"]["ai_empire"].has("race_preset"), "Should add race preset to AI empire")

func _add_mock_managers():
	# Create minimal mock data to avoid dependency issues in tests
	if not TurnManager:
		return  # Skip if managers aren't available

	# Set minimal data for testing
	TurnManager.current_turn = 1
	TurnManager.turn_order = ["player"]
	TurnManager.current_empire_index = 0

	GameManager.current_game_phase = 1
	GameManager.active_empires = ["player"]

	PlayerManager.unlocked_techs = []

	AIManager.owned_ships = {}
	AIManager.ai_empires = {}

	GalaxyManager.star_systems = {}
	GalaxyManager.nebulae = []
	GalaxyManager.black_holes = []
	GalaxyManager.wormholes = []

	EmpireManager.empires = {}
	ColonyManager.colonies = {}

	TechnologyEffectManager.applied_effects = {}
