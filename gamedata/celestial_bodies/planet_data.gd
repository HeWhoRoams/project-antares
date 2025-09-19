# /gamedata/celestial_bodies/planet_data.gd
class_name PlanetData
extends CelestialBodyData

enum PlanetSize { XS, S, M, L, XL }
enum PlanetType { OCEAN, TERRAN, DESERT, ICE, BARREN }
enum MineralRichness { VERY_LOW, LOW, NORMAL, HIGH, VERY_HIGH }
enum Gravity { LOW, NORMAL, HIGH }

@export var planet_type: PlanetType

@export_group("Planet Attributes")
@export var size: PlanetSize = PlanetSize.M
@export var max_population: int = 12
@export var mineral_richness: MineralRichness = MineralRichness.NORMAL
@export var gravity: Gravity = Gravity.NORMAL
@export var moons: int = 0
@export var food_per_farmer: int = 1
@export var production_per_worker: int = 1
@export var research_per_scientist: int = 1

## The ID of the empire that owns this planet. Empty if uncolonized.
@export var owner_id: StringName = &""

@export_group("Special Features")
@export var has_natives: bool = false
@export var has_artifacts: bool = false
@export var has_crashed_ship: bool = false
@export var is_abandoned: bool = false

@export_group("Fauna")
@export var has_native_animals: bool = false
@export var has_thriving_fauna: bool = false
@export var has_hostile_fauna: bool = false

func _init():
	body_type = BodyType.PLANET

func get_mineral_modifier() -> float:
	match mineral_richness:
		MineralRichness.VERY_LOW: return -1.5
		MineralRichness.LOW: return -1.0
		MineralRichness.NORMAL: return 0.0
		MineralRichness.HIGH: return 1.0
		MineralRichness.VERY_HIGH: return 1.5
	return 0.0