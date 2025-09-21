# /scripts/managers/DataManager.gd
# A global singleton (Autoload) responsible for loading all game data from files.
extends Node

## A dictionary to hold all loaded Technology resources, keyed by their unique 'id'.
var _technologies: Dictionary = {}
## (Future) A dictionary for all ShipPart resources.
# var ship_parts: Dictionary = {}
## (Future) A dictionary for all Faction resources.
# var factions: Dictionary = {}

## NEW: A variable to hold our structured tech tree data from the JSON file.
var _tech_tree_data: Dictionary = {}


func _ready() -> void:
	print("DataManager: Loading all game data...")
	_load_resources_from_directory("res://gamedata/technologies/", _technologies)
	_load_tech_tree_from_json("res://gamedata/technologies/tech_tree.json")
	print("DataManager: All game data loaded.")


#region Public API
## Returns the Technology resource for the given ID, if it exists.
func get_technology(id: String): # -> Technology:
	return _technologies.get(id)


## Returns an array of all loaded technology IDs.
func get_all_technology_ids() -> Array:
	return _technologies.keys()


## Returns an array of all loaded Technology resources.
func get_all_technologies() -> Array:
	return _technologies.values()


## Returns the entire technology tree structure.
func get_tech_tree_data() -> Dictionary:
	return _tech_tree_data

#endregion


## Generic function to scan a directory for .tres files and load them into a dictionary.
func _load_resources_from_directory(path: String, target_dictionary: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# We only care about .tres files and ignore hidden files/folders.
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource = ResourceLoader.load(dir.get_current_dir() + "/" + file_name)
				if resource and "id" in resource:
					# Use the resource's unique ID as the key in our dictionary.
					target_dictionary[resource.id] = resource
					print("  -> Loaded %s: %s" % [resource.get_class(), resource.id])
				else:
					printerr("  -> Failed to load or find ID in: %s" % file_name)
			
			file_name = dir.get_next()
	else:
		printerr("DataManager: Could not open directory at path: %s" % path)

## NEW: Function to load and parse the tech tree from our JSON file.
func _load_tech_tree_from_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		printerr("DataManager: Tech tree file not found at path: %s" % path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		printerr("DataManager: Failed to parse tech_tree.json. Error: %s" % json.get_error_message())
		return

	_tech_tree_data = json.get_data()
	
	# Create Technology resources from JSON data
	for category_data in _tech_tree_data["categories"]:
		var category_tier_techs = {}  # tier -> [tech_ids]
		for tier_key in category_data["tiers"]:
			var tier_techs = category_data["tiers"][tier_key]
			category_tier_techs[tier_key] = []
			for tech_data in tier_techs:
				var tech = Technology.new()
				tech.id = tech_data["id"]
				tech.display_name = tech_data["display_name"]
				tech.description = tech_data["description"]
				tech.research_cost = 100  # Default
				category_tier_techs[tier_key].append(tech.id)
				_technologies[tech.id] = tech
				print("  -> Created technology: %s" % tech.id)
		
		# Set prerequisites: higher tiers require one tech from previous tier
		var tiers = category_tier_techs.keys()
		tiers.sort()
		for i in range(1, tiers.size()):
			var current_tier = tiers[i]
			var prev_tier = tiers[i-1]
			for tech_id in category_tier_techs[current_tier]:
				var tech = _technologies[tech_id]
				# Require the first tech from previous tier
				var prereq_id = category_tier_techs[prev_tier][0]
				tech.prerequisites.append(_technologies[prereq_id])
	
	print("  -> Loaded tech tree data from JSON.")
