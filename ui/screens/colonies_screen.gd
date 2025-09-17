extends Control

@onready var colony_name_label: Label = %ColonyNameLabel
@onready var population_label: Label = %PopulationLabel
@onready var system_planet_list: VBoxContainer = %SystemPlanetList
@onready var center_grid: GridContainer = %CenterGrid
@onready var construction_display: PanelContainer = %ConstructionDisplay
@onready var construction_label: Label = %ConstructionLabel
@onready var construction_progress: ProgressBar = %ConstructionProgress
@onready var surface_background: TextureRect = %Background
@onready var buildings_container: Control = %BuildingsContainer

var _current_planet: PlanetData
var _planet_list_entry_scene = preload("res://ui/components/system_planet_list_entry.tscn")

const ROMAN_NUMERALS = ["I", "II", "III", "IV", "V", "VI", "VII"]

const SURFACE_BACKGROUNDS = {
	PlanetData.PlanetType.TERRAN: preload("res://assets/images/planet_surfaces/terran_surface.png"),
	PlanetData.PlanetType.DESERT: preload("res://assets/images/planet_surfaces/desert_surface.png"),
}

func _ready() -> void:
	if SceneManager.next_scene_context is PlanetData:
		_current_planet = SceneManager.next_scene_context
		_update_all_displays()
	else:
		printerr("ColoniesScreen: No valid PlanetData provided. Returning to starmap.")
		SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
		return

	# This coroutine will wait for the layout to calculate its height, then force the width to match.
	_make_construction_panel_square()

func _make_construction_panel_square() -> void:
	# Wait for the end of the frame so control nodes have their final sizes calculated.
	await get_tree().process_frame
	var height = construction_display.size.y
	construction_display.custom_minimum_size.x = height

func _update_all_displays() -> void:
	if not is_instance_valid(_current_planet):
		return
	
	var home_system = GalaxyManager.star_systems.get(_current_planet.system_id)
	
	var roman_numeral = ""
	if _current_planet.orbital_slot < ROMAN_NUMERALS.size():
		roman_numeral = ROMAN_NUMERALS[_current_planet.orbital_slot]
	var full_planet_name = "%s %s" % [home_system.display_name, roman_numeral]
	
	colony_name_label.text = "Colony of %s" % full_planet_name
	population_label.text = "Pop %d / %d" % [_current_planet.current_population, _current_planet.max_population]
	
	_populate_system_planet_list(home_system)
	_populate_center_grid()
	
	construction_label.text = "Building: Hydroponics Farm"
	construction_progress.value = 30
	surface_background.texture = SURFACE_BACKGROUNDS.get(_current_planet.planet_type)

func _populate_system_planet_list(system: StarSystem) -> void:
	for child in system_planet_list.get_children():
		child.queue_free()
	
	var planets_in_system: Dictionary = {}
	for body in system.celestial_bodies:
		if body is PlanetData:
			planets_in_system[body.orbital_slot] = body
			
	for i in range(6):
		var list_entry_panel = PanelContainer.new()
		# We make this panel transparent so it just acts as a container for the entry
		list_entry_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		system_planet_list.add_child(list_entry_panel)

		if planets_in_system.has(i):
			var planet_entry = _planet_list_entry_scene.instantiate()
			list_entry_panel.add_child(planet_entry)
			planet_entry.set_planet_data(planets_in_system[i], system.display_name)
		else:
			var spacer = Control.new()
			spacer.custom_minimum_size.y = 36 # approx height of an entry
			list_entry_panel.add_child(spacer)

func _populate_center_grid() -> void:
	for child in center_grid.get_children():
		child.queue_free()

	var panel_style = get_theme_stylebox("panel", "PanelContainer")
	
	var data = [
		"Credits: %d (+%d)" % [PlayerManager.player_empire.treasury, PlayerManager.player_empire.income_per_turn],
		"Farmers: %d" % _current_planet.farmers,
		"Food: TODO",
		"Workers: %d" % _current_planet.workers,
		"Production: TODO",
		"Scientists: %d" % _current_planet.scientists,
		"Research: TODO",
		"Total Pop: %d" % _current_planet.current_population
	]
	
	for text in data:
		var cell_panel = PanelContainer.new()
		cell_panel.add_theme_stylebox_override("panel", panel_style)
		
		var label = Label.new()
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		cell_panel.add_child(label)
		center_grid.add_child(cell_panel)

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()