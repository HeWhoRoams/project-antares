# /scripts/managers/ai_manager.gd
extends Node

const Empire = preload("res://gamedata/empires/empire.gd")
const ShipData = preload("res://gamedata/ships/ship_data.gd")
const AIDecisionWeights = preload("res://gamedata/AIDecisionWeights.gd")
const RacePreset = preload("res://gamedata/races/race_preset.gd")
const ColonyData = preload("res://gamedata/colonies.gd")
const BuildingData = preload("res://gamedata/buildings/building_data.gd")
const PlanetData = preload("res://gamedata/celestial_bodies/planet_data.gd")
const StarSystem = preload("res://gamedata/celestial_bodies/star_system.gd")
const GalaxyManager = preload("res://scripts/managers/galaxymanager.gd")
const EmpireManager = preload("res://scripts/managers/EmpireManager.gd")
const ColonyManager = preload("res://scripts/managers/ColonyManager.gd")
const TurnManager = preload("res://scripts/managers/turn_manager.gd")
const CouncilManager = preload("res://scripts/managers/council_manager.gd")
const TechnologyEffectManager = preload("res://scripts/managers/TechnologyEffectManager.gd")
const SaveLoadManager = preload("res://scripts/managers/SaveLoadManager.gd")

# AI Personality Types
enum AIPersonality {
	AGGRESSIVE,     # Prioritizes military expansion and conquest
	DEFENSIVE,      # Focuses on defense and economic development
	EXPANSIONIST,  # Rapid colonization and territory growth
	TECHNOLOGICAL,  # Research-focused development
	BALANCED        # Mixed strategy approach
}

var ai_empires: Dictionary = {}  # empire_id -> AI personality data
var owned_ships: Dictionary = {}

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		_initialize_new_game_state()

func _initialize_new_game_state() -> void:
	# Create AI empires with different personalities
	_create_ai_empire("ai_silicoids", "Silicoid Imperium", Color.RED, AIPersonality.AGGRESSIVE)
	_create_ai_empire("ai_humans", "United Earth", Color.BLUE, AIPersonality.BALANCED)
	_create_starting_fleets()

func _create_ai_empire(empire_id: StringName, display_name: String, color: Color, personality: AIPersonality) -> void:
	var empire = Empire.new()
	empire.id = empire_id
	empire.display_name = display_name
	empire.color = color
	empire.is_ai_controlled = true

	# Assign race preset based on personality
	var race_preset = _get_race_for_personality(personality)
	empire.race_preset = race_preset

	EmpireManager.register_empire(empire)

	# Store AI personality data
	ai_empires[empire_id] = {
		"personality": personality,
		"weights": _get_personality_weights(personality),
		"home_system": _assign_home_system(empire_id)
	}

func _get_personality_weights(personality: AIPersonality) -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()

	match personality:
		AIPersonality.AGGRESSIVE:
			weights.colony_expansion = 70
			weights.military_buildup = 80
			weights.research_focus = 30
			weights.economic_growth = 40
		AIPersonality.DEFENSIVE:
			weights.colony_expansion = 40
			weights.military_buildup = 70
			weights.research_focus = 50
			weights.economic_growth = 60
		AIPersonality.EXPANSIONIST:
			weights.colony_expansion = 90
			weights.military_buildup = 40
			weights.research_focus = 30
			weights.economic_growth = 50
		AIPersonality.TECHNOLOGICAL:
			weights.colony_expansion = 50
			weights.military_buildup = 30
			weights.research_focus = 90
			weights.economic_growth = 60
		AIPersonality.BALANCED:
			weights.colony_expansion = 60
			weights.military_buildup = 50
			weights.research_focus = 60
			weights.economic_growth = 70

	return weights

func _assign_home_system(empire_id: StringName) -> StringName:
	# Assign different home systems based on empire
	match empire_id:
		"ai_silicoids": return "sirius"
		"ai_humans": return "procyon"
		_: return "sirius"

func _create_starting_fleets() -> void:
	for empire_id in ai_empires.keys():
		var ship_data = ShipData.new()
		ship_data.id = "%s_scout_01" % empire_id
		ship_data.owner_id = empire_id
		ship_data.current_system_id = ai_empires[empire_id]["home_system"]
		owned_ships[ship_data.id] = ship_data

func take_turn(empire_id: StringName) -> void:
	if not ai_empires.has(empire_id):
		print("AIManager: No AI data for empire %s" % empire_id)
		return

	var ai_data = ai_empires[empire_id]
	var empire = EmpireManager.get_empire_by_id(empire_id)

	if not empire:
		print("AIManager: Empire %s not found" % empire_id)
		return

	print("AIManager: AI empire %s (%s) is taking its turn" % [empire.display_name, AIPersonality.keys()[ai_data.personality]])

	# Execute AI decision making based on current turn phase
	var current_phase = TurnManager.current_sub_phase

	match current_phase:
		TurnManager.TurnSubPhase.MOVEMENT:
			_process_ai_movement_phase(empire, ai_data)
		TurnManager.TurnSubPhase.PRODUCTION:
			_process_ai_production_phase(empire, ai_data)
		TurnManager.TurnSubPhase.RESEARCH:
			_process_ai_research_phase(empire, ai_data)
		TurnManager.TurnSubPhase.CONSTRUCTION:
			_process_ai_construction_phase(empire, ai_data)
		TurnManager.TurnSubPhase.DIPLOMACY:
			_process_ai_diplomacy_phase(empire, ai_data)
		TurnManager.TurnSubPhase.COMBAT_RESOLUTION:
			_process_ai_combat_phase(empire, ai_data)

func _process_ai_movement_phase(empire: Empire, ai_data: Dictionary) -> void:
	# AI fleet movement decisions
	var weights = ai_data.weights

	# Simple exploration logic - move ships to unexplored systems
	for ship_id in empire.owned_ships.keys():
		var ship = empire.owned_ships[ship_id]
		if ship.destination_system_id.is_empty():
			# Find nearest unexplored system
			var target_system = _find_exploration_target(ship.current_system_id, empire)
			if target_system:
				# Set destination (simplified - no actual movement calculation yet)
				ship.destination_system_id = target_system
				print("AIManager: %s moving ship %s toward %s" % [empire.display_name, ship_id, target_system])

func _process_ai_production_phase(empire: Empire, ai_data: Dictionary) -> void:
	# AI colony management decisions
	var weights = ai_data.weights

	# Manage existing colonies
	for colony_key in ColonyManager.colonies.keys():
		var colony = ColonyManager.colonies[colony_key]
		if colony.owner_id == empire.id:
			_manage_colony_population(colony, weights)
			_queue_colony_buildings(colony, weights, empire)

func _process_ai_research_phase(empire: Empire, ai_data: Dictionary) -> void:
	# AI research decisions
	var weights = ai_data.weights

	if empire.current_researching_tech.is_empty():
		# Choose a research target based on personality
		var target_tech = _choose_research_target(empire, weights)
		if target_tech:
			empire.current_researching_tech = target_tech
			print("AIManager: %s starting research on %s" % [empire.display_name, target_tech])

func _process_ai_construction_phase(empire: Empire, ai_data: Dictionary) -> void:
	# Construction phase is handled by ColonyManager.process_turn_for_empire
	# which was already called in production phase
	pass

func _process_ai_diplomacy_phase(empire: Empire, ai_data: Dictionary) -> void:
	# AI diplomatic decisions
	var personality = ai_data.personality

	# Simple diplomatic voting for council sessions
	if CouncilManager.get_session_status().get("active", false):
		var vote_target = _choose_diplomatic_vote_target(empire, personality)
		if vote_target:
			CouncilManager.cast_vote(empire.id, vote_target)
			print("AIManager: %s voting for %s in diplomatic council" % [empire.display_name, vote_target])

func _process_ai_combat_phase(empire: Empire, ai_data: Dictionary) -> void:
	# AI combat decisions (placeholder for future implementation)
	pass

func _manage_colony_population(colony: ColonyData, weights: AIDecisionWeights) -> void:
	# AI population assignment logic
	var total_pop = colony.current_population
	var farmers_needed = max(1, int(total_pop / 3))  # At least 1/3 farmers
	var workers_needed = max(1, int(total_pop / 3))  # At least 1/3 workers
	var scientists_needed = total_pop - farmers_needed - workers_needed

	# Adjust based on AI priorities
	if weights.research_focus > 60:
		scientists_needed = max(scientists_needed, int(total_pop / 4))
		farmers_needed = max(1, farmers_needed - 1)
	elif weights.economic_growth > 60:
		workers_needed = max(workers_needed, int(total_pop / 2))
		farmers_needed = max(1, farmers_needed - 1)
	# Apply assignments
	colony.farmers = clamp(farmers_needed, 0, total_pop)
	colony.workers = clamp(workers_needed, 0, total_pop - colony.farmers)
	colony.scientists = clamp(scientists_needed, 0, total_pop - colony.farmers - colony.workers)

func _queue_colony_buildings(colony: ColonyData, weights: AIDecisionWeights, empire: Empire) -> void:
	# AI building queue decisions
	if colony.construction_queue.size() >= 3:  # Don't queue too many
		return

	var available_buildings = _get_available_buildings(empire)
	var priority_building = _choose_building_priority(available_buildings, weights, colony)

	if priority_building:
		colony.construction_queue.append(priority_building)
		print("AIManager: %s queuing %s in colony" % [empire.display_name, priority_building.display_name])

func _choose_building_priority(available_buildings: Array, weights: AIDecisionWeights, colony: ColonyData) -> BuildingData:
	# Choose building based on AI priorities and colony needs
	var best_building = null
	var best_score = 0

	for building in available_buildings:
		var score = 0

		# Score based on AI personality
		if building.building_type == BuildingData.BuildingType.INDUSTRY:
			score += weights.economic_growth
		elif building.building_type == BuildingData.BuildingType.RESEARCH:
			score += weights.research_focus
		elif building.building_type == BuildingData.BuildingType.DEFENSE:
			score += weights.military_buildup
		elif building.building_type == BuildingData.BuildingType.INFRASTRUCTURE:
			score += weights.colony_expansion

		# Bonus for buildings that help with colony problems
		if colony.pollution > 5 and building.pollution_generated < 0:
			score += 20  # Prefer pollution-reducing buildings
		if colony.morale < 30 and building.morale_modifier > 0:
			score += 15  # Prefer morale-boosting buildings

		if score > best_score:
			best_score = score
			best_building = building

	return best_building

func _choose_research_target(empire: Empire, weights: AIDecisionWeights) -> StringName:
	# Simple research target selection
	var available_techs = _get_available_technologies(empire)

	if available_techs.is_empty():
		return ""

	# Choose based on personality
	if weights.research_focus > 70:
		# Tech-focused AI prioritizes advanced research
		for tech_id in ["tech_physics", "tech_power", "tech_computers"]:
			if available_techs.has(tech_id):
				return tech_id
	elif weights.military_buildup > 60:
		# Military AI prioritizes weapons and defense
		for tech_id in ["tech_weapons", "tech_defense", "tech_tactics"]:
			if available_techs.has(tech_id):
				return tech_id
	else:
		# Default: pick first available
		return available_techs[0]

func _choose_diplomatic_vote_target(empire: Empire, personality: AIPersonality) -> StringName:
	# Simple voting logic - vote for self or based on personality
	match personality:
		AIPersonality.AGGRESSIVE:
			return empire.id  # Aggressive AI votes for itself
		AIPersonality.BALANCED:
			# Balanced AI votes for the player if they exist
			if EmpireManager.empires.has("player"):
				return "player"
			else:
				return empire.id
		_:
			return empire.id  # Default: vote for self

func _find_exploration_target(current_system: StringName, empire: Empire) -> StringName:
	# Simple exploration logic - find nearest unowned system
	for system_id in GalaxyManager.star_systems.keys():
		var system = GalaxyManager.star_systems[system_id]
		var has_colony = false

		# Check if empire already has a colony here
		for body in system.celestial_bodies:
			if body is PlanetData and body.owner_id == empire.id:
				has_colony = true
				break

		if not has_colony and system_id != current_system:
			return system_id

	return ""  # No suitable target found

func _get_available_buildings(empire: Empire) -> Array:
	# Return list of buildings the empire can currently construct
	var buildings = []

	# Basic buildings always available
	buildings.append(BuildingData.create_hydroponics_farm())
	buildings.append(BuildingData.create_automated_factory())
	buildings.append(BuildingData.create_research_lab())

	# Advanced buildings based on tech
	if empire.unlocked_techs.has("tech_planetary_defense"):
		buildings.append(BuildingData.create_planetary_defense())

	return buildings

func _get_available_technologies(empire: Empire) -> Array:
	# Return list of technologies the empire can research
	var available = []

	# Simple list - in reality this would check prerequisites
	var all_techs = ["tech_physics", "tech_power", "tech_weapons", "tech_defense"]
	for tech_id in all_techs:
		if not empire.unlocked_techs.has(tech_id):
			available.append(tech_id)

	return available

func _get_race_for_personality(personality: AIPersonality) -> RacePreset:
	# Return appropriate race preset based on AI personality
	match personality:
		AIPersonality.AGGRESSIVE:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.FELYARI
			race._setup_felyari()
			return race  # Aggressive fleet hunters
		AIPersonality.DEFENSIVE:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.LITHARI
			race._setup_lithari()
			return race  # Defensive rock-skinned titans
		AIPersonality.EXPANSIONIST:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.ZHERIN
			race._setup_zherin()
			return race  # Rapid colonizers
		AIPersonality.TECHNOLOGICAL:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.SYNARI
			race._setup_synari()
			return race  # Knowledge seekers
		AIPersonality.BALANCED:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.CONCORDIANS
			race._setup_concordians()
			return race  # Adaptable diplomats
		_:
			var race = RacePreset.new()
			race.race_type = RacePreset.RaceType.CONCORDIANS
			race._setup_concordians()
			return race  # Default fallback

func _on_save_data_loaded(data: Dictionary) -> void:
	owned_ships.clear()
	ai_empires.clear()

	var ai_data = data.get("ai", {})

	# Load AI empire data
	var loaded_empires = ai_data.get("empires", {})
	for empire_id in loaded_empires:
		ai_empires[empire_id] = loaded_empires[empire_id]

	# Load ship data
	var loaded_ships = ai_data.get("owned_ships", {})
	for ship_id in loaded_ships:
		var ship_data = loaded_ships[ship_id]
		var new_ship = ShipData.new()
		new_ship.id = ship_data.id
		new_ship.owner_id = ship_data.owner_id
		new_ship.current_system_id = ship_data.current_system_id
		new_ship.destination_system_id = ship_data.destination_system_id
		new_ship.turns_to_arrival = ship_data.turns_to_arrival
		owned_ships[ship_id] = new_ship

	print("AIManager: Loaded AI state from save.")
