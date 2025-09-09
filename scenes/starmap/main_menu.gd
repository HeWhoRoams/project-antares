# /ui/screens/main_menu.gd
extends Control

@onready var new_game_button: Button = %NewGameButton # Assumes the button is named "NewGameButton"

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)

func _on_new_game_pressed() -> void:
	# Call our global SceneManager to switch to the starmap.
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
