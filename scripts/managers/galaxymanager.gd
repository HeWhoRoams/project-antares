# /scripts/managers/galaxymanager.gd
extends Node

const AssetLoader = preload("res://scripts/utils/AssetLoader.gd")
const CelestialBodyGenerator = preload("res://scripts/generators/celestial_body_generator.gd")
const GalaxyBuilder = preload("res://scripts/galaxy/GalaxyBuilder.gd")
const SystemNameGenerator = preload("res://scripts/generators/system_name_generator.gd")
const StarSystem = preload("res://gamedata/systems/star_system.gd")
const PlanetData = preload("res://gamedata/celestial_bodies/planet_data.gd")
const CelestialBodyData = preload("res://gamedata/celestial_bodies/celestial_body_data.gd")

@export var number_of_systems: int = 20
@export var galaxy_age: String = "normal"  # Options: "young", "normal", "old"

const GALAXY_SIZE_X = 1000.0
const GALAXY_SIZE_Y = 1000.0

var star_systems: Dictionary = {}
var nebulae: Array = []
var black_holes: Array = []
var wormholes: Array = []
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
	var GalaxyBuilderScript = AssetLoader.load_script("res://scripts/galaxy/GalaxyBuilder.gd")
	if GalaxyBuilderScript:
		_galaxy_builder = GalaxyBuilderScript.new()
	else:
		printerr("GalaxyManager: Failed to load GalaxyBuilder script!")
		return

	_celestial_body_generator = CelestialBodyGenerator.new()

	var name_data = AssetLoader.load_resource("res://gamedata/systems/system_names.tres")
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
	home_planet.planet_size = PlanetData.PlanetSize.L
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
		var star_color = get_star_color(system_data.num_celestials)
		var bodies = _celestial_body_generator.generate_bodies_for_system(system_data.num_celestials, star_color, galaxy_age)
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

func get_star_color(num_celestials: int) -> String:
	if num_celestials == 0 or num_celestials == 6:
		return "purple"
	elif num_celestials == 1 or num_celestials == 5:
		if num_celestials == 5 and randf() < 0.5:
			return "yellow"
		return "red"
	elif num_celestials == 2:
		return "blue"
	else:
		if num_celestials == 3 and randf() < 0.7:
			return "blue"
		return "yellow"

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
			if body is PlanetData:
				body.planet_type = body_data.get("planet_type", PlanetData.PlanetType.TERRAN)
				body.planet_size = body_data.get("planet_size", PlanetData.PlanetSize.M)
				body.max_population = body_data.get("max_population", 12)
				body.mineral_richness = body_data.get("mineral_richness", PlanetData.MineralRichness.NORMAL)
				body.gravity = body_data.get("gravity", PlanetData.Gravity.NORMAL)
				body.moons = body_data.get("moons", 0)
				body.food_per_farmer = body_data.get("food_per_farmer", 1)
				body.production_per_worker = body_data.get("production_per_worker", 1)
				body.research_per_scientist = body_data.get("research_per_scientist", 1)
				body.owner_id = body_data.get("owner_id", "")
				body.has_natives = body_data.get("has_natives", false)
				body.has_artifacts = body_data.get("has_artifacts", false)
				body.has_crashed_ship = body_data.get("has_crashed_ship", false)
				body.is_abandoned = body_data.get("is_abandoned", false)
				body.has_native_animals = body_data.get("has_native_animals", false)
				body.has_thriving_fauna = body_data.get("has_thriving_fauna", false)
				body.has_hostile_fauna = body_data.get("has_hostile_fauna", false)
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
