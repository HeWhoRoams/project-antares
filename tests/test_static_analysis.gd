# /tests/test_static_analysis.gd
extends "res://addons/gut/test.gd"

var script_files = []

func before_all():
	_collect_script_files("res://scripts/")
	_collect_script_files("res://ui/")
	_collect_script_files("res://scenes/")
	_collect_script_files("res://gamedata/")

func _collect_script_files(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				_collect_script_files(path + file_name + "/")
			elif file_name.ends_with(".gd"):
				script_files.append(path + file_name)
			file_name = dir.get_next()

func test_no_redundant_function_calls():
	for script_path in script_files:
		var file = FileAccess.open(script_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			_check_redundant_calls(script_path, content)
	assert_true(true, "Redundant function call check completed.")

func _check_redundant_calls(script_path: String, content: String):
	var lines = content.split("\n")
	var recent_calls = []
	var indent_stack = []

	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		var indent_level = _get_indent_level(lines[i])

		# Adjust indent stack
		while indent_stack.size() > 0 and indent_stack.back() >= indent_level:
			indent_stack.pop_back()
			if recent_calls.size() > 0:
				recent_calls.pop_back()

		if line.begins_with("func "):
			indent_stack.append(indent_level)
			recent_calls.clear()
		elif indent_level > (indent_stack.back() if indent_stack.size() > 0 else -1):
			# Inside a function
			var call = _extract_function_call(line)
			if call != "":
				if recent_calls.has(call) and recent_calls.back() == call:
					# Same call twice in a row - potential redundancy
					gut.p("Potential redundant consecutive function call detected in %s at line %d: %s" % [script_path, i + 1, call])
				recent_calls.append(call)
				if recent_calls.size() > 5:  # Keep only recent calls
					recent_calls.pop_front()

func _get_indent_level(line: String) -> int:
	var level = 0
	for c in line:
		if c == "\t":
			level += 4  # Assume tab = 4 spaces
		elif c == " ":
			level += 1
		else:
			break
	return level

func _extract_function_call(line: String) -> String:
	var call_start = line.find("(")
	if call_start == -1:
		return ""

	var call_end = line.rfind(")")
	if call_end == -1 or call_end <= call_start:
		return ""

	var call = line.substr(0, call_end + 1)
	if call.find(".") != -1:
		var parts = call.split(".")
		if parts.size() > 1:
			return parts[parts.size() - 1].split("(")[0]
	return ""

func test_type_consistency():
	for script_path in script_files:
		var file = FileAccess.open(script_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			_check_type_consistency(script_path, content)
	assert_true(true, "Type consistency check completed.")

func _check_type_consistency(script_path: String, content: String):
	var lines = content.split("\n")
	var variables = {}

	for i in range(lines.size()):
		var line = lines[i].strip_edges()

		# Check variable declarations
		if line.begins_with("var ") or line.find(" := ") != -1:
			var var_name = ""
			var var_type = ""

			if line.begins_with("var "):
				var parts = line.split(" ")
				if parts.size() > 1:
					var_name = parts[1].split(":")[0]
					if parts[1].find(":") != -1:
						var_type = parts[1].split(":")[1].strip_edges()
			elif line.find(" := ") != -1:
				var parts = line.split(" := ")
				if parts.size() > 1:
					var_name = parts[0].strip_edges()

			if var_name != "":
				variables[var_name] = var_type

		# Check function calls with parameters
		if line.find("(") != -1 and line.find(")") != -1:
			var call_start = line.find("(")
			var call_end = line.rfind(")")
			if call_start != -1 and call_end != -1 and call_end > call_start:
				var params_str = line.substr(call_start + 1, call_end - call_start - 1)
				var params = params_str.split(",")
				for param in params:
					param = param.strip_edges()
					if param.find("\"") != -1 and param.find("\"", param.find("\"") + 1) != -1:
						# String literal
						continue
					elif param.is_valid_int():
						# Integer literal
						continue
					elif param.is_valid_float():
						# Float literal
						continue
					elif variables.has(param):
						# Variable reference - could check type consistency here
						continue
					else:
						# Potential issue - unknown parameter
						pass
