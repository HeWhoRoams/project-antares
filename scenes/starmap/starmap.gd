# /scenes/starmap/starmap.gd
# Main controller for the starmap view.
extends Node2D

@export var star_system_view_scene: PackedScene
@export var ship_view_scene: PackedScene

var selected_ship_view: ShipView = null

func _ready() -> void:
	# Connect to the PlayerManager's signal to know when a ship arrives.
	PlayerManager.ship_arrived.connect(_on_ship_arrived)
	_draw_galaxy()
	_draw_player_ships()

func _unhandled_input(event: InputEvent) -> void:
	# Left-click to select
	if event.is_action_pressed("ui_accept"):
		var clicked_object = _get_object_at_position(get_global_mouse_position())
		_select_ship(clicked_object if clicked_object is ShipView else null)
	
	# Right-click to issue move order
	if event.is_action_pressed("ui_right"):
		if selected_ship_view:
			var clicked_object = _get_object_at_position(get_global_mouse_position())
			# We can only issue move orders to StarSystemViews
			if clicked_object is StarSystemView:
				PlayerManager.set_ship_destination(
					selected_ship_view.ship_data.id, 
					clicked_object.star_system_data.id
				)

func _get_object_at_position(screen_position: Vector2):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = screen_position
	query.collision_mask = 1
	var result = space_state.intersect_point(query)
	if not result.is_empty():
		return result[0].collider.get_owner()
	return null

func _select_ship(ship_to_select: ShipView):
	if selected_ship_view:
		selected_ship_view.deselect()
	selected_ship_view = ship_to_select
	if selected_ship_view:
		selected_ship_view.select()

## Called when the PlayerManager emits the ship_arrived signal.
func _on_ship_arrived(ship_data: ShipData) -> void:
	var ship_view: ShipView = find_child(ship_data.id, true, false)
	var new_system_location = GalaxyManager.star_systems.get(ship_data.current_system_id).position
	
	# Animate the ship moving to its new location.
	if ship_view:
		var tween = create_tween()
		tween.tween_property(ship_view, "position", new_system_location, 0.5).set_trans(Tween.TRANS_SINE)

func _draw_galaxy() -> void:
	if not star_system_view_scene:
		printerr("Starmap: StarSystemView scene is not set!")
		return
	for system_data in GalaxyManager.star_systems.values():
		var new_system_view = star_system_view_scene.instantiate()
		new_system_view.position = system_data.position
		# This part is still future work, but we need to pass the data for right-clicks.
		new_system_view.star_system_data = system_data 
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
