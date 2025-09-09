# /scripts/managers/SceneManager.gd
# A global singleton for handling scene transitions.
extends Node

var current_scene: Node = null

func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

## Changes the active scene to the one at the given path.
func change_scene(scene_path: String) -> void:
	# This is a deferred call, which waits for a safe moment to change scenes.
	get_tree().change_scene_to_file(scene_path)
