# /scripts/galaxy/GalaxyBuilder.gd
class_name GalaxyBuilder
extends RefCounted

const GALAXY_SIZE_X = 1000.0
const GALAXY_SIZE_Y = 1000.0
const MIN_STAR_DISTANCE = 50.0

func build_galaxy(num_stars: int) -> Dictionary:
	var systems = {}
	var star_positions = []
	var attempts = 0
	var max_attempts = num_stars * 100

	while systems.size() < num_stars and attempts < max_attempts:
		attempts += 1
		var new_pos = Vector2(randf_range(0, GALAXY_SIZE_X), randf_range(0, GALAXY_SIZE_Y))
		var too_close = false
		for existing_pos in star_positions:
			if new_pos.distance_to(existing_pos) < MIN_STAR_DISTANCE:
				too_close = true
				break

		if not too_close:
			var system_id = "system_%s" % systems.size()
			var num_celestials = _determine_num_celestial_bodies()

			systems[system_id] = {
				"id": system_id,
				"position": new_pos,
				"num_celestials": num_celestials
			}
			star_positions.append(new_pos)

	return systems

func generate_galaxy_features() -> Dictionary:
	var features = {
		"nebulae": [],
		"black_holes": [],
		"wormholes": []
	}

	# Generate nebulae (5-10% of galaxy area)
	var num_nebulae = randi_range(max(1, int(GALAXY_SIZE_X * GALAXY_SIZE_Y * 0.0005)), max(1, int(GALAXY_SIZE_X * GALAXY_SIZE_Y * 0.001)))
	for i in range(num_nebulae):
		var nebula = CelestialBodyData.new()
		nebula.body_type = CelestialBodyData.BodyType.NEBULA
		nebula.position = Vector2(randf_range(0, GALAXY_SIZE_X), randf_range(0, GALAXY_SIZE_Y))
		nebula.size = randf_range(50, 150)  # Nebula size
		features.nebulae.append(nebula)

	# Generate black holes (rare, 0.5-1% chance per 100x100 area)
	var num_black_holes = randi_range(0, max(1, int(GALAXY_SIZE_X * GALAXY_SIZE_Y * 0.00001)))
	for i in range(num_black_holes):
		var black_hole = CelestialBodyData.new()
		black_hole.body_type = CelestialBodyData.BodyType.BLACK_HOLE
		black_hole.position = Vector2(randf_range(0, GALAXY_SIZE_X), randf_range(0, GALAXY_SIZE_Y))
		black_hole.size = randf_range(10, 30)  # Event horizon size
		features.black_holes.append(black_hole)

	# Generate wormholes (very rare, 0.1-0.2% chance per 100x100 area)
	var num_wormholes = randi_range(0, max(1, int(GALAXY_SIZE_X * GALAXY_SIZE_Y * 0.000002)))
	for i in range(num_wormholes):
		var wormhole = CelestialBodyData.new()
		wormhole.body_type = CelestialBodyData.BodyType.WORMHOLE
		wormhole.position = Vector2(randf_range(0, GALAXY_SIZE_X), randf_range(0, GALAXY_SIZE_Y))
		wormhole.size = randf_range(5, 15)  # Wormhole size
		# Wormholes connect two points
		wormhole.exit_position = Vector2(randf_range(0, GALAXY_SIZE_X), randf_range(0, GALAXY_SIZE_Y))
		features.wormholes.append(wormhole)

	return features

func _determine_num_celestial_bodies() -> int:
	var rand_roll = randf()
	if rand_roll < 0.05: return 0
	elif rand_roll < 0.10: return 6
	elif rand_roll < 0.20: return 1
	elif rand_roll < 0.30: return 5
	elif rand_roll < 0.60: return 2
	elif rand_roll < 0.90: return 3
	else: return 4
