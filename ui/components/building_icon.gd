extends Control

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var tooltip_panel: PanelContainer = %TooltipPanel
@onready var tooltip_label: Label = %TooltipLabel

var _building_data: BuildingData

func _ready() -> void:
	tooltip_panel.hide()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_building_data(building: BuildingData) -> void:
	_building_data = building
	name_label.text = building.display_name
	
	if building.icon_texture:
		icon_texture.texture = building.icon_texture
	else:
		# Use default building icon
		icon_texture.texture = preload("res://assets/icons/building_generic.png")

func _on_mouse_entered() -> void:
	if _building_data:
		tooltip_label.text = "%s\n%s\nCost: %d credits/turn\n%s" % [
			_building_data.display_name,
			_building_data.description,
			_building_data.maintenance_cost,
			_building_data.get_effect_description()
		]
		tooltip_panel.show()

func _on_mouse_exited() -> void:
	tooltip_panel.hide()
