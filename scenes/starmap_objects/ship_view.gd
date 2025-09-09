# /scenes/starmap_objects/ship_view.gd
# The visual representation of a ship on the starmap.
class_name ShipView
extends Node2D

var ship_data: ShipData
var is_selected: bool = false

func set_ship_data(new_ship_data: ShipData) -> void:
	ship_data = new_ship_data
	name = ship_data.id

func select() -> void:
	is_selected = true
	modulate = Color.GREEN

func deselect() -> void:
	is_selected = false
	modulate = Color.WHITE
