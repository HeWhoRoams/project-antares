# /tests/test_scene_validator.gd
extends GutTest

const SCREENS_PATH = "res://ui/screens/"

# This test will dynamically create sub-tests for each scene it finds.
func test_all_scenes_load_without_errors():
	var screen_files = _get_all_tscn_files_in(SCREENS_PATH)
	assert_greater_than(screen_files.size(), 0, "Should have found at least one screen to test.")

	for scene_path in screen_files:
		# Use 'add_test_as_parameter' to create a named sub-test for each scene.
		add_test_as_parameter(
			"test_individual_scene_load",
			scene_path,
			"test_load_of_" + scene_path.get_file().replace(".tscn", "")
		)

# This is the actual test function that will be run for each scene path.
func test_individual_scene_load(scene_path):
	gut.p("Attempting to load scene: " + scene_path)
	
	# Use the SceneManager to load the scene.
	SceneManager.change_scene(scene_path)
	
	# Wait for half a second to allow the scene's _ready() function and
	# a few frames to process. GUT will automatically detect any errors
	# that Godot prints to the console during this time.
	await get_tree().create_timer(0.5).timeout
	
	# If we reach this point without GUT detecting an error, the scene loaded successfully.
	gut.pass_test("Scene loaded without crashing or logging errors.")

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