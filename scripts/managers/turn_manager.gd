# scripts/managers/turn_manager.gd
# Handles turn-based progression in the game, managing empire turn order, research advancement,
# technology effects application, and coordinating AI turns. Acts as the core of the game's turn loop.
extends Node

# Emitted when a full turn cycle completes for all empires, incrementing the global turn counter.
signal turn_ended(new_turn_number: int)

# Emitted to trigger processing of an empire's turn (e.g., colony updates, maintenance).
signal process_turn(empire: Empire)

# Emitted when it becomes an empire's turn to take actions.
signal start_of_turn(empire_id: StringName)

# Emitted when an empire finishes their turn.
signal end_of_turn(empire_id: StringName)

# Emitted when a sub-phase starts within an empire's turn.
signal sub_phase_started(empire_id: StringName, sub_phase: TurnSubPhase)

# Emitted when a sub-phase ends within an empire's turn.
signal sub_phase_ended(empire_id: StringName, sub_phase: TurnSubPhase)

# Enumeration defining the sub-phases within an empire's turn.
enum TurnSubPhase {
	MOVEMENT,           # Fleet movement and exploration
	PRODUCTION,         # Resource production and collection
	RESEARCH,           # Research advancement
	CONSTRUCTION,       # Building and ship construction completion
	DIPLOMACY,          # Diplomatic actions and council voting
	COMBAT_RESOLUTION   # Combat resolution
}

# The sequence of empire IDs determining the order of turns.
var turn_order: Array[StringName] = []

# Index in turn_order of the currently active empire.
var current_empire_index: int = 0

# The current global turn number (starts at 1, increments after all empires have played).
var current_turn: int = 1

# The current sub-phase within the active empire's turn.
var current_sub_phase: TurnSubPhase = TurnSubPhase.MOVEMENT

# Whether the current empire's turn is paused (e.g., waiting for combat resolution).
var turn_paused: bool = false


# Initializes the turn system for a new game.
# Populates the turn order from the empires dictionary, sets starting index and turn number.
# Emits the start_of_turn signal for the first empire if any exist.
# Optionally, the turn order can be shuffled for random play order.
# @param empires: Dictionary of all empires in the game, keyed by ID.
func start_new_game(empires: Dictionary) -> void:
	turn_order.clear()
	for empire_id in empires.keys():
		turn_order.append(empire_id)
	# Optionally shuffle for random order
	# turn_order.shuffle()
	current_empire_index = 0
	current_turn = 1
	current_sub_phase = TurnSubPhase.MOVEMENT
	turn_paused = false
	# Emit start of first turn
	if not turn_order.is_empty():
		start_of_turn.emit(turn_order[0])
		_start_sub_phase(turn_order[0], TurnSubPhase.MOVEMENT)


# Ends the current empire's turn, processes any end-of-turn logic, and advances to the next empire.
# Handles research advancement, turn cycling, victory checks, and AI turn activation.
# If no turn order exists (edge case), does nothing.
func end_turn() -> void:
	if turn_order.is_empty():
		return
	
	# Emit end of turn for current empire
	var current_empire_id = turn_order[current_empire_index]
	end_of_turn.emit(current_empire_id)
	
	# Process turn for current empire (colony updates, etc.)
	var empire = EmpireManager.get_empire_by_id(current_empire_id)
	if empire:
		process_turn.emit(empire)
		_process_research(empire)
	
	# Move to next empire in the order
	current_empire_index = (current_empire_index + 1) % turn_order.size()
	
	# If back to start of order (wrapped around), increment global turn and check victory
	if current_empire_index == 0:
		current_turn += 1
		turn_ended.emit(current_turn)
		GameManager.check_for_victory()
	
	# Emit start of turn for new current empire
	var new_empire_id = turn_order[current_empire_index]
	start_of_turn.emit(new_empire_id)
	
	# If the new empire is AI-controlled, immediately trigger its turn
	var new_empire = EmpireManager.get_empire_by_id(new_empire_id)
	if new_empire and new_empire.is_ai_controlled:
		AIManager.take_turn(new_empire_id)


# Connects to the save data loaded signal for restoring state.
func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

# Advances the empire's research progress and handles technology completion.
# Adds research points based on empire's RPT, checks for completion, unlocks tech, applies effects, and notifies player.
# Called at the end of each empire's turn.
# @param empire: The Empire object to process research for.
func _process_research(empire: Empire) -> void:
	if empire.current_researching_tech == "":
		return  # No tech being researched, skip
	
	var tech = DataManager.get_technology(empire.current_researching_tech)
	if not tech:
		return  # Invalid tech, skip
	
	empire.research_progress += empire.research_per_turn  # Increment progress
	
	if empire.research_progress >= tech.research_cost:
		# Tech completed, perform unlock logic
		empire.unlocked_techs.append(empire.current_researching_tech)
		empire.current_researching_tech = ""  # Clear current research
		empire.research_progress = 0  # Reset progress
		
		# Notify player (TODO: Implement proper popup notification)
		if not empire.is_ai_controlled:
			# TODO: Show notification popup
			print("Technology unlocked: " + tech.display_name)
		
		# Apply effects of the unlocked technology
		_apply_tech_effects(empire, tech)

		# Apply technology effects through the TechnologyEffectManager
		TechnologyEffectManager.apply_technology_effects(empire)

# Applies the effects of a newly unlocked technology to the empire.
# Parses the tech tree data to find the effects array for the given tech and applies them via _apply_effects.
# This is a design-time lookup; in a production system, effects could be cached.
# @param empire: The Empire receiving the effects.
# @param tech: The Technology object whose effects to apply.
func _apply_tech_effects(empire: Empire, tech: Technology) -> void:
	# Find the effects array from the external tech tree JSON data
	var tech_tree_data = DataManager.get_tech_tree_data()
	for category_data in tech_tree_data["categories"]:
		for tier_key in category_data["tiers"]:
			var tier_techs = category_data["tiers"][tier_key]
			for tech_data in tier_techs:
				if tech_data["id"] == tech.id:
					if tech_data.has("effects"):
						var effects = tech_data["effects"]
						_apply_effects(empire, effects)  # Apply each effect
						print("Applied effects for: " + tech.display_name)
					return  # Found and processed, exit nested loops

# Applies a list of effects to an empire, modifying its attributes based on effect type.
# Currently supports "EMPIRE_MODIFIER" type, e.g., adjusting income_per_turn as a multiplier.
# Effects are defined as dictionaries with "type", "target", and "value" keys.
# Unknown effect types are logged but ignored for future expansion.
# @param empire: The Empire to modify.
# @param effects: Array of effect dictionaries to apply.
func _apply_effects(empire: Empire, effects: Array) -> void:
	for effect in effects:
		var type = effect["type"]
		var target = effect["target"]
		var value = effect["value"]  # Often a float like 0.1 for 10% increase
		match type:
			"EMPIRE_MODIFIER":
				if target == "income_per_turn":
					empire.income_per_turn = int(empire.income_per_turn * (1.0 + value))  # Multiply by 1 + percentage
			_:
				print("Unknown effect type: " + type)  # Log unsupported effects for debugging

# Starts a new sub-phase for the specified empire.
# Emits the sub_phase_started signal and processes the sub-phase logic.
# @param empire_id: The empire whose sub-phase is starting.
# @param sub_phase: The sub-phase to start.
func _start_sub_phase(empire_id: StringName, sub_phase: TurnSubPhase) -> void:
	current_sub_phase = sub_phase
	sub_phase_started.emit(empire_id, sub_phase)
	print("TurnManager: Starting sub-phase %s for empire %s" % [TurnSubPhase.keys()[sub_phase], empire_id])

	# Process sub-phase specific logic
	_process_sub_phase(empire_id, sub_phase)

# Processes the logic for a specific sub-phase.
# @param empire_id: The empire whose sub-phase is being processed.
# @param sub_phase: The sub-phase to process.
func _process_sub_phase(empire_id: StringName, sub_phase: TurnSubPhase) -> void:
	var empire = EmpireManager.get_empire_by_id(empire_id)
	if not empire:
		return

	match sub_phase:
		TurnSubPhase.MOVEMENT:
			# Fleet movement and exploration
			_process_movement_phase(empire)
		TurnSubPhase.PRODUCTION:
			# Resource production and collection
			_process_production_phase(empire)
		TurnSubPhase.RESEARCH:
			# Research advancement
			_process_research_phase(empire)
		TurnSubPhase.CONSTRUCTION:
			# Building and ship construction completion
			_process_construction_phase(empire)
		TurnSubPhase.DIPLOMACY:
			# Diplomatic actions and council voting
			_process_diplomacy_phase(empire)
		TurnSubPhase.COMBAT_RESOLUTION:
			# Combat resolution
			_process_combat_phase(empire)

# Processes the movement phase for an empire.
# @param empire: The empire whose movement phase is being processed.
func _process_movement_phase(empire: Empire) -> void:
	# TODO: Process fleet movement, exploration, etc.
	print("TurnManager: Processing movement phase for %s" % empire.display_name)

	# For now, auto-advance to next phase
	_advance_sub_phase(empire.id)

# Processes the production phase for an empire.
# @param empire: The empire whose production phase is being processed.
func _process_production_phase(empire: Empire) -> void:
	# Process colony production
	ColonyManager.process_turn_for_empire(empire)
	print("TurnManager: Processing production phase for %s" % empire.display_name)

	# For now, auto-advance to next phase
	_advance_sub_phase(empire.id)

# Processes the research phase for an empire.
# @param empire: The empire whose research phase is being processed.
func _process_research_phase(empire: Empire) -> void:
	# Process research advancement
	_process_research(empire)
	print("TurnManager: Processing research phase for %s" % empire.display_name)

	# For now, auto-advance to next phase
	_advance_sub_phase(empire.id)

# Processes the construction phase for an empire.
# @param empire: The empire whose construction phase is being processed.
func _process_construction_phase(empire: Empire) -> void:
	# Construction completion is handled in ColonyManager.process_turn_for_empire
	# which was already called in production phase
	print("TurnManager: Processing construction phase for %s" % empire.display_name)

	# For now, auto-advance to next phase
	_advance_sub_phase(empire.id)

# Processes the diplomacy phase for an empire.
# @param empire: The empire whose diplomacy phase is being processed.
func _process_diplomacy_phase(empire: Empire) -> void:
	# Handle diplomatic actions and council voting
	GameManager.check_diplomatic_victory()
	print("TurnManager: Processing diplomacy phase for %s" % empire.display_name)

	# For now, auto-advance to next phase
	_advance_sub_phase(empire.id)

# Processes the combat resolution phase for an empire.
# @param empire: The empire whose combat phase is being processed.
func _process_combat_phase(empire: Empire) -> void:
	# TODO: Process combat resolution
	print("TurnManager: Processing combat phase for %s" % empire.display_name)

	# For now, auto-advance to next phase (which will end the turn)
	_advance_sub_phase(empire.id)

# Advances to the next sub-phase or ends the turn if all sub-phases are complete.
# @param empire_id: The empire whose turn is advancing.
func _advance_sub_phase(empire_id: StringName) -> void:
	sub_phase_ended.emit(empire_id, current_sub_phase)

	# Check if this was the last sub-phase
	if current_sub_phase == TurnSubPhase.COMBAT_RESOLUTION:
		# End the empire's turn
		end_turn()
	else:
		# Advance to next sub-phase
		var next_phase = current_sub_phase + 1
		_start_sub_phase(empire_id, next_phase)

# Restores turn-related state from a loaded game save.
# Optional fields provide backward compatibility if not present in older saves.
# @param data: Dictionary containing the saved game data.
func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("turn_order"):
		turn_order = data["turn_order"]
	if data.has("current_empire_index"):
		current_empire_index = data["current_empire_index"]
	if data.has("turn"):
		current_turn = data["turn"]
	if data.has("current_sub_phase"):
		current_sub_phase = data["current_sub_phase"]
	if data.has("turn_paused"):
		turn_paused = data["turn_paused"]
