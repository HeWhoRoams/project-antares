# /scripts/managers/EmpireManager.gd
# Manages all empires in the game, including registration, retrieval, and diplomatic relations.
# Handles loading and saving of empire data, and acts as the central repository for empire objects.
extends Node

const Empire = preload("res://gamedata/empires/empire.gd")
const RacePreset = preload("res://gamedata/races/race_preset.gd")

# Dictionary storing all active empires in the game, keyed by their unique StringName ID.
# Each value is an Empire object containing all empire-specific data and state.
var empires: Dictionary = {}

# Registers a new empire to the manager if it doesn't already exist.
# Prevents duplicate empire IDs and logs the registration.
# @param empire_data: The Empire object to add to the game.
func register_empire(empire_data: Empire) -> void:
	if empires.has(empire_data.id):
		printerr("EmpireManager: An empire with ID '%s' already exists!" % empire_data.id)
		return

	empires[empire_data.id] = empire_data

	# Apply race bonuses if race preset exists
	if empire_data.race_preset:
		_apply_race_bonuses(empire_data)

	print("EmpireManager: Registered new empire '%s'." % empire_data.display_name)

# Retrieves an empire object by its unique ID.
# Returns null if no empire with that ID exists.
# @param id: The StringName ID of the empire to retrieve.
# @return: The Empire object or null if not found.
func get_empire_by_id(id: StringName) -> Empire:
	return empires.get(id)

# Initializes diplomatic relationships between all empires at the start of a new game.
# Sets the default diplomatic status to PEACE for all pairs of empires.
# This ensures every empire has a defined stance towards every other empire.
func initialize_diplomacy() -> void:
	for id1 in empires:
		for id2 in empires:
			if id1 == id2:
				continue  # Skip self-relations (an empire doesn't have diplomacy with itself)

			var empire1: Empire = empires[id1]
			# By default, all empires start at peace.
			if not empire1.diplomatic_statuses.has(id2):
				empire1.diplomatic_statuses[id2] = Empire.DiplomacyStatus.PEACE

# Connects to the SaveLoadManager's signal if a game is being loaded.
func _ready() -> void:
	if SaveLoadManager and SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		print("EmpireManager: SaveLoadManager not available or not loading game")

# Handles loading empire data from a saved game.
# Reconstructs Empire objects from the serialized dictionary data,
# restoring all empire properties like treasury, colonies, ships, etc.
# Uses .get() with defaults for backward compatibility (e.g., research points).
# @param data: The loaded save data dictionary containing empires information.
func _on_save_data_loaded(data: Dictionary) -> void:
	if not data.has("empires"):
		printerr("EmpireManager: No empires data in save file!")
		return

	empires.clear()  # Clear any existing empires to avoid duplicates
	var empires_data = data["empires"]
	for empire_id in empires_data:
		var empire_data = empires_data[empire_id]
		var empire = Empire.new()  # Create new Empire instance
		# Load core empire attributes
		empire.id = empire_data["id"]
		empire.display_name = empire_data["display_name"]
		empire.color = Color(empire_data["color"][0], empire_data["color"][1], empire_data["color"][2], empire_data["color"][3])
		empire.treasury = empire_data["treasury"]
		empire.income_per_turn = empire_data["income_per_turn"]
		# Load research attributes with defaults for older saves
		empire.research_points = empire_data.get("research_points", 50)
		empire.research_per_turn = empire_data.get("research_per_turn", 10)
		empire.diplomatic_statuses = empire_data["diplomatic_statuses"]
		empire.is_ai_controlled = empire_data["is_ai_controlled"]
		# Conditionally load optional attributes present in newer saves
		if empire_data.has("home_system_id"):
			empire.home_system_id = empire_data["home_system_id"]
		if empire_data.has("owned_ships"):
			empire.owned_ships = empire_data["owned_ships"]
		if empire_data.has("owned_colonies"):
			empire.owned_colonies = empire_data["owned_colonies"]

		empires[empire_id] = empire

	print("EmpireManager: Empires loaded from save file.")

# Applies race-specific bonuses to an empire based on its race preset.
# Modifies starting resources, modifiers, and other empire attributes.
# @param empire: The Empire object to apply bonuses to.
func _apply_race_bonuses(empire: Empire) -> void:
	if not empire.race_preset:
		return

	var race = empire.race_preset

	# Apply starting bonuses
	empire.treasury = int(empire.treasury * race.starting_credits)
	empire.research_points = int(empire.research_points * race.starting_research)

	# Store race modifiers for later application (applied during colony/ship calculations)
	# The actual modifier application happens in ColonyManager and other systems
	print("EmpireManager: Applied race bonuses for %s (%s)" % [empire.display_name, race.display_name])
