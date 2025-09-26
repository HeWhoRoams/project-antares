extends GutTest

func test_game_setup_data_creation():
	var setup = GameSetupData.new()
	assert_not_null(setup, "GameSetupData should be created successfully")

func test_game_setup_data_defaults():
	var setup = GameSetupData.new()
	assert_eq(setup.galaxy_size, GameManager.GalaxySize.MEDIUM, "Default galaxy size should be MEDIUM")
	assert_eq(setup.difficulty, GameManager.Difficulty.NORMAL, "Default difficulty should be NORMAL")
	assert_eq(setup.empire_count, 5, "Default empire count should be 5")
	assert_eq(setup.victory_condition, GameManager.VictoryCondition.CONQUEST, "Default victory should be CONQUEST")

func test_game_setup_data_validation():
	var setup = GameSetupData.new()
	setup.empire_count = 15  # Invalid
	assert_false(setup.validate(), "Setup with invalid empire count should fail validation")

	setup.empire_count = 5  # Valid
	setup.galaxy_seed = -1  # Invalid
	assert_false(setup.validate(), "Setup with negative seed should fail validation")

	setup.galaxy_seed = 12345  # Valid
	assert_true(setup.validate(), "Valid setup should pass validation")

func test_system_count_calculation():
	var setup = GameSetupData.new()

	setup.galaxy_size = GameManager.GalaxySize.SMALL
	assert_eq(setup.get_system_count(), 50, "Small galaxy should have 50 systems")

	setup.galaxy_size = GameManager.GalaxySize.MEDIUM
	assert_eq(setup.get_system_count(), 100, "Medium galaxy should have 100 systems")

	setup.galaxy_size = GameManager.GalaxySize.LARGE
	assert_eq(setup.get_system_count(), 150, "Large galaxy should have 150 systems")

	setup.galaxy_size = GameManager.GalaxySize.HUGE
	assert_eq(setup.get_system_count(), 250, "Huge galaxy should have 250 systems")

func test_ai_resource_multiplier():
	var setup = GameSetupData.new()

	setup.difficulty = GameManager.Difficulty.EASY
	assert_eq(setup.get_ai_resource_multiplier(), 0.5, "Easy difficulty should have 0.5x AI resources")

	setup.difficulty = GameManager.Difficulty.NORMAL
	assert_eq(setup.get_ai_resource_multiplier(), 1.0, "Normal difficulty should have 1.0x AI resources")

	setup.difficulty = GameManager.Difficulty.HARD
	assert_eq(setup.get_ai_resource_multiplier(), 1.25, "Hard difficulty should have 1.25x AI resources")

	setup.difficulty = GameManager.Difficulty.IMPOSSIBLE
	assert_eq(setup.get_ai_resource_multiplier(), 1.5, "Impossible difficulty should have 1.5x AI resources")

func test_static_creation_methods():
	var default_setup = GameSetupData.create_default()
	assert_not_null(default_setup, "Default setup should be created")
	assert_eq(default_setup.galaxy_size, GameManager.GalaxySize.MEDIUM, "Default setup should have medium galaxy")

	var tutorial_setup = GameSetupData.create_tutorial()
	assert_not_null(tutorial_setup, "Tutorial setup should be created")
	assert_eq(tutorial_setup.galaxy_size, GameManager.GalaxySize.SMALL, "Tutorial setup should have small galaxy")
	assert_true(tutorial_setup.tutorial_enabled, "Tutorial setup should have tutorial enabled")
	assert_eq(tutorial_setup.galaxy_seed, 12345, "Tutorial setup should have fixed seed")
