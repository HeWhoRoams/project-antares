# /scripts/managers/AudioManager.gd
extends Node

const AssetLoader = preload("res://scripts/utils/AssetLoader.gd")

# We use two separate players to allow SFX to play over music.
var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

# Playlist variables
var _current_playlist: Array = []
var _current_track_index: int = 0
var _shuffle: bool = false

# A dictionary to cache our loaded SFX for quick playback.
var _sfx_library: Dictionary = {
	"hover": preload("res://assets/audio/sfx/ui/ui_hover.wav"),
	"confirm": preload("res://assets/audio/sfx/ui/ui_confirm.wav"),
	"back": preload("res://assets/audio/sfx/ui/ui_back.wav"),
	"explosion": preload("res://assets/audio/sfx/gameplay/explosion.wav"),
	"colonization": preload("res://assets/audio/sfx/gameplay/colonization.wav")
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
	
	# Connect music finished signal for playlist
	_music_player.finished.connect(_on_music_finished)

## Plays a music track. It will loop by default.
func play_music(track_path: String) -> void:
	if track_path.is_empty():
		_music_player.stop()
		return

	var audio_stream = AssetLoader.load_audio(track_path)
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

## Plays a playlist of music tracks.
func play_music_playlist(tracks: Array, shuffle: bool = false) -> void:
	_current_playlist = tracks.duplicate()
	_shuffle = shuffle
	_current_track_index = 0
	if _shuffle:
		_current_playlist.shuffle()
	_play_current_track()

## Fades out the music over a duration.
func fade_out_music(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(_music_player, "volume_db", -80.0, duration)
	tween.tween_callback(_music_player.stop)

func _on_music_finished() -> void:
	_next_track()

func _play_current_track() -> void:
	if _current_playlist.is_empty():
		return
	var track_path = _current_playlist[_current_track_index]
	play_music(track_path)

func _next_track() -> void:
	if _current_playlist.is_empty():
		return
	_current_track_index = (_current_track_index + 1) % _current_playlist.size()
	if _shuffle and _current_track_index == 0:
		_current_playlist.shuffle()
	_play_current_track()

## Saves volume settings.
func save_volume_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", db_to_linear(AudioServer.get_bus_volume_db(_master_bus_idx)))
	config.set_value("audio", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(_music_bus_idx)))
	config.set_value("audio", "sfx_volume", db_to_linear(AudioServer.get_bus_volume_db(_sfx_bus_idx)))
	config.save("user://audio_settings.cfg")

## Loads volume settings.
func load_volume_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	if err == OK:
		set_master_volume(config.get_value("audio", "master_volume", 1.0))
		set_music_volume(config.get_value("audio", "music_volume", 1.0))
		set_sfx_volume(config.get_value("audio", "sfx_volume", 1.0))
