# /scenes/starmap/starmap_camera.gd
extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

func _unhandled_input(event: InputEvent) -> void:
	# --- Zooming Logic ---
	if event.is_action_pressed("starmap_zoom_in"):
		zoom -= Vector2(zoom_speed, zoom_speed)
	if event.is_action_pressed("starmap_zoom_out"):
		zoom += Vector2(zoom_speed, zoom_speed)
	zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

	# --- Panning Logic ---
	if event is InputEventMouseMotion and Input.is_action_pressed("starmap_pan"):
		position -= event.relative * zoom
