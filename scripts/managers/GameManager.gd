# /scripts/managers/GameManager.gd
# Manages the overall game state, including win/loss conditions.
extends Node

var current_game_data: GameData


func _ready() -> void:
	PlayerManager.player_won_game.connect(_on_player_won_game)


func start_new_game() -> void:
	current_game_data = GameData.new()
	# You can initialize other things here, like generating the galaxy
	# GalaxyManager.generate_galaxy(current_game_data)


func get_current_game_data() -> GameData:
	return current_game_data


func _on_player_won_game() -> void:
	print("GAME WON!")
	# Use the SceneManager to transition to the victory screen.
	SceneManager.change_scene("res://ui/screens/victory_screen.tscn")
