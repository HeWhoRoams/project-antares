# /scripts/managers/CouncilManager.gd
extends Node

# Signal emitted when a vote is cast
signal vote_cast(voter_id: StringName, target_id: StringName)

# Signal emitted when a session starts
signal session_started

# Signal emitted when a session ends
signal session_ended

# Current session status
var session_status: Dictionary = {
	"active": false,
	"session_type": "",
	"participants": [],
	"current_vote": null
}

# Votes cast in the current session
var votes: Dictionary = {}

# Council members and leadership
var council_members: Array[StringName] = []
var council_president: StringName = ""

# Current session data
var current_session: Dictionary = {}

# Initialize the CouncilManager
func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

# Start a diplomatic council session
func start_session(session_type: String = "diplomatic") -> void:
	session_status = {
		"active": true,
		"session_type": session_type,
		"participants": _get_active_empires(),
		"current_vote": null
	}
	votes.clear()
	session_started.emit()
	print("CouncilManager: Started %s session with %d participants" % [session_type, session_status.participants.size()])

# End the current session
func end_session() -> void:
	session_status.active = false
	session_ended.emit()
	print("CouncilManager: Session ended")

# Get the current session status
func get_session_status() -> Dictionary:
	return session_status

# Cast a vote for an empire
func cast_vote(voter_id: StringName, target_id: StringName) -> bool:
	if not session_status.active:
		print("CouncilManager: No active session to vote in")
		return false

	if not session_status.participants.has(voter_id):
		print("CouncilManager: %s is not a participant in this session" % voter_id)
		return false

	votes[voter_id] = target_id
	vote_cast.emit(voter_id, target_id)
	
	# Check if all votes are cast and end session if so
	if votes.size() == session_status.participants.size():
		_tally_votes()
		end_session()
	
	return true

# Get all active empires for session participants
func _get_active_empires() -> Array:
	var active_empires = []
	for empire_id in EmpireManager.empires.keys():
		var empire = EmpireManager.get_empire_by_id(empire_id)
		if empire and not empire.is_ai_controlled:  # Only include human players for now
			active_empires.append(empire_id)
	return active_empires

# Tally the votes and apply results
func _tally_votes() -> void:
	var results = {}
	for voter_id in votes.keys():
		var target = votes[voter_id]
		if results.has(target):
			results[target] += 1
		else:
			results[target] = 1
	
	print("CouncilManager: Vote results: ", results)
	
	# Apply vote results based on session type
	_apply_vote_results(results)

# Apply the results of the votes
func _apply_vote_results(results: Dictionary) -> void:
	if results.is_empty():
		return

	# Find the winner (most votes)
	var winner = ""
	var max_votes = 0
	for target_id in results.keys():
		if results[target_id] > max_votes:
			max_votes = results[target_id]
			winner = target_id

	print("CouncilManager: Vote winner: %s with %d votes" % [winner, max_votes])

	# Apply effects based on session type
	match session_status.session_type:
		"diplomatic":
			_apply_diplomatic_effects(winner)
		"war_declaration":
			_apply_war_declaration_effects(winner)
		"treaty":
			_apply_treaty_effects(winner)

# Apply diplomatic effects from voting
func _apply_diplomatic_effects(winner: StringName) -> void:
	if winner.is_empty():
		return

	var winner_empire = EmpireManager.get_empire_by_id(winner)
	if winner_empire:
		# Increase diplomatic standing for the winner
		for empire_id in EmpireManager.empires.keys():
			if empire_id != winner:
				var other_empire = EmpireManager.get_empire_by_id(empire_id)
				if other_empire:
					# Adjust diplomatic status based on vote results
					# This is a simplified implementation
					pass

# Apply war declaration effects
func _apply_war_declaration_effects(winner: StringName) -> void:
	# Implementation for war declaration voting
	pass

# Apply treaty effects
func _apply_treaty_effects(winner: StringName) -> void:
	# Implementation for treaty voting
	pass

# Handle loading saved game data
func _on_save_data_loaded(data: Dictionary) -> void:
	var council_data = data.get("council", {})
	session_status = council_data.get("session_status", {"active": false})
	votes = council_data.get("votes", {})
	council_members = council_data.get("council_members", [])
	council_president = council_data.get("council_president", "")
	print("CouncilManager: Loaded council state from save")

# Static functions for public API

# Check if an empire qualifies for council membership
static func qualifies_for_council(empire_id: StringName) -> bool:
	var empire = EmpireManager.get_empire_by_id(empire_id)
	if not empire:
		return false

	# Qualification criteria (simplified - in a real game this would be more complex)
	return empire.income_per_turn >= 10 and not empire.is_ai_controlled

# Update council membership based on current empires
static func update_council_membership() -> void:
	if not CouncilManager:
		return

	CouncilManager.council_members.clear()

	for empire_id in EmpireManager.empires.keys():
		if qualifies_for_council(empire_id):
			CouncilManager.council_members.append(empire_id)

	# Elect a president if we have members
	if CouncilManager.council_members.size() > 0:
		CouncilManager._hold_elections()
	else:
		CouncilManager.council_president = ""

	print("CouncilManager: Updated council membership, %d members" % CouncilManager.council_members.size())

# Hold elections for council president
func _hold_elections() -> void:
	if council_members.is_empty():
		council_president = ""
		return

	# Simple election - just pick the first qualified empire (in a real game this would be more complex)
	council_president = council_members[0]
	print("CouncilManager: Elected %s as council president" % council_president)

# Start a diplomatic victory session (used for victory conditions)
static func start_diplomatic_victory_session() -> void:
	if not CouncilManager:
		return

	CouncilManager.start_session("diplomatic_victory")

# Remove a council member
static func remove_council_member(empire_id: StringName) -> void:
	if not CouncilManager:
		return

	CouncilManager.council_members.erase(empire_id)
	if CouncilManager.council_president == empire_id:
		CouncilManager._hold_elections()

	print("CouncilManager: Removed %s from council" % empire_id)
