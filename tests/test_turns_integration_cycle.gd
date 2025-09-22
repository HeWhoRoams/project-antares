# /tests/test_integration_turn_cycle.gd
extends GutTest

var _player_manager: PlayerManager
var _turn_manager: TurnManager
var _colony_manager: ColonyManager
var _empire_manager: EmpireManager

func before_all():
	# Get references to the managers we'll be testing
	_player_manager = get_node("/root/PlayerManager")
	_turn_manager = get_node("/root/TurnManager")
	_colony_manager = get_node("/root/ColonyManager")
	_empire_manager = get_node("/root/EmpireManager")

func test_full_turn_cycle_updates_colony_production():
	# -- SETUP --
	# Ensure we have a clean state
	var player_empire = _empire_manager.get_empire_by_id(&"player_1")
	assert_is_not_null(player_empire, "Player empire should exist.")
	
	var colonies = _colony_manager._get_colonies_for_empire(player_empire)
	assert_greater_than(colonies.size(), 0, "Player should start with at least one colony.")
	
	var home_colony: PlanetData = colonies[0]
	home_colony.workers = 5 # Set a known number of workers
	home_colony.construction_queue.append(&"bldg_nanoforge") # Add a buildable item
	home_colony.current_build_progress = 0
	
	var initial_progress = home_colony.current_build_progress

	# -- EXECUTE --
	# Run the function that processes the turn for the player
	_colony_manager.process_turn_for_empire(player_empire)
	
	# -- VERIFY --
	# Check if the build progress has increased as expected
	var expected_production = home_colony.workers * _colony_manager.BASE_PROD_PER_WORKER
	assert_eq(
		home_colony.current_build_progress,
		initial_progress + expected_production,
		"Build progress should increase by the amount of production from workers."
	)