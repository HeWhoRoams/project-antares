# /scripts/managers/DebugManager.gd
extends Node

var is_debug_mode_enabled: bool = true
var _debug_overlay_scene = preload("res://ui/debug/debug_overlay.tscn")
var _debug_overlay_instance: CanvasLayer = null

func _ready() -> void:
	is_debug_mode_enabled = ProjectSettings.get_setting("debug/logging/log_user_actions", true)
	print("DebugManager: User action logging is %s." % ("ENABLED" if is_debug_mode_enabled else "DISABLED"))

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"): # Typically the Escape key
		# For now, we'll use Escape to toggle the debug overlay
		if is_instance_valid(_debug_overlay_instance):
			_debug_overlay_instance.queue_free()
			_debug_overlay_instance = null
		else:
			_debug_overlay_instance = _debug_overlay_scene.instantiate()
			get_tree().get_root().add_child(_debug_overlay_instance)

func log_action(message: String) -> void:
	if is_debug_mode_enabled:
		print("[ACTION] %s" % message)