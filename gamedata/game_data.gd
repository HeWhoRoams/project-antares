# /gamedata/game_data.gd
class_name GameData
extends Resource

@export var current_turn: int = 1
@export var galaxy_seed: int = 0
@export var difficulty: int = 1
@export var victory_condition: int = 0
@export var player_empire_id: StringName = ""
@export var ai_empire_ids: Array[StringName] = []

# Game state flags
@export var is_game_paused: bool = false
@export var is_game_over: bool = false
@export var winner_empire_id: StringName = ""

# Game settings
@export var galaxy_size: int = 1  # 0=Small, 1=Medium, 2=Large, 3=Huge
@export var starting_credits: int = 250
@export var starting_research: int = 50
@export var ai_aggression_level: int = 1  # 0=Passive, 1=Normal, 2=Aggressive

# Game statistics
@export var total_turns_played: int = 0
@export var player_victories: int = 0
@export var player_defeats: int = 0

# Time tracking
@export var game_start_time: int = 0
@export var last_save_time: int = 0

# Constructor
func _init() -> void:
	game_start_time = Time.get_ticks_msec()

# Utility methods
func increment_turn() -> void:
	current_turn += 1
	total_turns_played += 1

func pause_game() -> void:
	is_game_paused = true

func resume_game() -> void:
	is_game_paused = false

func end_game(winner_id: StringName = "") -> void:
	is_game_over = true
	winner_empire_id = winner_id

func is_player_victory() -> bool:
	return is_game_over and winner_empire_id == player_empire_id

func get_game_duration_seconds() -> int:
	return (Time.get_ticks_msec() - game_start_time) / 1000

# Static factory methods
static func create_new_game() -> GameData:
	var game_data = GameData.new()
	game_data.current_turn = 1
	game_data.galaxy_seed = randi()
	game_data.difficulty = 1
	game_data.victory_condition = 0
	game_data.is_game_paused = false
	game_data.is_game_over = false
	game_data.winner_empire_id = ""
	return game_data

static func create_custom_game(difficulty_level: int = 1, galaxy_size_setting: int = 1) -> GameData:
	var game_data = GameData.new()
	game_data.current_turn = 1
	game_data.galaxy_seed = randi()
	game_data.difficulty = difficulty_level
	game_data.galaxy_size = galaxy_size_setting
	game_data.victory_condition = 0
	game_data.is_game_paused = false
	game_data.is_game_over = false
	game_data.winner_empire_id = ""
	return game_data

# Serialization helper methods
func to_dictionary() -> Dictionary:
	return {
		"current_turn": current_turn,
		"galaxy_seed": galaxy_seed,
		"difficulty": difficulty,
		"victory_condition": victory_condition,
		"player_empire_id": player_empire_id,
		"ai_empire_ids": ai_empire_ids,
		"is_game_paused": is_game_paused,
		"is_game_over": is_game_over,
		"winner_empire_id": winner_empire_id,
		"galaxy_size": galaxy_size,
		"starting_credits": starting_credits,
		"starting_research": starting_research,
		"ai_aggression_level": ai_aggression_level,
		"total_turns_played": total_turns_played,
		"player_victories": player_victories,
		"player_defeats": player_defeats,
		"game_start_time": game_start_time,
		"last_save_time": last_save_time
	}

static func from_dictionary(data: Dictionary) -> GameData:
	var game_data = GameData.new()
	game_data.current_turn = data.get("current_turn", 1)
	game_data.galaxy_seed = data.get("galaxy_seed", 0)
	game_data.difficulty = data.get("difficulty", 1)
	game_data.victory_condition = data.get("victory_condition", 0)
	game_data.player_empire_id = data.get("player_empire_id", "")
	game_data.ai_empire_ids = data.get("ai_empire_ids", [])
	game_data.is_game_paused = data.get("is_game_paused", false)
	game_data.is_game_over = data.get("is_game_over", false)
	game_data.winner_empire_id = data.get("winner_empire_id", "")
	game_data.galaxy_size = data.get("galaxy_size", 1)
	game_data.starting_credits = data.get("starting_credits", 250)
	game_data.starting_research = data.get("starting_research", 50)
	game_data.ai_aggression_level = data.get("ai_aggression_level", 1)
	game_data.total_turns_played = data.get("total_turns_played", 0)
	game_data.player_victories = data.get("player_victories", 0)
	game_data.player_defeats = data.get("player_defeats", 0)
	game_data.game_start_time = data.get("game_start_time", 0)
	game_data.last_save_time = data.get("last_save_time", 0)
	return game_data
