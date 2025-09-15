# /scripts/generators/celestial_body_generator.gd
class_name CelestialBodyGenerator
extends RefCounted

const MAX_ORBITAL_SLOTS = 7
const BASE_PLANET_CHANCE = 0.85
const PLANET_CHANCE_DECAY = 0.20
const MOON_CHANCE_WEIGHTS = { 0: 50, 1: 40, 2: 8, 3: 2 }

var _weighted_moon_count_array: Array

func _init():
	_weighted_moon_count_array = _create_weighted_array(MOON_CHANCE_WEIGHTS)

func _create_weighted_array(weights: Dictionary) -> Array:
	var array: Array = []
	for key in weights:
		for _i in range(weights[key]):
			array.append(key)
	return array

func generate_bodies_for_system(num_bodies_to_generate: int) -> Array[CelestialBodyData]:
	var bodies: Array[CelestialBodyData] = []
	var available_slots = range(MAX_ORBITAL_SLOTS)
	available_slots.shuffle()
	
	var planet_count = 0
	
	for i in range(min(num_bodies_to_generate, MAX_ORBITAL_SLOTS)):
		var slot = available_slots[i]
		var current_planet_chance = BASE_PLANET_CHANCE - (planet_count * PLANET_CHANCE_DECAY)
		
		if randf() < current_planet_chance:
			var new_planet = PlanetData.new()
			new_planet.orbital_slot = slot
			_generate_planet_attributes(new_planet)
			bodies.append(new_planet)
			planet_count += 1
		else:
			var new_body = CelestialBodyData.new()
			new_body.orbital_slot = slot
			new_body.body_type = [CelestialBodyData.BodyType.ASTEROID_BELT, CelestialBodyData.BodyType.GAS_GIANT].pick_random()
			bodies.append(new_body)
			
	return bodies

func _generate_planet_attributes(planet: PlanetData) -> void:
	# Assign a random type, size, and other attributes
	planet.planet_type = PlanetData.PlanetType.values().pick_random()
	planet.mineral_richness = PlanetData.MineralRichness.values().pick_random()
	planet.gravity = PlanetData.Gravity.values().pick_random()
	planet.moons = _weighted_moon_count_array.pick_random()
	
	# Assign size and corresponding max population
	var size_roll = randf()
	if size_roll < 0.1: # 10% chance
		planet.size = PlanetData.PlanetSize.XS
		planet.max_population = 5
	elif size_roll < 0.25: # 15% chance
		planet.size = PlanetData.PlanetSize.S
		planet.max_population = 8
	elif size_roll < 0.75: # 50% chance
		planet.size = PlanetData.PlanetSize.M
		planet.max_population = 12
	elif size_roll < 0.9: # 15% chance
		planet.size = PlanetData.PlanetSize.L
		planet.max_population = 16
	else: # 10% chance
		planet.size = PlanetData.PlanetSize.XL
		planet.max_population = 20

	# 1% chance of being an "Abandoned" world
	if randf() < 0.01:
		planet.is_abandoned = true
		planet.has_artifacts = true
		planet.has_crashed_ship = true
		planet.mineral_richness = PlanetData.MineralRichness.VERY_LOW
		return

	if randf() < 0.05: planet.has_natives = true
	if randf() < 0.05: planet.has_artifacts = true
	if randf() < 0.05: planet.has_crashed_ship = true
	
	var fauna_roll = randf()
	if fauna_roll < 0.10:
		planet.has_hostile_fauna = true
	elif fauna_roll < 0.25:
		planet.has_thriving_fauna = true
	elif fauna_roll < 0.40:
		planet.has_native_animals = true