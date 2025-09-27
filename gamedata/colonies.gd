# /gamedata/colonies.gd
class_name ColonyData
extends Resource

@export var owner_id: StringName = ""
@export var system_id: StringName = ""
@export var orbital_slot: int = 0
@export var current_population: int = 0
@export var farmers: int = 0
@export var workers: int = 0
@export var scientists: int = 0
@export var food_produced: int = 0
@export var production_produced: int = 0
@export var research_produced: int = 0
@export var growth_progress: int = 0
@export var construction_queue: Array = []
@export var buildings: Array = []
@export var pollution: int = 0
@export var morale: int = 50

# Static factory methods for creating colonies
static func create_new_colony(owner: StringName, system: StringName, slot: int, starting_pop: int = 10) -> ColonyData:
	var colony = ColonyData.new()
	colony.owner_id = owner
	colony.system_id = system
	colony.orbital_slot = slot
	colony.current_population = starting_pop
	colony.workers = starting_pop  # Start with all workers
	return colony

static func create_from_data(data: Dictionary) -> ColonyData:
	var colony = ColonyData.new()
	colony.owner_id = data.get("owner_id", "")
	colony.system_id = data.get("system_id", "")
	colony.orbital_slot = data.get("orbital_slot", 0)
	colony.current_population = data.get("current_population", 0)
	colony.farmers = data.get("farmers", 0)
	colony.workers = data.get("workers", 0)
	colony.scientists = data.get("scientists", 0)
	colony.food_produced = data.get("food_produced", 0)
	colony.production_produced = data.get("production_produced", 0)
	colony.research_produced = data.get("research_produced", 0)
	colony.growth_progress = data.get("growth_progress", 0)
	colony.construction_queue = data.get("construction_queue", [])
	colony.buildings = data.get("buildings", [])
	colony.pollution = data.get("pollution", 0)
	colony.morale = data.get("morale", 50)
	return colony

# Utility methods for colony management
func get_total_assigned_population() -> int:
	return farmers + workers + scientists

func get_unassigned_population() -> int:
	return current_population - get_total_assigned_population()

func is_population_fully_assigned() -> bool:
	return get_total_assigned_population() >= current_population

func get_available_jobs() -> Dictionary:
	var total_assigned = get_total_assigned_population()
	var unassigned = current_population - total_assigned
	return {
		"farmers": farmers,
		"workers": workers,
		"scientists": scientists,
		"unassigned": unassigned,
		"total_population": current_population
	}

# Population assignment methods
func assign_population_to_farmers(amount: int) -> bool:
	var unassigned = get_unassigned_population()
	if amount <= 0 or unassigned < amount:
		return false
	farmers += amount
	return true

func assign_population_to_workers(amount: int) -> bool:
	var unassigned = get_unassigned_population()
	if amount <= 0 or unassigned < amount:
		return false
	workers += amount
	return true

func assign_population_to_scientists(amount: int) -> bool:
	var unassigned = get_unassigned_population()
	if amount <= 0 or unassigned < amount:
		return false
	scientists += amount
	return true

func rebalance_population(farmer_ratio: float, worker_ratio: float, scientist_ratio: float) -> void:
	# Reset assignments
	farmers = 0
	workers = 0
	scientists = 0
	
	# Reassign based on ratios
	var total_pop = current_population
	farmers = int(total_pop * farmer_ratio)
	workers = int(total_pop * worker_ratio)
	scientists = total_pop - farmers - workers

# Production calculation methods
func calculate_food_output(base_per_farmer: int = 2, modifiers: Dictionary = {}) -> int:
	var base_food = farmers * base_per_farmer
	var modifier = modifiers.get("food_modifier", 1.0)
	var bonus = modifiers.get("food_bonus", 0)
	return int(base_food * modifier) + bonus

func calculate_production_output(base_per_worker: int = 1, modifiers: Dictionary = {}) -> int:
	var base_production = workers * base_per_worker
	var modifier = modifiers.get("production_modifier", 1.0)
	var bonus = modifiers.get("production_bonus", 0)
	return int(base_production * modifier) + bonus

func calculate_research_output(base_per_scientist: int = 1, modifiers: Dictionary = {}) -> int:
	var base_research = scientists * base_per_scientist
	var modifier = modifiers.get("research_modifier", 1.0)
	var bonus = modifiers.get("research_bonus", 0)
	return int(base_research * modifier) + bonus

# Growth methods
func add_population(amount: int) -> void:
	current_population += amount
	# Auto-assign new population to workers by default
	workers += amount

func remove_population(amount: int) -> void:
	current_population = max(0, current_population - amount)
	# Remove from assignments proportionally
	var total_assigned = get_total_assigned_population()
	if total_assigned > 0:
		var ratio = float(current_population) / float(total_assigned)
		farmers = int(farmers * ratio)
		workers = int(workers * ratio)
		scientists = current_population - farmers - workers

# Building methods
func add_building(building_data) -> void:
	buildings.append(building_data)
	pollution += building_data.pollution_generated
	morale += building_data.morale_modifier

func remove_building(building_data) -> void:
	buildings.erase(building_data)
	pollution = max(0, pollution - building_data.pollution_generated)
	morale = max(0, morale - building_data.morale_modifier)

# Queue methods
func queue_building(building_data) -> void:
	construction_queue.append(building_data)

func dequeue_building() -> Variant:
	if construction_queue.size() > 0:
		return construction_queue.pop_front()
	return null

func clear_construction_queue() -> void:
	construction_queue.clear()
