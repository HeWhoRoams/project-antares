# /scenes/starmap_objects/star_system_view.gd
class_name StarSystemView
extends Node2D

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D # --- NEW: Reference to the star sprite

var star_system_data: StarSystem

var _tooltip_scene: PackedScene = preload("res://ui/components/system_summary_tooltip.tscn")
var _tooltip_instance: PanelContainer = null
var system_popup_scene: PackedScene = preload("res://ui/popups/system_view_popup.tscn")


func _ready() -> void:
	if star_system_data:
		label.text = star_system_data.display_name


func _on_area_2d_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		get_viewport().set_input_as_handled()
		_open_system_view()


func _open_system_view() -> void:
	if get_tree().get_first_node_in_group("system_popup"):
		return

	var ui_layer = get_tree().get_first_node_in_group("hud")
	if not ui_layer:
		printerr("StarSystemView: Could not find UI layer node.")
		return

	var popup = system_popup_scene.instantiate()
	popup.add_to_group("system_popup")
	ui_layer.add_child(popup)
	# --- UPDATED: Pass the sprite's texture to the popup ---
	popup.populate_system_data(star_system_data, sprite.texture)


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
