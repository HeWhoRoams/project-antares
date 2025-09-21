extends "res://addons/gut/test.gd"

func test_ship_combat_interaction():
    var ship_class = load("res://scripts/Ship.gd")
    var attacker = ship_class.new()
    var defender = ship_class.new()

    attacker.weapon_damage = 10
    defender.armor = 5
    defender.shields = 5

    var pre_hp = defender.hp
    attacker.attack(defender)

    assert_true(defender.hp < pre_hp, "Defender should take damage from attacker")
