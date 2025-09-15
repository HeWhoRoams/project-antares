# /scripts/managers/galaxymanager.gd
extends Node

@export var number_of_systems: int = 20

# ADDED: Re-introducing the constants needed for positioning.
const GALAXY_SIZE_X = 1000.0
const GALAXY_SIZE_Y = 1000.0

var star_systems: Dictionary = {}
var _celestial_body_generator: CelestialBodyGenerator
var _galaxy_builder: GalaxyBuilder
var _system_name_generator: SystemNameGenerator

const STAR_COLORS = {
	"purple": Color(0.6, 0.2, 0.8),
	"red": Color(1.0, 0.3, 0.3),
	"blue": Color(0.5, 0.7, 1.0),
	"yellow": Color(1.0, 1.0, 0.6)
}

func _ready() -> void:
	_celestial_body_generator = CelestialBodyGenerator.new()
	var name_data = load("res://gamedata/systems/system_names.tres")
	_system_name_generator = SystemNameGenerator.new(name_data)
	
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		generate_procedural_galaxy()

func generate_procedural_galaxy() -> void:
	print("GalaxyManager: Generating galaxy...")
	star_systems.clear()

	# Create the player's home system with specific properties
	var sol = StarSystem.new()
	sol.id = "sol"
	sol.display_name = "Sol"
	sol.position = Vector2.ZERO
	var home_planet = PlanetData.new()
	home_planet.planet_type = PlanetData.PlanetType.TERRAN
	home_planet.size = PlanetData.PlanetSize.L
	home_planet.max_population = 16
	home_planet.orbital_slot = 2 # 3rd rock from the sun
	sol.celestial_bodies.append(home_planet)
	star_systems[sol.id] = sol
	_system_name_generator.add_used_name(sol.display_name)
	
	# Create a guaranteed home system for the AI faction
	var sirius = StarSystem.new()
	sirius.id = "sirius"
	sirius.display_name = "Sirius"
	sirius.position = Vector2(GALAXY_SIZE_X * 0.75, GALAXY_SIZE_Y * 0.5)
	sirius.celestial_bodies = _celestial_body_generator.generate_bodies_for_system(4) # Give AI a decent system
	star_systems[sirius.id] = sirius
	_system_name_generator.add_used_name(sirius.display_name)
	
	# Procedurally generate the rest
	var GalaxyBuilderScript = load("res://scripts/galaxy/GalaxyBuilder.gd")
	if GalaxyBuilderScript:
		_galaxy_builder = GalaxyBuilderScript.new()
		var procedural_systems = _galaxy_builder.build_galaxy(number_of_systems - 2)
		for system_id in procedural_systems:
			var system_data = procedural_systems[system_id]
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
	else:
		if num_celestials == 3 and randf() < 0.7:
			return STAR_COLORS.blue
		return STAR_COLORS.yellow

func _on_save_data_loaded(data: Dictionary) -> void:
	# This function will need to be updated to handle the new resource properties
	pass
