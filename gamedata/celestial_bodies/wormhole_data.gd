class_name WormholeData
extends CelestialBodyData

@export var stability: float = 1.0
@export var exit_position: Vector2

func _init() -> void:
	body_type = BodyType.WORMHOLE
