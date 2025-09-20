# /gamedata/game_data.gd
# A resource to hold the current state of the game.
extends Resource
class_name GameData

# Player's main resources
@export var credits: int = 100
@export var research: int = 0

# Game progression
@export var current_turn: int = 1

# Player's assets
# Example: var owned_planets: Array[PlanetData]
# Example: var owned_ships: Array[ShipData]

# Technologies
@export var unlocked_technologies: Array[String] # Array of technology IDs
