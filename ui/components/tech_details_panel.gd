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
	hide()
	research_button.pressed.connect(_on_research_button_pressed)

func display_technology(tech_resource: Technology) -> void:
	if not tech_resource:
		hide()
		return

	_current_technology = tech_resource
	name_label.text = _current_technology.display_name
	icon_rect.texture = _current_technology.icon
	cost_label.text = "Cost: %s RP" % _current_technology.research_cost
	description_label.text = _current_technology.description
	
	# Update button state based on new PlayerManager logic.
	if PlayerManager.unlocked_techs.has(_current_technology.id):
		research_button.text = "Researched"
		research_button.disabled = true
	elif PlayerManager.can_research(_current_technology):
		research_button.text = "Research"
		research_button.disabled = false
	else:
		# Not researched, but can't afford it.
		research_button.text = "Research"
		research_button.disabled = true
	
	show()

func _on_research_button_pressed() -> void:
	if _current_technology:
		var success = PlayerManager.unlock_technology(_current_technology)
		# If research was successful, refresh this panel to show the new state.
		if success:
			display_technology(_current_technology)