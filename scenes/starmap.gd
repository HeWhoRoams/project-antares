# /scenes/starmap/starmap.gd
# Main controller for the starmap view.
extends Node2D

## Assign the StarSystemView scene in the editor.
@export var star_system_view_scene: PackedScene
## Assign the ShipView scene in the editor.
@export var ship_view_scene: PackedScene

func _ready() -> void:
	_draw_galaxy()
	_draw_player_ships()

func _draw_galaxy() -> void:
	if not star_system_view_scene:
		printerr("Starmap: StarSystemView scene is not set!")
		return
		
	for system_data in GalaxyManager.star_systems.values():
		var new_system_view = star_system_view_scene.instantiate()
		new_system_view.position = system_data.position
		# (Future) new_system_view.set_system_data(system_data)
		add_child(new_system_view)

func _draw_player_ships() -> void:
	if not ship_view_scene:
		printerr("Starmap: ShipView scene is not set!")
		return
		
	for ship_data in PlayerManager.owned_ships.values():
		# Find the star system this ship is supposed to be in.
		var current_system = GalaxyManager.star_systems.get(ship_data.current_system_id)
		if current_system:
			var new_ship_view = ship_view_scene.instantiate()
			new_ship_view.set_ship_data(ship_data)
			# Position the ship at its star system's location.
			new_ship_view.position = current_system.position
			add_child(new_ship_view)