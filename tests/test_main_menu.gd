extends "res://addons/gut/test.gd"

func test_main_menu_scene_loads():
    var scene = load("res://ui/main_menu.tscn")
    assert_not_null(scene, "main_menu.tscn should exist")
    var instance = scene.instantiate()
    assert_not_null(instance, "main_menu.tscn should instantiate")
