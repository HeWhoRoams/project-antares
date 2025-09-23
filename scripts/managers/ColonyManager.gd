# /scripts/managers/ColonyManager.gd
extends Node

var colonies: Dictionary = {}

const BASE_FOOD_PER_FARMER = 2
const BASE_PROD_PER_WORKER = 1
const BASE_RES_PER_SCIENTIST = 1
const POP_CONSUMES_FOOD = 1
const POP_GROWTH_THRESHOLD = 100

# Type hints removed from function arguments to resolve parse error
func establish_colony(planet, empire, starting_pop: int):
	if not is_instance_valid(planet) or not is_instance_valid(empire):
		return null

	planet.owner_id = empire.id

	var new_colony = ColonyData.new()
	new_colony.owner_id = empire.id
	new_colony.system_id = planet.system_id
	new_colony.orbital_slot = planet.orbital_slot
	new_colony.current_population = starting_pop
	new_colony.workers = starting_pop

	var colony_key = "%s_%d" % [planet.system_id, planet.orbital_slot]
	colonies[colony_key] = new_colony

	DebugManager.log_action("Colony established for %s on %s." % [empire.display_name, "a planet"]) # PlanetData has no name yet
	return new_colony

func colonize_planet(planet, empire) -> void:
	# Find and consume a Colony Ship from the empire's fleet
	var colony_ship_found = false
	for ship_id in empire.owned_ships.keys():
		var ship = empire.owned_ships[ship_id]
		if ship.id.begins_with("colony_ship"):  # Assume colony ships have id like "colony_ship_XX"
			empire.owned_ships.erase(ship_id)
			colony_ship_found = true
			break
	if not colony_ship_found:
		print("No colony ship available for colonization.")
		return
	establish_colony(planet, empire, 1)

# Type hint removed from function argument to resolve parse error
func process_turn_for_empire(empire) -> void:
	var all_colonies = _get_colonies_for_empire(empire)
	for planet in all_colonies:
		_process_resource_production(planet)
		_process_population_growth(planet)
		_process_construction(planet)

func _process_resource_production(planet) -> void:
	var colony = colonies.get("%s_%d" % [planet.system_id, planet.orbital_slot])
	if not colony:
		return

	# Calculate food production based on planet modifiers
	var food_production = colony.farmers * planet.food_per_farmer
	colony.food_produced = food_production

	# Calculate production output based on planet modifiers
	var production_output = colony.workers * planet.production_per_worker
	colony.production_produced = production_output

	# Calculate research output based on planet modifiers
	var research_output = colony.scientists * planet.research_per_scientist
	colony.research_produced = research_output

func _process_population_growth(planet) -> void:
	var colony = colonies.get("%s_%d" % [planet.system_id, planet.orbital_slot])
	if not colony:
		return

	var food_consumed = colony.current_population * POP_CONSUMES_FOOD
	var food_surplus = colony.food_produced - food_consumed

	if food_surplus > 0:
		colony.growth_progress += food_surplus
		if colony.growth_progress >= POP_GROWTH_THRESHOLD:
			colony.current_population += 1
			colony.growth_progress = 0
			# Auto-assign new population to workers
			colony.workers += 1

func _process_construction(planet) -> void:
	var colony = colonies.get("%s_%d" % [planet.system_id, planet.orbital_slot])
	if not colony:
		return

	if colony.construction_queue.is_empty():
		return

	var current_item = colony.construction_queue[0]
	current_item.progress += colony.production_produced

	if current_item.progress >= current_item.cost:
		# Item completed
		colony.construction_queue.pop_front()
		# Apply effects (e.g., add building, spawn ship)
		_apply_construction_effect(colony, current_item)

func scrap_building(planet, building) -> void:
	# Find the colony
	var colony = colonies.get("%s_%d" % [planet.system_id, planet.orbital_slot])
	if not colony:
		return

	# Check if the building is constructed (placeholder, assume not tracked yet)
	# For now, return half credits
	var credits_returned = building.production_cost / 2
	var empire = EmpireManager.get_empire_by_id(colony.owner_id)
	if empire:
		empire.treasury += credits_returned
		print("Scrapped building %s for %d credits." % [building.display_name, credits_returned])

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

func _on_save_data_loaded(data: Dictionary) -> void:
	if not data.has("colonies"):
		printerr("ColonyManager: No colonies data in save file!")
		return

	colonies.clear()
	var colonies_data = data["colonies"]
	for colony_key in colonies_data:
		var colony_data = colonies_data[colony_key]
		var colony = ColonyData.new()
		colony.owner_id = colony_data["owner_id"]
		colony.system_id = colony_data["system_id"]
		colony.orbital_slot = colony_data["orbital_slot"]
		colony.current_population = colony_data["current_population"]
		colony.farmers = colony_data.get("farmers", 0)
		colony.workers = colony_data.get("workers", 0)
		colony.scientists = colony_data.get("scientists", 0)
		colony.food_produced = colony_data.get("food_produced", 0)
		colony.production_produced = colony_data.get("production_produced", 0)
		colony.research_produced = colony_data.get("research_produced", 0)
		colony.growth_progress = colony_data.get("growth_progress", 0)

		# Reconstruct construction queue
		var queue_ids = colony_data.get("construction_queue", [])
		for item_id in queue_ids:
			var item = DataManager.get_buildable_item(item_id)
			if item:
				colony.construction_queue.append(item)

		colonies[colony_key] = colony

	print("ColonyManager: Colonies loaded from save file.")

# Type hints removed from function arguments and return value to resolve parse error
func _get_colonies_for_empire(empire) -> Array:
	var colony_list: Array = []
	for system in GalaxyManager.star_systems.values():
		for body in system.celestial_bodies:
			if body is PlanetData and body.owner_id == empire.id:
				colony_list.append(body)
	return colony_list
