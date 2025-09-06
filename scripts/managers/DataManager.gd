# /scripts/managers/DataManager.gd
# A global singleton (Autoload) responsible for loading all game data from files.

extends Node

## A dictionary to hold all loaded Technology resources, keyed by their unique 'id'.
var technologies: Dictionary = {}
## (Future) A dictionary for all ShipPart resources.
# var ship_parts: Dictionary = {}
## (Future) A dictionary for all Faction resources.
# var factions: Dictionary = {}


func _ready() -> void:
	print("DataManager: Loading all game data...")
	_load_resources_from_directory("res://gamedata/technologies/", technologies)
	print("DataManager: All game data loaded.")


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