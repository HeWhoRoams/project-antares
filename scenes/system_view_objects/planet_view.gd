# /scenes/system_view_objects/planet_view.gd
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

# We'll need some placeholder textures for different planet types.
const PLANET_TEXTURES = {
	PlanetData.PlanetType.TERRAN: preload("res://assets/images/planets/terran.png"),
	PlanetData.PlanetType.DESERT: preload("res://assets/images/planets/desert.png"),
	PlanetData.PlanetType.ICE: preload("res://assets/images/planets/ice.png"),
	# Add other planet types here as you create the assets
}

func set_body_data(body_data: CelestialBodyData) -> void:
	var label_text = "Slot %s" % body_data.orbital_slot
	
	if body_data is PlanetData:
		var planet_data: PlanetData = body_data
		label_text += " - %s" % PlanetData.PlanetType.keys()[planet_data.planet_type].capitalize()
		sprite.texture = PLANET_TEXTURES.get(planet_data.planet_type, PLANET_TEXTURES[PlanetData.PlanetType.TERRAN]) # Fallback
	else:
		label_text += " - %s" % CelestialBodyData.BodyType.keys()[body_data.body_type].capitalize().replace("_", " ")
		# You could set a texture for asteroid belts or gas giants here
		
	label.text = label_text
