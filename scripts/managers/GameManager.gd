# /scripts/managers/GameManager.gd
# Manages the overall game state, including win/loss conditions.
extends Node

enum GamePhase {
	SETUP,
	GALAXY_VIEW,
	COMBAT,
	COLONY_VIEW,
	GAME_OVER
}

signal game_phase_changed(new_phase: GamePhase)

var current_game_phase: GamePhase = GamePhase.SETUP
var active_empires: Array[StringName] = []

var current_game_data: GameData


func set_game_phase(new_phase: GamePhase) -> void:
	current_game_phase = new_phase
	game_phase_changed.emit(new_phase)


func _ready() -> void:
	PlayerManager.player_won_game.connect(_on_player_won_game)
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)


func start_new_game() -> void:
	current_game_data = GameData.new()
	# You can initialize other things here, like generating the galaxy
	# GalaxyManager.generate_galaxy(current_game_data)


func get_current_game_data() -> GameData:
	return current_game_data


func check_conquest_victory() -> bool:
	for empire_id in active_empires:
		var empire = EmpireManager.get_empire_by_id(empire_id)
		if not empire:
			continue
		var home_system = GalaxyManager.star_systems.get(empire.home_system_id)
		if not home_system:
			continue
		var owns_home = false
		for body in home_system.celestial_bodies:
			if body is PlanetData and body.owner_id == empire_id:
				owns_home = true
				break
		if not owns_home:
			return false
	return true

func check_diplomatic_victory() -> bool:
	return false

func check_score_victory() -> bool:
	return false

func check_for_victory() -> void:
	if check_conquest_victory():
		_on_victory("conqueror", "Conquest")
	elif check_diplomatic_victory():
		_on_victory("diplomat", "Diplomacy")
	elif check_score_victory():
		_on_victory("scorer", "Score")

func eliminate_empire(empire_id: StringName) -> void:
	active_empires.erase(empire_id)

func _on_victory(winner_id: StringName, reason: String) -> void:
	set_game_phase(GamePhase.GAME_OVER)
	# Transition to victory screen
	SceneManager.change_scene("res://ui/screens/victory_screen.tscn")

func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("game_phase"):
		current_game_phase = data["game_phase"] as GamePhase
	if data.has("active_empires"):
		active_empires = data["active_empires"]

func _on_player_won_game() -> void:
	_on_victory("player_1", "Technology")
