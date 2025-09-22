# /ui/main_menu.gd
extends Control

@onready var continue_button: Button = $ButtonVBox/ContinueButton

func _ready() -> void:
	continue_button.disabled = not SaveLoadManager.has_save_file()
	AudioManager.play_music("res://assets/audio/music/main_theme.ogg")

func _on_new_game_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'New Game' button pressed.")
	AudioManager.play_sfx("confirm")
	GameManager.start_new_game()
	SceneManager.change_scene("res://scenes/starmap/starmap.tscn")

func _on_continue_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'Continue' button pressed.")
	AudioManager.play_sfx("confirm")
	SaveLoadManager.load_game()

func _on_generate_demo_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'Generate Demo' button pressed.")
	AudioManager.play_sfx("confirm")
	var demo_manager = DemoManager.new()
	demo_manager.generate_demo_state()
	SaveLoadManager.save_game()
	continue_button.disabled = false

func _on_load_game_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'Load Game' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/load_game_screen.tscn")

func _on_settings_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'Settings' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/settings_screen.tscn")

func _on_quit_button_pressed() -> void:
	DebugManager.log_action("Main Menu: 'Quit' button pressed.")
	AudioManager.play_sfx("back")
	get_tree().quit()

func _on_any_button_mouse_entered() -> void:
	AudioManager.play_sfx("hover")

func _on_any_button_pressed() -> void:
	AudioManager.play_sfx("confirm")
