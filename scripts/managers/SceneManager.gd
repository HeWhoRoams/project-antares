# /scripts/managers/SceneManager.gd
extends Node

var previous_scene_path: String = ""
var next_scene_context: Variant = null

func _ready() -> void:
	var root = get_tree().get_root()
	if root.get_child_count() > 0:
		var initial_scene = root.get_child(root.get_child_count() - 1)
		if initial_scene:
			previous_scene_path = initial_scene.scene_file_path

func change_scene(scene_path: String, context: Variant = null) -> void:
	if get_tree().current_scene and not get_tree().current_scene.scene_file_path.is_empty():
		previous_scene_path = get_tree().current_scene.scene_file_path
	
	next_scene_context = context
	get_tree().change_scene_to_file(scene_path)

func return_to_previous_scene() -> void:
	if not previous_scene_path.is_empty():
		get_tree().change_scene_to_file(previous_scene_path)
	else:
		printerr("SceneManager: No previous scene path to return to.")
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
