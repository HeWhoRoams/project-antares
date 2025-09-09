# /ui/screens/main_menu.gd
extends Control

# This is the function the button will call when pressed.
func _on_new_game_button_pressed() -> void:
	# Call our global SceneManager to switch to the starmap.
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
