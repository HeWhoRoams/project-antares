class_name MoonData
extends CelestialBodyData

enum MoonSize { XS, S, M, L, XL }

@export var size: MoonSize = MoonSize.M
@export var mineral_richness: PlanetData.MineralRichness = PlanetData.MineralRichness.NORMAL
@export var gravity: PlanetData.Gravity = PlanetData.Gravity.NORMAL
@export var max_population: int = 5
@export var owner_id: StringName = ""
@export var has_natives: bool = false
@export var has_artifacts: bool = false
@export var has_crashed_ship: bool = false
@export var is_abandoned: bool = false
@export var has_native_animals: bool = false
@export var has_thriving_fauna: bool = false
@export var has_hostile_fauna: bool = false

func _init() -> void:
	body_type = BodyType.MOON
