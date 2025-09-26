# GalaxyGenerator.gd
# This script generates the entire galaxy, including star systems and their celestial bodies.
# It acts as a coordinator, delegating system layout to GalaxyBuilder and planet/moon generation to CelestialBodyGenerator.
class_name GalaxyGenerator
extends RefCounted

# Instance of GalaxyBuilder for creating the structural layout of star systems.
var galaxy_builder: GalaxyBuilder

# Instance of CelestialBodyGenerator for populating systems with planets, moons, etc.
var celestial_body_generator: CelestialBodyGenerator

# Initializes the generator with required builder instances.
func _init():
	galaxy_builder = GalaxyBuilder.new()
	celestial_body_generator = CelestialBodyGenerator.new()

# Generates an array of star systems for the game galaxy.
# Uses GalaxyBuilder to create system positions and properties, then populates each system with celestial bodies.
# @param num_systems: The desired number of star systems to generate.
# @return: An array of dictionaries, each representing a completed star system with planets.
func generate(num_systems: int) -> Array:
	var systems = []  # Array to hold the generated systems
	var galaxy_data = galaxy_builder.build_galaxy(num_systems)  # Get base system data
	for system_id in galaxy_data:  # Iterate over each system's ID
		var system = galaxy_data[system_id]  # Retrieve system dictionary
		var planets = celestial_body_generator.generate_bodies_for_system(system.num_celestials)  # Generate planets/moons
		system["planets"] = planets  # Add the generated bodies to the system data
		systems.append(system)  # Collect the completed system
	return systems  # Return the array of systems for the galaxy
