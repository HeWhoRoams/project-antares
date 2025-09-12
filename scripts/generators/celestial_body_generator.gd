# /scripts/generators/celestial_body_generator.gd
class_name CelestialBodyGenerator
extends RefCounted

# --- Configuration ---
const BODY_COUNT_WEIGHTS = { 0: 5, 1: 15, 2: 25, 3: 25, 4: 15, 5: 10, 6: 5 }
const BASE_PLANET_CHANCE = 0.85
const PLANET_CHANCE_DECAY = 0.20
const MOON_CHANCE_WEIGHTS = { 0: 50, 1: 40, 2: 8, 3: 2 }

var _weighted_body_count_array: Array
var _weighted_moon_count_array: Array

func _init():
	_weighted_body_count_array = _create_weighted_array(BODY_COUNT_WEIGHTS)
	_weighted_moon_count_array = _create_weighted_array(MOON_CHANCE_WEIGHTS)

# Helper to create weighted arrays for random selection.
func _create_weighted_array(weights: Dictionary) -> Array:
	var array: Array = []
	for key in weights:
		for _i in range(weights[key]):
			array.append(key)
	return array

# --- Public API ---
func generate_bodies_for_system() -> Array[CelestialBodyData]:
	var bodies: Array[CelestialBodyData] = []
	var planet_count = 0
	var num_bodies_to_generate = _weighted_body_count_array.pick_random()

	for i in range(num_bodies_to_generate):
		var current_planet_chance = BASE_PLANET_CHANCE - (planet_count * PLANET_CHANCE_DECAY)
		
		if randf() < current_planet_chance:
			# It's a planet!
			var new_planet = PlanetData.new()
			new_planet.orbital_slot = i
			_generate_planet_attributes(new_planet) # Assign its unique attributes
			bodies.append(new_planet)
			planet_count += 1
		else:
			# Not a planet, so it's a Gas Giant or Asteroid Belt.
			var new_body = CelestialBodyData.new()
			new_body.orbital_slot = i
			new_body.body_type = [CelestialBodyData.BodyType.ASTEROID_BELT, CelestialBodyData.BodyType.GAS_GIANT].pick_random()
			bodies.append(new_body)
			
	return bodies

# --- Private Helper for Planet Generation ---
func _generate_planet_attributes(planet: PlanetData) -> void:
	# Assign a random type
	planet.planet_type = PlanetData.PlanetType.values().pick_random()

	# Assign mineral richness and gravity
	planet.mineral_richness = PlanetData.MineralRichness.values().pick_random()
	planet.gravity = PlanetData.Gravity.values().pick_random()
	
	# Assign moons based on weighted chance
	planet.moons = _weighted_moon_count_array.pick_random()

	# 1% chance of being an "Abandoned" world
	if randf() < 0.01:
		planet.is_abandoned = true
		planet.has_artifacts = true
		planet.has_crashed_ship = true
		planet.mineral_richness = PlanetData.MineralRichness.VERY_LOW
		return # Abandoned worlds don't have other special features

	# Add other random features (e.g., 5% chance for each)
	if randf() < 0.05: planet.has_natives = true
	if randf() < 0.05: planet.has_artifacts = true
	if randf() < 0.05: planet.has_crashed_ship = true
	
	var fauna_roll = randf()
	if fauna_roll < 0.10: # 10% chance
		planet.has_hostile_fauna = true
	elif fauna_roll < 0.25: # 15% chance
		planet.has_thriving_fauna = true
	elif fauna_roll < 0.40: # 15% chance
		planet.has_native_animals = true
