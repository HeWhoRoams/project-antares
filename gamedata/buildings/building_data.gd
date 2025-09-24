class_name BuildingData
extends BuildableItem

# Building-specific data that extends the base BuildableItem
# Buildings provide ongoing effects to colonies

enum BuildingType {
	INFRASTRUCTURE,  # Population growth, happiness
	INDUSTRY,        # Production bonuses
	RESEARCH,        # Research bonuses
	DEFENSE,         # Military defense
	SPECIAL          # Unique effects
}

enum BuildingTier {
	BASIC,
	ADVANCED,
	ELITE
}

# Building classification
@export var building_type: BuildingType = BuildingType.INDUSTRY
@export var building_tier: BuildingTier = BuildingTier.BASIC

# Maintenance costs (credits per turn)
@export var maintenance_cost: int = 0

# Operational requirements
@export var requires_power: bool = false
@export var requires_workers: bool = false

# Effect modifiers (applied to colony when built)
@export var food_modifier: float = 0.0      # Multiplier to food production
@export var production_modifier: float = 0.0 # Multiplier to production
@export var research_modifier: float = 0.0   # Multiplier to research
@export var population_growth_modifier: float = 0.0  # Multiplier to growth rate
@export var morale_modifier: int = 0         # Flat morale bonus/penalty

# Special effects
@export var pollution_generated: int = 0     # Pollution this building creates
@export var defense_bonus: int = 0           # Ground defense strength
@export var sensor_range_bonus: int = 0      # Increases colony sensor range

# Prerequisites
@export var required_technology: StringName = ""  # Tech required to build
@export var required_building: StringName = ""    # Another building required

# Construction requirements
@export var construction_time: int = 1       # Turns to build (minimum 1)

# Visual/icon representation
@export var icon_texture: Texture2D
@export var building_sprite: Texture2D

# Flavor and description
@export_multiline var flavor_text: String = ""
@export_multiline var strategic_notes: String = ""

func _init():
	super._init()
	# Set default production cost if not set
	if production_cost == 0:
		production_cost = 50

func can_build_in_colony(colony: ColonyData, empire_techs: Array) -> bool:
	# Check technology prerequisite
	if not required_technology.is_empty() and not empire_techs.has(required_technology):
		return false

	# Check building prerequisite (simplified - would need colony building tracking)
	if not required_building.is_empty():
		# TODO: Check if colony has required building
		pass

	# Check planet-specific restrictions
	var planet = _get_planet_for_colony(colony)
	if planet:
		# Example restrictions based on planet type
		match building_type:
			BuildingType.RESEARCH:
				if planet.planet_type == PlanetData.PlanetType.BARREN:
					return false  # Research buildings don't work well on barren worlds
			BuildingType.INDUSTRY:
				if planet.planet_type == PlanetData.PlanetType.ICE:
					return false  # Industrial buildings don't work well on ice worlds

	return true

func get_construction_cost() -> int:
	return production_cost

func get_maintenance_cost() -> int:
	return maintenance_cost

func get_total_cost_over_time(turns_to_build: int) -> int:
	return (production_cost + (maintenance_cost * turns_to_build))

func get_effect_description() -> String:
	var effects = []

	if food_modifier != 0:
		var sign = "+" if food_modifier > 0 else ""
		effects.append("Food: %s%.0f%%" % [sign, food_modifier * 100])

	if production_modifier != 0:
		var sign = "+" if production_modifier > 0 else ""
		effects.append("Production: %s%.0f%%" % [sign, production_modifier * 100])

	if research_modifier != 0:
		var sign = "+" if research_modifier > 0 else ""
		effects.append("Research: %s%.0f%%" % [sign, research_modifier * 100])

	if population_growth_modifier != 0:
		var sign = "+" if population_growth_modifier > 0 else ""
		effects.append("Growth: %s%.0f%%" % [sign, population_growth_modifier * 100])

	if morale_modifier != 0:
		var sign = "+" if morale_modifier > 0 else ""
		effects.append("Morale: %s%d" % [sign, morale_modifier])

	if defense_bonus > 0:
		effects.append("Defense: +%d" % defense_bonus)

	if pollution_generated > 0:
		effects.append("Pollution: +%d" % pollution_generated)

	return ", ".join(effects) if effects.size() > 0 else "No special effects"

func _get_planet_for_colony(colony: ColonyData) -> PlanetData:
	# Helper to get planet data for a colony
	for system in GalaxyManager.star_systems.values():
		for body in system.celestial_bodies:
			if body is PlanetData and body.system_id == colony.system_id and body.orbital_slot == colony.orbital_slot:
				return body
	return null

# Static factory methods for common buildings
static func create_hydroponics_farm() -> BuildingData:
	var building = BuildingData.new()
	building.id = "bldg_hydroponics"
	building.display_name = "Hydroponics Farm"
	building.description = "Advanced farming facility that maximizes food production from limited space."
	building.production_cost = 60
	building.maintenance_cost = 2
	building.building_type = BuildingData.BuildingType.INFRASTRUCTURE
	building.food_modifier = 0.5  # +50% food production
	building.required_technology = "tech_hydroponics"
	building.construction_time = 2
	return building

static func create_automated_factory() -> BuildingData:
	var building = BuildingData.new()
	building.id = "bldg_auto_factory"
	building.display_name = "Automated Factory"
	building.description = "Robotic manufacturing facility that produces goods with minimal supervision."
	building.production_cost = 100
	building.maintenance_cost = 4
	building.building_type = BuildingData.BuildingType.INDUSTRY
	building.production_modifier = 0.75  # +75% production
	building.pollution_generated = 2
	building.required_technology = "tech_robotics"
	building.construction_time = 3
	return building

static func create_research_lab() -> BuildingData:
	var building = BuildingData.new()
	building.id = "bldg_research_lab"
	building.display_name = "Research Laboratory"
	building.description = "State-of-the-art facility for scientific research and technological advancement."
	building.production_cost = 80
	building.maintenance_cost = 3
	building.building_type = BuildingData.BuildingType.RESEARCH
	building.research_modifier = 0.6  # +60% research
	building.required_technology = "tech_physics"
	building.construction_time = 2
	return building

static func create_planetary_defense() -> BuildingData:
	var building = BuildingData.new()
	building.id = "bldg_planetary_defense"
	building.display_name = "Planetary Defense Battery"
	building.description = "Automated defense system that protects the colony from orbital bombardment."
	building.production_cost = 120
	building.maintenance_cost = 5
	building.building_type = BuildingData.BuildingType.DEFENSE
	building.defense_bonus = 50
	building.required_technology = "tech_planetary_defense"
	building.construction_time = 4
	return building
