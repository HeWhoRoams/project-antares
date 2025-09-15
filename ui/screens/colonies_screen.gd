extends Control

@onready var colony_list_tree: Tree = %ColonyList
@onready var planet_details_label: Label = %PlanetDetailsLabel
@onready var population_output_label: Label = %PopulationOutputLabel
@onready var mini_starmap_label: Label = %MiniStarmapLabel
@onready var global_variables_label: Label = %GlobalVariablesLabel
@onready var construction_label: Label = %ConstructionLabel
@onready var construction_progress: ProgressBar = %ConstructionProgress
@onready var surface_background: TextureRect = %Background
@onready var buildings_container: Control = %BuildingsContainer
@onready var pop_allocation_display: GridContainer = %PopulationAllocation

var _current_planet: PlanetData

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

func _update_all_displays() -> void:
	if not is_instance_valid(_current_planet):
		return
	
	colony_name_label.text = "Colony of %s" % _current_planet.display_name
	population_label.text = "Pop %d / %d" % [_current_planet.current_population, _current_planet.max_population]
	
	var temp_label = Label.new()
	temp_label.text = "List of planets in system"
	system_planet_list.add_child(temp_label)
	
	temp_label = Label.new()
	temp_label.text = "Resource icons and numbers"
	resource_display.add_child(temp_label)
	
	_update_population_display()
		
	construction_label.text = "Building: Hydroponics Farm"
	construction_progress.value = 30
	
	surface_background.texture = SURFACE_BACKGROUNDS.get(_current_planet.planet_type)
	
	temp_label = Label.new()
	temp_label.text = "Constructed building sprites go here"
	temp_label.position = Vector2(100, 100)
	buildings_container.add_child(temp_label)

func _update_population_display() -> void:
	for child in pop_allocation_display.get_children():
		child.queue_free()
	
	var pop_icon = ResourceLoader.load("res://assets/icons/population.png")
	if not pop_icon:
		printerr("ColoniesScreen: Could not load population icon at 'res://assets/icons/population.png'.")
		return

	var farmer_label = Label.new()
	farmer_label.text = "Farmers:"
	pop_allocation_display.add_child(farmer_label)
	for i in _current_planet.farmers:
		var icon = TextureRect.new()
		icon.texture = pop_icon
		pop_allocation_display.add_child(icon)
	
	var worker_label = Label.new()
	worker_label.text = "Workers:"
	pop_allocation_display.add_child(worker_label)
	for i in _current_planet.workers:
		var icon = TextureRect.new()
		icon.texture = pop_icon
		pop_allocation_display.add_child(icon)
		
	var scientist_label = Label.new()
	scientist_label.text = "Scientists:"
	pop_allocation_display.add_child(scientist_label)
	for i in _current_planet.scientists:
		var icon = TextureRect.new()
		icon.texture = pop_icon
		pop_allocation_display.add_child(icon)

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()