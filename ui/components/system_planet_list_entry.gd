extends HBoxContainer

@onready var icon: TextureRect = %PlanetIcon
@onready var label: Label = %PlanetNameLabel

const PLANET_ICONS = {
	PlanetData.PlanetType.OCEAN: preload("res://assets/images/planets/ocean.png"),
	PlanetData.PlanetType.TERRAN: preload("res://assets/images/planets/terran.png"),
	PlanetData.PlanetType.DESERT: preload("res://assets/images/planets/desert.png"),
	PlanetData.PlanetType.ICE: preload("res://assets/images/planets/ice.png"),
	PlanetData.PlanetType.BARREN: preload("res://assets/images/planets/barren.png")
}

const ROMAN_NUMERALS = ["I", "II", "III", "IV", "V", "VI", "VII"]

func set_planet_data(planet: PlanetData, system_name: String) -> void:
	icon.texture = PLANET_ICONS.get(planet.planet_type)
	
	var roman_numeral = ""
	if planet.orbital_slot < ROMAN_NUMERALS.size():
		roman_numeral = ROMAN_NUMERALS[planet.orbital_slot]
		
	label.text = "%s %s" % [system_name, roman_numeral]
