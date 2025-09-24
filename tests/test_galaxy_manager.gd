# /tests/test_galaxy_manager.gd
extends "res://addons/gut/test.gd"

var galaxy_manager

func before_all():
	galaxy_manager = load("res://scripts/managers/galaxymanager.gd").new()

func after_all():
	galaxy_manager.free()

func test_galaxy_manager_instantiates():
	assert_true(is_instance_valid(galaxy_manager), "Galaxy Manager should be a valid instance.")

func test_star_systems_dict_initially_empty():
	assert_true(galaxy_manager.star_systems.is_empty(), "Star systems dict should be empty initially.")
