# /scripts/managers/galaxymanager.gd
extends Node

@export var number_of_systems: int = 10
@export var galaxy_radius: float = 800.0
@export var min_system_distance: float = 150.0

var star_systems: Dictionary = {}
var _system_name_generator: SystemNameGenerator
var _celestial_body_generator: CelestialBodyGenerator # Add this line

func _ready() -> void:
	var name_data = load("res://gamedata/systems/system_name_data.tres")
	_system_name_generator = SystemNameGenerator.new(name_data)
	_celestial_body_generator = CelestialBodyGenerator.new() # Add this line
	
	generate_procedural_galaxy()

func generate_procedural_galaxy() -> void:
	print("GalaxyManager: Procedurally generating galaxy...")
	star_systems.clear()

	# 1. Always create the player's home system at the center.
	var sol = StarSystem.new()
	sol.id = "sol"
	sol.display_name = "Sol"
	sol.position = Vector2.ZERO
	# For the demo, give Sol a guaranteed Terran planet.
	var terran_planet = PlanetData.new()
	terran_planet.planet_type = PlanetData.PlanetType.TERRAN
	terran_planet.orbital_slot = 2 # Let's say it's the 3rd rock from the sun
	sol.celestial_bodies.append(terran_planet)
	star_systems[sol.id] = sol
	_system_name_generator.add_used_name(sol.display_name)

	# 2. Generate the rest of the systems randomly.
	for i in range(number_of_systems):
		var new_system = StarSystem.new()
		var system_id = "system_%s" % i
		new_system.id = system_id
		new_system.display_name = _system_name_generator.generate_unique_name()
		new_system.position = Vector2(randf_range(-galaxy_radius, galaxy_radius), randf_range(-galaxy_radius, galaxy_radius))
		
		# --- Use the new generator to add planets ---
		new_system.celestial_bodies = _celestial_body_generator.generate_bodies_for_system()
		
		star_systems[new_system.id] = new_system
	
	print("GalaxyManager: Generation complete. Created %s systems." % star_systems.size())
