# /ui/hud/hud.gd
extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var research_label: Label = %ResearchLabel
@onready var end_turn_button: Button = %EndTurnButton
@onready var credits_label: Label = %CreditsLabel
@onready var fleet_label: Label = %FleetLabel
@onready var food_label: Label = %FoodLabel
@onready var freighters_label: Label = %FreightersLabel
@onready var research_eta_label: Label = %ResearchEtaLabel
@onready var mini_map_container: Control = %MiniMapContainer

func _ready() -> void:
	# Wait for one frame to ensure all singletons are fully initialized
	await get_tree().process_frame

	TurnManager.turn_ended.connect(_on_turn_ended)
	PlayerManager.research_points_changed.connect(_on_research_points_changed)

	_update_turn_label(TurnManager.current_turn)
	_update_research_label(PlayerManager.research_points)
	_update_sidebar_dummy_data()
	_draw_minimap()

func _update_sidebar_dummy_data() -> void:
	credits_label.text = "Credits: %d\n(+%d/turn)" % [PlayerManager.player_empire.treasury, PlayerManager.player_empire.income_per_turn]
	fleet_label.text = "Fleet Strength:\n%d ships" % PlayerManager.player_empire.owned_ships.size()
	food_label.text = "Food: TODO\nSurplus: TODO"
	freighters_label.text = "Freighters:\nTODO"
	research_eta_label.text = "Research: %s\nETA: TODO turns" % PlayerManager.player_empire.current_researching_tech

func _on_turn_ended(new_turn_number: int) -> void:
	_update_turn_label(new_turn_number)
	_show_turn_transition_effect(new_turn_number)

func _show_turn_transition_effect(new_turn: int) -> void:
	# Create a simple turn transition effect
	var tween = create_tween()
	turn_label.modulate = Color.YELLOW
	tween.tween_property(turn_label, "modulate", Color.WHITE, 1.0)
	tween.tween_callback(func(): turn_label.text = "Turn: %s" % new_turn)

	# Play turn change sound
	AudioManager.play_sfx("turn_change")

	# Show turn change notification
	_show_notification("Turn %d" % new_turn, "New turn has begun!")

func _on_research_points_changed(new_points: int) -> void:
	_update_research_label(new_points)

func _update_turn_label(turn: int) -> void:
	turn_label.text = "Turn: %s" % turn

func _update_research_label(points: int) -> void:
	research_label.text = "Research: %s" % points

func _on_end_turn_button_pressed() -> void:
	DebugManager.log_action("HUD: 'End Turn' button pressed.")
	AudioManager.play_sfx("confirm")

	# Check for unassigned population or fleets before ending turn
	var issues = _check_turn_end_conditions()
	if issues.size() > 0:
		_show_end_turn_confirmation(issues)
	else:
		TurnManager.end_turn()

func _check_turn_end_conditions() -> Array[String]:
	var issues: Array[String] = []

	# Check for unassigned population in colonies
	for colony_key in ColonyManager.colonies:
		var colony = ColonyManager.colonies[colony_key]
		if colony.owner_id == PlayerManager.player_empire.id:
			var total_assigned = colony.farmers + colony.workers + colony.scientists
			var unassigned = colony.current_population - total_assigned
			if unassigned > 0:
				issues.append("Colony at %s has %d unassigned population" % [colony.system_id, unassigned])

	# Check for fleets without destinations (simplified check)
	for ship_id in PlayerManager.player_empire.owned_ships:
		var ship = PlayerManager.player_empire.owned_ships[ship_id]
		if ship.destination_system_id.is_empty():
			issues.append("Fleet at %s has no destination set" % ship.current_system_id)
			break  # Only report one fleet issue to avoid spam

	return issues

func _show_end_turn_confirmation(issues: Array[String]) -> void:
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "End Turn?"
	confirmation_dialog.dialog_text = "Are you sure you want to end your turn?\n\nIssues found:\n" + "\n".join(issues)
	confirmation_dialog.ok_button_text = "End Turn Anyway"
	confirmation_dialog.cancel_button_text = "Cancel"

	# Connect signals
	confirmation_dialog.confirmed.connect(_on_end_turn_confirmed)
	confirmation_dialog.canceled.connect(_on_end_turn_cancelled)

	# Add to scene and show
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()

func _on_end_turn_confirmed() -> void:
	TurnManager.end_turn()

func _on_end_turn_cancelled() -> void:
	# Just close the dialog, no action needed
	pass

func _input(event: InputEvent) -> void:
	# Handle keyboard shortcuts
	if event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			# Space bar to end turn
			_on_end_turn_button_pressed()
		elif event.keycode == KEY_ESCAPE:
			# Escape to cancel current action (if any)
			pass

func _on_colonies_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Colonies' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/colonies_screen.tscn")

func _on_planets_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Planets' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/planets_screen.tscn")

func _on_ships_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Ships' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/ships_screen.tscn")

func _on_npcs_button_pressed() -> void:
	DebugManager.log_action("HUD: 'NPCs' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/npcs_screen.tscn")

func _on_diplomacy_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Diplomacy' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/diplomacy_screen.tscn")

func _on_settings_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Settings' button pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/settings_screen.tscn")

func _on_credits_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Credits' panel pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/credits_screen.tscn")

func _on_fleet_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Fleet' panel pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/ships_screen.tscn")

func _on_food_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Food' panel pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/food_screen.tscn")

func _on_freighters_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Freighters' panel pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/freighters_screen.tscn")

func _on_research_button_pressed() -> void:
	DebugManager.log_action("HUD: 'Research' panel pressed.")
	AudioManager.play_sfx("confirm")
	SceneManager.change_scene("res://ui/screens/research_screen.tscn")

func _show_notification(title: String, message: String, duration: float = 3.0) -> void:
	# Create a simple notification popup
	var notification = AcceptDialog.new()
	notification.title = title
	notification.dialog_text = message
	notification.ok_button_text = "OK"

	# Auto-close after duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(func(): if is_instance_valid(notification): notification.queue_free())
	notification.add_child(timer)
	timer.start()

	# Show notification
	add_child(notification)
	notification.popup_centered()

func _draw_minimap() -> void:
	# Clear existing minimap
	for child in mini_map_container.get_children():
		child.queue_free()

	if GalaxyManager.star_systems.is_empty():
		return

	# Calculate bounds of all systems
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)

	for system in GalaxyManager.star_systems.values():
		min_pos = min_pos.min(system.position)
		max_pos = max_pos.max(system.position)

	var galaxy_size = max_pos - min_pos
	var map_size = mini_map_container.size

	# Avoid division by zero
	if galaxy_size.x == 0 or galaxy_size.y == 0:
		return

	var scale_x = map_size.x / galaxy_size.x
	var scale_y = map_size.y / galaxy_size.y
	var scale = min(scale_x, scale_y) * 0.8  # Leave some margin

	# Draw systems
	for system_id in GalaxyManager.star_systems:
		var system = GalaxyManager.star_systems[system_id]
		var relative_pos = system.position - min_pos
		var map_pos = Vector2(relative_pos.x * scale, relative_pos.y * scale)

		# Check if player owns any colonies in this system
		var has_player_colony = false
		for body in system.celestial_bodies:
			if body is PlanetData and body.owner_id == PlayerManager.player_empire.id:
				has_player_colony = true
				break

		# Create a dot for the system
		var dot = ColorRect.new()
		dot.size = Vector2(3, 3)
		dot.position = map_pos - dot.size / 2

		if has_player_colony:
			dot.color = PlayerManager.player_empire.color
		else:
			dot.color = Color(0.5, 0.5, 0.5, 0.7)  # Gray for unexplored/neutral

		mini_map_container.add_child(dot)

func _on_any_button_mouse_entered() -> void:
	AudioManager.play_sfx("hover")
