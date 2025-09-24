extends GutTest

func test_ai_personality_creation():
	var ai_manager = AIManager.new()
	ai_manager._create_ai_empire("test_ai", "Test Empire", Color.GREEN, AIManager.AIPersonality.AGGRESSIVE)

	assert_true(AIManager.ai_empires.has("test_ai"), "AI empire should be created")
	var ai_data = AIManager.ai_empires["test_ai"]
	assert_eq(ai_data.personality, AIManager.AIPersonality.AGGRESSIVE, "Personality should be set correctly")

	var weights = ai_data.weights
	assert_gt(weights.military_buildup, 70, "Aggressive AI should prioritize military")
	assert_lt(weights.research_focus, 40, "Aggressive AI should not prioritize research")

func test_ai_personality_weights():
	var ai_manager = AIManager.new()

	# Test aggressive personality
	var aggressive_weights = ai_manager._get_personality_weights(AIManager.AIPersonality.AGGRESSIVE)
	assert_eq(aggressive_weights.military_buildup, 80, "Aggressive AI military weight")
	assert_eq(aggressive_weights.research_focus, 30, "Aggressive AI research weight")

	# Test technological personality
	var tech_weights = ai_manager._get_personality_weights(AIManager.AIPersonality.TECHNOLOGICAL)
	assert_eq(tech_weights.research_focus, 90, "Technological AI research weight")
	assert_eq(tech_weights.military_buildup, 30, "Technological AI military weight")

	# Test balanced personality
	var balanced_weights = ai_manager._get_personality_weights(AIManager.AIPersonality.BALANCED)
	assert_eq(balanced_weights.economic_growth, 70, "Balanced AI economic weight")
	assert_eq(balanced_weights.colony_expansion, 60, "Balanced AI expansion weight")

func test_ai_colony_population_management():
	var colony = ColonyData.new()
	colony.current_population = 10
	colony.farmers = 0
	colony.workers = 0
	colony.scientists = 0

	var ai_manager = AIManager.new()
	var weights = AIDecisionWeights.new()
	weights.research_focus = 70  # High research priority

	ai_manager._manage_colony_population(colony, weights)

	# Should assign more scientists due to high research priority
	assert_gt(colony.scientists, 2, "High research AI should assign more scientists")
	assert_ge(colony.farmers, 1, "Should still assign at least some farmers")
	assert_eq(colony.farmers + colony.workers + colony.scientists, colony.current_population, "All population should be assigned")

func test_ai_building_priority_selection():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"

	var colony = ColonyData.new()
	colony.pollution = 10  # High pollution
	colony.morale = 20     # Low morale

	var weights = AIDecisionWeights.new()
	weights.economic_growth = 80  # High economic priority

	var available_buildings = ai_manager._get_available_buildings(empire)
	var priority_building = ai_manager._choose_building_priority(available_buildings, weights, colony)

	assert_not_null(priority_building, "Should select a building")
	# Should prefer industry buildings due to high economic priority
	assert_eq(priority_building.building_type, BuildingData.BuildingType.INDUSTRY, "Should prioritize industry building")

func test_ai_research_target_selection():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["tech_basic"]  # Has basic tech unlocked

	var weights = AIDecisionWeights.new()
	weights.research_focus = 80  # High research priority

	var target = ai_manager._choose_research_target(empire, weights)

	# Should choose advanced research due to high research priority
	assert_not_null(target, "Should select a research target")
	assert_true(target.begins_with("tech_"), "Should be a valid tech ID")

func test_ai_diplomatic_voting():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"

	# Test aggressive AI voting
	var aggressive_vote = ai_manager._choose_diplomatic_vote_target(empire, AIManager.AIPersonality.AGGRESSIVE)
	assert_eq(aggressive_vote, empire.id, "Aggressive AI should vote for itself")

	# Test balanced AI voting
	var balanced_vote = ai_manager._choose_diplomatic_vote_target(empire, AIManager.AIPersonality.BALANCED)
	# Should try to vote for player if exists, otherwise self
	assert_not_null(balanced_vote, "Balanced AI should make a vote")

func test_ai_exploration_target():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"

	# Create test systems
	var current_system = StarSystem.new()
	current_system.id = "sol"
	var current_planet = PlanetData.new()
	current_planet.system_id = "sol"
	current_planet.owner_id = empire.id  # Empire owns this system
	current_system.celestial_bodies = [current_planet]
	GalaxyManager.star_systems["sol"] = current_system

	var target_system = StarSystem.new()
	target_system.id = "alpha_centauri"
	var target_planet = PlanetData.new()
	target_planet.system_id = "alpha_centauri"
	target_planet.owner_id = ""  # Unowned system
	target_system.celestial_bodies = [target_planet]
	GalaxyManager.star_systems["alpha_centauri"] = target_system

	var exploration_target = ai_manager._find_exploration_target("sol", empire)
	assert_eq(exploration_target, "alpha_centauri", "Should find unowned system as exploration target")

func test_ai_take_turn_integration():
	var ai_manager = AIManager.new()

	# Create test empire
	var empire = Empire.new()
	empire.id = "test_ai"
	empire.display_name = "Test AI Empire"
	empire.is_ai_controlled = true
	EmpireManager.register_empire(empire)

	# Set up AI data
	AIManager.ai_empires[empire.id] = {
		"personality": AIManager.AIPersonality.BALANCED,
		"weights": ai_manager._get_personality_weights(AIManager.AIPersonality.BALANCED),
		"home_system": "test_system"
	}

	# Test take_turn doesn't crash
	ai_manager.take_turn(empire.id)

	# Should have processed without errors
	assert_true(true, "AI take_turn should complete without errors")

func test_ai_available_buildings():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"

	var buildings = ai_manager._get_available_buildings(empire)

	assert_gt(buildings.size(), 0, "Should have available buildings")
	assert_true(buildings[0] is BuildingData, "Buildings should be BuildingData instances")

	# Test with tech unlocked
	empire.unlocked_techs = ["tech_planetary_defense"]
	var advanced_buildings = ai_manager._get_available_buildings(empire)

	# Should have more buildings available with tech
	assert_ge(advanced_buildings.size(), buildings.size(), "Should have at least as many buildings with tech")

func test_ai_available_technologies():
	var ai_manager = AIManager.new()
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.unlocked_techs = ["tech_basic"]

	var available_techs = ai_manager._get_available_technologies(empire)

	assert_gt(available_techs.size(), 0, "Should have available technologies")
	for tech_id in available_techs:
		assert_false(empire.unlocked_techs.has(tech_id), "Should not include already unlocked techs")
		assert_true(tech_id.begins_with("tech_"), "Should be valid tech IDs")
