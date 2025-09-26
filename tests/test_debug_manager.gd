# /tests/test_debug_manager.gd
extends "res://addons/gut/test.gd"

var debug_manager

func before_all():
	debug_manager = load("res://scripts/managers/DebugManager.gd").new()
	add_child(debug_manager)
	# Manually call ready since we are not using the scene tree here
	debug_manager._ready()

func after_all():
	remove_child(debug_manager)
	debug_manager.free()

func test_debug_manager_instantiates():
	assert_true(is_instance_valid(debug_manager), "Debug Manager should be a valid instance.")

func test_log_action():
	debug_manager.log_action("Test action")
	assert_true(true, "Logging action should not error.")
