extends Node

# Fallback assets
const FALLBACK_TEXTURE = preload("res://assets/icons/population.png")
const FALLBACK_AUDIO = preload("res://assets/audio/sfx/ui/ui_error.wav")

# Safe load for textures (Texture2D)
static func load_texture(path: String) -> Texture2D:
	var texture = load(path)
	if texture == null:
		DebugManager.log_error("Failed to load texture: " + path + ". Using fallback.")
		return FALLBACK_TEXTURE
	return texture

# Safe load for audio streams
static func load_audio(path: String) -> AudioStream:
	var audio = load(path)
	if audio == null:
		DebugManager.log_error("Failed to load audio: " + path + ". Using fallback.")
		return FALLBACK_AUDIO
	return audio

# Safe load for packed scenes
static func load_scene(path: String) -> PackedScene:
	var scene = load(path)
	if scene == null:
		DebugManager.log_error("Failed to load scene: " + path + ". Returning null.")
		return null
	return scene

# Safe load for scripts
static func load_script(path: String) -> Script:
	var script = load(path)
	if script == null:
		DebugManager.log_error("Failed to load script: " + path + ". Returning null.")
		return null
	return script

# Safe load for resources (generic)
static func load_resource(path: String) -> Resource:
	var resource = ResourceLoader.load(path)
	if resource == null:
		DebugManager.log_error("Failed to load resource: " + path + ". Returning null.")
		return null
	return resource

# Safe load for generic (returns Variant)
static func safe_load(path: String, fallback = null):
	var asset = load(path)
	if asset == null:
		DebugManager.log_error("Failed to load asset: " + path + ". Using fallback.")
		return fallback
	return asset
