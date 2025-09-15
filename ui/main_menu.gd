# /ui/main_menu.gd
extends Control

@onready var continue_button: Button = $ButtonVBox/ContinueButton

func _ready() -> void:
	continue_button.disabled = not SaveLoadManager.has_save_file()
	# Play music when the main menu loads.
	# Replace with the actual path to your music file.
	AudioManager.play_music("res://assets/audio/music/main_theme.ogg")

func _on_new_game_button_pressed() -> void:
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")

func _on_continue_button_pressed() -> void:
	AudioManager.play_sfx("confirm")
	SaveLoadManager.load_game()

func _on_quit_button_pressed() -> void:
	AudioManager.play_sfx("back")
	get_tree().quit()

# --- Generic handlers for UI sounds ---

func _on_any_button_mouse_entered() -> void:
	AudioManager.play_sfx("hover")

func _on_any_button_pressed() -> void:
	AudioManager.play_sfx("confirm")
	# Placeholder for buttons that don't have functionality yet