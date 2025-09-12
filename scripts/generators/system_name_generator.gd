# /scripts/generators/system_name_generator.gd
class_name SystemNameGenerator
extends RefCounted

var _name_data: SystemNameData # <-- Type updated here
var _used_names: PackedStringArray

# The constructor now expects a SystemNameData resource.
func _init(name_data: SystemNameData): # <-- Type updated here
	_name_data = name_data
	_used_names = []

# This is the public function the GalaxyManager will call.
func generate_unique_name() -> String:
	for _i in range(20):
		var prefix = _name_data.prefixes.pick_random()
		var main_name = _name_data.main_names.pick_random()
		var suffix_chance = randf()

		var final_name = ""
		if suffix_chance > 0.7:
			final_name = "%s %s %s" % [prefix, main_name, _name_data.suffixes.pick_random()]
		else:
			final_name = "%s %s" % [prefix, main_name]
		
		if not final_name in _used_names:
			_used_names.append(final_name)
			return final_name
	
	return "Uncharted Sector %s" % randi()

func add_used_name(name: String):
	if not name in _used_names:
		_used_names.append(name)
