# /scripts/managers/AudioManager.gd
extends Node

# We use two separate players to allow SFX to play over music.
var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

# A dictionary to cache our loaded SFX for quick playback.
var _sfx_library: Dictionary = {
	"hover": preload("res://assets/audio/sfx/ui/ui_hover.wav"),
	"confirm": preload("res://assets/audio/sfx/ui/ui_confirm.wav"),
	"back": preload("res://assets/audio/sfx/ui/ui_back.wav")
}

var _master_bus_idx: int
var _music_bus_idx: int
var _sfx_bus_idx: int

func _ready() -> void:
	# Create the audio player nodes as children of this singleton.
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	
	# Get the integer index for our audio buses.
	_master_bus_idx = AudioServer.get_bus_index("Master")
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# Assign the players to their respective buses.
	_music_player.bus = "Music"
	_sfx_player.bus = "SFX"

## Plays a music track. It will loop by default.
func play_music(track_path: String) -> void:
	if track_path.is_empty():
		_music_player.stop()
		return
		
	var audio_stream = load(track_path)
	_music_player.stream = audio_stream
	_music_player.play()

## Plays a one-shot sound effect from the preloaded library.
func play_sfx(sfx_name: String) -> void:
	if _sfx_library.has(sfx_name):
		_sfx_player.stream = _sfx_library[sfx_name]
		_sfx_player.play()

## Sets the master volume from a linear value (0.0 to 1.0).
func set_master_volume(linear_value: float) -> void:
	AudioServer.set_bus_volume_db(_master_bus_idx, linear_to_db(linear_value))

## Sets the music volume from a linear value (0.0 to 1.0).
func set_music_volume(linear_value: float) -> void:
	AudioServer.set_bus_volume_db(_music_bus_idx, linear_to_db(linear_value))

## Sets the SFX volume from a linear value (0.0 to 1.0).
func set_sfx_volume(linear_value: float) -> void:
	AudioServer.set_bus_volume_db(_sfx_bus_idx, linear_to_db(linear_value))
