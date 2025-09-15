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

func _ready() -> void:
	# Create the audio player nodes as children of this singleton.
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)

## Plays a music track. It will loop by default.
func play_music(track_path: String) -> void:
	if track_path.is_empty():
		_music_player.stop()
		return
		
	var audio_stream = load(track_path)
	_music_player.stream = audio_stream
	_music_player.play()
	# Music streams are looped by default in their import settings.

## Plays a one-shot sound effect from the preloaded library.
func play_sfx(sfx_name: String) -> void:
	if _sfx_library.has(sfx_name):
		_sfx_player.stream = _sfx_library[sfx_name]
		_sfx_player.play()
