# /gamedata/buildings/buildable_item.gd
class_name BuildableItem
extends Resource

## The unique identifier for this item, e.g., "bldg_hydroponics" or "ship_scout".
@export var id: StringName

## The player-facing name, e.g., "Hydroponics Farm".
@export var display_name: String

## The amount of industrial production points required to build this item.
@export var production_cost: int = 50

## A description of the item for UI tooltips.
@export_multiline var description: String