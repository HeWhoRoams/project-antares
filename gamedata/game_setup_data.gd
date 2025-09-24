class_name GameSetupData
extends Resource

# Game setup configuration data that defines the parameters for a new game.
# This resource is used to store all the settings chosen in the main menu
# before starting a new game.

# The size of the galaxy to generate.
@export var galaxy_size: GameManager.GalaxySize = GameManager.GalaxySize.MEDIUM

# The difficulty level for AI opponents.
@export var difficulty: GameManager.Difficulty = GameManager.Difficulty.NORMAL

# The number of empires in the game (including the player).
@export var empire_count: int = 5

# The victory condition for the game.
@export var victory_condition: GameManager.VictoryCondition = GameManager.VictoryCondition.CONQUEST

# The player's chosen empire/race.
@export var player_race: String = "Human"

# Whether to enable tutorial mode.
@export var tutorial_enabled: bool = true

# Whether to enable random events.
@export var random_events_enabled: bool = true

# Whether to enable AI aggression.
@export var ai_aggression_enabled: bool = true

# Custom galaxy seed for reproducible generation.
@export var galaxy_seed: int = 0

# Whether to use a custom seed or generate randomly.
@export var use_custom_seed: bool = false

# Returns the number of star systems to generate based on galaxy size.
func get_system_count() -> int:
	match galaxy_size:
		GameManager.GalaxySize.SMALL:
			return 50
		GameManager.GalaxySize.MEDIUM:
			return 100
		GameManager.GalaxySize.LARGE:
			return 150
		GameManager.GalaxySize.HUGE:
			return 250
		_:
			return 100  # Default to medium

# Returns the AI resource multiplier based on difficulty.
func get_ai_resource_multiplier() -> float:
	match difficulty:
		GameManager.Difficulty.EASY:
			return 0.5
		GameManager.Difficulty.NORMAL:
			return 1.0
		GameManager.Difficulty.HARD:
			return 1.25
		GameManager.Difficulty.IMPOSSIBLE:
			return 1.5
		_:
			return 1.0  # Default to normal

# Validates that the setup data is within acceptable ranges.
func validate() -> bool:
	if empire_count < 2 or empire_count > 10:
		push_error("Empire count must be between 2 and 10")
		return false

	if galaxy_seed < 0:
		push_error("Galaxy seed must be non-negative")
		return false

	return true

# Creates a default setup for quick start games.
static func create_default() -> GameSetupData:
	var setup = GameSetupData.new()
	setup.galaxy_size = GameManager.GalaxySize.MEDIUM
	setup.difficulty = GameManager.Difficulty.NORMAL
	setup.empire_count = 5
	setup.victory_condition = GameManager.VictoryCondition.CONQUEST
	setup.player_race = "Human"
	setup.tutorial_enabled = false
	setup.random_events_enabled = true
	setup.ai_aggression_enabled = true
	setup.use_custom_seed = false
	setup.galaxy_seed = 0
	return setup

# Creates a setup for tutorial mode.
static func create_tutorial() -> GameSetupData:
	var setup = GameSetupData.new()
	setup.galaxy_size = GameManager.GalaxySize.SMALL
	setup.difficulty = GameManager.Difficulty.EASY
	setup.empire_count = 3
	setup.victory_condition = GameManager.VictoryCondition.CONQUEST
	setup.player_race = "Human"
	setup.tutorial_enabled = true
	setup.random_events_enabled = false
	setup.ai_aggression_enabled = false
	setup.use_custom_seed = true
	setup.galaxy_seed = 12345  # Fixed seed for tutorial consistency
	return setup
