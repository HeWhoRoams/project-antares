extends Control

@onready var main_slider: HSlider = %MainSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider

func _ready() -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	var music_bus_idx = AudioServer.get_bus_index("Music")
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	main_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_idx))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_idx))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_idx))

func _on_main_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_save_game_button_pressed() -> void:
	SaveLoadManager.save_game()

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()
