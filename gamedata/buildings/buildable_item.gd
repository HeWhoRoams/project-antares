# /gamedata/buildings/buildable_item.gd
class_name BuildableItem
extends Resource

enum ItemType {
	BUILDING,
	SHIP,
	TECHNOLOGY,
	UNIT
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var id: StringName = ""
@export var display_name: String = ""
@export var description: String = ""
@export var item_type: ItemType = ItemType.BUILDING
@export var rarity: Rarity = Rarity.COMMON
@export var build_cost_production: int = 10
@export var research_cost: int = 0
@export var upkeep_energy: int = 0
@export var build_time: int = 1
@export var pollution_generated: int = 0
@export var morale_modifier: int = 0
@export var is_unique: bool = false
@export var prerequisites: Array[StringName] = []
@export var category: String = "General"
@export var tier: int = 1

# Constructor
func _init() -> void:
	pass

# Validation methods
func is_valid() -> bool:
	return not id.is_empty() and not display_name.is_empty() and build_cost_production >= 0

func has_prerequisites() -> bool:
	return not prerequisites.is_empty()

func meets_prerequisites(empire_techs: Array[StringName]) -> bool:
	for prereq in prerequisites:
		if not empire_techs.has(prereq):
			return false
	return true

# Comparison methods
func equals(other: BuildableItem) -> bool:
	if other == null:
		return false
	return id == other.id

func compare_by_cost(other: BuildableItem) -> int:
	if build_cost_production < other.build_cost_production:
		return -1
	elif build_cost_production > other.build_cost_production:
		return 1
	else:
		return 0

func compare_by_tier(other: BuildableItem) -> int:
	if tier < other.tier:
		return -1
	elif tier > other.tier:
		return 1
	else:
		return 0

# Utility methods
func get_full_description() -> String:
	var desc = description
	if pollution_generated > 0:
		desc += "\nPollution: +" + str(pollution_generated)
	elif pollution_generated < 0:
		desc += "\nPollution: " + str(pollution_generated)
	
	if morale_modifier > 0:
		desc += "\nMorale: +" + str(morale_modifier)
	elif morale_modifier < 0:
		desc += "\nMorale: " + str(morale_modifier)
	
	if upkeep_energy > 0:
		desc += "\nEnergy Upkeep: " + str(upkeep_energy)
	
	return desc

func get_requirements_summary() -> String:
	if prerequisites.is_empty():
		return "No prerequisites"
	else:
		return "Requires: " + ", ".join(prerequisites)

# Static factory methods for common buildable items
static func create_basic_item(item_id: StringName, name: String, cost: int = 10) -> BuildableItem:
	var item = BuildableItem.new()
	item.id = item_id
	item.display_name = name
	item.description = "A basic buildable item."
	item.build_cost_production = cost
	item.build_time = max(1, cost / 10)
	item.item_type = ItemType.BUILDING
	return item

static func create_advanced_item(item_id: StringName, name: String, cost: int = 50, tier_level: int = 2) -> BuildableItem:
	var item = BuildableItem.new()
	item.id = item_id
	item.display_name = name
	item.description = "An advanced buildable item."
	item.build_cost_production = cost
	item.tier = tier_level
	item.build_time = max(2, cost / 5)
	item.prerequisites = ["basic_technology"]
	item.item_type = ItemType.BUILDING
	return item

static func create_unique_item(item_id: StringName, name: String, cost: int = 100) -> BuildableItem:
	var item = BuildableItem.new()
	item.id = item_id
	item.display_name = name
	item.description = "A unique, one-per-empire buildable item."
	item.build_cost_production = cost
	item.is_unique = true
	item.tier = 3
	item.build_time = max(3, cost / 3)
	item.prerequisites = ["advanced_technology"]
	item.item_type = ItemType.BUILDING
	return item

# Copy method
func duplicate() -> BuildableItem:
	var copy = BuildableItem.new()
	copy.id = id
	copy.display_name = display_name
	copy.description = description
	copy.item_type = item_type
	copy.rarity = rarity
	copy.build_cost_production = build_cost_production
	copy.research_cost = research_cost
	copy.upkeep_energy = upkeep_energy
	copy.build_time = build_time
	copy.pollution_generated = pollution_generated
	copy.morale_modifier = morale_modifier
	copy.is_unique = is_unique
	copy.prerequisites = prerequisites.duplicate()
	copy.category = category
	copy.tier = tier
	return copy

# Serialization methods
func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"description": description,
		"item_type": item_type,
		"rarity": rarity,
		"build_cost_production": build_cost_production,
		"research_cost": research_cost,
		"upkeep_energy": upkeep_energy,
		"build_time": build_time,
		"pollution_generated": pollution_generated,
		"morale_modifier": morale_modifier,
		"is_unique": is_unique,
		"prerequisites": prerequisites,
		"category": category,
		"tier": tier
	}

static func from_dictionary(data: Dictionary) -> BuildableItem:
	var item = BuildableItem.new()
	item.id = data.get("id", "")
	item.display_name = data.get("display_name", "")
	item.description = data.get("description", "")
	item.item_type = data.get("item_type", ItemType.BUILDING)
	item.rarity = data.get("rarity", Rarity.COMMON)
	item.build_cost_production = data.get("build_cost_production", 0)
	item.research_cost = data.get("research_cost", 0)
	item.upkeep_energy = data.get("upkeep_energy", 0)
	item.build_time = data.get("build_time", 1)
	item.pollution_generated = data.get("pollution_generated", 0)
	item.morale_modifier = data.get("morale_modifier", 0)
	item.is_unique = data.get("is_unique", false)
	item.prerequisites = data.get("prerequisites", []).duplicate()
	item.category = data.get("category", "General")
	item.tier = data.get("tier", 1)
	return item
