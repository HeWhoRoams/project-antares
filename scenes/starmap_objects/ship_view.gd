# /scenes/starmap/starmap.gd
# Main controller for the starmap view.
extends Node2D

## Assign the StarSystemView scene in the editor.
@export var star_system_view_scene: PackedScene
## Assign the ShipView scene in the editor.
@export var ship_view_scene: PackedScene

# A variable to hold a reference to the currently selected ship.
var selected_ship_view: ShipView = null

func _ready() -> void:
	_draw_galaxy()
	_draw_player_ships()

func _unhandled_input(event: InputEvent) -> void:
	# Check for a left mouse click.
	if event.is_action_pressed("ui_accept"): # "ui_accept" is the default for left-click.
		# Figure out what we clicked on.
		var clicked_object = _get_object_at_position(get_global_mouse_position())
		
		# If we clicked on a ship, select it.
		if clicked_object is ShipView:
			_select_ship(clicked_object)
		# If we clicked on empty space, deselect whatever we had selected.
		else:
			_select_ship(null)

## Uses Godot's physics engine to find the topmost 2D object at a screen position.
func _get_object_at_position(screen_position: Vector2):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = screen_position
	# We only want to detect objects on physics layer 1.
	query.collision_mask = 1
	var result = space_state.intersect_point(query)
	
	if not result.is_empty():
		# The result gives us the collider, so we get its owner (the ShipView).
		return result[0].collider.get_owner()
	
	return null

## Manages the selection state of ships.
func _select_ship(ship_to_select: ShipView):
	# If we already have a ship selected, deselect it first.
	if selected_ship_view:
		selected_ship_view.deselect()
	
	# Set the new ship as the selected one.
	selected_ship_view = ship_to_select
	
	# If the new selection is actually a ship (and not null), select it.
	if selected_ship_view:
		selected_ship_view.select()

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
		var current_system = GalaxyManager.star_systems.get(ship_data.current_system_id)
		if current_system:
			var new_ship_view = ship_view_scene.instantiate()
			new_ship_view.set_ship_data(ship_data)
			new_ship_view.position = current_system.position
			add_child(new_ship_view)