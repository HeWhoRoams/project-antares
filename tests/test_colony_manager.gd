# /tests/test_colony_manager.gd
extends "res://addons/gut/test.gd"

var colony_manager

func before_all():
	colony_manager = load("res://scripts/managers/ColonyManager.gd").new()
	add_child(colony_manager)
	# Manually call ready since we are not using the scene tree here
	colony_manager._ready()

func after_all():
	remove_child(colony_manager)
	colony_manager.free()

func test_colony_manager_instantiates():
	assert_true(is_instance_valid(colony_manager), "Colony Manager should be a valid instance.")

func test_colonies_dict_initially_empty():
	assert_true(colony_manager.colonies.is_empty(), "Colonies dict should be empty initially.")
