class_name NebulaData
extends CelestialBodyData

@export var density: float = 0.5

func _init() -> void:
	body_type = BodyType.NEBULA
