extends "res://addons/gut/test.gd"

var ai_manager

func before_all():
	ai_manager = load("res://scripts/managers/AIManager.gd").new()
	add_child(ai_manager)
	# Manually call ready since we are not using the scene tree here
	ai_manager._ready()

func after_all():
	remove_child(ai_manager)
	ai_manager.free()

func test_ai_manager_instantiates():
	assert_true(is_instance_valid(ai_manager), "AI Manager should be a valid instance.")
