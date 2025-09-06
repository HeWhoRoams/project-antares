# /ui/components/tech_entry.gd
extends PanelContainer

# Defines a custom signal that is emitted when this UI entry is clicked.
# It passes the Technology resource associated with this entry as an argument.
signal selected(tech_resource: Technology)

@onready var icon_rect: TextureRect = $HBoxContainer/Icon
@onready var name_label: Label = $HBoxContainer/Name

# A private variable to hold the data for this specific entry.
var _technology: Technology

## This is the public function our TechScreen will call to populate this entry.
func set_technology_data(tech_resource: Technology) -> void:
	if tech_resource:
		_technology = tech_resource # Store the technology data for later.
		name_label.text = _technology.display_name
		icon_rect.texture = _technology.icon

## This built-in function is called whenever there is a UI input event.
func _gui_input(event: InputEvent) -> void:
	# Check if the event is a left mouse button click that has just been pressed.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# If it is, emit our custom signal, passing this entry's technology data.
		selected.emit(_technology)