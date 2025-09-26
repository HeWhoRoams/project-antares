# /tests/test_empire_manager.gd
extends "res://addons/gut/test.gd"

var empire_manager

func before_all():
	empire_manager = load("res://scripts/managers/EmpireManager.gd").new()
	add_child(empire_manager)
	# Manually call ready since we are not using the scene tree here
	empire_manager._ready()

func after_all():
	remove_child(empire_manager)
	empire_manager.free()

func test_empire_manager_instantiates():
	assert_true(is_instance_valid(empire_manager), "Empire Manager should be a valid instance.")

func test_empires_dict_initially_empty():
	assert_true(empire_manager.empires.is_empty(), "Empires dict should be empty initially.")

func test_register_empire():
	var empire = Empire.new()
	empire.id = "test_empire"
	empire.display_name = "Test Empire"
	empire_manager.register_empire(empire)
	assert_true(empire_manager.empires.has("test_empire"), "Empire should be registered.")

func test_get_empire_by_id():
	var empire = empire_manager.get_empire_by_id("test_empire")
	assert_not_null(empire, "Should return the registered empire.")
	assert_eq(empire.id, "test_empire", "ID should match.")
