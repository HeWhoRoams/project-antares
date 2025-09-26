extends Node

# Technology Effect Manager
# Handles applying technology bonuses to empires and colonies

var applied_effects: Dictionary = {}  # empire_id -> {tech_id -> effect_data}

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

# Applies all technology effects for an empire
# Called when technologies are unlocked or when empire data is loaded
func apply_technology_effects(empire: Empire) -> void:
	if not empire:
		return

	var empire_id = empire.id
	if not applied_effects.has(empire_id):
		applied_effects[empire_id] = {}

	# Clear existing effects for this empire
	applied_effects[empire_id].clear()

	# Apply effects for each unlocked technology
	for tech_id in empire.unlocked_techs:
		var effect_data = _parse_technology_effect(tech_id)
		if effect_data:
			applied_effects[empire_id][tech_id] = effect_data
			_apply_effect_to_empire(empire, effect_data)

	print("TechnologyEffectManager: Applied %d technology effects for %s" % [applied_effects[empire_id].size(), empire.display_name])

# Gets the total bonus for a specific effect type for an empire
func get_empire_bonus(empire_id: StringName, effect_type: String) -> float:
	if not applied_effects.has(empire_id):
		return 0.0

	var total_bonus = 0.0
	for tech_id in applied_effects[empire_id]:
		var effect_data = applied_effects[empire_id][tech_id]
		if effect_data.type == effect_type:
			total_bonus += effect_data.value

	return total_bonus

# Gets the total multiplier for a specific effect type for an empire
func get_empire_multiplier(empire_id: StringName, effect_type: String) -> float:
	if not applied_effects.has(empire_id):
		return 1.0

	var total_multiplier = 1.0
	for tech_id in applied_effects[empire_id]:
		var effect_data = applied_effects[empire_id][tech_id]
		if effect_data.type == effect_type:
			total_multiplier *= effect_data.value

	return total_multiplier

# Parses a technology effect string into structured data
func _parse_technology_effect(tech_id: String) -> Dictionary:
	var tech_data = DataManager.get_technology(tech_id)
	if not tech_data or not tech_data.has("effect"):
		return {}

	var effect_string = tech_data.effect
	var effect_data = {}

	# Parse different effect types
	if "+25% research efficiency" in effect_string:
		effect_data = {"type": "research_efficiency", "value": 1.25}
	elif "+1 research per scientist" in effect_string:
		effect_data = {"type": "research_per_scientist", "value": 1.0}
	elif "+2 research per scientist" in effect_string:
		effect_data = {"type": "research_per_scientist", "value": 2.0}
	elif "Research efficiency +50%" in effect_string:
		effect_data = {"type": "research_efficiency", "value": 1.5}
	elif "+100% research" in effect_string:
		effect_data = {"type": "research_efficiency", "value": 2.0}

	# Production effects
	elif "+1 production per worker" in effect_string:
		effect_data = {"type": "production_per_worker", "value": 1.0}
	elif "+2 production" in effect_string:
		effect_data = {"type": "production_bonus", "value": 2.0}
	elif "+3 production" in effect_string:
		effect_data = {"type": "production_bonus", "value": 3.0}
	elif "Doubles production per factory" in effect_string:
		effect_data = {"type": "factory_production_multiplier", "value": 2.0}
	elif "Doubles all planetary production" in effect_string:
		effect_data = {"type": "planetary_production_multiplier", "value": 2.0}
	elif "Improves planetary production by +50%" in effect_string:
		effect_data = {"type": "planetary_production_multiplier", "value": 1.5}

	# Food effects
	elif "+1 food per farmer" in effect_string:
		effect_data = {"type": "food_per_farmer", "value": 1.0}
	elif "+25% food output" in effect_string:
		effect_data = {"type": "food_multiplier", "value": 1.25}
	elif "+2 food per farmer" in effect_string:
		effect_data = {"type": "food_per_farmer", "value": 2.0}

	# Population effects
	elif "+25% population cap" in effect_string:
		effect_data = {"type": "population_cap_multiplier", "value": 1.25}
	elif "+100% population growth rate" in effect_string:
		effect_data = {"type": "population_growth_multiplier", "value": 2.0}
	elif "Increases planet population capacity by +2" in effect_string:
		effect_data = {"type": "population_cap_bonus", "value": 2.0}

	# Combat effects
	elif "+25% durability" in effect_string:
		effect_data = {"type": "ship_defense_multiplier", "value": 1.25}
	elif "+50% durability" in effect_string:
		effect_data = {"type": "ship_defense_multiplier", "value": 1.5}
	elif "+25% ship combat maneuverability" in effect_string:
		effect_data = {"type": "ship_maneuverability", "value": 1.25}
	elif "+10 defense" in effect_string:
		effect_data = {"type": "ship_defense_bonus", "value": 10.0}
	elif "+75% ship accuracy" in effect_string:
		effect_data = {"type": "ship_accuracy_multiplier", "value": 1.75}
	elif "+30% defensive bonus" in effect_string:
		effect_data = {"type": "ship_defense_multiplier", "value": 1.3}

	# Economic effects
	elif "+20% BC income" in effect_string:
		effect_data = {"type": "credit_income_multiplier", "value": 1.2}
	elif "+50% empire-wide income" in effect_string:
		effect_data = {"type": "empire_income_multiplier", "value": 1.5}
	elif "+50% trade income empire-wide" in effect_string:
		effect_data = {"type": "trade_income_multiplier", "value": 1.5}

	# Ship speed/range effects
	elif "+2 parsec range" in effect_string:
		effect_data = {"type": "ship_range_bonus", "value": 2.0}
	elif "+4 parsec range" in effect_string:
		effect_data = {"type": "ship_range_bonus", "value": 4.0}
	elif "+6 parsec range" in effect_string:
		effect_data = {"type": "ship_range_bonus", "value": 6.0}
	elif "+8 parsec range" in effect_string:
		effect_data = {"type": "ship_range_bonus", "value": 8.0}
	elif "+12 parsec range" in effect_string:
		effect_data = {"type": "ship_range_bonus", "value": 12.0}

	# Special abilities
	elif "Ship cloaking" in effect_string:
		effect_data = {"type": "unlocks_cloaking", "value": true}
	elif "Ship cloaking ability" in effect_string:
		effect_data = {"type": "unlocks_cloaking", "value": true}
	elif "Telepathic combat" in effect_string:
		effect_data = {"type": "unlocks_telepathic_combat", "value": true}
	elif "Psionic energy weapon" in effect_string:
		effect_data = {"type": "unlocks_psionic_weapons", "value": true}

	# Building unlocks
	elif "Unlocks basic factory" in effect_string:
		effect_data = {"type": "unlocks_basic_factory", "value": true}
	elif "Unlocks automated factories" in effect_string:
		effect_data = {"type": "unlocks_automated_factory", "value": true}
	elif "Unlocks research labs" in effect_string:
		effect_data = {"type": "unlocks_research_lab", "value": true}
	elif "Unlocks arcology" in effect_string:
		effect_data = {"type": "unlocks_arcology", "value": true}

	# Terraforming and colonization
	elif "Unlocks Terraforming" in effect_string:
		effect_data = {"type": "unlocks_terraforming", "value": true}
	elif "can colonize all" in effect_string.to_lower():
		effect_data = {"type": "colonize_all_planets", "value": true}

	# Diplomacy and governance
	elif "Improves diplomacy and morale" in effect_string:
		effect_data = {"type": "diplomacy_morale_bonus", "value": 10.0}
	elif "+10% relations" in effect_string:
		effect_data = {"type": "diplomacy_bonus", "value": 1.1}

	# Espionage
	elif "+10 spy defense" in effect_string:
		effect_data = {"type": "espionage_defense_bonus", "value": 10.0}
	elif "+20 spy defense" in effect_string:
		effect_data = {"type": "espionage_defense_bonus", "value": 20.0}

	# Default fallback for unrecognized effects
	else:
		effect_data = {"type": "unknown", "value": 0.0, "description": effect_string}

	return effect_data

# Applies a parsed effect to an empire
func _apply_effect_to_empire(empire: Empire, effect_data: Dictionary) -> void:
	var effect_type = effect_data.type
	var value = effect_data.value

	match effect_type:
		# Research effects
		"research_efficiency":
			empire.research_per_turn = int(empire.research_per_turn * value)
		"research_per_scientist":
			# This will be applied in colony calculations
			pass

		# Production effects
		"production_per_worker":
			# This will be applied in colony calculations
			pass
		"production_bonus":
			# This will be applied in colony calculations
			pass
		"factory_production_multiplier":
			# This will be applied in colony calculations
			pass
		"planetary_production_multiplier":
			# This will be applied in colony calculations
			pass

		# Economic effects
		"credit_income_multiplier":
			empire.income_per_turn = int(empire.income_per_turn * value)
		"empire_income_multiplier":
			empire.income_per_turn = int(empire.income_per_turn * value)
		"trade_income_multiplier":
			empire.income_per_turn = int(empire.income_per_turn * value)

		# Population effects
		"population_growth_multiplier":
			# This will be applied in colony calculations
			pass
		"population_cap_multiplier":
			# This will be applied in colony calculations
			pass
		"population_cap_bonus":
			# This will be applied in colony calculations
			pass

		# Combat effects
		"ship_defense_multiplier":
			# This will be applied to ship calculations
			pass
		"ship_attack_multiplier":
			# This will be applied to ship calculations
			pass
		"ship_accuracy_multiplier":
			# This will be applied to ship calculations
			pass
		"ship_maneuverability":
			# This will be applied to ship calculations
			pass

		# Special abilities
		"unlocks_cloaking":
			# This unlocks cloaking technology for ship design
			pass
		"unlocks_telepathic_combat":
			# This unlocks telepathic combat abilities
			pass
		"unlocks_psionic_weapons":
			# This unlocks psionic weapons
			pass

		# Building unlocks
		"unlocks_basic_factory":
			# This unlocks basic factory construction
			pass
		"unlocks_automated_factory":
			# This unlocks automated factory construction
			pass
		"unlocks_research_lab":
			# This unlocks research lab construction
			pass
		"unlocks_arcology":
			# This unlocks arcology construction
			pass

		# Terraforming
		"unlocks_terraforming":
			# This unlocks terraforming technology
			pass
		"colonize_all_planets":
			# This allows colonization of all planet types
			pass

		_:
			# Unknown effect type
			pass

# Calculates research output for a colony including technology bonuses
func calculate_colony_research(colony: ColonyData, empire_id: StringName) -> int:
	var base_research = colony.scientists * 2  # Base research per scientist
	var tech_bonus = get_empire_bonus(empire_id, "research_per_scientist")
	var efficiency_multiplier = get_empire_multiplier(empire_id, "research_efficiency")

	return int((base_research + tech_bonus) * efficiency_multiplier)

# Calculates production output for a colony including technology bonuses
func calculate_colony_production(colony: ColonyData, empire_id: StringName) -> int:
	var base_production = colony.workers * 1  # Base production per worker
	var tech_bonus = get_empire_bonus(empire_id, "production_per_worker")
	var production_bonus = get_empire_bonus(empire_id, "production_bonus")
	var factory_multiplier = get_empire_multiplier(empire_id, "factory_production_multiplier")
	var planetary_multiplier = get_empire_multiplier(empire_id, "planetary_production_multiplier")

	return int((base_production + tech_bonus + production_bonus) * factory_multiplier * planetary_multiplier)

# Calculates food output for a colony including technology bonuses
func calculate_colony_food(colony: ColonyData, empire_id: StringName) -> int:
	var base_food = colony.farmers * 2  # Base food per farmer
	var tech_bonus = get_empire_bonus(empire_id, "food_per_farmer")
	var food_multiplier = get_empire_multiplier(empire_id, "food_multiplier")

	return int((base_food + tech_bonus) * food_multiplier)

# Calculates population growth for a colony including technology bonuses
func calculate_population_growth(colony: ColonyData, empire_id: StringName) -> float:
	var base_growth = 0.1  # Base 10% growth per turn
	var growth_multiplier = get_empire_multiplier(empire_id, "population_growth_multiplier")

	return base_growth * growth_multiplier

# Checks if an empire has unlocked a specific technology ability
func has_technology_ability(empire_id: StringName, ability: String) -> bool:
	if not applied_effects.has(empire_id):
		return false

	for tech_id in applied_effects[empire_id]:
		var effect_data = applied_effects[empire_id][tech_id]
		if effect_data.type == ability and effect_data.value == true:
			return true

	return false

# Gets the ship range bonus for an empire
func get_ship_range_bonus(empire_id: StringName) -> int:
	return int(get_empire_bonus(empire_id, "ship_range_bonus"))

# Gets the ship defense multiplier for an empire
func get_ship_defense_multiplier(empire_id: StringName) -> float:
	return get_empire_multiplier(empire_id, "ship_defense_multiplier")

# Gets the ship attack multiplier for an empire
func get_ship_attack_multiplier(empire_id: StringName) -> float:
	return get_empire_multiplier(empire_id, "ship_attack_multiplier")

# Gets the ship accuracy multiplier for an empire
func get_ship_accuracy_multiplier(empire_id: StringName) -> float:
	return get_empire_multiplier(empire_id, "ship_accuracy_multiplier")

# Save/Load functionality
func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("technology_effects"):
		applied_effects = data["technology_effects"]
	else:
		applied_effects = {}

	print("TechnologyEffectManager: Loaded technology effects from save.")

# Called when saving the game
func get_save_data() -> Dictionary:
	return {
		"technology_effects": applied_effects
	}
