extends Control

@onready var colony_name_label: Label = %ColonyNameLabel
@onready var population_label: Label = %PopulationLabel
@onready var system_planet_list: VBoxContainer = %SystemPlanetList
@onready var resource_display: GridContainer = %ResourceDisplay
@onready var pop_allocation_display: VBoxContainer = %PopulationAllocation
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

const RESOURCE_ICONS = {
	"credits": preload("res://assets/icons/resource_credits.png"),
	"food": preload("res://assets/icons/resource_food.png"),
	"production": preload("res://assets/icons/resource_production.png"),
	"research": preload("res://assets/icons/resource_research.png")
}

const JOB_ICONS = {
	"farmer": preload("res://assets/icons/job_farmer.png"),
	"worker": preload("res://assets/icons/job_worker.png"),
	"scientist": preload("res://assets/icons/job_scientist.png")
}

const POP_ICON = preload("res://assets/icons/population.png")


func _ready() -> void:
	if SceneManager.next_scene_context is PlanetData:
		_current_planet = SceneManager.next_scene_context
		_update_all_displays()
	else:
		printerr("ColoniesScreen: No valid PlanetData provided. Returning to starmap.")
		SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
		return

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
	_populate_resource_display()
	_populate_population_display()
	
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
		if planets_in_system.has(i):
			var planet_entry = _planet_list_entry_scene.instantiate()
			system_planet_list.add_child(planet_entry)
			planet_entry.set_planet_data(planets_in_system[i], system.display_name)
		else:
			var spacer = Label.new()
			spacer.text = "Orbital Slot %d - Empty" % (i + 1)
			spacer.custom_minimum_size.y = 36
			system_planet_list.add_child(spacer)

func _populate_resource_display() -> void:
	for c in resource_display.get_children(): c.queue_free()
	# This section is a placeholder for actual resource calculation
	_add_resource_row("credits", 25, 5)
	_add_resource_row("food", 10, 2)
	_add_resource_row("production", 10, 0)
	_add_resource_row("research", 20, 0)
	
func _add_resource_row(type: String, total: int, surplus: int) -> void:
	var icon_rect = TextureRect.new()
	icon_rect.texture = RESOURCE_ICONS[type]
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	resource_display.add_child(icon_rect)
	
	var label = Label.new()
	label.text = "%d (%+d)" % [total, surplus]
	resource_display.add_child(label)

func _populate_population_display() -> void:
	for c in pop_allocation_display.get_children(): c.queue_free()
	
	_add_population_row("farmer", _current_planet.farmers)
	_add_population_row("worker", _current_planet.workers)
	_add_population_row("scientist", _current_planet.scientists)

func _add_population_row(job_type: String, count: int) -> void:
	var hbox = HBoxContainer.new()
	var job_icon = TextureRect.new()
	job_icon.texture = JOB_ICONS[job_type]
	job_icon.custom_minimum_size = Vector2(32, 32)
	job_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	job_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(job_icon)
	
	for i in count:
		var pop_icon_rect = TextureRect.new()
		pop_icon_rect.texture = POP_ICON
		pop_icon_rect.custom_minimum_size = Vector2(24, 32)
		pop_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pop_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(pop_icon_rect)
		
	pop_allocation_display.add_child(hbox)

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()
