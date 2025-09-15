# /scripts/managers/SceneManager.gd
# A global singleton for handling scene transitions.
extends Node

var current_scene: Node = null
var previous_scene_path: String = ""

func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	get_tree().scene_changed.connect(_on_scene_changed)

## Changes the active scene to the one at the given path.
func change_scene(scene_path: String) -> void:
	# Store the current scene's path before changing.
	if current_scene and not current_scene.scene_file_path.is_empty():
		previous_scene_path = current_scene.scene_file_path
	
	get_tree().change_scene_to_file(scene_path)

## Returns to the previously active scene.
func return_to_previous_scene() -> void:
	if not previous_scene_path.is_empty():
		change_scene(previous_scene_path)
	else:
		# Fallback in case there's no history (e.g., first scene)
		printerr("SceneManager: No previous scene path to return to.")
		change_scene("res://ui/main_menu.tscn")

func _on_scene_changed(scene: Node) -> void:
	current_scene = scene