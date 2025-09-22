# /scenes/system_view_objects/planet_view.gd
extends Control

@onready var sprite: Sprite2D = %Sprite2D
@onready var label: Label = %Label
@onready var hover_frame: Panel = %HoverFrame

var _body_data: CelestialBodyData
var _is_mouse_over_sprite: bool = false

const PLANET_TEXTURES = {
	PlanetData.PlanetType.OCEAN: preload("res://assets/images/planets/ocean.png"),
	PlanetData.PlanetType.TERRAN: preload("res://assets/images/planets/terran.png"),
	PlanetData.PlanetType.DESERT: preload("res://assets/images/planets/desert.png"),
	PlanetData.PlanetType.ICE: preload("res://assets/images/planets/ice.png"),
	PlanetData.PlanetType.BARREN: preload("res://assets/images/planets/barren.png")
}

const BODY_TEXTURES = {
	CelestialBodyData.BodyType.GAS_GIANT: preload("res://assets/images/planets/gas_giant.png"),
	CelestialBodyData.BodyType.ASTEROID_BELT: preload("res://assets/images/planets/asteroid_belt.png")
}

const PLANET_SIZES = {
	PlanetData.PlanetType.OCEAN: Vector2(80, 80),
	PlanetData.PlanetType.TERRAN: Vector2(80, 80),
	PlanetData.PlanetType.DESERT: Vector2(80, 80),
	PlanetData.PlanetType.ICE: Vector2(80, 80),
	PlanetData.PlanetType.BARREN: Vector2(80, 80)
}

const GENERAL_BODY_SIZES = {
	CelestialBodyData.BodyType.GAS_GIANT: Vector2(150, 150),
	CelestialBodyData.BodyType.ASTEROID_BELT: Vector2(120, 120)
}

const ROMAN_NUMERALS = ["I", "II", "III", "IV", "V", "VI", "VII"]

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited)

func set_body_data(body_data: CelestialBodyData, system_name: String) -> void:
	_body_data = body_data
	var body_type_string: String
	var target_size := Vector2(100, 100)

	if body_data is PlanetData:
		var planet_data: PlanetData = body_data
		body_type_string = PlanetData.PlanetType.keys()[planet_data.planet_type].capitalize()
		sprite.texture = PLANET_TEXTURES.get(planet_data.planet_type)
		target_size = PLANET_SIZES.get(planet_data.planet_type, Vector2(80, 80))
	else:
		body_type_string = CelestialBodyData.BodyType.keys()[body_data.body_type].capitalize().replace("_", " ")
		sprite.texture = BODY_TEXTURES.get(body_data.body_type)
		target_size = GENERAL_BODY_SIZES.get(body_data.body_type, Vector2(100, 100))
		
	var roman_numeral = ""
	if body_data.orbital_slot < ROMAN_NUMERALS.size():
		roman_numeral = ROMAN_NUMERALS[body_data.orbital_slot]
	
	label.text = "%s %s\n%s" % [system_name, roman_numeral, body_type_string]
	
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_x = target_size.x / tex_size.x
			var scale_y = target_size.y / tex_size.y
			sprite.scale = Vector2(min(scale_x, scale_y), min(scale_x, scale_y))

func _gui_input(event: InputEvent) -> void:
	# Check if the mouse is inside the sprite's rectangle, relative to the sprite's own position
	var sprite_rect = sprite.get_rect()
	var is_over = sprite_rect.has_point(event.position - sprite.position)
	
	if event is InputEventMouseMotion:
		if is_over and not _is_mouse_over_sprite:
			_is_mouse_over_sprite = true
			hover_frame.show()
			AudioManager.play_sfx("hover")
		elif not is_over and _is_mouse_over_sprite:
			_is_mouse_over_sprite = false
			hover_frame.hide()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if is_over and _body_data is PlanetData and _body_data.owner_id == PlayerManager.player_empire.id:
			AudioManager.play_sfx("confirm")
			SceneManager.change_scene("res://ui/screens/colonies_screen.tscn", _body_data)

func _on_mouse_exited() -> void:
	# This ensures the hover frame disappears if the mouse leaves the entire component.
	_is_mouse_over_sprite = false
	hover_frame.hide()
