# /gamedata/empires/empire.gd
class_name Empire
extends Resource

enum DiplomacyStatus { WAR, PEACE, ALLIANCE, TRUCE }

## A unique identifier for this empire, e.g., "player_1" or "ai_silicoids".
@export var id: StringName

## The player-facing name, e.g., "Human Federation".
@export var display_name: String

## The primary color used for this empire's UI elements, borders, etc.
@export var color: Color

## The race that makes up this empire.
@export var race_preset: Resource # This will hold a RacePreset resource

## The empire's current treasury balance.
@export var treasury: int = 250

## The income generated per turn.
@export var income_per_turn: int = 25

## Tracks the diplomatic status with other empires.
## Key: other_empire.id (StringName), Value: DiplomacyStatus (enum)
@export var diplomatic_statuses: Dictionary = {}

## Flag to determine if this empire is controlled by the AI.
@export var is_ai_controlled: bool = false