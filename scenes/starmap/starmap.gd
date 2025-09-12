# /scenes/starmap/starmap.gd
# Main controller for the starmap view.
extends Node2D

@export var star_system_view_scene: PackedScene
@export var ship_view_scene: PackedScene
@export var system_info_popup_scene: PackedScene

var hud_scene: PackedScene = preload("res://ui/hud/hud.tscn")
var selected_ship_view: ShipView = null

func _ready() -> void:
	var hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	
	PlayerManager.ship_arrived.connect(_on_ship_arrived)
	_draw_galaxy()
	_draw_all_ships()

func _unhandled_input(event: InputEvent) -> void:
	# Left-click logic to select ships or show system info
	if event.is_action_pressed("ui_accept"):
		var clicked_object = _get_object_at_position(get_global_mouse_position())
		
		if clicked_object is ShipView:
			_select_ship(clicked_object)
		elif clicked_object is StarSystemView:
			# For now, we open the detailed view on click. This can be changed later.
			clicked_object._open_system_view()
		else:
			_select_ship(null) # Deselect if clicking empty space
	
	# Right-click to issue move order
	if event.is_action_pressed("ui_right"):
		if selected_ship_view:
			var clicked_object = _get_object_at_position(get_global_mouse_position())
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

func _on_ship_arrived(ship_data: ShipData) -> void:
	# This function needs a full rewrite to handle the new drawing logic
	# For now, we'll just redraw all ships. A more optimized approach can be added later.
	_redraw_all_ships()

func _draw_galaxy() -> void:
	if not star_system_view_scene:
		printerr("Starmap: StarSystemView scene is not set!")
		return
	for system_data in GalaxyManager.star_systems.values():
		var new_system_view: StarSystemView = star_system_view_scene.instantiate()
		new_system_view.position = system_data.position
		new_system_view.star_system_data = system_data 
		add_child(new_system_view)

func _redraw_all_ships() -> void:
	# Helper function to clear existing ships before redrawing
	for child in get_children():
		if child is ShipView:
			child.queue_free()
	_draw_all_ships()

func _draw_all_ships() -> void:
	if not ship_view_scene:
		printerr("Starmap: ShipView scene is not set!")
		return
	
	# 1. Group all ships by their current system
	var ships_by_system: Dictionary = {}
	var all_ships = PlayerManager.owned_ships.values() + AIManager.owned_ships.values()
	
	for ship_data in all_ships:
		var system_id = ship_data.current_system_id
		if not ships_by_system.has(system_id):
			ships_by_system[system_id] = []
		ships_by_system[system_id].append(ship_data)

	# 2. Draw the grouped ships for each system
	for system_id in ships_by_system.keys():
		_draw_ships_for_system(system_id, ships_by_system[system_id])


# UPDATED: Removed the '[ShipData]' type hint from the 'ships' argument to fix the error.
func _draw_ships_for_system(system_id: StringName, ships: Array) -> void:
	var system_node = GalaxyManager.star_systems.get(system_id)
	if not system_node: return

	# Sort ships to ensure the player's ship (owner_id 1) is always first
	ships.sort_custom(func(a, b): return a.owner_id < b.owner_id)

	var base_position = system_node.position
	var top_right_offset = Vector2(30, -30)
	var stacking_offset = Vector2(0, 30)
	var max_ships_to_show = 3

	for i in range(min(ships.size(), max_ships_to_show)):
		var ship_data = ships[i]
		var new_ship_view: ShipView = ship_view_scene.instantiate()
		
		# Calculate position
		new_ship_view.position = base_position + top_right_offset + (stacking_offset * i)
		
		# Set data and color
		new_ship_view.set_ship_data(ship_data)
		if ship_data.owner_id == 1:
			new_ship_view.modulate = Color.CYAN
		else:
			new_ship_view.modulate = Color.RED
			
		add_child(new_ship_view)
