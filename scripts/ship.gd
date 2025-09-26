# /scripts/Ship.gd
class_name Ship
extends RefCounted

var hp: int = 100
var weapon_damage: int = 0
var armor: int = 0
var shields: int = 0

func attack(target: Ship) -> void:
	var damage = weapon_damage
	target.shields -= damage
	if target.shields < 0:
		target.hp += target.shields
		target.shields = 0
