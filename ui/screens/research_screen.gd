extends Control

@onready var tech_tree_container: VBoxContainer = $TechTreePanel/ScrollContainer/VBoxContainer

const TECH_ENTRY_SCENE = preload("res://ui/components/tech_entry.tscn")

var player_empire: Empire

func _ready() -> void:
	player_empire = GameManager.player_empire
	populate_tech_tree()

func populate_tech_tree() -> void:
	var tech_tree_data = DataManager.get_tech_tree_data()
	
	for category_data in tech_tree_data["categories"]:
		var category_name = category_data["category_name"]
		var category_id = category_data["category_id"]
		
		# Create category header
		var category_label = Label.new()
		category_label.text = category_name
		category_label.add_theme_font_size_override("font_size", 24)
		tech_tree_container.add_child(category_label)
		
		# Create container for tiers
		var category_container = VBoxContainer.new()
		category_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tech_tree_container.add_child(category_container)
		
		# Sort tiers by number
		var tiers = category_data["tiers"]
		var tier_keys = tiers.keys()
		tier_keys.sort()
		
		for tier_key in tier_keys:
			var tier_techs = tiers[tier_key]
			
			# Tier header
			var tier_label = Label.new()
			tier_label.text = "Tier " + str(tier_key)
			tier_label.add_theme_font_size_override("font_size", 18)
			category_container.add_child(tier_label)
			
			# Container for techs in this tier
			var tier_container = HBoxContainer.new()
			tier_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			category_container.add_child(tier_container)
			
			for tech_data in tier_techs:
				var tech_id = tech_data["id"]
				var tech_resource = DataManager.get_technology(tech_id)
				
				if tech_resource:
					var tech_entry = TECH_ENTRY_SCENE.instantiate()
					tech_entry.set_technology_data(tech_resource)
					tech_entry.connect("selected", Callable(self, "_on_tech_selected").bind(tech_resource))
					tier_container.add_child(tech_entry)
					
					# Disable if already unlocked or researching
					if player_empire.unlocked_techs.has(tech_id) or player_empire.current_researching_tech == tech_id:
						tech_entry.disabled = true
					# Check prerequisites
					elif not _are_prerequisites_met(tech_resource):
						tech_entry.disabled = true
						tech_entry.modulate = Color(0.5, 0.5, 0.5, 1.0)  # Gray out

func _are_prerequisites_met(tech: Technology) -> bool:
	for prereq in tech.prerequisites:
		if not player_empire.unlocked_techs.has(prereq.id):
			return false
	return true

func _on_tech_selected(tech: Technology) -> void:
	if player_empire.current_researching_tech != "":
		# Cancel current research
		player_empire.current_researching_tech = ""
		player_empire.research_progress = 0
	
	player_empire.current_researching_tech = tech.id
	print("Started researching: " + tech.display_name)
	# TODO: Refresh UI to show selection

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()
