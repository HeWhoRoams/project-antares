extends Node

# Fallback assets
const FALLBACK_TEXTURE = preload("res://assets/icons/population.png")
const FALLBACK_AUDIO = preload("res://assets/audio/sfx/ui/ui_error.wav")

# Safe load for textures (Texture2D)
static func load_texture(path: String) -> Texture2D:
	var texture = load(path)
	if texture == null or not (texture is Texture2D):
		DebugManager.log_error("Failed to load texture or wrong type: " + path + ". Using fallback.")
		return FALLBACK_TEXTURE
	return texture as Texture2D

# Safe load for audio streams
static func load_audio(path: String) -> AudioStream:
	var audio = load(path)
	if audio == null or not (audio is AudioStream):
		DebugManager.log_error("Failed to load audio or wrong type: " + path + ". Using fallback.")
		return FALLBACK_AUDIO
	return audio as AudioStream

# Safe load for packed scenes
static func load_scene(path: String) -> PackedScene:
	var scene = load(path)
	if scene == null or not (scene is PackedScene):
		DebugManager.log_error("Failed to load scene or wrong type: " + path + ". Returning null.")
		return null
	return scene as PackedScene

# Safe load for scripts
static func load_script(path: String) -> Script:
	var script = load(path)
	if script == null or not (script is Script):
		DebugManager.log_error("Failed to load script or wrong type: " + path + ". Returning null.")
		return null
	return script as Script

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
