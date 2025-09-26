extends "res://addons/gut/test.gd"

func test_ship_combat_interaction():
    var ship_class = load("res://scripts/ship.gd")
    var attacker = ship_class.new()
    var defender = ship_class.new()

    attacker.weapon_damage = 10
    defender.armor = 5
    defender.shields = 5

    var pre_hp = defender.hp
    var pre_shields = defender.shields
    attacker.attack(defender)

    assert_true(defender.hp < pre_hp, "Defender should take damage from attacker")
    assert_eq(defender.hp, 95, "Defender hp should be 95 after taking 5 damage")
    assert_eq(defender.shields, 0, "Defender shields should be depleted")
