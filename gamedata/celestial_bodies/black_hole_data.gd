class_name BlackHoleData
extends CelestialBodyData

@export var mass: float = 10.0
@export var event_horizon_radius: float = 5.0

func _init() -> void:
	body_type = BodyType.BLACK_HOLE
