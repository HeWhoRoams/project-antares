extends GutTest

func test_turn_sub_phases():
	var empires = {
		"empire1": Empire.new(),
		"empire2": Empire.new()
	}
	empires["empire1"].id = "empire1"
	empires["empire2"].id = "empire2"

	TurnManager.start_new_game(empires)

	# Check initial state
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.MOVEMENT, "Should start with MOVEMENT phase")
	assert_eq(TurnManager.current_empire_index, 0, "Should start with first empire")

func test_sub_phase_progression():
	var empires = {
		"empire1": Empire.new()
	}
	empires["empire1"].id = "empire1"

	TurnManager.start_new_game(empires)

	# Manually advance through phases (normally automatic)
	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.PRODUCTION, "Should advance to PRODUCTION")

	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.RESEARCH, "Should advance to RESEARCH")

	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.CONSTRUCTION, "Should advance to CONSTRUCTION")

	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.DIPLOMACY, "Should advance to DIPLOMACY")

	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.COMBAT_RESOLUTION, "Should advance to COMBAT_RESOLUTION")

	# Next advance should end the turn
	TurnManager._advance_sub_phase("empire1")
	assert_eq(TurnManager.current_empire_index, 0, "Should have ended turn and stayed on same empire (single empire test)")

func test_turn_initialization():
	var empires = {
		"empire1": Empire.new(),
		"empire2": Empire.new()
	}
	empires["empire1"].id = "empire1"
	empires["empire2"].id = "empire2"

	TurnManager.start_new_game(empires)

	assert_eq(TurnManager.turn_order.size(), 2, "Should have 2 empires in turn order")
	assert_eq(TurnManager.current_turn, 1, "Should start on turn 1")
	assert_eq(TurnManager.current_sub_phase, TurnManager.TurnSubPhase.MOVEMENT, "Should start with MOVEMENT phase")
	assert_false(TurnManager.turn_paused, "Turn should not be paused initially")

func test_sub_phase_processing():
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.display_name = "Test Empire"

	# Test each sub-phase processing (they should not crash)
	TurnManager._process_movement_phase(empire)
	TurnManager._process_production_phase(empire)
	TurnManager._process_research_phase(empire)
	TurnManager._process_construction_phase(empire)
	TurnManager._process_diplomacy_phase(empire)
	TurnManager._process_combat_phase(empire)

	# If we get here without errors, the test passes
	assert_true(true, "All sub-phase processing methods completed without errors")

func test_turn_signals():
	var empires = {
		"empire1": Empire.new()
	}
	empires["empire1"].id = "empire1"

	var signal_received = false
	var received_empire = ""
	var received_phase = -1

	TurnManager.sub_phase_started.connect(func(empire_id, phase):
		signal_received = true
		received_empire = empire_id
		received_phase = phase
	)

	TurnManager.start_new_game(empires)

	assert_true(signal_received, "Should have received sub_phase_started signal")
	assert_eq(received_empire, "empire1", "Should be for correct empire")
	assert_eq(received_phase, TurnManager.TurnSubPhase.MOVEMENT, "Should be MOVEMENT phase")
