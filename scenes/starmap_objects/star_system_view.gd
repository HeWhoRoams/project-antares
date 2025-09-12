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
	# Create a new tooltip instance when the mouse enters.
	if not _tooltip_instance:
		_tooltip_instance = _tooltip_scene.instantiate()
		# Add it to a high-level UI layer to ensure it draws on top.
		get_tree().get_first_node_in_group("ui_layer").add_child(_tooltip_instance)
		_tooltip_instance.update_data(star_system_data)
		# Position the tooltip next to the mouse cursor.
		_tooltip_instance.global_position = get_global_mouse_position() + Vector2(20, 20)

func _on_area_2d_mouse_exited() -> void:
	# Destroy the tooltip when the mouse leaves.
	if _tooltip_instance:
		_tooltip_instance.queue_free()
		_tooltip_instance = null

# We need a UI layer group to add the tooltip to.
# Let's add the HUD to this group.
func _notification(what):
	if what == NOTIFICATION_PARENTED:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.add_to_group("ui_layer")
