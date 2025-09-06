# /ui/hud/hud.gd
# Controller for the main game HUD.
extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var end_turn_button: Button = %EndTurnButton

func _ready() -> void:
	# Connect the button press to the TurnManager's function.
	end_turn_button.pressed.connect(TurnManager.end_turn)
	# Connect this script to the TurnManager's signal to receive updates.
	TurnManager.turn_ended.connect(_on_turn_ended)
	
	# Set the initial label text.
	_update_turn_label(TurnManager.current_turn)

func _on_turn_ended(new_turn_number: int) -> void:
	_update_turn_label(new_turn_number)

func _update_turn_label(turn: int) -> void:
	turn_label.text = "Turn: %s" % turn