extends Control

# References to UI sections
@onready var colony_name_label: Label = %ColonyNameLabel
@onready var population_label: Label = %PopulationLabel
@onready var system_planet_list: VBoxContainer = %SystemPlanetList
@onready var resource_display: GridContainer = %ResourceDisplay
@onready var pop_allocation_display: GridContainer = %PopulationAllocation
@onready var construction_label: Label = %ConstructionLabel
@onready var construction_progress: ProgressBar = %ConstructionProgress
@onready var surface_background: TextureRect = %Background
@onready var buildings_container: Control = %BuildingsContainer

# The PlanetData resource for the currently viewed colony
var _current_planet: PlanetData

# Preload textures for backgrounds
const SURFACE_BACKGROUNDS = {
	PlanetData.PlanetType.TERRAN: preload("res://assets/images/planet_surfaces/terran_surface.png"),
	PlanetData.PlanetType.DESERT: preload("res://assets/images/planet_surfaces/desert_surface.png"),
	# Add other surface backgrounds here
}

func _ready() -> void:
	# Get the planet data that was passed from the previous scene
	if SceneManager.next_scene_context is PlanetData:
		_current_planet = SceneManager.next_scene_context
		_update_all_displays()
	else:
		# Fallback for testing - find the player's first colony
		var player_empire = EmpireManager.get_empire_by_id(&"player_1")
		if player_empire:
			var colonies = ColonyManager._get_colonies_for_empire(player_empire)
			if not colonies.is_empty():
				_current_planet = colonies[0]
				_update_all_displays()
				return
		
		printerr("ColoniesScreen: No valid PlanetData provided or found. Returning to starmap.")
		SceneManager.change_scene("res://scenes/starmap/starmap.tscn")
		return

func _update_all_displays() -> void:
	if not is_instance_valid(_current_planet):
		return
	
	# 1. Update Top Bar
	var home_system = GalaxyManager.star_systems.get(_current_planet.system_id) # We'll need to add system_id to PlanetData
	colony_name_label.text = "Colony of %s" % home_system.display_name
	population_label.text = "Pop %d / %d" % [_current_planet.current_population, _current_planet.max_population]
	
	# 2. Update System Planet List (Placeholder)
	for child in system_planet_list.get_children():
		child.queue_free()
	var temp_label = Label.new()
	temp_label.text = "List of planets in system"
	system_planet_list.add_child(temp_label)
	
	# 3. Update Resource Display (Placeholder)
	for child in resource_display.get_children():
		child.queue_free()
	temp_label = Label.new()
	temp_label.text = "Resource icons and numbers"
	resource_display.add_child(temp_label)
	
	# 4. Update Population Allocation Display
	_update_population_display()
		
	# 5. Update Construction Display (Placeholder)
	construction_label.text = "Building: Hydroponics Farm"
	construction_progress.value = 30
	
	# 6. Update Planet Surface
	surface_background.texture = SURFACE_BACKGROUNDS.get(_current_planet.planet_type)
	for child in buildings_container.get_children():
		child.queue_free()
	temp_label = Label.new()
	temp_label.text = "Constructed building sprites go here"
	temp_label.position = Vector2(100, 100)
	buildings_container.add_child(temp_label)

func _update_population_display() -> void:
	for child in pop_allocation_display.get_children():
		child.queue_free()
	
	var pop_icon = ResourceLoader.load("rres://assets/images/icons/population.png")
	if not pop_icon:
		printerr("ColoniesScreen: Could not load population icon at 'res://assets/images/icons/population.png'.")
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
