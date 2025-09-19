# /scripts/managers/ColonyManager.gd
extends Node

## A dictionary of all active colonies, keyed by a unique planet identifier.
var colonies: Dictionary = {}

const BASE_FOOD_PER_FARMER = 2
const BASE_PROD_PER_WORKER = 1
const BASE_RES_PER_SCIENTIST = 1
const POP_CONSUMES_FOOD = 1
const POP_GROWTH_THRESHOLD = 100

## Creates a new ColonyData resource and adds it to the manager.
func establish_colony(planet: PlanetData, owner: Empire, starting_pop: int) -> ColonyData:
	if not is_instance_valid(planet) or not is_instance_valid(owner):
		return null

	# Set ownership on the planet itself
	planet.owner_id = owner.id

	# Create the new colony data
	var new_colony = ColonyData.new()
	new_colony.owner_id = owner.id
	new_colony.system_id = planet.system_id
	new_colony.orbital_slot = planet.orbital_slot
	new_colony.current_population = starting_pop
	new_colony.workers = starting_pop # Default all starting pop to workers

	var colony_key = "%s_%d" % [planet.system_id, planet.orbital_slot]
	colonies[colony_key] = new_colony

	DebugManager.log_action("Colony established for %s on %s." % [owner.display_name, planet.name])
	return new_colony

func process_turn_for_empire(empire: Empire) -> void:
	var all_colonies = _get_colonies_for_empire(empire)
	for _planet in all_colonies:
		# Placeholder for turn processing logic
		pass

func _get_colonies_for_empire(empire: Empire) -> Array[PlanetData]:
	var colony_list: Array[PlanetData] = []
	for system in GalaxyManager.star_systems.values():
		for body in system.celestial_bodies:
			if body is PlanetData and body.owner_id == empire.id:
				colony_list.append(body)
	return colony_list