# /scripts/managers/EmpireManager.gd
extends Node

## A dictionary holding all active empires, keyed by their unique ID.
var empires: Dictionary = {}

## Adds a new empire to the game.
func register_empire(empire_data: Empire) -> void:
	if empires.has(empire_data.id):
		printerr("EmpireManager: An empire with ID '%s' already exists!" % empire_data.id)
		return
	
	empires[empire_data.id] = empire_data
	print("EmpireManager: Registered new empire '%s'." % empire_data.display_name)

## Retrieves an empire's data using its ID.
func get_empire_by_id(id: StringName) -> Empire:
	return empires.get(id)

## Called at the start of a new game to set initial diplomatic states.
func initialize_diplomacy() -> void:
	for id1 in empires:
		for id2 in empires:
			if id1 == id2:
				continue

			var empire1: Empire = empires[id1]
			# By default, all empires start at peace.
			if not empire1.diplomatic_statuses.has(id2):
				empire1.diplomatic_statuses[id2] = Empire.DiplomacyStatus.PEACE

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

func _on_save_data_loaded(data: Dictionary) -> void:
	if not data.has("empires"):
		printerr("EmpireManager: No empires data in save file!")
		return

	empires.clear()
	var empires_data = data["empires"]
	for empire_id in empires_data:
		var empire_data = empires_data[empire_id]
		var empire = Empire.new()
		empire.id = empire_data["id"]
		empire.display_name = empire_data["display_name"]
		empire.color = Color(empire_data["color"][0], empire_data["color"][1], empire_data["color"][2], empire_data["color"][3])
		empire.treasury = empire_data["treasury"]
		empire.income_per_turn = empire_data["income_per_turn"]
		empire.diplomatic_statuses = empire_data["diplomatic_statuses"]
		empire.is_ai_controlled = empire_data["is_ai_controlled"]

		empires[empire_id] = empire

	print("EmpireManager: Empires loaded from save file.")
