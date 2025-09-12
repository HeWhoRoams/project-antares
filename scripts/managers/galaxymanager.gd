# /scripts/managers/galaxymanager.gd
extends Node

@export var number_of_systems: int = 20

var star_systems: Dictionary = {}
# Note: The generators are no longer needed here as the Builder handles them.
# We will keep the celestial_body_generator for now to handle planets within systems.
var _celestial_body_generator: CelestialBodyGenerator

# NEW: A reference to our galaxy builder script.
var _galaxy_builder: GalaxyBuilder

func _ready() -> void:
	# The builder is now responsible for creating the galaxy layout
	_galaxy_builder = GalaxyBuilder.new()
	
	# We still need this for populating the systems with planets later.
	_celestial_body_generator = CelestialBodyGenerator.new()
	
	generate_procedural_galaxy()

func generate_procedural_galaxy() -> void:
	print("GalaxyManager: Handing off to GalaxyBuilder...")
	star_systems.clear()
	
	# The builder now creates the star systems and returns the data.
	# We pass 'get_tree().current_scene' so the builder knows where to draw the stars.
	star_systems = _galaxy_builder.build_galaxy(number_of_systems, get_tree().current_scene)
	
	# After building, we can populate the systems with planets.
	_populate_systems_with_planets()

func _populate_systems_with_planets() -> void:
	for system_data in star_systems.values():
		# The builder determined the number of bodies and color.
		# Now we use the celestial_body_generator to create the actual planet data.
		system_data["planets"] = _celestial_body_generator.generate_bodies_for_system(system_data.num_celestials)
	
	print("GalaxyManager: All systems populated with celestial bodies.")