# /ui/hud/hud.gd
extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var research_label: Label = %ResearchLabel
@onready var end_turn_button: Button = %EndTurnButton

func _ready() -> void:
	# Connect button press to the TurnManager's function
	end_turn_button.pressed.connect(TurnManager.end_turn)
	# Connect this script to signals from managers to receive updates
	TurnManager.turn_ended.connect(_on_turn_ended)
	PlayerManager.research_points_changed.connect(_on_research_points_changed) # We will add this signal next
	
	# Set initial values
	_update_turn_label(TurnManager.current_turn)
	_update_research_label(PlayerManager.research_points)

func _on_turn_ended(new_turn_number: int) -> void:
	_update_turn_label(new_turn_number)

func _on_research_points_changed(new_points: int) -> void:
	_update_research_label(new_points)

func _update_turn_label(turn: int) -> void:
	turn_label.text = "Turn: %s" % turn

func _update_research_label(points: int) -> void:
	research_label.text = "Research: %s" % points
