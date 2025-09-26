# /gamedata/game_data.gd
class_name GameData
extends Resource

@export var current_turn: int = 1
@export var galaxy_seed: int = 0
@export var difficulty: int = 1
@export var victory_condition: int = 0
@export var player_empire_id: StringName = ""
@export var ai_empire_ids: Array[StringName] = []
