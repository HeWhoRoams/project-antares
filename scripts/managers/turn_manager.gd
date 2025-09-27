# /scripts/managers/turn_manager.gd
extends Node

signal start_of_turn(empire_id: StringName)
signal turn_ended(new_turn_number: int)
signal sub_phase_changed(new_sub_phase: TurnSubPhase)

enum TurnSubPhase {
	SETUP,
	MOVEMENT,
	PRODUCTION,
	RESEARCH,
	CONSTRUCTION,
	DIPLOMACY,
	COMBAT_RESOLUTION,
	CLEANUP
}

const EmpireManager = preload("res://scripts/managers/EmpireManager.gd")
const PlayerManager = preload("res://scripts/managers/player_manager.gd")
const AIManager = preload("res://scripts/managers/ai_manager.gd")
const ColonyManager = preload("res://scripts/managers/ColonyManager.gd")
const GameManager = preload("res://scripts/managers/GameManager.gd")
const SaveLoadManager = preload("res://scripts/managers/SaveLoadManager.gd")

var current_turn: int = 1
var current_sub_phase: TurnSubPhase = TurnSubPhase.SETUP
var turn_order: Array[StringName] = []
var current_empire_index: int = 0
var is_processing_turn: bool = false

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		_initialize_new_game_state()

func _initialize_new_game_state() -> void:
	# Initialize turn order with all active empires
	turn_order = EmpireManager.empires.keys()
	current_empire_index = 0
	current_turn = 1
	current_sub_phase = TurnSubPhase.SETUP
	is_processing_turn = false

func start_new_game(empires: Dictionary) -> void:
	turn_order = empires.keys()
	current_empire_index = 0
	current_turn = 1
	current_sub_phase = TurnSubPhase.SETUP
	is_processing_turn = false
	
	# Notify that the first turn is starting
	start_of_turn.emit(turn_order[current_empire_index])

func advance_to_next_empire() -> void:
	if turn_order.is_empty():
		return

	current_empire_index = (current_empire_index + 1) % turn_order.size()
	
	if current_empire_index == 0:
		# We've completed a full cycle through all empires
		advance_to_next_turn()
	else:
		# Move to next empire in the current turn
		var current_empire_id = turn_order[current_empire_index]
		start_of_turn.emit(current_empire_id)

func advance_to_next_turn() -> void:
	current_turn += 1
	current_sub_phase = TurnSubPhase.SETUP
	turn_ended.emit(current_turn)
	
	# Start the next turn cycle
	if not turn_order.is_empty():
		current_empire_index = 0
		var current_empire_id = turn_order[current_empire_index]
		start_of_turn.emit(current_empire_id)

func process_turn_for_empire(empire_id: StringName) -> void:
	if is_processing_turn:
		return
	
	is_processing_turn = true
	
	# Process the turn in sub-phases
	match current_sub_phase:
		TurnSubPhase.SETUP:
			_process_setup_phase(empire_id)
		TurnSubPhase.MOVEMENT:
			_process_movement_phase(empire_id)
		TurnSubPhase.PRODUCTION:
			_process_production_phase(empire_id)
		TurnSubPhase.RESEARCH:
			_process_research_phase(empire_id)
		TurnSubPhase.CONSTRUCTION:
			_process_construction_phase(empire_id)
		TurnSubPhase.DIPLOMACY:
			_process_diplomacy_phase(empire_id)
		TurnSubPhase.COMBAT_RESOLUTION:
			_process_combat_resolution_phase(empire_id)
		TurnSubPhase.CLEANUP:
			_process_cleanup_phase(empire_id)
	
	is_processing_turn = false
	
	# Advance to next sub-phase or next empire
	if current_sub_phase == TurnSubPhase.CLEANUP:
		advance_to_next_empire()
	else:
		current_sub_phase = TurnSubPhase.get(current_sub_phase + 1)
		sub_phase_changed.emit(current_sub_phase)
		process_turn_for_empire(empire_id)

func _process_setup_phase(empire_id: StringName) -> void:
	# Setup phase - prepare for turn processing
	print("TurnManager: Processing setup phase for empire %s" % empire_id)

func _process_movement_phase(empire_id: StringName) -> void:
	# Movement phase - handle fleet movements
	print("TurnManager: Processing movement phase for empire %s" % empire_id)
	
	var empire = EmpireManager.get_empire_by_id(empire_id)
	if not empire:
		return
		
	# Process ship movement for the empire
	for ship_id in empire.owned_ships.keys():
		var ship = empire.owned_ships[ship_id]
		if ship.turns_to_arrival > 0:
			ship.turns_to_arrival -= 1
			if ship.turns_to_arrival == 0:
				ship.current_system_id = ship.destination_system_id
				ship.destination_system_id = &""
				ship_arrived.emit(ship)

func _process_production_phase(empire_id: StringName) -> void:
	# Production phase - handle resource generation
	print("TurnManager: Processing production phase for empire %s" % empire_id)
	
	ColonyManager.process_turn_for_empire(empire_id)

func _process_research_phase(empire_id: StringName) -> void:
	# Research phase - handle technology research
	print("TurnManager: Processing research phase for empire %s" % empire_id)
	
	var empire = EmpireManager.get_empire_by_id(empire_id)
	if not empire:
		return
		
	# Add research points
	empire.research_points += empire.research_per_turn
	research_points_changed.emit(empire.research_points)

func _process_construction_phase(empire_id: StringName) -> void:
	# Construction phase - handle building construction
	print("TurnManager: Processing construction phase for empire %s" % empire_id)
	
	ColonyManager.process_construction_for_empire(empire_id)

func _process_diplomacy_phase(empire_id: StringName) -> void:
	# Diplomacy phase - handle diplomatic actions
	print("TurnManager: Processing diplomacy phase for empire %s" % empire_id)
	
	# AI empires take their diplomatic turns
	if empire_id.begins_with("ai_"):
		AIManager.take_turn(empire_id)

func _process_combat_resolution_phase(empire_id: StringName) -> void:
	# Combat resolution phase - handle combat
	print("TurnManager: Processing combat resolution phase for empire %s" % empire_id)

func _process_cleanup_phase(empire_id: StringName) -> void:
	# Cleanup phase - finalize turn processing
	print("TurnManager: Processing cleanup phase for empire %s" % empire_id)

func get_current_empire_id() -> StringName:
	if turn_order.is_empty():
		return &""
	return turn_order[current_empire_index]

func is_player_turn() -> bool:
	var current_empire_id = get_current_empire_id()
	return not current_empire_id.begins_with("ai_")

func skip_to_next_phase() -> void:
	if current_sub_phase == TurnSubPhase.CLEANUP:
		advance_to_next_empire()
	else:
		current_sub_phase = TurnSubPhase.get(current_sub_phase + 1)
		sub_phase_changed.emit(current_sub_phase)

func get_turn_status() -> Dictionary:
	return {
		"current_turn": current_turn,
		"current_sub_phase": current_sub_phase,
		"current_empire_id": get_current_empire_id(),
		"turn_order": turn_order,
		"current_empire_index": current_empire_index,
		"is_processing_turn": is_processing_turn
	}

func _on_save_data_loaded(data: Dictionary) -> void:
	var turn_data = data.get("turn", {})
	current_turn = turn_data.get("current_turn", 1)
	current_sub_phase = turn_data.get("current_sub_phase", TurnSubPhase.SETUP)
	turn_order = turn_data.get("turn_order", [])
	current_empire_index = turn_data.get("current_empire_index", 0)
	is_processing_turn = turn_data.get("is_processing_turn", false)
	
	print("TurnManager: Loaded turn state from save.")

# Static utility methods
static func get_sub_phase_name(sub_phase: TurnSubPhase) -> String:
	match sub_phase:
		TurnSubPhase.SETUP: return "Setup"
		TurnSubPhase.MOVEMENT: return "Movement"
		TurnSubPhase.PRODUCTION: return "Production"
		TurnSubPhase.RESEARCH: return "Research"
		TurnSubPhase.CONSTRUCTION: return "Construction"
		TurnSubPhase.DIPLOMACY: return "Diplomacy"
		TurnSubPhase.COMBAT_RESOLUTION: return "Combat Resolution"
		TurnSubPhase.CLEANUP: return "Cleanup"
		_: return "Unknown"

static func get_turn_progress_percentage(current_phase: TurnSubPhase) -> float:
	var total_phases = TurnSubPhase.size()
	var current_phase_index = TurnSubPhase.keys().find(current_phase)
	return float(current_phase_index) / float(total_phases) * 100.0
