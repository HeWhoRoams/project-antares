# /scripts/managers/turn_manager.gd
# A global singleton to manage the game turn and progression.
extends Node

## Emitted whenever the "End Turn" button is processed.
## Sends the new turn number as an argument.
signal turn_ended(new_turn_number: int)

var current_turn: int = 1

## This is the public function the UI will call to advance the game.
func end_turn() -> void:
	var previous_turn = current_turn
	current_turn += 1
	
	print("--- Turn %s Ended ---" % previous_turn)
	print("--- Turn %s Began ---" % current_turn)
	
	turn_ended.emit(current_turn)