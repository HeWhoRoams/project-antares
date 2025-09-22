# /gamedata/celestial_bodies/planet_data.gd
class_name PlanetData
extends CelestialBodyData

enum PlanetType { OCEAN, TERRAN, DESERT, ICE, BARREN }
enum MineralRichness { VERY_LOW, LOW, NORMAL, HIGH, VERY_HIGH }
enum Gravity { LOW, NORMAL, HIGH }

@export var planet_type: PlanetType

@export_group("Colony State")
## The ID of the empire that owns this planet. Empty if uncolonized.
@export var owner_id: StringName = &""
## The current number of population units.
@export var current_population: int = 0
## The number of population units assigned to farming.
@export var farmers: int = 0
## The number of population units assigned to industry.
@export var workers: int = 0
## The number of population units assigned to research.
@export var scientists: int = 0

@export_group("Planet Attributes")
@export var max_population: int = 12
@export var mineral_richness: MineralRichness = MineralRichness.NORMAL
@export var gravity: Gravity = Gravity.NORMAL
@export var moons: int = 0

@export_group("Construction")
## An array of BuildableItem IDs.
@export var construction_queue: Array[StringName] = []
@export var current_build_progress: float = 0.0

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
	size = BodySize.M

func get_mineral_modifier() -> float:
	match mineral_richness:
		MineralRichness.VERY_LOW: return -1.5
		MineralRichness.LOW: return -1.0
		MineralRichness.NORMAL: return 0.0
		MineralRichness.HIGH: return 1.0
		MineralRichness.VERY_HIGH: return 1.5
	return 0.0
