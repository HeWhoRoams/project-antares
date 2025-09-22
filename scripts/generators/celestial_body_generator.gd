# /scripts/generators/celestial_body_generator.gd
class_name CelestialBodyGenerator
extends RefCounted

const MAX_ORBITAL_SLOTS = 7
const BASE_PLANET_CHANCE = 0.85
const PLANET_CHANCE_DECAY = 0.20
const MOON_CHANCE_WEIGHTS = { 0: 50, 1: 40, 2: 8, 3: 2 }
const PLANET_SPECIALS_WEIGHTS = {
	"none": 80,
	"natives": 5,
	"artifacts": 5,
	"crashed_ship": 5,
	"hostile_fauna": 3,
	"thriving_fauna": 1,
	"native_animals": 1
}

var _weighted_moon_count_array: Array

func _init():
	_weighted_moon_count_array = _create_weighted_array(MOON_CHANCE_WEIGHTS)

func _create_weighted_array(weights: Dictionary) -> Array:
	var array: Array = []
	for key in weights:
		for _i in range(weights[key]):
			array.append(key)
	return array

func _weighted_pick(options: Array, weights: Array) -> Variant:
	var total_weight = 0
	for w in weights:
		total_weight += w
	var roll = randf() * total_weight
	var cumulative = 0
	for i in range(options.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return options[i]
	return options.back()

func generate_bodies_for_system(num_bodies_to_generate: int, star_color: String = "") -> Array[CelestialBodyData]:
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
			_generate_planet_attributes(new_planet, star_color)
			bodies.append(new_planet)
			planet_count += 1
		else:
			var new_body = CelestialBodyData.new()
			new_body.orbital_slot = slot
			new_body.body_type = [CelestialBodyData.BodyType.ASTEROID_BELT, CelestialBodyData.BodyType.GAS_GIANT].pick_random()
			bodies.append(new_body)
			
	return bodies

func _generate_planet_attributes(planet: PlanetData, star_color: String = "") -> void:
	# Assign a random type, size, and other attributes
	if star_color == "yellow":
		# Yellow Star rule: increase probability of TERRAN
		var types = PlanetData.PlanetType.values()
		var weights = []
		for type in types:
			if type == PlanetData.PlanetType.TERRAN:
				weights.append(3)  # Higher weight for TERRAN
			else:
				weights.append(1)
		planet.planet_type = _weighted_pick(types, weights)
	else:
		planet.planet_type = PlanetData.PlanetType.values().pick_random()
	planet.mineral_richness = PlanetData.MineralRichness.values().pick_random()
	planet.gravity = PlanetData.Gravity.values().pick_random()
	# Generate moons based on planet size
	var moon_weights = MOON_CHANCE_WEIGHTS.duplicate()
	match planet.planet_size:
		PlanetData.PlanetSize.XS:
			moon_weights = {0: 90, 1: 10}
		PlanetData.PlanetSize.S:
			moon_weights = {0: 70, 1: 25, 2: 5}
		PlanetData.PlanetSize.M:
			moon_weights = {0: 50, 1: 35, 2: 10, 3: 5}
		PlanetData.PlanetSize.L:
			moon_weights = {0: 30, 1: 30, 2: 25, 3: 15}
		PlanetData.PlanetSize.XL:
			moon_weights = {0: 20, 1: 25, 2: 30, 3: 25}
	var moon_array = _create_weighted_array(moon_weights)
	planet.moons = moon_array.pick_random()
	
	# Assign size and corresponding max population
	var size_roll = randf()
	if size_roll < 0.1: # 10% chance
		planet.planet_size = PlanetData.PlanetSize.XS
		planet.max_population = 5
	elif size_roll < 0.25: # 15% chance
		planet.planet_size = PlanetData.PlanetSize.S
		planet.max_population = 8
	elif size_roll < 0.75: # 50% chance
		planet.planet_size = PlanetData.PlanetSize.M
		planet.max_population = 12
	elif size_roll < 0.9: # 15% chance
		planet.planet_size = PlanetData.PlanetSize.L
		planet.max_population = 16
	else: # 10% chance
		planet.planet_size = PlanetData.PlanetSize.XL
		planet.max_population = 20

	# 1% chance of being an "Abandoned" world
	if randf() < 0.01:
		planet.is_abandoned = true
		planet.has_artifacts = true
		planet.has_crashed_ship = true
		planet.mineral_richness = PlanetData.MineralRichness.VERY_LOW
		return

	# Generate planet specials using weighted table
	var special = _weighted_pick(PLANET_SPECIALS_WEIGHTS.keys(), PLANET_SPECIALS_WEIGHTS.values())
	match special:
		"natives":
			planet.has_natives = true
		"artifacts":
			planet.has_artifacts = true
		"crashed_ship":
			planet.has_crashed_ship = true
		"hostile_fauna":
			planet.has_hostile_fauna = true
		"thriving_fauna":
			planet.has_thriving_fauna = true
		"native_animals":
			planet.has_native_animals = true
		"none":
			pass

func generate_body_from_type(body_type: String) -> CelestialBodyData:
	if body_type == "terrestrial":
		var planet = PlanetData.new()
		_generate_planet_attributes(planet)
		return planet
	else:
		var body = CelestialBodyData.new()
		var body_type_enum = CelestialBodyData.BodyType.get(body_type.to_upper())
		if body_type_enum != null:
			body.body_type = body_type_enum
		else:
			body.body_type = CelestialBodyData.BodyType.PLANET  # Default fallback
		return body
