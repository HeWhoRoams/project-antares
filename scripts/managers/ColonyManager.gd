# /scripts/managers/ColonyManager.gd
extends Node

## A dictionary of all active colonies, keyed by a unique planet identifier.
var colonies: Dictionary = {}

func _ready() -> void:
	TurnManager.process_turn.connect(process_turn_for_empire)

const BASE_FOOD_PER_FARMER = 2
const BASE_PROD_PER_WORKER = 1
const BASE_RES_PER_SCIENTIST = 1
const POP_CONSUMES_FOOD = 1
const POP_GROWTH_THRESHOLD = 100

const ROMAN_NUMERALS = ["I", "II", "III", "IV", "V", "VI", "VII"]

## Creates a new ColonyData resource and adds it to the manager.
func establish_colony(planet: PlanetData, owner: Empire, starting_pop: int) -> ColonyData:
	if not is_instance_valid(planet) or not is_instance_valid(owner):
		return null

	planet.owner_id = owner.id

	var new_colony = ColonyData.new()
	new_colony.owner_id = owner.id
	new_colony.system_id = planet.system_id
	new_colony.orbital_slot = planet.orbital_slot
	new_colony.current_population = starting_pop
	new_colony.workers = starting_pop

	var colony_key = "%s_%d" % [planet.system_id, planet.orbital_slot]
	colonies[colony_key] = new_colony

	var system = GalaxyManager.star_systems.get(planet.system_id)
	var roman_numeral = ""
	if planet.orbital_slot < ROMAN_NUMERALS.size():
		roman_numeral = ROMAN_NUMERALS[planet.orbital_slot]
	var planet_name = "%s %s" % [system.display_name, roman_numeral]

	DebugManager.log_action("Colony established for %s on %s." % [owner.display_name, planet_name])
	return new_colony

## Returns the ColonyData for a given PlanetData resource, if it exists.
func get_colony_for_planet(planet: PlanetData) -> ColonyData:
	var colony_key = "%s_%d" % [planet.system_id, planet.orbital_slot]
	return colonies.get(colony_key)

func process_turn_for_empire(empire: Empire) -> void:
	var all_colonies = _get_colonies_for_empire(empire)

	for _planet in all_colonies:
		pass

func _get_colonies_for_empire(empire: Empire) -> Array[PlanetData]:
	var colony_list: Array[PlanetData] = []
	for system in GalaxyManager.star_systems.values():
		for body in system.celestial_bodies:
			if body is PlanetData and body.owner_id == empire.id:
				colony_list.append(body)
	return colony_list
