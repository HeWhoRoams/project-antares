extends "res://addons/gut/test.gd"

func test_main_menu_scene_loads():
    var scene = load("res://scenes/MainMenu.tscn")
    assert_not_null(scene, "MainMenu.tscn should exist")
    var instance = scene.instantiate()
    assert_not_null(instance, "MainMenu.tscn should instantiate")
