extends GutTest

func test_technology_effect_parsing():
	var tech_effect_manager = TechnologyEffectManager.new()

	# Test research efficiency parsing
	var research_tech = {"id": "logic_matrix", "effect": "+25% research efficiency"}
	var research_effect = tech_effect_manager._parse_technology_effect("logic_matrix")
	assert_eq(research_effect.get("type"), "research_efficiency", "Should parse research efficiency")
	assert_eq(research_effect.get("value"), 1.25, "Should parse 25% bonus as 1.25 multiplier")

	# Test production bonus parsing
	var production_tech = {"id": "mechworks", "effect": "+1 production per worker"}
	var production_effect = tech_effect_manager._parse_technology_effect("mechworks")
	assert_eq(production_effect.get("type"), "production_per_worker", "Should parse production per worker")
	assert_eq(production_effect.get("value"), 1.0, "Should parse +1 production bonus")

	# Test ship defense parsing
	var defense_tech = {"id": "barrier_mk_i", "effect": "+25% durability"}
	var defense_effect = tech_effect_manager._parse_technology_effect("barrier_mk_i")
	assert_eq(defense_effect.get("type"), "ship_defense_multiplier", "Should parse ship defense")
	assert_eq(defense_effect.get("value"), 1.25, "Should parse 25% defense bonus")

	# Test economic parsing
	var economic_tech = {"id": "interstellar_bank", "effect": "+50% empire-wide income"}
	var economic_effect = tech_effect_manager._parse_technology_effect("interstellar_bank")
	assert_eq(economic_effect.get("type"), "empire_income_multiplier", "Should parse empire income")
	assert_eq(economic_effect.get("value"), 1.5, "Should parse 50% income bonus")

func test_technology_effect_application():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.display_name = "Test Empire"
	empire.treasury = 100
	empire.income_per_turn = 20

	# Add some test technologies
	empire.unlocked_techs = ["logic_matrix", "interstellar_bank"]

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Check that effects were applied
	assert_true(tech_effect_manager.applied_effects.has("test_empire"), "Should have applied effects for empire")
	var empire_effects = tech_effect_manager.applied_effects["test_empire"]
	assert_gt(empire_effects.size(), 0, "Should have applied some effects")

	# Check income multiplier was applied
	var income_multiplier = tech_effect_manager.get_empire_multiplier("test_empire", "empire_income_multiplier")
	assert_gt(income_multiplier, 1.0, "Should have income multiplier from technology")

func test_colony_calculations_with_tech():
	var tech_effect_manager = TechnologyEffectManager.new()
	var colony = ColonyData.new()
	colony.farmers = 2
	colony.workers = 3
	colony.scientists = 1

	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["logic_matrix", "mechworks"]  # Research efficiency +25%, +1 production per worker

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Test research calculation
	var research_output = tech_effect_manager.calculate_colony_research(colony, empire.id)
	assert_gt(research_output, 2, "Should have bonus research from technology")  # Base 2 + bonuses

	# Test production calculation
	var production_output = tech_effect_manager.calculate_colony_production(colony, empire.id)
	assert_gt(production_output, 3, "Should have bonus production from technology")  # Base 3 + bonuses

	# Test food calculation
	var food_output = tech_effect_manager.calculate_colony_food(colony, empire.id)
	assert_eq(food_output, 4, "Should have base food output")  # 2 farmers * 2 food each

func test_technology_ability_unlocks():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["cloak_field"]  # Unlocks cloaking

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Check that cloaking ability is unlocked
	var has_cloaking = tech_effect_manager.has_technology_ability("test_empire", "unlocks_cloaking")
	assert_true(has_cloaking, "Should have cloaking ability unlocked")

	# Check that non-unlocked ability is not available
	var has_telepathy = tech_effect_manager.has_technology_ability("test_empire", "unlocks_telepathic_combat")
	assert_false(has_telepathy, "Should not have telepathic combat unlocked")

func test_ship_bonuses_from_technology():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["barrier_mk_iii", "fusion_impulse"]  # +50% durability, +2 parsec range

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Check ship defense multiplier
	var defense_multiplier = tech_effect_manager.get_ship_defense_multiplier("test_empire")
	assert_gt(defense_multiplier, 1.0, "Should have defense multiplier from technology")

	# Check ship range bonus
	var range_bonus = tech_effect_manager.get_ship_range_bonus("test_empire")
	assert_gt(range_bonus, 0, "Should have range bonus from technology")

func test_population_growth_with_technology():
	var tech_effect_manager = TechnologyEffectManager.new()
	var colony = ColonyData.new()
	colony.current_population = 5

	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["bio_replication"]  # +100% population growth rate

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Test population growth calculation
	var growth_rate = tech_effect_manager.calculate_population_growth(colony, empire.id)
	assert_gt(growth_rate, 0.1, "Should have increased growth rate from technology")  # Base 0.1

func test_empire_bonuses_accumulation():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["research_grid", "neural_net"]  # Both give research per scientist bonuses

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Check that bonuses accumulate
	var research_bonus = tech_effect_manager.get_empire_bonus("test_empire", "research_per_scientist")
	assert_gt(research_bonus, 1.0, "Should accumulate research bonuses from multiple technologies")

func test_unknown_technology_effect():
	var tech_effect_manager = TechnologyEffectManager.new()

	# Test with unknown effect string
	var unknown_tech = {"id": "unknown_tech", "effect": "Does something mysterious"}
	var unknown_effect = tech_effect_manager._parse_technology_effect("unknown_tech")

	assert_eq(unknown_effect.get("type"), "unknown", "Should handle unknown effects gracefully")
	assert_eq(unknown_effect.get("value"), 0.0, "Unknown effects should have zero value")

func test_technology_effect_save_load():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["logic_matrix"]

	# Apply effects
	tech_effect_manager.apply_technology_effects(empire)

	# Get save data
	var save_data = tech_effect_manager.get_save_data()
	assert_true(save_data.has("technology_effects"), "Should include technology effects in save data")

	# Simulate loading
	tech_effect_manager.applied_effects.clear()
	tech_effect_manager._on_save_data_loaded(save_data)

	assert_true(tech_effect_manager.applied_effects.has("test_empire"), "Should restore effects after loading")

func test_empty_technology_list():
	var tech_effect_manager = TechnologyEffectManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = []  # No technologies

	# Apply technology effects
	tech_effect_manager.apply_technology_effects(empire)

	# Should handle empty tech list gracefully
	assert_true(tech_effect_manager.applied_effects.has("test_empire"), "Should create entry even with no techs")
	assert_eq(tech_effect_manager.applied_effects["test_empire"].size(), 0, "Should have no effects for empire with no techs")

func test_invalid_technology_id():
	var tech_effect_manager = TechnologyEffectManager.new()

	# Test parsing with invalid tech ID
	var invalid_effect = tech_effect_manager._parse_technology_effect("nonexistent_tech")
	assert_eq(invalid_effect.size(), 0, "Should return empty dict for invalid tech ID")
