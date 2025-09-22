# /scripts/galaxy/GalaxyGenerator.gd
class_name GalaxyGenerator
extends RefCounted

var galaxy_builder: GalaxyBuilder
var celestial_body_generator: CelestialBodyGenerator

func _init():
	galaxy_builder = GalaxyBuilder.new()
	celestial_body_generator = CelestialBodyGenerator.new()

func generate(num_systems: int) -> Array:
	var systems = []
	var galaxy_data = galaxy_builder.build_galaxy(num_systems)
	for system_id in galaxy_data:
		var system = galaxy_data[system_id]
		var planets = celestial_body_generator.generate_bodies_for_system(system.num_celestials)
		system["planets"] = planets
		systems.append(system)
	return systems
