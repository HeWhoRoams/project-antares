# /scripts/managers/GalaxyManager.gd
# A global singleton to generate and manage the galaxy state.
extends Node

## A dictionary of all StarSystem resources, keyed by their ID.
var star_systems: Dictionary = {}

func _ready() -> void:
	# For the MVP, we'll generate a simple, hardcoded galaxy.
	# Later, this can be replaced with a procedural generator.
	generate_galaxy()

func generate_galaxy() -> void:
	print("GalaxyManager: Generating galaxy...")
	
	var sol = StarSystem.new()
	sol.id = "sol"
	sol.display_name = "Sol"
	sol.position = Vector2(0, 0)
	star_systems[sol.id] = sol

	var alpha_centauri = StarSystem.new()
	alpha_centauri.id = "alpha_centauri"
	alpha_centauri.display_name = "Alpha Centauri"
	alpha_centauri.position = Vector2(80, 120)
	star_systems[alpha_centauri.id] = alpha_centauri
	
	var sirius = StarSystem.new()
	sirius.id = "sirius"
	sirius.display_name = "Sirius"
	sirius.position = Vector2(-100, 50)
	star_systems[sirius.id] = sirius
	
	print("GalaxyManager: Generation complete. Found %s systems." % star_systems.size())