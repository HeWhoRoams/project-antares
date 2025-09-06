# /ui/components/tech_details_panel.gd
class_name TechDetailsPanel
extends PanelContainer

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var cost_label: Label = %Cost
@onready var description_label: Label = %Description
@onready var research_button: Button = %ResearchButton

var _current_technology: Technology

func _ready() -> void:
	# Start with the panel hidden until a technology is selected.
	hide()
	research_button.pressed.connect(_on_research_button_pressed)

## This is the public function the TechScreen will call.
func display_technology(tech_resource: Technology) -> void:
	if not tech_resource:
		hide()
		return

	_current_technology = tech_resource
	name_label.text = _current_technology.display_name
	icon_rect.texture = _current_technology.icon
	cost_label.text = "Cost: %s RP" % _current_technology.research_cost
	description_label.text = _current_technology.description
	
	# (Future) Add logic here to enable/disable the button
	# based on if the tech is already researched or prerequisites are met.
	research_button.disabled = false
	
	show()

func _on_research_button_pressed() -> void:
	if _current_technology:
		print("Researching technology: %s" % _current_technology.display_name)
		# (Future) Add logic to spend research points and unlock the tech.
		research_button.disabled = true