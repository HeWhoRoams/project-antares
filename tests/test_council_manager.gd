extends GutTest

func test_council_membership():
	var empire1 = Empire.new()
	empire1.id = "empire1"
	empire1.home_system_id = "sol"
	EmpireManager.register_empire(empire1)

	var empire2 = Empire.new()
	empire2.id = "empire2"
	empire2.home_system_id = "sirius"
	EmpireManager.register_empire(empire2)

	# Create home systems
	var sol_system = StarSystem.new()
	sol_system.id = "sol"
	var sol_planet = PlanetData.new()
	sol_planet.system_id = "sol"
	sol_planet.owner_id = "empire1"
	sol_system.celestial_bodies = [sol_planet]
	GalaxyManager.star_systems["sol"] = sol_system

	var sirius_system = StarSystem.new()
	sirius_system.id = "sirius"
	var sirius_planet = PlanetData.new()
	sirius_planet.system_id = "sirius"
	sirius_planet.owner_id = "empire2"
	sirius_system.celestial_bodies = [sirius_planet]
	GalaxyManager.star_systems["sirius"] = sirius_system

	# Test qualification
	assert_true(CouncilManager.qualifies_for_council("empire1"), "Empire1 should qualify for council")
	assert_true(CouncilManager.qualifies_for_council("empire2"), "Empire2 should qualify for council")

	# Test membership updates
	CouncilManager.update_council_membership()
	assert_true(CouncilManager.council_members.has("empire1"), "Empire1 should be council member")
	assert_true(CouncilManager.council_members.has("empire2"), "Empire2 should be council member")

func test_council_elections():
	# Clear existing members and add test members
	CouncilManager.council_members = ["empire1", "empire2", "empire3"]
	CouncilManager.council_president = ""

	CouncilManager._hold_elections()
	assert_not_null(CouncilManager.council_president, "President should be elected")
	assert_true(CouncilManager.council_members.has(CouncilManager.council_president), "President should be a council member")

func test_diplomatic_victory_session():
	CouncilManager.council_members = ["empire1", "empire2", "empire3"]
	CouncilManager.current_session = {}

	CouncilManager.start_diplomatic_victory_session()

	var session_status = CouncilManager.get_session_status()
	assert_true(session_status["active"], "Session should be active")
	assert_eq(session_status["members"].size(), 3, "All members should be in session")

func test_voting_mechanics():
	CouncilManager.council_members = ["empire1", "empire2", "empire3"]
	CouncilManager.start_diplomatic_victory_session()

	# Cast votes
	assert_true(CouncilManager.cast_vote("empire1", "empire2"), "Vote should be accepted")
	assert_true(CouncilManager.cast_vote("empire2", "empire2"), "Vote should be accepted")
	assert_true(CouncilManager.cast_vote("empire3", "empire2"), "Vote should be accepted")

	# Check session ended (all votes cast)
	var session_status = CouncilManager.get_session_status()
	assert_false(session_status["active"], "Session should have ended")

func test_invalid_votes():
	CouncilManager.council_members = ["empire1", "empire2"]
	CouncilManager.start_diplomatic_victory_session()

	# Test invalid votes
	assert_false(CouncilManager.cast_vote("non_member", "empire1"), "Non-member cannot vote")
	assert_false(CouncilManager.cast_vote("empire1", "non_member"), "Cannot vote for non-member")

func test_council_member_removal():
	CouncilManager.council_members = ["empire1", "empire2", "empire3"]
	CouncilManager.council_president = "empire1"

	CouncilManager.remove_council_member("empire1")
	assert_false(CouncilManager.council_members.has("empire1"), "Member should be removed")
	assert_not_null(CouncilManager.council_president, "New president should be elected")

func test_insufficient_members():
	CouncilManager.council_members = ["empire1"]
	CouncilManager.start_diplomatic_victory_session()

	var session_status = CouncilManager.get_session_status()
	assert_false(session_status["active"], "Session should not start with insufficient members")
