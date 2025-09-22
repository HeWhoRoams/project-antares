# /tests/test_ui_layouts.gd
extends GutTest

# Directory to save new screenshots for review
const CURRENT_SCREENSHOT_DIR = "res://tests/screenshots/current/"
# Directory where you will store the "correct" or "golden" master images
const GOLDEN_SCREENSHOT_DIR = "res://tests/screenshots/golden/"

# You will need to create the two folders above in your project.

func test_main_menu_layout():
	var scene_path = "res://ui/main_menu.tscn"
	var result = await _compare_scene_to_golden_image(scene_path, "main_menu.png")
	assert_true(result, "Main menu layout should match the golden image.")

func test_hud_layout():
	var scene_path = "res://ui/hud/hud.tscn"
	var result = await _compare_scene_to_golden_image(scene_path, "hud.png")
	assert_true(result, "HUD layout should match the golden image.")

# --- Helper function to perform the screenshot comparison ---
func _compare_scene_to_golden_image(scene_path: String, golden_image_name: String) -> bool:
	var scene = load(scene_path).instantiate()
	add_child(scene)
	# Wait two frames for the UI to fully settle and draw.
	await get_tree().process_frame
	await get_tree().process_frame
	
	var current_image = get_viewport().get_texture().get_image()
	remove_child(scene)
	scene.queue_free()

	# Save the current screenshot for manual review if the test fails
	DirAccess.make_dir_recursive_absolute(CURRENT_SCREENSHOT_DIR)
	current_image.save_png(CURRENT_SCREENSHOT_DIR + golden_image_name)

	var golden_path = GOLDEN_SCREENSHOT_DIR + golden_image_name
	if not FileAccess.file_exists(golden_path):
		gut.fail_test("Golden image not found at: " + golden_path)
		return false
	
	var golden_image = Image.load_from_file(golden_path)
	
	# Basic comparison: check if dimensions and pixel data are identical.
	if golden_image.get_size() != current_image.get_size():
		gut.p("Image sizes do not match. Golden: %s, Current: %s" % [golden_image.get_size(), current_image.get_size()])
		return false
		
	if golden_image.get_data() != current_image.get_data():
		gut.p("Pixel data does not match for " + golden_image_name)
		return false
		
	return true