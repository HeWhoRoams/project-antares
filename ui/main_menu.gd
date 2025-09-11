# /ui/main_menu.gd
extends Control

func _on_new_game_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
