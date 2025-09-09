# /scenes/starmap/starmap_camera.gd
extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

func _unhandled_input(event: InputEvent) -> void:
	# --- Zooming Logic ---
	# This checks for mouse wheel up/down events.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(zoom_speed, zoom_speed)
		# Clamp the zoom level to our min/max values.
		zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

	# --- Panning Logic ---
	# This checks if the middle mouse button is held down while the mouse is moving.
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_page_down"): # Middle mouse button
		# We move the camera in the opposite direction of the mouse movement.
		# The movement is scaled by the zoom to feel natural.
		position -= event.relative * zoom