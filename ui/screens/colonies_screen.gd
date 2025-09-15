extends Control

@onready var colony_list_tree: Tree = %ColonyList
@onready var planet_details_label: Label = %PlanetDetailsLabel
@onready var population_output_label: Label = %PopulationOutputLabel
@onready var mini_starmap_label: Label = %MiniStarmapLabel
@onready var global_variables_label: Label = %GlobalVariablesLabel

# Dummy data for demonstration purposes
var _colonies_data = [
	{ "name": "Sol III", "farmers": 5, "workers": 3, "scientists": 2, "building": "Nanoforge", "eta": 5 },
	{ "name": "Sirius II", "farmers": 2, "workers": 8, "scientists": 1, "building": "Orbital Yard", "eta": 12 },
	{ "name": "Alpha Centauri IV", "farmers": 3, "workers": 3, "scientists": 8, "building": "Research Lab", "eta": 3 },
	{ "name": "Epsilon Draconis I", "farmers": 7, "workers": 2, "scientists": 1, "building": "Cloning Facility", "eta": 8 },
]

func _ready() -> void:
	_setup_colony_list()
	_populate_colony_list()
	_update_bottom_panels(null) # Start with empty panels
	
	# Set the global variables panel once, as it's not affected by selection.
	global_variables_label.text = "Credits: 250 BC\nFood: 15\nResearch: 59 RP"


func _setup_colony_list() -> void:
	colony_list_tree.set_columns(5)
	colony_list_tree.set_column_titles_visible(true)
	colony_list_tree.set_column_title(0, "Planet")
	colony_list_tree.set_column_title(1, "Cultivators")
	colony_list_tree.set_column_title(2, "Contributors")
	colony_list_tree.set_column_title(3, "Researchers")
	colony_list_tree.set_column_title(4, "Active Build")

func _populate_colony_list() -> void:
	var root = colony_list_tree.create_item()
	for colony_data in _colonies_data:
		var item = colony_list_tree.create_item(root)
		item.set_text(0, colony_data.name)
		item.set_text(1, str(colony_data.farmers))
		item.set_text(2, str(colony_data.workers))
		item.set_text(3, str(colony_data.scientists))
		item.set_text(4, "%s (%s turns)" % [colony_data.building, colony_data.eta])
		# Store the raw data in the item for later use
		item.set_metadata(0, colony_data)

func _on_colony_list_item_selected() -> void:
	var selected_item = colony_list_tree.get_selected()
	if not selected_item:
		return
	
	var selected_data = selected_item.get_metadata(0)
	_update_bottom_panels(selected_data)

func _update_bottom_panels(data) -> void:
	if data:
		planet_details_label.text = "Details for:\n%s" % data.name
		population_output_label.text = "Farmers: %s\nWorkers: %s\nScientists: %s" % [data.farmers, data.workers, data.scientists]
		mini_starmap_label.text = "Showing location for:\n%s" % data.name
	else:
		# When nothing is selected, the panels are blank.
		planet_details_label.text = ""
		population_output_label.text = ""
		mini_starmap_label.text = ""

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()
