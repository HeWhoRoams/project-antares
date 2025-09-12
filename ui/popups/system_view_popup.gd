# /ui/popups/system_view_popup.gd
extends PanelContainer

var planet_view_scene = preload("res://scenes/system_view_objects/planet_view.tscn")

@onready var system_name_label: Label = $VBoxContainer/Header/SystemNameLabel
@onready var close_button: Button = $VBoxContainer/Header/CloseButton
@onready var orbits_container: Node2D = $VBoxContainer/Body/OrbitsContainer
@onready var ship_list: VBoxContainer = $VBoxContainer/Footer/VBoxContainer/ShipList
@onready var star_sprite: TextureRect = $VBoxContainer/Body/StarSprite

const ORBIT_RADIUS_STEP = 90
const ORBIT_BODY_OFFSET = 150

func _ready() -> void:
	if close_button == null:
		# --- DEFENSIVE CODE ---
		if DebugManager.is_debug_mode_enabled:
			printerr("SystemViewPopup: 'CloseButton' node not found. Check the scene tree.")
		# --- END DEFENSIVE CODE ---
		return # Prevent crash
	
	close_button.pressed.connect(queue_free)
	global_position = get_viewport().get_visible_rect().size / 2.0 - size / 2.0


func populate_system_data(system_data: StarSystem, star_texture: Texture2D) -> void:
	# --- DEFENSIVE CODE ---
	if DebugManager.is_debug_mode_enabled:
		if system_name_label == null: printerr("SystemViewPopup: 'SystemNameLabel' node not found.")
		if star_sprite == null: printerr("SystemViewPopup: 'StarSprite' node not found.")
		if orbits_container == null: printerr("SystemViewPopup: 'OrbitsContainer' node not found.")
		if ship_list == null: printerr("SystemViewPopup: 'ShipList' node not found.")
	# --- END DEFENSIVE CODE ---

	# Always perform null checks before using nodes to prevent crashes
	if system_name_label: system_name_label.text = system_data.display_name
	if star_sprite: star_sprite.texture = star_texture

	if orbits_container:
		for child in orbits_container.get_children():
			child.queue_free()
	
	if ship_list:
		for child in ship_list.get_children():
			child.queue_free()

	# Display celestial bodies
	if orbits_container and !system_data.celestial_bodies.is_empty():
		for body in system_data.celestial_bodies:
			var planet_view = planet_view_scene.instantiate()
			orbits_container.add_child(planet_view)
			var x_pos = ORBIT_BODY_OFFSET + (body.orbital_slot * ORBIT_RADIUS_STEP)
			planet_view.position = Vector2(x_pos, 0)
			planet_view.set_body_data(body)

	_find_and_list_ships(system_data.id)


func _find_and_list_ships(system_id: StringName):
	if ship_list == null: return # Can't add ships if the list doesn't exist

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
