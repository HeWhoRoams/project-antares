# /scripts/managers/galaxymanager.gd
extends Node

@export var number_of_systems: int = 20

const GALAXY_SIZE_X = 1000.0
const GALAXY_SIZE_Y = 1000.0

var star_systems: Dictionary = {}
var nebulae: Array[CelestialBodyData] = []
var black_holes: Array[CelestialBodyData] = []
var wormholes: Array[CelestialBodyData] = []
var _celestial_body_generator: CelestialBodyGenerator
var _galaxy_builder: GalaxyBuilder
var _system_name_generator: SystemNameGenerator

const STAR_COLORS = {
	"purple": Color(0.6, 0.2, 0.8),
	"red": Color(1.0, 0.3, 0.3),
	"blue": Color(0.5, 0.7, 1.0),
	"yellow": Color(1.0, 1.0, 0.6)
}

func _ready() -> void:
	var GalaxyBuilderScript = load("res://scripts/galaxy/GalaxyBuilder.gd")
	if GalaxyBuilderScript:
		_galaxy_builder = GalaxyBuilderScript.new()
	else:
		printerr("GalaxyManager: Failed to load GalaxyBuilder script!")
		return

	_celestial_body_generator = CelestialBodyGenerator.new()
	
	var name_data = load("res://gamedata/systems/system_names.tres")
	_system_name_generator = SystemNameGenerator.new(name_data)
	
	if SaveLoadManager.is_loading_game:
		SaveLoadManager.save_data_loaded.connect(_on_save_data_loaded)
	else:
		generate_procedural_galaxy()

func generate_procedural_galaxy() -> void:
	print("GalaxyManager: Generating galaxy...")
	star_systems.clear()

	var sol = StarSystem.new()
	sol.id = "sol"
	sol.display_name = "Sol"
	sol.position = Vector2.ZERO
	var home_planet = PlanetData.new()
	home_planet.system_id = sol.id
	home_planet.planet_type = PlanetData.PlanetType.TERRAN
	home_planet.size = PlanetData.PlanetSize.L
	home_planet.max_population = 16
	home_planet.orbital_slot = 2
	sol.celestial_bodies.append(home_planet)
	star_systems[sol.id] = sol
	_system_name_generator.add_used_name(sol.display_name)
	
	var sirius = StarSystem.new()
	sirius.id = "sirius"
	sirius.display_name = "Sirius"
	sirius.position = Vector2(GALAXY_SIZE_X * 0.75, GALAXY_SIZE_Y * 0.5)
	var ai_bodies = _celestial_body_generator.generate_bodies_for_system(4)
	for body in ai_bodies:
		body.system_id = sirius.id
	sirius.celestial_bodies = ai_bodies
	star_systems[sirius.id] = sirius
	_system_name_generator.add_used_name(sirius.display_name)
	
	var procedural_systems = _galaxy_builder.build_galaxy(number_of_systems - 2)
	for system_id in procedural_systems:
		var system_data = procedural_systems[system_id]
		var new_system = StarSystem.new()
		new_system.id = system_id
		new_system.display_name = _system_name_generator.generate_unique_name()
		new_system.position = system_data.position
		var bodies = _celestial_body_generator.generate_bodies_for_system(system_data.num_celestials)
		for body in bodies:
			body.system_id = new_system.id
		new_system.celestial_bodies = bodies
		star_systems[system_id] = new_system

	# Generate galaxy features
	var features = _galaxy_builder.generate_galaxy_features()
	nebulae = features.nebulae
	black_holes = features.black_holes
	wormholes = features.wormholes

	print("GalaxyManager: All systems and features created.")

func get_star_color(num_celestials: int) -> Color:
	if num_celestials == 0 or num_celestials == 6:
		return STAR_COLORS.purple
	elif num_celestials == 1 or num_celestials == 5:
		if num_celestials == 5 and randf() < 0.5:
			return STAR_COLORS.yellow
		return STAR_COLORS.red
	elif num_celestials == 2:
		return STAR_COLORS.blue
	else:
		if num_celestials == 3 and randf() < 0.7:
			return STAR_COLORS.blue
		return STAR_COLORS.yellow

func _on_save_data_loaded(data: Dictionary) -> void:
	if not data.has("galaxy"):
		printerr("GalaxyManager: No galaxy data in save file!")
		return

	star_systems.clear()
	nebulae.clear()
	black_holes.clear()
	wormholes.clear()

	var galaxy_data = data["galaxy"]
	for system_id in galaxy_data:
		var system_data = galaxy_data[system_id]
		var system = StarSystem.new()
		system.id = system_data["id"]
		system.display_name = system_data["display_name"]
		system.position = Vector2(system_data["position"][0], system_data["position"][1])

		for body_data in system_data["celestial_bodies"]:
			var body = _celestial_body_generator.generate_body_from_type(body_data["body_type"])
			body.orbital_slot = body_data["orbital_slot"]
			body.system_id = system.id
			if body is PlanetData and body_data.has("owner_id"):
				body.owner_id = body_data["owner_id"]
			system.celestial_bodies.append(body)

		star_systems[system_id] = system

	# Load galaxy features
	if data.has("galaxy_features"):
		var features_data = data["galaxy_features"]

		for nebula_data in features_data.get("nebulae", []):
			var nebula = CelestialBodyData.new()
			nebula.body_type = CelestialBodyData.BodyType.NEBULA
			nebula.position = Vector2(nebula_data["position"][0], nebula_data["position"][1])
			nebula.size = nebula_data["size"]
			nebulae.append(nebula)

		for black_hole_data in features_data.get("black_holes", []):
			var black_hole = CelestialBodyData.new()
			black_hole.body_type = CelestialBodyData.BodyType.BLACK_HOLE
			black_hole.position = Vector2(black_hole_data["position"][0], black_hole_data["position"][1])
			black_hole.size = black_hole_data["size"]
			black_holes.append(black_hole)

		for wormhole_data in features_data.get("wormholes", []):
			var wormhole = CelestialBodyData.new()
			wormhole.body_type = CelestialBodyData.BodyType.WORMHOLE
			wormhole.position = Vector2(wormhole_data["position"][0], wormhole_data["position"][1])
			wormhole.size = wormhole_data["size"]
			wormhole.exit_position = Vector2(wormhole_data["exit_position"][0], wormhole_data["exit_position"][1])
			wormholes.append(wormhole)

	print("GalaxyManager: Galaxy loaded from save file.")
