extends Node

const AssetLoader = preload("res://scripts/utils/AssetLoader.gd")

## Generates a demo game state with 5 races, random systems, colonized planets, and turn 50.
func generate_demo_state() -> void:
	print("DemoManager: Generating demo game state...")
	
	# Clear existing data
	_clear_existing_data()
	
	# Generate galaxy
	_generate_galaxy()
	
	# Create empires
	_create_empires()
	
	# Assign home systems and colonize planets
	_assign_home_systems_and_colonies()
	
	# Set turn to 50
	TurnManager.current_turn = 50
	
	# Initialize diplomacy
	EmpireManager.initialize_diplomacy()
	
	print("DemoManager: Demo game state generated successfully.")

func _clear_existing_data() -> void:
	GalaxyManager.star_systems.clear()
	EmpireManager.empires.clear()
	ColonyManager.colonies.clear()
	PlayerManager.player_empire.owned_ships.clear()
	AIManager.owned_ships.clear()
	TurnManager.current_turn = 1

func _generate_galaxy() -> void:
	var galaxy_builder = GalaxyBuilder.new()
	var systems_data = galaxy_builder.build_galaxy(50)  # 50 systems

	# Initialize system name generator
	var name_data = AssetLoader.load_resource("res://gamedata/systems/system_names.tres")
	var system_name_generator = SystemNameGenerator.new(name_data)

	for system_id in systems_data:
		var system_data = systems_data[system_id]
		var star_system = StarSystem.new()
		star_system.id = system_id
		star_system.display_name = system_name_generator.generate_unique_name()
		star_system.position = system_data.position
		
		# Generate celestial bodies
		var celestial_generator = CelestialBodyGenerator.new()
		star_system.celestial_bodies = celestial_generator.generate_celestial_bodies(system_data.num_celestials, system_id)
		
		GalaxyManager.star_systems[system_id] = star_system

func _create_empires() -> void:
	var races = ["Humans", "Silicoids", "Mrrshan", "Psilons", "Alkari"]
	var colors = [Color.BLUE, Color.RED, Color.GREEN, Color.YELLOW, Color.PURPLE]
	
	for i in range(5):
		var empire = Empire.new()
		empire.id = "empire_%d" % i
		empire.display_name = "%s Empire" % races[i]
		empire.color = colors[i]
		empire.is_ai_controlled = (i > 0)  # First is player, rest are AI
		
		EmpireManager.register_empire(empire)

func _assign_home_systems_and_colonies() -> void:
	var system_ids = GalaxyManager.star_systems.keys()
	system_ids.shuffle()
	
	var empire_ids = EmpireManager.empires.keys()
	
	for i in range(min(5, empire_ids.size())):
		var empire_id = empire_ids[i]
		var empire = EmpireManager.empires[empire_id]
		
		# Assign home system
		var home_system_id = system_ids[i]
		var home_system = GalaxyManager.star_systems[home_system_id]
		
		# Find a habitable planet in the home system
		var habitable_planet = null
		for body in home_system.celestial_bodies:
			if body is PlanetData and body.body_type == "terrestrial":
				habitable_planet = body
				break
		
		if habitable_planet:
			# Colonize the planet
			ColonyManager.establish_colony(habitable_planet, empire, 10)  # 10 starting population
			
			# Add some additional colonies
			_colonize_additional_planets(empire, 3)  # 3 additional colonies per empire

func _colonize_additional_planets(empire: Empire, num_colonies: int) -> void:
	var available_systems = []
	for system_id in GalaxyManager.star_systems:
		var system = GalaxyManager.star_systems[system_id]
		var has_habitable_planet = false
		for body in system.celestial_bodies:
			if body is PlanetData and body.body_type == "terrestrial" and body.owner_id == "":
				has_habitable_planet = true
				break
		if has_habitable_planet:
			available_systems.append(system_id)
	
	available_systems.shuffle()
	
	for i in range(min(num_colonies, available_systems.size())):
		var system_id = available_systems[i]
		var system = GalaxyManager.star_systems[system_id]
		
		for body in system.celestial_bodies:
			if body is PlanetData and body.body_type == "terrestrial" and body.owner_id == "":
				ColonyManager.establish_colony(body, empire, randi_range(5, 15))
				break
