# /scenes/starmap/starmap.gd
# Main controller for the starmap view.
extends Node2D

@export var star_system_view_scene: PackedScene
@export var ship_view_scene: PackedScene
@export var system_info_popup_scene: PackedScene

@onready var camera: Camera2D = %Camera2D

var hud_scene: PackedScene = preload("res://ui/hud/hud.tscn")
var selected_ship_view: ShipView = null
var is_panning: bool = false

func _ready() -> void:
	# This _ready function runs after the managers' _ready functions.
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.emit_load_data() # Tell the manager to send out the loaded data
	
	# The rest of the setup happens after the data is loaded and the galaxy is drawn.
	var hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	
	PlayerManager.ship_arrived.connect(_on_ship_arrived)
	
	# The drawing must happen *after* the managers have their data.
	# We can wait one frame to be sure.
	await get_tree().process_frame
	_draw_galaxy()
	_draw_all_ships()

func _unhandled_input(event: InputEvent) -> void:
	# --- Panning Logic ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Start panning only if the click is on empty space
			if _get_object_at_position(get_global_mouse_position()) == null:
				is_panning = true
		else:
			# Stop panning when the button is released
			is_panning = false
	
	if event is InputEventMouseMotion and is_panning:
		# Move the camera by the mouse's relative motion, adjusted for zoom
		camera.position -= event.relative * camera.zoom
		return # Prevent other inputs while panning

	# --- Selection & Ordering Logic ---
	if event.is_action_pressed("ui_accept"):
		var clicked_object = _get_object_at_position(get_global_mouse_position())
		
		if clicked_object is ShipView:
			_select_ship(clicked_object)
		elif clicked_object is StarSystemView:
			clicked_object._open_system_view()
		else:
			_select_ship(null)
	
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
	_redraw_all_ships()

func _draw_galaxy() -> void:
	if not star_system_view_scene:
		printerr("Starmap: StarSystemView scene is not set!")
		return
	for system_data in GalaxyManager.star_systems.values():
		var new_system_view: StarSystemView = star_system_view_scene.instantiate()
		new_system_view.position = system_data.position
		new_system_view.star_system_data = system_data
		
		var star_color = GalaxyManager.get_star_color(system_data.celestial_bodies.size())
		new_system_view.get_node("Sprite2D").modulate = star_color
		
		add_child(new_system_view)

func _redraw_all_ships() -> void:
	for child in get_children():
		if child is ShipView:
			child.queue_free()
	_draw_all_ships()

func _draw_all_ships() -> void:
	if not ship_view_scene:
		printerr("Starmap: ShipView scene is not set!")
		return
	
	var ships_by_system: Dictionary = {}
	var all_ships = PlayerManager.owned_ships.values() + AIManager.owned_ships.values()
	
	for ship_data in all_ships:
		var system_id = ship_data.current_system_id
		if not ships_by_system.has(system_id):
			ships_by_system[system_id] = []
		ships_by_system[system_id].append(ship_data)

	for system_id in ships_by_system.keys():
		_draw_ships_for_system(system_id, ships_by_system[system_id])

func _draw_ships_for_system(system_id: StringName, ships: Array) -> void:
	var system_data = GalaxyManager.star_systems.get(system_id)
	if not system_data: return

	ships.sort_custom(func(a, b): return a.owner_id < b.owner_id)

	var base_position = system_data.position
	var top_right_offset = Vector2(30, -30)
	var stacking_offset = Vector2(0, 30)
	var max_ships_to_show = 3

	for i in range(min(ships.size(), max_ships_to_show)):
		var ship_data = ships[i]
		var new_ship_view: ShipView = ship_view_scene.instantiate()
		
		new_ship_view.position = base_position + top_right_offset + (stacking_offset * i)
		new_ship_view.set_ship_data(ship_data)
		
		# UPDATED: Comparing against the player's StringName empire ID instead of the integer 1.
		if ship_data.owner_id == PlayerManager.player_empire.id:
			new_ship_view.modulate = Color.CYAN
		else:
			new_ship_view.modulate = Color.RED
			
		add_child(new_ship_view)
