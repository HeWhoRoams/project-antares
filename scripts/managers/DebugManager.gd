# /scripts/managers/DebugManager.gd
extends Node

var is_debug_mode_enabled: bool = true

func _ready() -> void:
	# Read the debug logging setting from the project config. Default to 'true'.
	is_debug_mode_enabled = ProjectSettings.get_setting("debug/logging/log_user_actions", true)
	print("DebugManager: User action logging is %s." % ("ENABLED" if is_debug_mode_enabled else "DISABLED"))

## Prints a formatted log message for a user action if logging is enabled.
func log_action(message: String) -> void:
	if is_debug_mode_enabled:
		print("[ACTION] %s" % message)

## Prints a formatted log message for an error if logging is enabled.
func log_error(message: String) -> void:
	if is_debug_mode_enabled:
		print("[ERROR] %s" % message)
