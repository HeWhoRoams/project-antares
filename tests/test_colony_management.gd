extends GutTest

func test_population_job_assignment():
	var planet = PlanetData.new()
	planet.system_id = "test_system"
	planet.orbital_slot = 1

	var empire = Empire.new()
	empire.id = "test_empire"

	# Create a colony
	var colony = ColonyManager.establish_colony(planet, empire, 10)
	assert_not_null(colony, "Colony should be created successfully")
	assert_eq(colony.current_population, 10, "Colony should have 10 population")

	# Test job assignment
	var success = ColonyManager.assign_population_job(planet, "farmer", 3)
	assert_true(success, "Should be able to assign 3 farmers")

	var assignment = ColonyManager.get_population_assignment(planet)
	assert_eq(assignment["farmers"], 3, "Should have 3 farmers assigned")
	assert_eq(assignment["workers"], 7, "Should have 7 workers (default assignment)")
	assert_eq(assignment["unassigned"], 0, "Should have no unassigned population")

	# Test invalid assignment (not enough unassigned population)
	success = ColonyManager.assign_population_job(planet, "scientist", 5)
	assert_false(success, "Should not be able to assign more than available unassigned population")

func test_building_data_creation():
	var building = BuildingData.create_hydroponics_farm()
	assert_not_null(building, "Building should be created successfully")
	assert_eq(building.display_name, "Hydroponics Farm", "Building should have correct name")
	assert_eq(building.building_type, BuildingData.BuildingType.INFRASTRUCTURE, "Should be infrastructure type")
	assert_eq(building.food_modifier, 0.5, "Should have 50% food modifier")

func test_building_effect_description():
	var building = BuildingData.new()
	building.food_modifier = 0.25
	building.production_modifier = -0.1
	building.defense_bonus = 20

	var description = building.get_effect_description()
	assert_true(description.contains("Food: +25%"), "Should show food bonus")
	assert_true(description.contains("Production: -10%"), "Should show production penalty")
	assert_true(description.contains("Defense: +20"), "Should show defense bonus")

func test_building_construction():
	var planet = PlanetData.new()
	planet.system_id = "test_system"
	planet.orbital_slot = 2

	var empire = Empire.new()
	empire.id = "test_empire"

	# Create colony with production capacity
	var colony = ColonyManager.establish_colony(planet, empire, 5)
	colony.workers = 5  # Give workers to produce
	colony.production_produced = 10  # Set production output

	# Add a building to construction queue
	var building = BuildingData.create_automated_factory()
	colony.construction_queue.append(building)

	# Process construction
	ColonyManager._process_construction(planet)

	# Building should be completed (10 production >= 100 cost? Wait, let's check the cost)
	# Actually, the building costs 100 but we only produced 10, so it shouldn't complete
	assert_eq(colony.construction_queue.size(), 1, "Building should not be completed yet")

	# Give more production
	colony.production_produced = 100
	ColonyManager._process_construction(planet)

	assert_eq(colony.construction_queue.size(), 0, "Building should be completed")
	assert_eq(colony.buildings.size(), 1, "Building should be added to colony")
	assert_eq(colony.pollution, 2, "Building should add pollution")

func test_colony_resource_production():
	var planet = PlanetData.new()
	planet.system_id = "test_system"
	planet.orbital_slot = 3
	planet.food_per_farmer = 2
	planet.production_per_worker = 1
	planet.research_per_scientist = 1

	var empire = Empire.new()
	empire.id = "test_empire"

	var colony = ColonyManager.establish_colony(planet, empire, 10)
	colony.farmers = 3
	colony.workers = 4
	colony.scientists = 2

	ColonyManager._process_resource_production(planet)

	assert_eq(colony.food_produced, 6, "Should produce 6 food (3 farmers * 2)")
	assert_eq(colony.production_produced, 4, "Should produce 4 production (4 workers * 1)")
	assert_eq(colony.research_produced, 2, "Should produce 2 research (2 scientists * 1)")

func test_population_growth():
	var planet = PlanetData.new()
	planet.system_id = "test_system"
	planet.orbital_slot = 4
	planet.food_per_farmer = 3

	var empire = Empire.new()
	empire.id = "test_empire"

	var colony = ColonyManager.establish_colony(planet, empire, 5)
	colony.farmers = 3
	colony.food_produced = 10  # 3 farmers * 3 = 9, but set to 10 for surplus

	ColonyManager._process_population_growth(planet)

	# Should have growth progress but not enough for new population yet
	assert_eq(colony.current_population, 5, "Population should not grow yet")
	assert_gt(colony.growth_progress, 0, "Should have growth progress")

	# Add enough progress for growth
	colony.growth_progress = 95  # Close to threshold
	colony.food_produced = 10
	ColonyManager._process_population_growth(planet)

	assert_eq(colony.current_population, 6, "Population should grow to 6")
	assert_eq(colony.workers, 6, "New population should be assigned to workers")
