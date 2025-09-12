# /ui/popups/system_view_popup.gd
extends PanelContainer

# Scene Preloads
var planet_view_scene = preload("res://scenes/system_view_objects/planet_view.tscn")

# Node References
@onready var system_name_label: Label = %SystemNameLabel
@onready var close_button: Button = %CloseButton
@onready var orbits_container: Node2D = %OrbitsContainer
@onready var ship_list: VBoxContainer = %ShipList

const ORBIT_RADIUS_STEP = 90
const ORBIT_BODY_OFFSET = 150

func _ready() -> void:
	close_button.pressed.connect(queue_free)
	# A simple way to center the popup.
	global_position = get_viewport().get_visible_rect().size / 2.0 - size / 2.0


func populate_system_data(system_data: StarSystem) -> void:
	system_name_label.text = system_data.display_name

	# Clear any previous data
	for child in orbits_container.get_children():
		child.queue_free()
	for child in ship_list.get_children():
		child.queue_free()

	# Display celestial bodies
	for body in system_data.celestial_bodies:
		var planet_view = planet_view_scene.instantiate()
		orbits_container.add_child(planet_view)
		# Position planets in a simple horizontal line for now
		var x_pos = ORBIT_BODY_OFFSET + (body.orbital_slot * ORBIT_RADIUS_STEP)
		planet_view.position = Vector2(x_pos, 0)
		planet_view.set_body_data(body)

	# Find and list ships in the system
	_find_and_list_ships(system_data.id)


func _find_and_list_ships(system_id: StringName):
	# Check player ships
	for ship in PlayerManager.owned_ships.values():
		if ship.current_system_id == system_id:
			_add_ship_to_list(ship.id, Color.CYAN)

	# Check AI ships
	for ship in AIManager.owned_ships.values():
		if ship.current_system_id == system_id:
			_add_ship_to_list(ship.id, Color.RED)


func _add_ship_to_list(ship_name: String, color: Color) -> void:
	var label = Label.new()
	label.text = ship_name
	label.modulate = color
	ship_list.add_child(label)
