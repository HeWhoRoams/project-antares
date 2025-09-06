# /scenes/starmap_objects/ship_view.gd
# The visual representation of a ship on the starmap.
class_name ShipView
extends Node2D

var ship_data: ShipData

# This public function allows the starmap to link this visual node
# to its corresponding data resource.
func set_ship_data(new_ship_data: ShipData) -> void:
	ship_data = new_ship_data
	# The name of this node in the scene tree will match the ship's ID for easy debugging.
	name = ship_data.id