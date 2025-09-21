# /scripts/managers/turn_manager.gd
extends Node

signal turn_ended(new_turn_number: int)
signal process_turn(empire: Empire)
signal start_of_turn(empire_id: StringName)
signal end_of_turn(empire_id: StringName)

var turn_order: Array[StringName] = []
var current_empire_index: int = 0
var current_turn: int = 1


func start_new_game(empires: Dictionary) -> void:
	turn_order.clear()
	for empire_id in empires.keys():
		turn_order.append(empire_id)
	# Optionally shuffle for random order
	# turn_order.shuffle()
	current_empire_index = 0
	current_turn = 1
	# Emit start of first turn
	if not turn_order.is_empty():
		start_of_turn.emit(turn_order[0])


func end_turn() -> void:
	if turn_order.is_empty():
		return
	
	# Emit end of turn for current empire
	var current_empire_id = turn_order[current_empire_index]
	end_of_turn.emit(current_empire_id)
	
	# Process turn for current empire (colony updates, etc.)
	var empire = EmpireManager.get_empire_by_id(current_empire_id)
	if empire:
		process_turn.emit(empire)
		_process_research(empire)
	
	# Move to next empire
	current_empire_index = (current_empire_index + 1) % turn_order.size()
	
	# If back to start, increment turn
	if current_empire_index == 0:
		current_turn += 1
		turn_ended.emit(current_turn)
	
	# Emit start of turn for new current empire
	var new_empire_id = turn_order[current_empire_index]
	start_of_turn.emit(new_empire_id)
	
	# If AI, take turn
	var new_empire = EmpireManager.get_empire_by_id(new_empire_id)
	if new_empire and new_empire.is_ai_controlled:
		AIManager.take_turn(new_empire_id)


func _ready() -> void:
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)


func _process_research(empire: Empire) -> void:
	if empire.current_researching_tech == "":
		return
	
	var tech = DataManager.get_technology(empire.current_researching_tech)
	if not tech:
		return
	
	empire.research_progress += empire.research_per_turn
	
	if empire.research_progress >= tech.research_cost:
		# Tech completed
		empire.unlocked_techs.append(empire.current_researching_tech)
		empire.current_researching_tech = ""
		empire.research_progress = 0
		
		# Notify player
		if not empire.is_ai_controlled:
			# TODO: Show notification popup
			print("Technology unlocked: " + tech.display_name)
		
		# Apply effects
		_apply_tech_effects(empire, tech)

func _apply_tech_effects(empire: Empire, tech: Technology) -> void:
	# Find the benefit text from tech tree data
	var tech_tree_data = DataManager.get_tech_tree_data()
	for category_data in tech_tree_data["categories"]:
		for tier_key in category_data["tiers"]:
			var tier_techs = category_data["tiers"][tier_key]
			for tech_data in tier_techs:
				if tech_data["id"] == tech.id:
					var benefit = tech_data["benefit"]
					_apply_benefit(empire, benefit)
					print("Applied effects for: " + tech.display_name + " - " + benefit)
					return

func _apply_benefit(empire: Empire, benefit: String) -> void:
	# Parse benefit text and apply effects
	if "+5% to all income from population and trade." in benefit:
		empire.income_per_turn = int(empire.income_per_turn * 1.05)
	elif "Unlocks the 'Automated Research Lab' building" in benefit:
		# TODO: Add to buildable items
		pass
	# Add more parsing as needed


func _on_save_data_loaded(data: Dictionary) -> void:
	if data.has("turn_order"):
		turn_order = data["turn_order"]
	if data.has("current_empire_index"):
		current_empire_index = data["current_empire_index"]
	if data.has("turn"):
		current_turn = data["turn"]
