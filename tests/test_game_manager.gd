# /tests/test_game_manager.gd
extends "res://addons/gut/test.gd"

var game_manager

func before_all():
	game_manager = load("res://scripts/managers/GameManager.gd").new()
	add_child(game_manager)
	# Manually call ready since we are not using the scene tree here
	game_manager._ready()

func after_all():
	remove_child(game_manager)
	game_manager.free()

func test_game_manager_instantiates():
	assert_true(is_instance_valid(game_manager), "Game Manager should be a valid instance.")

func test_initial_game_phase_is_setup():
	assert_eq(game_manager.current_game_phase, game_manager.GamePhase.SETUP, "Initial game phase should be SETUP.")

func test_set_game_phase():
	game_manager.set_game_phase(game_manager.GamePhase.GALAXY_VIEW)
	assert_eq(game_manager.current_game_phase, game_manager.GamePhase.GALAXY_VIEW, "Game phase should be set correctly.")
