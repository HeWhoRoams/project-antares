# /tests/test_scene_validator.gd
extends "res://addons/gut/test.gd"

const SCREENS_PATH = "res://ui/screens/"

# This test loads each scene and checks for errors.
func test_all_scenes_load_without_errors():
	var screen_files = _get_all_tscn_files_in(SCREENS_PATH)
	assert_true(screen_files.size() > 0, "Should have found at least one screen to test.")

	for scene_path in screen_files:
		gut.p("Attempting to load scene: " + scene_path)

		# Instantiate the scene and add to test tree.
		var scene = load(scene_path).instantiate()
		add_child(scene)

		# Wait for half a second to allow the scene's _ready() function and
		# a few frames to process. GUT will automatically detect any errors
		# that Godot prints to the console during this time.
		await get_tree().create_timer(0.5).timeout

		remove_child(scene)
		scene.queue_free()

		gut.pass_test("Scene " + scene_path + " loaded without crashing or logging errors.")

# Helper function to find all scene files in a directory.
func _get_all_tscn_files_in(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				files.append(dir.get_current_dir().path_join(file_name))
			file_name = dir.get_next()
	else:
		gut.fail_test("Could not open directory at path: " + path)
	return files
