# /gamedata/celestial_bodies/celestial_body_data.gd
class_name CelestialBodyData
extends Resource

enum BodyType { PLANET, ASTEROID_BELT, GAS_GIANT }

@export var body_type: BodyType
@export var orbital_slot: int = 0 # The body's position from the star (0 = innermost)
