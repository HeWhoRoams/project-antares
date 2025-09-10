# /gamedata/factions/race_personality.gd
class_name RacePersonality
extends Resource

@export_group("Diplomatic Style")
@export_range(1, 10) var eloquence: int = 5
@export_range(1, 10) var formality: int = 5

@export_group("Behavioral Traits")
@export_range(1, 10) var aggression: int = 5
@export_range(1, 10) var pragmatism: int = 5
@export_range(1, 10) var honor: int = 5
@export_range(1, 10) var patience: int = 5

@export_group("Trust & Deception")
@export_range(1, 10) var trust: int = 5
@export_range(1, 10) var deception: int = 5
@export_range(1, 10) var vindictiveness: int = 5

@export_group("State-Based")
@export_range(1, 10) var desperation: int = 1
