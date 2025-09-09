# /scripts/managers/GameManager.gd
# Manages the overall game state, including win/loss conditions.
extends Node

func _ready() -> void:
	PlayerManager.player_won_game.connect(_on_player_won_game)

func _on_player_won_game() -> void:
	print("GAME WON!")
	# Use the SceneManager to transition to the victory screen.
	SceneManager.change_scene("res://ui/screens/victory_screen.tscn")
