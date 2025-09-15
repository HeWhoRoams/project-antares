# /scripts/managers/turn_manager.gd
extends Node

signal turn_ended(new_turn_number: int)

var current_turn: int = 1

func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)

func _on_save_data_loaded(data: Dictionary) -> void:
	current_turn = data.get("turn", 1)
	print("TurnManager: Loaded turn %d from save." % current_turn)

func end_turn() -> void:
	var previous_turn = current_turn
	current_turn += 1
	
	print("--- Turn %s Ended ---" % previous_turn)
	
	# Process colony updates for all empires
	for empire in EmpireManager.empires.values():
		ColonyManager.process_turn_for_empire(empire)
	
	print("--- Turn %s Began ---" % current_turn)
	
	turn_ended.emit(current_turn)