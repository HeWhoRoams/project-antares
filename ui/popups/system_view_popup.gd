# /ui/popups/system_view_popup.gd
extends CenterContainer

var planet_view_scene = preload("res://scenes/system_view_objects/planet_view.tscn")

const ORBIT_BASE_RADIUS = 150.0
const ORBIT_RADIUS_STEP = 60.0
const ORBIT_COLOR = Color(1, 1, 1, 0.3)
const ORBIT_LINE_WIDTH = 2.0
const ICON_BUFFER = 100 # Extra space for the planet icons on the outermost ring

# CRITICAL: This line must look for the unique node named "%MainPanel"
@onready var main_panel: PanelContainer = %MainPanel
@onready var body_panel: PanelContainer = %Body
@onready var system_name_label: Label = %SystemNameLabel
@onready var close_button: Button = %CloseButton
@onready var orbits_container: Control = %OrbitsContainer
@onready var ship_list: VBoxContainer = %ShipList
@onready var star_sprite: TextureRect = %StarSprite

var _max_orbit_slot: int = 0

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	main_panel.custom_minimum_size.y = screen_size.y * 0.85
	
	if close_button:
		close_button.pressed.connect(queue_free)
	
	if orbits_container:
		orbits_container.draw.connect(_on_orbits_container_draw)

func populate_system_data(system_data: StarSystem, star_texture: Texture2D) -> void:
	if system_name_label: system_name_label.text = system_data.display_name
	if star_sprite: star_sprite.texture = star_texture

	for child in orbits_container.get_children():
		if child is Control and not child is TextureRect:
			child.queue_free()
	for child in ship_list.get_children():
		child.queue_free()

	if system_data.celestial_bodies.is_empty():
		_max_orbit_slot = -1
		body_panel.custom_minimum_size = Vector2(400, 400)
		orbits_container.queue_redraw()
		return

	var orbits: Dictionary = {}
	_max_orbit_slot = 0
	for body in system_data.celestial_bodies:
		if not orbits.has(body.orbital_slot):
			orbits[body.orbital_slot] = []
		orbits[body.orbital_slot].append(body)
		if body.orbital_slot > _max_orbit_slot:
			_max_orbit_slot = body.orbital_slot
	
	var max_radius = ORBIT_BASE_RADIUS + (_max_orbit_slot * ORBIT_RADIUS_STEP)
	var required_diameter = (max_radius * 2) + ICON_BUFFER
	body_panel.custom_minimum_size = Vector2(required_diameter, required_diameter)
	
	await get_tree().process_frame
	
	var center = orbits_container.size / 2.0
	for slot in orbits.keys():
		var bodies_in_orbit: Array = orbits[slot]
		var angle_step = TAU / bodies_in_orbit.size()
		var current_angle = 0.0
		
		for body in bodies_in_orbit:
			var planet_view = planet_view_scene.instantiate()
			orbits_container.add_child(planet_view)
			
			var radius = ORBIT_BASE_RADIUS + (body.orbital_slot * ORBIT_RADIUS_STEP)
			var body_pos = center + Vector2.from_angle(current_angle) * radius
			
			planet_view.position = body_pos - (planet_view.size / 2.0)
			planet_view.set_body_data(body, system_data.display_name)
			
			current_angle += angle_step
	
	orbits_container.queue_redraw()
	_find_and_list_ships(system_data.id)

func _on_orbits_container_draw():
	var center = orbits_container.size / 2.0
	for i in range(_max_orbit_slot + 1):
		var radius = ORBIT_BASE_RADIUS + (i * ORBIT_RADIUS_STEP)
		orbits_container.draw_arc(center, radius, 0, TAU, 64, ORBIT_COLOR, ORBIT_LINE_WIDTH, true)

func _find_and_list_ships(system_id: StringName):
	if ship_list == null: return

	for ship in PlayerManager.owned_ships.values():
		if ship.current_system_id == system_id:
			_add_ship_to_list(ship.id, Color.CYAN)

	for ship in AIManager.owned_ships.values():
		if ship.current_system_id == system_id:
			_add_ship_to_list(ship.id, Color.RED)

func _add_ship_to_list(ship_name: String, color: Color) -> void:
	var label = Label.new()
	label.text = ship_name
	label.modulate = color
	ship_list.add_child(label)