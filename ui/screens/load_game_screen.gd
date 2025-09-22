extends Control

@onready var save_files_container: VBoxContainer = %SaveFilesContainer

const SAVE_FILE_PREFIX = "savegame_"
const SAVE_FILE_SUFFIX = ".json"

func _ready() -> void:
	_refresh_save_files()

func _refresh_save_files() -> void:
	# Clear existing entries
	for child in save_files_container.get_children():
		child.queue_free()
	
	# List save files
	var dir = DirAccess.open("user://")
	if not dir:
		printerr("LoadGameScreen: Cannot open user:// directory")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with(SAVE_FILE_PREFIX) and file_name.ends_with(SAVE_FILE_SUFFIX):
			var slot_name = file_name.trim_prefix(SAVE_FILE_PREFIX).trim_suffix(SAVE_FILE_SUFFIX)
			_add_save_file_entry(slot_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _add_save_file_entry(slot_name: String) -> void:
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label = Label.new()
	label.text = "Save Slot: " + slot_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var load_button = Button.new()
	load_button.text = "Load"
	load_button.connect("pressed", Callable(self, "_on_load_pressed").bind(slot_name))
	
	var delete_button = Button.new()
	delete_button.text = "Delete"
	delete_button.connect("pressed", Callable(self, "_on_delete_pressed").bind(slot_name))
	
	hbox.add_child(label)
	hbox.add_child(load_button)
	hbox.add_child(delete_button)
	
	save_files_container.add_child(hbox)

func _on_load_pressed(slot_name: String) -> void:
	SaveLoadManager.load_game(slot_name)

func _on_delete_pressed(slot_name: String) -> void:
	var file_path = "user://savegame_%s.json" % slot_name
	var dir = DirAccess.open("user://")
	if dir.file_exists(file_path.trim_prefix("user://")):
		dir.remove(file_path.trim_prefix("user://"))
		_refresh_save_files()

func _on_return_button_pressed() -> void:
	AudioManager.play_sfx("back")
	SceneManager.return_to_previous_scene()
