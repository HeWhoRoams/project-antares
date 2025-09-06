# /gamedata/technologies/technology.gd
# Defines the data structure for a single researchable technology.

@tool
class_name Technology extends Resource

## The unique identifier for this technology (e.g., "tech_lasers_1").
@export var id: StringName

## The player-facing name of the technology (e.g., "Red Lasers").
@export var display_name: String

## The description shown in the UI, can include flavor text.
@export_multiline var description: String

## The icon to display in the technology tree.
@export var icon: Texture2D

## The amount of research points required to unlock this technology.
@export_range(0, 10000) var research_cost: int = 100

## The technologies that must be unlocked before this one is available.
@export var prerequisites: Array[Technology] = []

## (Future) Effects this technology unlocks, like new ship parts or buildings.
# @export var unlocked_effects: Array[Effect]