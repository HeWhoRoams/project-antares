# /tests/test_data_manager.gd
extends "res://addons/gut/test.gd"

var data_manager

func before_all():
	data_manager = load("res://scripts/managers/DataManager.gd").new()
	add_child(data_manager)
	# Manually call ready since we are not using the scene tree here
	data_manager._ready()

func after_all():
	remove_child(data_manager)
	data_manager.free()

func test_technologies_are_loaded():
	assert_true(data_manager.get_all_technologies().size() > 0, "There should be technologies loaded.")

func test_get_technology_returns_valid_tech():
	var tech = data_manager.get_technology("tech_predictive_algorithms")
	assert_true(is_instance_of(tech, Resource), "Should return a valid resource.")
	assert_eq(tech.id, "tech_predictive_algorithms", "The ID of the returned tech should be correct.")

func test_get_technology_returns_null_for_invalid_id():
	var tech = data_manager.get_technology("invalid_tech_id")
	assert_null(tech, "Should return null for an invalid ID.")

func test_tech_tree_data_is_loaded():
	var tech_tree = data_manager.get_tech_tree_data()
	assert_true(tech_tree.has("categories"), "Tech tree should have categories.")
