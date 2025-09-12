extends Node

## Emitted when the galaxy generation is complete.
signal galaxy_generation_finished

const GALAXY_SIZE_X = 1000.0
const GALAXY_SIZE_Y = 1000.0
const MIN_STAR_DISTANCE = 50.0
const MAX_PLANETS_PER_SYSTEM = 6

var _star_scene = preload("res://scenes/starmap/star.tscn")
var _star_texture = preload("res://assets/images/stars/star_base.png") # Load the base star texture

## Dictionary to hold color tints for different star types.
## Purple: 0 or 6 celestials
## Red: 1 or 5 celestials
## Blue: 2 or 3 celestials
## Yellow: 3, 4, or 5 celestials with increased Terran frequency
const STAR_COLORS = {
	"purple": Color("800080"),  # Purple
	"red": Color("FF0000"),     # Red
	"blue": Color("0000FF"),     # Blue
	"yellow": Color("FFFF00")    # Yellow
}


func build_galaxy(num_stars: int, parent_node: Node) -> Dictionary:
	print("GalaxyBuilder: Starting galaxy generation with %s stars..." % num_stars)
	var systems = {}
	var star_positions = []

	var attempts = 0
	var max_attempts = num_stars * 100 # Prevent infinite loops for dense galaxies

	while systems.size() < num_stars and attempts < max_attempts:
		attempts += 1
		var new_pos = Vector2(
			randf_range(0, GALAXY_SIZE_X),
			randf_range(0, GALAXY_SIZE_Y)
		)

		var too_close = false
		for existing_pos in star_positions:
			if new_pos.distance_to(existing_pos) < MIN_STAR_DISTANCE:
				too_close = true
				break

		if not too_close:
			var system_id = "system_%s" % systems.size()
			
			# Determine number of celestial bodies
			var num_celestials = _determine_num_celestial_bodies()
			
			# Determine star color based on num_celestials
			var star_color = _get_star_color(num_celestials)
			
			var new_star_node = _star_scene.instantiate()
			new_star_node.name = system_id
			new_star_node.position = new_pos
			
			# Create a TextureRect for the star graphic and apply tint
			var star_graphic = TextureRect.new()
			star_graphic.texture = _star_texture
			star_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			star_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			star_graphic.custom_minimum_size = Vector2(32, 32) # Adjust size as needed
			star_graphic.modulate = star_color # Apply the color tint
			star_graphic.pivot_offset = star_graphic.custom_minimum_size / 2.0 # Center pivot for rotation/scaling if desired
			
			new_star_node.add_child(star_graphic)
			star_graphic.set_owner(new_star_node) # Ensure it's saved with the scene

			parent_node.add_child(new_star_node)
			
			# Add StarSystem data to the dictionary
			systems[system_id] = {
				"id": system_id,
				"position": new_pos,
				"celestials": num_celestials, # Store the number of celestials for later use
				"star_color": star_color,    # Store the color for reference
				"planets": [] # This will be populated later
			}
			star_positions.append(new_pos)
			
			print("  -> Created star system %s at %s with %d celestials (color: %s)" % [system_id, new_pos, num_celestials, star_color.to_html(false)])

	if systems.size() < num_stars:
		printerr("GalaxyBuilder: Could not generate %s stars after %s attempts. Generated %s instead." % [num_stars, attempts, systems.size()])
	else:
		print("GalaxyBuilder: Galaxy generation finished with %s stars." % systems.size())
		
	galaxy_generation_finished.emit(systems)
	return systems


func _determine_num_celestial_bodies() -> int:
	# Purple: 0 or 6 (rare) - 5% each
	# Red: 1 or 5 (medium rare) - 10% each
	# Blue: 2 or 3 (more common) - 30% each
	# Yellow: 3, 4, or 5 (mediumly common) - (special handling for yellow to favor terran)

	var rand_roll = randf()

	if rand_roll < 0.05: # 5% for 0 celestials (purple)
		return 0
	elif rand_roll < 0.10: # 5% for 6 celestials (purple)
		return 6
	elif rand_roll < 0.20: # 10% for 1 celestial (red)
		return 1
	elif rand_roll < 0.30: # 10% for 5 celestials (red)
		return 5
	elif rand_roll < 0.60: # 30% for 2 celestials (blue)
		return 2
	elif rand_roll < 0.90: # 30% for 3 celestials (blue/yellow overlap) - handled in _get_star_color
		return 3
	else: # Remaining 10% for 4 celestials (yellow overlap) - handled in _get_star_color
		return 4

func _get_star_color(num_celestials: int) -> Color:
	match num_celestials:
		0, 6:
			return STAR_COLORS.purple
		1, 5: # Note: 5 also overlaps with yellow, but red is rarer, so we prioritize it here.
			return STAR_COLORS.red
		2:
			return STAR_COLORS.blue
		3, 4:
			# For 3 or 4, there's an overlap with blue and yellow.
			# We can make yellow more probable here or add specific logic later for 'terran frequency'.
			# For now, let's make 3 more likely blue, 4 more likely yellow for distinctness.
			if num_celestials == 3:
				if randf() < 0.7: # 70% blue for 3, 30% yellow
					return STAR_COLORS.blue
				else:
					return STAR_COLORS.yellow
			elif num_celestials == 4:
				if randf() < 0.3: # 30% blue for 4, 70% yellow
					return STAR_COLORS.blue
				else:
					return STAR_COLORS.yellow
		_:
			# Fallback for any unexpected number of celestials, or for 5 if not caught by red.
			# We'll make 5 more distinctly yellow here, as red is supposed to be rarer.
			return STAR_COLORS.yellow # If num_celestials is 5 and it somehow reaches here (shouldn't if red is handled first)