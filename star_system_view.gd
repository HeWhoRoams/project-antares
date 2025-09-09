# /scenes/starmap_objects/star_system_view.gd
extends Node2D

@onready var label: Label = $Label
var star_system_data: StarSystem

func _ready() -> void:
	if star_system_data:
		label.text = star_system_data.display_name
