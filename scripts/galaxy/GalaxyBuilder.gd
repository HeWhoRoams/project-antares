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

func _determine_num_celestial_bodies() -> int:
	var rand_roll = randf()
	if rand_roll < 0.05: return 0
	elif rand_roll < 0.10: return 6
	elif rand_roll < 0.20: return 1
	elif rand_roll < 0.30: return 5
	elif rand_roll < 0.60: return 2
	elif rand_roll < 0.90: return 3
	else: return 4