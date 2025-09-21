extends "res://addons/gut/test.gd"

func test_galaxy_generation_runs():
    var generator = load("res://scripts/GalaxyGenerator.gd").new()
    var galaxy = generator.generate(5) # e.g., generate 5 systems
    assert_true(galaxy.size() > 0, "Galaxy should contain systems")
    assert_true(galaxy[0].has("planets"), "First system should contain planets")
