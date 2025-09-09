# /ui/hud/hud.gd
# Controller for the main game HUD.
extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var end_turn_button: Button = %EndTurnButton
@onready var research_label: Label = %ResearchLabel # Add reference to this label

func _ready() -> void:
	end_turn_button.pressed.connect(TurnManager.end_turn)
	TurnManager.turn_ended.connect(_on_turn_ended)
	_update_hud() # Update HUD on start

func _on_turn_ended(new_turn_number: int) -> void:
	_update_hud()

func _update_hud() -> void:
	turn_label.text = "Turn: %s" % TurnManager.current_turn
	# Display the current research points from the PlayerManager.
	research_label.text = "Research: %s" % PlayerManager.research_points