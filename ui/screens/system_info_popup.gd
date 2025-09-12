# /ui/screens/system_info_popup.gd
extends CanvasLayer

# Drag your PanelContainer node from the Scene dock into this slot in the Inspector.
@export var main_panel: PanelContainer

func _ready() -> void:
	# Get the full size of the game window (the viewport).
	var screen_size = get_viewport().get_visible_rect().size
	
	# Set the panel's minimum size to be 75% of the screen size.
	main_panel.custom_minimum_size = screen_size * 0.75
