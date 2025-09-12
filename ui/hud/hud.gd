# /ui/hud/hud.gd
extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var research_label: Label = %ResearchLabel
@onready var end_turn_button: Button = %EndTurnButton

# References to the new right sidebar labels
@onready var credits_label: Label = %CreditsLabel
@onready var fleet_label: Label = %FleetLabel
@onready var food_label: Label = %FoodLabel
@onready var freighters_label: Label = %FreightersLabel
@onready var research_eta_label: Label = %ResearchEtaLabel

func _ready() -> void:
	# Connect button press to the TurnManager's function
	end_turn_button.pressed.connect(TurnManager.end_turn)
	# Connect this script to signals from managers to receive updates
	TurnManager.turn_ended.connect(_on_turn_ended)
	PlayerManager.research_points_changed.connect(_on_research_points_changed)
	
	# Set initial values
	_update_turn_label(TurnManager.current_turn)
	_update_research_label(PlayerManager.research_points)
	_update_sidebar_dummy_data()

func _update_sidebar_dummy_data() -> void:
	credits_label.text = "Credits: 250 BC\n(+25 BC/turn)"
	fleet_label.text = "Fleet Strength:\n1 Scout"
	food_label.text = "Food: 15\nSurplus: +2"
	freighters_label.text = "Freighters:\n0 / 10"
	research_eta_label.text = "Research: 59 RP\nETA: 10 turns"

# --- Signal Handlers for UI Updates ---

func _on_turn_ended(new_turn_number: int) -> void:
	_update_turn_label(new_turn_number)

func _on_research_points_changed(new_points: int) -> void:
	_update_research_label(new_points)

func _update_turn_label(turn: int) -> void:
	turn_label.text = "Turn: %s" % turn

func _update_research_label(points: int) -> void:
	research_label.text = "Research: %s" % points

# --- Signal Handlers for Bottom Bar Navigation ---

func _on_colonies_button_pressed():
	SceneManager.change_scene("res://ui/screens/colonies_screen.tscn")

func _on_planets_button_pressed():
	SceneManager.change_scene("res://ui/screens/planets_screen.tscn")

func _on_ships_button_pressed():
	SceneManager.change_scene("res://ui/screens/ships_screen.tscn")

func _on_npcs_button_pressed():
	SceneManager.change_scene("res://ui/screens/npcs_screen.tscn")

func _on_diplomacy_button_pressed():
	SceneManager.change_scene("res://ui/screens/diplomacy_screen.tscn")

func _on_settings_button_pressed():
	SceneManager.change_scene("res://ui/screens/settings_screen.tscn")

# --- Signal Handlers for Right Sidebar Navigation ---

func _on_credits_button_pressed():
	SceneManager.change_scene("res://ui/screens/credits_screen.tscn")

func _on_fleet_button_pressed():
	SceneManager.change_scene("res://ui/screens/ships_screen.tscn")

func _on_food_button_pressed():
	SceneManager.change_scene("res://ui/screens/food_screen.tscn")

func _on_freighters_button_pressed():
	SceneManager.change_scene("res://ui/screens/freighters_screen.tscn")

func _on_research_button_pressed():
	# For now this goes to the placeholder, later it will go to the tech tree
	SceneManager.change_scene("res://ui/screens/research_screen.tscn")