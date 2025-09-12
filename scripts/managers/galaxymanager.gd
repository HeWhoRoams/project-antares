# /scripts/managers/galaxymanager.gd
extends Node

@export var number_of_systems: int = 20

var star_systems: Dictionary = {}
var _celestial_body_generator: CelestialBodyGenerator
var _galaxy_builder: GalaxyBuilder
var _system_name_generator: SystemNameGenerator

# Moved from GalaxyBuilder
const STAR_COLORS = {
	"purple": Color(0.6, 0.2, 0.8),
	"red": Color(1.0, 0.3, 0.3),
	"blue": Color(0.5, 0.7, 1.0),
	"yellow": Color(1.0, 1.0, 0.6)
}

func _ready() -> void:
	var GalaxyBuilderScript = load("res://scripts/galaxy/GalaxyBuilder.gd")
	if GalaxyBuilderScript:
		_galaxy_builder = GalaxyBuilderScript.new()
	else:
		printerr("GalaxyManager: Failed to load GalaxyBuilder script!")
		return

	_celestial_body_generator = CelestialBodyGenerator.new()
	
	var name_data = load("res://gamedata/systems/system_names.tres")
	_system_name_generator = SystemNameGenerator.new(name_data)
	
	generate_procedural_galaxy()

func generate_procedural_galaxy() -> void:
	print("GalaxyManager: Generating galaxy...")
	star_systems.clear()

	var system_data_dict = _galaxy_builder.build_galaxy(number_of_systems)
	
	for system_id in system_data_dict:
		var system_data = system_data_dict[system_id]
		
		var new_system = StarSystem.new()
		new_system.id = system_id
		new_system.display_name = _system_name_generator.generate_unique_name()
		new_system.position = system_data.position
		new_system.celestial_bodies = _celestial_body_generator.generate_bodies_for_system(system_data.num_celestials)
		
		star_systems[system_id] = new_system

	print("GalaxyManager: All systems created.")

func get_star_color(num_celestials: int) -> Color:
	if num_celestials == 0 or num_celestials == 6:
		return STAR_COLORS.purple
	elif num_celestials == 1 or num_celestials == 5:
		if num_celestials == 5 and randf() < 0.5:
			return STAR_COLORS.yellow
		return STAR_COLORS.red
	elif num_celestials == 2:
		return STAR_COLORS.blue
	else: # Catches 3 and 4
		if num_celestials == 3 and randf() < 0.7:
			return STAR_COLORS.blue
		return STAR_COLORS.yellow
