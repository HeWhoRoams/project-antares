# /ui/debug/debug_overlay.gd
extends CanvasLayer

@onready var debug_label: Label = %DebugLabel

func _process(_delta):
	var text = "--- DEBUG OVERLAY (F3 to toggle) ---\n"
	text += "Turn: %d\n" % TurnManager.current_turn
	
	var player_empire = EmpireManager.get_empire_by_id(&"player_1")
	if player_empire:
		text += "Player Treasury: %d BC\n" % player_empire.treasury

	debug_label.text = text