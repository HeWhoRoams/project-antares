# /scripts/managers/turn_manager.gd
extends Node

signal turn_ended(new_turn_number: int)
signal process_turn(empire: Empire)


func end_turn() -> void:
	var game_data = GameManager.get_current_game_data()
	if not game_data:
		printerr("TurnManager: Cannot end turn, no game data available.")
		return

	var previous_turn = game_data.current_turn
	game_data.current_turn += 1
	
	print("--- Turn %s Ended ---" % previous_turn)
	
	# Process colony updates for all empires
	for empire in EmpireManager.empires.values():
		process_turn.emit(empire)
	
	print("--- Turn %s Began ---" % game_data.current_turn)
	
	turn_ended.emit(game_data.current_turn)
