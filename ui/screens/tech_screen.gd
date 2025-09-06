# /ui/screens/tech_screen.gd
extends Control

## The template scene for a single technology entry in our list.
@export var tech_entry_scene: PackedScene

## Assign the TechDetailsPanel node from the scene tree here.
@export var tech_details_panel: TechDetailsPanel

# Assign the layout containers from the scene tree.
@export var landscape_layout: HBoxContainer
@export var portrait_layout: VBoxContainer

# Assign the main content panels from the scene tree.
@export var tech_list_panel: PanelContainer

# A threshold to decide if the screen is "wide" or "tall".
const WIDE_ASPECT_RATIO_THRESHOLD = 1.25

func _ready() -> void:
	# Connect to the signal that fires when the game window is resized.
	get_viewport().size_changed.connect(_update_layout)
	# Set the initial layout when the screen first loads.
	_update_layout()
	# Populate the list with data.
	_populate_tech_list()

func _update_layout() -> void:
	# This function re-parents the list and details panels based on screen shape.
	var screen_size = get_viewport().get_visible_rect().size
	var aspect_ratio = screen_size.x / screen_size.y

	var list_parent = tech_list_panel.get_parent()
	if list_parent:
		list_parent.remove_child(tech_list_panel)
	
	var details_parent = tech_details_panel.get_parent()
	if details_parent:
		details_parent.remove_child(tech_details_panel)
		
	if aspect_ratio > WIDE_ASPECT_RATIO_THRESHOLD:
		landscape_layout.show()
		portrait_layout.hide()
		landscape_layout.add_child(tech_list_panel)
		landscape_layout.add_child(tech_details_panel)
	else:
		landscape_layout.hide()
		portrait_layout.show()
		portrait_layout.add_child(tech_list_panel)
		portrait_layout.add_child(tech_details_panel)

func _populate_tech_list() -> void:
	if not tech_entry_scene:
		printerr("TechEntry scene is not set in the TechScreen inspector!")
		return

	# This path needs to point to the container for the tech entries.
	var tech_list_container = %TechListContainer # Using a Unique Name (%) is best

	for child in tech_list_container.get_children():
		child.queue_free()

	for tech in DataManager.technologies.values():
		var new_entry = tech_entry_scene.instantiate()
		tech_list_container.add_child(new_entry)
		new_entry.set_technology_data(tech)
		new_entry.selected.connect(_on_tech_entry_selected)

## This function receives the signal from a TechEntry when it is clicked.
func _on_tech_entry_selected(tech_resource: Technology) -> void:
	# Instead of printing, we now tell the details panel to display the data.
	tech_details_panel.display_technology(tech_resource)