# scripts/managers/GameManager.gd
# This script manages the overall state of the game, including transitioning between different phases,
# tracking active empires, handling victory conditions, and coordinating with other managers.
# It acts as a central hub for game logic and state persistence.
extends Node

# Enumeration defining the possible phases of the game flow.
# SETUP: Initial setup of the game.
# GALAXY_VIEW: Viewing and interacting with the galaxy map.
# COMBAT: Resolving battles between fleets.
# COLONY_VIEW: Managing colonies and production.
# GAME_OVER: End of the game, victory or defeat screen.
enum GamePhase {
	SETUP,
	GALAXY_VIEW,
	COMBAT,
	COLONY_VIEW,
	GAME_OVER
}

# Enumeration defining galaxy sizes.
enum GalaxySize {
	SMALL,    # 50 systems
	MEDIUM,   # 100 systems
	LARGE,    # 150 systems
	HUGE      # 250 systems
}

# Enumeration defining difficulty levels.
enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	IMPOSSIBLE
}

# Enumeration defining victory conditions.
enum VictoryCondition {
	CONQUEST,    # Own all other empires' home systems
	DIPLOMATIC  # Win Galactic Council votes
}

# Emitted whenever the game phase changes to notify other parts of the application.
signal game_phase_changed(new_phase: GamePhase)

# The current phase of the game, starts in SETUP.
var current_game_phase: GamePhase = GamePhase.SETUP

# List of IDs of empires that are still active in the game.
var active_empires: Array[StringName] = []

# The current game data object containing all persistent game state.
var current_game_data: GameData

# The current game setup configuration.
var current_game_setup: GameSetupData


# Sets the current game phase and emits a signal to notify listeners of the change.
# Used to transition the game flow between phases like setup, galaxy view, etc.
# @param new_phase: The new GamePhase to set.
func set_game_phase(new_phase: GamePhase) -> void:
	current_game_phase = new_phase
	game_phase_changed.emit(new_phase)

# Sets the game setup configuration for a new game.
# This should be called before start_new_game() to configure the game parameters.
# @param setup_data: The GameSetupData resource containing game configuration.
func set_game_setup(setup_data: GameSetupData) -> void:
	if setup_data and setup_data.validate():
		current_game_setup = setup_data
	else:
		push_error("Invalid game setup data provided")
		current_game_setup = GameSetupData.create_default()


func _ready() -> void:
	if not PlayerManager.player_won_game.is_connected(_on_player_won_game):
		PlayerManager.player_won_game.connect(_on_player_won_game)
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)


# Initializes a new game from scratch.
# Creates a new GameData instance, sets active empires to all empires managed by EmpireManager,
# and starts the turn system. Optionally, galaxy generation can be added here.
func start_new_game() -> void:
	current_game_data = GameData.new()
	active_empires = EmpireManager.empires.keys()
	TurnManager.start_new_game(EmpireManager.empires)
	# You can initialize other things here, like generating the galaxy
	# GalaxyManager.generate_galaxy(current_game_data)


# Returns the current game data object. Used by other components to access shared game state.
# @return: The GameData instance containing the current state's data.
func get_current_game_data() -> GameData:
	return current_game_data


# Checks if conquest victory has been achieved by any empire.
# Conquest victory is achieved when one empire owns at least one planet in every rival's home system.
# Iterates through all active empires and verifies if each has conquered all others' home worlds.
# @return: True if conquest victory is achieved by at least one empire, false otherwise.
func check_conquest_victory() -> bool:
	# Loop through each potential conquering empire
	for empire_a_id in active_empires:
		var empire_a = EmpireManager.get_empire_by_id(empire_a_id)
		if not empire_a:
			continue  # Skip if empire not found (should not happen normally)
		var has_conquered_all = true  # Assume this empire has conquered all until proven otherwise
		# Check against each rival empire
		for empire_b_id in active_empires:
			if empire_a_id == empire_b_id:
				continue  # Don't check against self
			var empire_b = EmpireManager.get_empire_by_id(empire_b_id)
			if not empire_b:
				continue  # Skip invalid empires
			var home_system = GalaxyManager.star_systems.get(empire_b.home_system_id)
			if not home_system:
				continue  # If home system doesn't exist, skip (edge case)
			var owns_home = false  # Check if empire_a owns any planet in empire_b's home system
			for body in home_system.celestial_bodies:
				if body is PlanetData and body.owner_id == empire_a_id:
					owns_home = true
					break  # Found at least one owned planet, no need to check further
			if not owns_home:
				has_conquered_all = false  # Failed to own home system, so not conquered all
				break  # No need to check more rivals
		if has_conquered_all:
			return true  # This empire has conquered all others
	return false  # No empire has achieved conquest victory

# Check for diplomatic victory through Galactic Council voting.
# Diplomatic victory occurs when the council votes for an emperor.
# @return: True if diplomatic victory has been achieved, false otherwise.
func check_diplomatic_victory() -> bool:
	# Update council membership first
	CouncilManager.update_council_membership()

	# If there's no active session and we have enough members, start one
	if CouncilManager.get_session_status().get("active", false) == false:
		if CouncilManager.council_members.size() >= 2:
			CouncilManager.start_diplomatic_victory_session()

	# Check if there's an active session
	var session_status = CouncilManager.get_session_status()
	if session_status.get("active", false):
		# For now, auto-vote for AI empires (simple implementation)
		# TODO: Implement proper AI voting logic
		for member_id in CouncilManager.council_members:
			var empire = EmpireManager.get_empire_by_id(member_id)
			if empire and empire.is_ai_controlled:
				if session_status.votes[member_id] == null:
					# AI votes for itself (simple strategy)
					CouncilManager.cast_vote(member_id, member_id)

	return false  # Victory will be triggered by CouncilManager when voting completes

# Placeholder for score-based victory (e.g., reached a certain score level).
# @return: Always false until scoring system is implemented.
func check_score_victory() -> bool:
	return false

# Checks all victory conditions in priority order and triggers victory if any is met.
# Currently prioritizes conquest over diplomatic over score.
func check_for_victory() -> void:
	if check_conquest_victory():
		_on_victory("conqueror", "Conquest")
	elif check_diplomatic_victory():
		_on_victory("diplomat", "Diplomacy")
	elif check_score_victory():
		_on_victory("scorer", "Score")

# Removes an empire from the active list when it has been eliminated (e.g., lost its home worlds).
# Note: Does not delete the empire data, just removes from active play.
# @param empire_id: The ID of the empire to eliminate from active list.
func eliminate_empire(empire_id: StringName) -> void:
	active_empires.erase(empire_id)

# Internal handler for when victory occurs. Sets game phase to end and switches to victory scene.
# @param _winner_id: ID of the winning entity (not used here but for potential expansion).
# @param _reason: Reason for victory (for UI or logging).
func _on_victory(_winner_id: StringName, _reason: String) -> void:
	set_game_phase(GamePhase.GAME_OVER)
	# Transition to victory screen
	SceneManager.change_scene("res://ui/screens/victory_screen.tscn")

# Loads game phase and active empires from saved data during game loading.
# @param data: Dictionary containing saved game data.
func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("game_phase"):
		current_game_phase = data["game_phase"] as GamePhase
	if data.has("active_empires"):
		active_empires = data["active_empires"]

# Handler for when a player achieves technology victory (e.g., research all techs).
# Connects to PlayerManager's signal to trigger game end.
func _on_player_won_game() -> void:
	_on_victory("player_1", "Technology")
