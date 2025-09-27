# /gamedata/AIDecisionWeights.gd
class_name AIDecisionWeights
extends Resource

# AI Decision Priorities (0-100 scale)
@export var colony_expansion: int = 50
@export var military_buildup: int = 50
@export var research_focus: int = 50
@export var economic_growth: int = 50

# Constructor
func _init() -> void:
	pass

# Utility methods
func normalize() -> void:
	colony_expansion = clamp(colony_expansion, 0, 100)
	military_buildup = clamp(military_buildup, 0, 100)
	research_focus = clamp(research_focus, 0, 100)
	economic_growth = clamp(economic_growth, 0, 100)

func get_total_weight() -> int:
	return colony_expansion + military_buildup + research_focus + economic_growth

func get_normalized_weights() -> Dictionary:
	var total = get_total_weight()
	if total == 0:
		return {
			"colony_expansion": 0.25,
			"military_buildup": 0.25,
			"research_focus": 0.25,
			"economic_growth": 0.25
		}
	
	return {
		"colony_expansion": float(colony_expansion) / total,
		"military_buildup": float(military_buildup) / total,
		"research_focus": float(research_focus) / total,
		"economic_growth": float(economic_growth) / total
	}

# Adjustment methods
func adjust_colony_expansion(amount: int) -> void:
	colony_expansion = clamp(colony_expansion + amount, 0, 100)

func adjust_military_buildup(amount: int) -> void:
	military_buildup = clamp(military_buildup + amount, 0, 100)

func adjust_research_focus(amount: int) -> void:
	research_focus = clamp(research_focus + amount, 0, 100)

func adjust_economic_growth(amount: int) -> void:
	economic_growth = clamp(economic_growth + amount, 0, 100)

# Static factory methods for different AI personalities
static func create_aggressive_weights() -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()
	weights.colony_expansion = 70
	weights.military_buildup = 80
	weights.research_focus = 30
	weights.economic_growth = 40
	return weights

static func create_defensive_weights() -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()
	weights.colony_expansion = 40
	weights.military_buildup = 70
	weights.research_focus = 50
	weights.economic_growth = 60
	return weights

static func create_expansionist_weights() -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()
	weights.colony_expansion = 90
	weights.military_buildup = 40
	weights.research_focus = 30
	weights.economic_growth = 50
	return weights

static func create_technological_weights() -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()
	weights.colony_expansion = 50
	weights.military_buildup = 30
	weights.research_focus = 90
	weights.economic_growth = 60
	return weights

static func create_balanced_weights() -> AIDecisionWeights:
	var weights = AIDecisionWeights.new()
	weights.colony_expansion = 60
	weights.military_buildup = 50
	weights.research_focus = 60
	weights.economic_growth = 70
	return weights

# Copy method
func duplicate() -> AIDecisionWeights:
	var copy = AIDecisionWeights.new()
	copy.colony_expansion = colony_expansion
	copy.military_buildup = military_buildup
	copy.research_focus = research_focus
	copy.economic_growth = economic_growth
	return copy

# Comparison method
func equals(other: AIDecisionWeights) -> bool:
	if other == null:
		return false
	return (colony_expansion == other.colony_expansion and
			military_buildup == other.military_buildup and
			research_focus == other.research_focus and
			economic_growth == other.economic_growth)

# String representation
func to_string() -> String:
	return "AIDecisionWeights(Colony: %d, Military: %d, Research: %d, Economy: %d)" % [
		colony_expansion, military_buildup, research_focus, economic_growth
	]
