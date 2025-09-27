# /gamedata/buildings/building_data.gd
class_name BuildingData
extends BuildableItem

enum BuildingType {
	NONE,
	HYDRO_FARM,
	AUTOMATED_FACTORY,
	RESEARCH_LAB,
	PLANETARY_DEFENSE,
	# Add other building types as needed
}

@export var building_type: BuildingType = BuildingType.NONE
@export var pollution_generated: int = 0
@export var morale_modifier: int = 0
@export var defense_bonus: int = 0

# Constructor
func _init() -> void:
	pass

# Static factory methods for convenience
static func create_hydroponics_farm() -> BuildingData:
	var building = BuildingData.new()
	building.id = &"bldg_hydroponics"
	building.display_name = "Hydroponics Farm"
	building.description = "Increases food production on planets."
	building.building_type = BuildingType.HYDRO_FARM
	building.build_cost_production = 10
	building.upkeep_energy = 1
	building.output_food = 5
	building.pollution_generated = 1
	building.morale_modifier = 0
	building.defense_bonus = 0
	return building

static func create_automated_factory() -> BuildingData:
	var building = BuildingData.new()
	building.id = &"bldg_automated_factory"
	building.display_name = "Automated Factory"
	building.description = "Increases industrial production output."
	building.building_type = BuildingType.AUTOMATED_FACTORY
	building.build_cost_production = 15
	building.upkeep_energy = 2
	building.output_production = 5
	building.pollution_generated = 2
	building.morale_modifier = -5
	building.defense_bonus = 0
	return building

static func create_research_lab() -> BuildingData:
	var building = BuildingData.new()
	building.id = &"bldg_research_lab"
	building.display_name = "Research Lab"
	building.description = "Generates research points for technological advancement."
	building.building_type = BuildingType.RESEARCH_LAB
	building.build_cost_production = 20
	building.upkeep_energy = 2
	building.output_research = 5
	building.pollution_generated = 0
	building.morale_modifier = 5
	building.defense_bonus = 0
	return building

static func create_planetary_defense() -> BuildingData:
	var building = BuildingData.new()
	building.id = &"bldg_planetary_defense"
	building.display_name = "Planetary Defense"
	building.description = "Boosts planetary defense capabilities against invasion."
	building.building_type = BuildingType.PLANETARY_DEFENSE
	building.build_cost_production = 25
	building.upkeep_energy = 3
	building.output_food = 0
	building.output_production = 0
	building.output_research = 0
	building.pollution_generated = 1
	building.morale_modifier = 0
	building.defense_bonus = 10
	return building

# Validation methods
func is_valid_building() -> bool:
	return is_valid() and building_type != BuildingType.NONE

func get_building_type_name() -> String:
	match building_type:
		BuildingType.HYDRO_FARM:
			return "Hydroponics Farm"
		BuildingType.AUTOMATED_FACTORY:
			return "Automated Factory"
		BuildingType.RESEARCH_LAB:
			return "Research Lab"
		BuildingType.PLANETARY_DEFENSE:
			return "Planetary Defense"
		_:
			return "Unknown Building"

func get_effect_description() -> String:
	var effects = []

	if output_food > 0:
		effects.append("+%d Food" % output_food)
	if output_production > 0:
		effects.append("+%d Production" % output_production)
	if output_research > 0:
		effects.append("+%d Research" % output_research)
	if defense_bonus > 0:
		effects.append("+%d Defense" % defense_bonus)
	if morale_modifier > 0:
		effects.append("+%d Morale" % morale_modifier)
	elif morale_modifier < 0:
		effects.append("%d Morale" % morale_modifier)
	if pollution_generated > 0:
		effects.append("+%d Pollution" % pollution_generated)

	return ", ".join(effects) if effects.size() > 0 else "No effects"

# Comparison methods
func is_same_type(other: BuildingData) -> bool:
	if other == null:
		return false
	return building_type == other.building_type

func compare_by_type(other: BuildingData) -> int:
	if building_type < other.building_type:
		return -1
	elif building_type > other.building_type:
		return 1
	else:
		return 0

# Utility methods
func get_pollution_level() -> int:
	return pollution_generated

func get_morale_impact() -> int:
	return morale_modifier

func get_defense_value() -> int:
	return defense_bonus

# Copy method
func duplicate() -> BuildingData:
	var copy = BuildingData.new()
	copy.id = id
	copy.display_name = display_name
	copy.description = description
	copy.building_type = building_type
	copy.build_cost_production = build_cost_production
	copy.upkeep_energy = upkeep_energy
	copy.output_food = output_food
	copy.output_production = output_production
	copy.output_research = output_research
	copy.pollution_generated = pollution_generated
	copy.morale_modifier = morale_modifier
	copy.defense_bonus = defense_bonus
	copy.is_unique = is_unique
	copy.prerequisites = prerequisites.duplicate()
	copy.category = category
	copy.tier = tier
	return copy

# Serialization methods
func to_dictionary() -> Dictionary:
	var data = to_dictionary()
	data["building_type"] = building_type
	data["pollution_generated"] = pollution_generated
	data["morale_modifier"] = morale_modifier
	data["defense_bonus"] = defense_bonus
	return data

static func from_dictionary(data: Dictionary) -> BuildingData:
	var building = BuildingData.new()
	building.id = data.get("id", "")
	building.display_name = data.get("display_name", "")
	building.description = data.get("description", "")
	building.building_type = data.get("building_type", BuildingType.NONE)
	building.build_cost_production = data.get("build_cost_production", 0)
	building.upkeep_energy = data.get("upkeep_energy", 0)
	building.output_food = data.get("output_food", 0)
	building.output_production = data.get("output_production", 0)
	building.output_research = data.get("output_research", 0)
	building.pollution_generated = data.get("pollution_generated", 0)
	building.morale_modifier = data.get("morale_modifier", 0)
	building.defense_bonus = data.get("defense_bonus", 0)
	building.is_unique = data.get("is_unique", false)
	building.prerequisites = data.get("prerequisites", []).duplicate()
	building.category = data.get("category", "General")
	building.tier = data.get("tier", 1)
	return building
