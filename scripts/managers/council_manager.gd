extends Node

# Galactic Council Manager
# Handles the Galactic Council system for diplomatic victory
# Tracks council members, elections, and voting on resolutions

signal council_session_started(session_data: Dictionary)
signal council_session_ended(results: Dictionary)
signal council_member_added(empire_id: StringName)
signal council_member_removed(empire_id: StringName)

# Council membership - empires that have colonized their home systems
var council_members: Array[StringName] = []

# Current council leader/president
var council_president: StringName = ""

# Current council session data
var current_session: Dictionary = {}

# Council election history
var election_history: Array[Dictionary] = []

# Council resolutions history
var resolution_history: Array[Dictionary] = []

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

# Check if an empire qualifies for council membership
func qualifies_for_council(empire_id: StringName) -> bool:
	var empire = EmpireManager.get_empire_by_id(empire_id)
	if not empire:
		return false

	# Must own at least one planet in their home system
	if not empire.home_system_id:
		return false

	var home_system = GalaxyManager.star_systems.get(empire.home_system_id)
	if not home_system:
		return false

	for body in home_system.celestial_bodies:
		if body is PlanetData and body.owner_id == empire_id:
			return true

	return false

# Add an empire to the council
func add_council_member(empire_id: StringName) -> void:
	if not qualifies_for_council(empire_id):
		return

	if not council_members.has(empire_id):
		council_members.append(empire_id)
		council_member_added.emit(empire_id)
		print("CouncilManager: Empire %s added to Galactic Council" % empire_id)

# Remove an empire from the council
func remove_council_member(empire_id: StringName) -> void:
	if council_members.has(empire_id):
		council_members.erase(empire_id)
		council_member_removed.emit(empire_id)

		# If the president was removed, hold new elections
		if council_president == empire_id:
			council_president = ""
			_hold_elections()
		print("CouncilManager: Empire %s removed from Galactic Council" % empire_id)

# Hold council elections for president
func _hold_elections() -> void:
	if council_members.is_empty():
		return

	# Simple election: random selection for now
	# TODO: Implement proper election mechanics based on influence/population
	council_president = council_members[randi() % council_members.size()]

	var election_result = {
		"turn": TurnManager.current_turn,
		"president": council_president,
		"candidates": council_members.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}

	election_history.append(election_result)
	print("CouncilManager: Empire %s elected as Galactic Council President" % council_president)

# Start a council session for diplomatic victory voting
func start_diplomatic_victory_session() -> void:
	if council_members.size() < 2:
		print("CouncilManager: Not enough council members for diplomatic victory")
		return

	current_session = {
		"type": "diplomatic_victory",
		"start_turn": TurnManager.current_turn,
		"votes": {},
		"voting_closed": false,
		"timestamp": Time.get_unix_time_from_system()
	}

	# Initialize votes for all council members
	for member_id in council_members:
		current_session.votes[member_id] = null  # null means no vote yet

	council_session_started.emit(current_session)
	print("CouncilManager: Diplomatic victory council session started")

# Cast a vote in the current session
func cast_vote(empire_id: StringName, vote_target: StringName) -> bool:
	if not current_session.has("votes") or not current_session.votes.has(empire_id):
		return false

	if not council_members.has(vote_target):
		return false

	current_session.votes[empire_id] = vote_target
	print("CouncilManager: Empire %s voted for %s in diplomatic victory" % [empire_id, vote_target])

	# Check if all votes are in
	if _all_votes_cast():
		_end_session()

	return true

# Check if all council members have cast their votes
func _all_votes_cast() -> bool:
	for member_id in council_members:
		if current_session.votes[member_id] == null:
			return false
	return true

# End the current council session and determine results
func _end_session() -> void:
	current_session.voting_closed = true

	var vote_counts = {}
	for voter_id in current_session.votes:
		var vote_target = current_session.votes[voter_id]
		if not vote_counts.has(vote_target):
			vote_counts[vote_target] = 0
		vote_counts[vote_target] += 1

	# Find the winner (most votes)
	var winner = ""
	var max_votes = 0
	for candidate in vote_counts:
		if vote_counts[candidate] > max_votes:
			max_votes = vote_counts[candidate]
			winner = candidate
		elif vote_counts[candidate] == max_votes:
			# Tie - no winner
			winner = ""
			break

	var results = {
		"session_type": current_session.type,
		"winner": winner,
		"vote_counts": vote_counts,
		"total_votes": council_members.size(),
		"session_data": current_session
	}

	resolution_history.append(results)
	council_session_ended.emit(results)

	if winner:
		print("CouncilManager: Diplomatic victory! Empire %s won with %d votes" % [winner, max_votes])
		GameManager._on_victory(winner, "Diplomatic Victory")
	else:
		print("CouncilManager: Diplomatic victory vote resulted in a tie - no winner")

	current_session = {}

# Get current session status
func get_session_status() -> Dictionary:
	if current_session.is_empty():
		return {"active": false}

	var status = current_session.duplicate()
	status["active"] = true
	status["members"] = council_members.duplicate()
	status["votes_cast"] = 0

	for member_id in council_members:
		if current_session.votes[member_id] != null:
			status.votes_cast += 1

	return status

# Update council membership (call this periodically)
func update_council_membership() -> void:
	var empires = EmpireManager.empires.keys()

	# Add new qualifying members
	for empire_id in empires:
		if qualifies_for_council(empire_id):
			add_council_member(empire_id)

	# Remove disqualified members
	for member_id in council_members.duplicate():
		if not qualifies_for_council(member_id):
			remove_council_member(member_id)

	# Hold elections if no president
	if council_president == "" and council_members.size() > 0:
		_hold_elections()

func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("council"):
		var council_data = data["council"]
		council_members = council_data.get("members", [])
		council_president = council_data.get("president", "")
		current_session = council_data.get("current_session", {})
		election_history = council_data.get("election_history", [])
		resolution_history = council_data.get("resolution_history", [])

		print("CouncilManager: Council data loaded from save file")
