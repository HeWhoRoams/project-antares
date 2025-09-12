# /scenes/starmap_objects/star_system_view.gd
class_name StarSystemView
extends Node2D

@onready var label: Label = $Label
var star_system_data: StarSystem

var _tooltip_scene: PackedScene = preload("res://ui/components/system_summary_tooltip.tscn")
var _tooltip_instance: PanelContainer = null

# Preload the popup scene
var system_popup_scene: PackedScene = preload("res://ui/popups/system_view_popup.tscn")


func _ready() -> void:
	if star_system_data:
		label.text = star_system_data.display_name


# Handles clicks on the system
func _on_area_2d_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		get_viewport().set_input_as_handled() # Prevents click from passing through
		_open_system_view()


func _open_system_view() -> void:
	# Check if a popup is already open to prevent duplicates
	if get_tree().get_first_node_in_group("system_popup"):
		return

	var ui_layer = get_tree().get_first_node_in_group("hud")
	if not ui_layer:
		printerr("StarSystemView: Could not find UI layer node.")
		return

	var popup = system_popup_scene.instantiate()
	popup.add_to_group("system_popup") # Add a group to easily find it
	ui_layer.add_child(popup)
	popup.populate_system_data(star_system_data)


# --- Tooltip Logic ---
func _on_area_2d_mouse_entered() -> void:
	var ui_layer = get_tree().get_first_node_in_group("hud")
	if not ui_layer:
		printerr("StarSystemView: Could not find UI layer node (did you add the HUD to the 'hud' group?).")
		return

	if not _tooltip_instance:
		_tooltip_instance = _tooltip_scene.instantiate()
		ui_layer.add_child(_tooltip_instance)
		_tooltip_instance.update_data(star_system_data)
		_tooltip_instance.global_position = get_global_mouse_position() + Vector2(20, 20)


func _on_area_2d_mouse_exited() -> void:
	if _tooltip_instance:
		_tooltip_instance.queue_free()
		_tooltip_instance = null
