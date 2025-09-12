# /scenes/starmap_objects/star_system_view.gd
class_name StarSystemView
extends Node2D

@onready var label: Label = $Label
var star_system_data: StarSystem

var _tooltip_scene: PackedScene = preload("res://ui/components/system_summary_tooltip.tscn")
var _tooltip_instance: PanelContainer = null

func _ready() -> void:
	if star_system_data:
		label.text = star_system_data.display_name

func _on_area_2d_mouse_entered() -> void:
	# Get the UI layer only when the mouse enters.
	# This ensures the node is definitely in the scene tree.
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
