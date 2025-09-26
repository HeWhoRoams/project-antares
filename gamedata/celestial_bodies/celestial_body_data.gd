# /gamedata/celestial_bodies/celestial_body_data.gd
class_name CelestialBodyData
extends Resource

enum BodyType { PLANET, MOON, ASTEROID_BELT, GAS_GIANT, NEBULA, BLACK_HOLE, WORMHOLE }

@export var system_id: StringName
@export var body_type: BodyType
@export var orbital_slot: int = 0 # The body's position from the star (0 = innermost)
@export var position: Vector2 # Position in galaxy space (for nebulae, black holes, wormholes)
@export var size: float = 0.0 # Size/radius of the feature (for nebulae, black holes, wormholes)
@export var exit_position: Vector2 # Exit position for wormholes
