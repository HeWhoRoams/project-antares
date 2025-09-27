@tool
extends GutTest

## Unit tests for Ship and Fleet Integration including ShipManager coordination

var ShipManager = load("res://scripts/managers/ShipManager.gd")
var ShipData = load("res://gamedata/ships/ship_data.gd")
var ShipDesign = load("res://gamedata/ships/ship_design.gd")
var Fleet = load("res://gamedata/ships/fleet.gd")
var Empire = load("res://gamedata/empires/empire.gd")
var PlanetData = load("res://gamedata/celestial_bodies/planet_data.gd")
var ColonyData = load("res://gamedata/colonies/colony_data.gd")
var BuildingData = load("res://gamedata/buildings/building_data.gd")

func test_ship_manager_integration():
	should("integrate ship and fleet systems correctly")
	var manager = ShipManager.new()
	
	assert(manager.ships.is_empty())
	assert(manager.fleets.is_empty())
	assert(manager.ship_designs.is_empty())
	assert(manager.ship_modules.is_empty())
	assert(manager.ships_by_system.is_empty())
	assert(manager.ships_by_fleet.is_empty())
	assert(manager.ships_by_planet.is_empty())
	assert(manager.fleets_by_system.is_empty())
	assert(manager.fleets_by_empire.is_empty())
	assert(manager.active_combats.is_empty())

func test_ship_creation_integration():
	should("create ships and integrate with tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var empire_id = "empire_1"
	var system_id = "system_1"
	
	var ship = manager.create_ship(design, empire_id, system_id)
	
	assert(ship != null)
	assert(ship.ship_id != "")
	assert(manager.ships.has(ship.ship_id))
	assert(manager.ships_by_system.has(system_id))
	assert(manager.ships_by_system[system_id].has(ship.ship_id))
	assert(manager.get_ship_by_id(ship.ship_id) == ship)
	assert(manager.get_ships_by_empire(empire_id).size() == 1)
	assert(manager.get_ships_in_system(system_id).size() == 1)

func test_ship_destruction_integration():
	should("destroy ships and remove from all tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var ship_id = ship.ship_id
	
	var success = manager.destroy_ship(ship_id)
	
	assert(success)
	assert(not manager.ships.has(ship_id))
	assert(not manager.ships_by_system.has("system_1") or 
		   not manager.ships_by_system["system_1"].has(ship_id))
	assert(manager.get_ship_by_id(ship_id) == null)
	assert(manager.get_ships_by_empire("empire_1").is_empty())
	assert(manager.get_ships_in_system("system_1").is_empty())

func test_fleet_creation_integration():
	should("create fleets and integrate with tracking systems")
	var manager = ShipManager.new()
	var fleet_name = "Test Fleet"
	var empire_id = "empire_1"
	var system_id = "system_1"
	
	var fleet = manager.create_fleet(fleet_name, empire_id, system_id)
	
	assert(fleet != null)
	assert(fleet.fleet_id != "")
	assert(manager.fleets.has(fleet.fleet_id))
	assert(manager.fleets_by_system.has(system_id))
	assert(manager.fleets_by_system[system_id].has(fleet.fleet_id))
	assert(manager.fleets_by_empire.has(empire_id))
	assert(manager.fleets_by_empire[empire_id].has(fleet.fleet_id))
	assert(manager.get_fleet_by_id(fleet.fleet_id) == fleet)
	assert(manager.get_fleets_by_empire(empire_id).size() == 1)
	assert(manager.get_fleets_in_system(system_id).size() == 1)

func test_fleet_destruction_integration():
	should("destroy fleets and remove from all tracking systems")
	var manager = ShipManager.new()
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	var fleet_id = fleet.fleet_id
	
	var success = manager.destroy_fleet(fleet_id)
	
	assert(success)
	assert(not manager.fleets.has(fleet_id))
	assert(not manager.fleets_by_system.has("system_1") or 
		   not manager.fleets_by_system["system_1"].has(fleet_id))
	assert(not manager.fleets_by_empire.has("empire_1") or 
		   not manager.fleets_by_empire["empire_1"].has(fleet_id))
	assert(manager.get_fleet_by_id(fleet_id) == null)
	assert(manager.get_fleets_by_empire("empire_1").is_empty())
	assert(manager.get_fleets_in_system("system_1").is_empty())

func test_ship_assignment_to_fleet_integration():
	should("assign ships to fleets and update tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	
	var success = manager.assign_ship_to_fleet(ship.ship_id, fleet.fleet_id)
	
	assert(success)
	assert(ship.current_fleet_id == fleet.fleet_id)
	assert(fleet.ships.has(ship))
	assert(manager.ships_by_fleet.has(fleet.fleet_id))
	assert(manager.ships_by_fleet[fleet.fleet_id].has(ship.ship_id))
	assert(manager.get_ships_by_empire("empire_1").size() == 1)
	assert(manager.get_fleets_by_empire("empire_1").size() == 1)

func test_ship_removal_from_fleet_integration():
	should("remove ships from fleets and update tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	
	manager.assign_ship_to_fleet(ship.ship_id, fleet.fleet_id)
	var success = manager.remove_ship_from_fleet(ship.ship_id)
	
	assert(success)
	assert(ship.current_fleet_id == "")
	assert(not fleet.ships.has(ship))
	assert(not manager.ships_by_fleet.has(fleet.fleet_id) or 
		   not manager.ships_by_fleet[fleet.fleet_id].has(ship.ship_id))
	assert(manager.get_ships_by_empire("empire_1").size() == 1)
	assert(manager.get_fleets_by_empire("empire_1").size() == 1)

func test_ship_docking_integration():
	should("dock ships at planets and update tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var planet_id = "planet_1"
	
	var success = manager.dock_ship_at_planet(ship.ship_id, planet_id)
	
	assert(success)
	assert(ship.docked_at_planet_id == planet_id)
	assert(ship.current_system_id == "")
	assert(manager.ships_by_planet.has(planet_id))
	assert(manager.ships_by_planet[planet_id].has(ship.ship_id))
	assert(not manager.ships_by_system.has("system_1") or 
		   not manager.ships_by_system["system_1"].has(ship.ship_id))
	assert(manager.get_ships_at_planet(planet_id).size() == 1)
	assert(manager.get_ships_in_system("system_1").is_empty())

func test_ship_undocking_integration():
	should("undock ships from planets and update tracking systems")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var planet_id = "planet_1"
	
	manager.dock_ship_at_planet(ship.ship_id, planet_id)
	var success = manager.undock_ship_from_planet(ship.ship_id)
	
	assert(success)
	assert(ship.docked_at_planet_id == "")
	assert(ship.current_system_id != "")
	assert(not manager.ships_by_planet.has(planet_id) or 
		   not manager.ships_by_planet[planet_id].has(ship.ship_id))
	assert(manager.ships_by_system.has(ship.current_system_id))
	assert(manager.ships_by_system[ship.current_system_id].has(ship.ship_id))
	assert(manager.get_ships_at_planet(planet_id).is_empty())
	assert(manager.get_ships_in_system(ship.current_system_id).size() == 1)

func test_ship_repair_integration():
	should("repair ships and update statistics")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	
	# Damage the ship first
	ship.hull_integrity = 0.5
	
	var repaired_amount = manager.repair_ship(ship.ship_id, 0.3)
	
	assert(repaired_amount > 0)
	assert(ship.hull_integrity > 0.5)
	assert(ship.hull_integrity <= 1.0)

func test_ship_refueling_integration():
	should("refuel ships and update fuel levels")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	
	# Use some fuel first
	ship.fuel_level = 50.0
	
	var refueled_amount = manager.refuel_ship(ship.ship_id, 25.0)
	
	assert(refueled_amount > 0)
	assert(ship.fuel_level > 50.0)
	assert(ship.fuel_level <= ship.fuel_capacity)

func test_cargo_transfer_integration():
	should("transfer cargo between ships correctly")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_1", "system_1")
	
	# Add cargo to ship1
	ship1.add_cargo("ore", 10)
	
	var success = manager.transfer_cargo_between_ships(ship1.ship_id, ship2.ship_id, "ore", 5)
	
	assert(success)
	assert(ship1.get_cargo_weight() == 5)
	assert(ship2.get_cargo_weight() == 5)
	assert(manager.get_ship_by_id(ship1.ship_id).get_cargo_weight() == 5)
	assert(manager.get_ship_by_id(ship2.ship_id).get_cargo_weight() == 5)

func test_fleet_movement_integration():
	should("move fleets between systems and update tracking")
	var manager = ShipManager.new()
	var fleet = manager.create_fleet("Moving Fleet", "empire_1", "system_1")
	var destination_system = "system_2"
	
	var success = manager.move_fleet(fleet.fleet_id, destination_system)
	
	assert(success)
	assert(fleet.current_system_id == destination_system)
	assert(fleet.destination_system_id == "")
	assert(not manager.fleets_by_system.has("system_1") or 
		   not manager.fleets_by_system["system_1"].has(fleet.fleet_id))
	assert(manager.fleets_by_system.has(destination_system))
	assert(manager.fleets_by_system[destination_system].has(fleet.fleet_id))

func test_fleet_merging_integration():
	should("merge fleets and update tracking systems")
	var manager = ShipManager.new()
	var fleet1 = manager.create_fleet("Primary Fleet", "empire_1", "system_1")
	var fleet2 = manager.create_fleet("Secondary Fleet", "empire_1", "system_1")
	
	// Add a ship to fleet2 to make merging meaningful
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	manager.assign_ship_to_fleet(ship.ship_id, fleet2.fleet_id)
	
	var success = manager.merge_fleets(fleet1.fleet_id, fleet2.fleet_id)
	
	assert(success)
	assert(not manager.fleets.has(fleet2.fleet_id))
	assert(not manager.fleets_by_system.has("system_1") or 
		   not manager.fleets_by_system["system_1"].has(fleet2.fleet_id))
	assert(not manager.fleets_by_empire.has("empire_1") or 
		   not manager.fleets_by_empire["empire_1"].has(fleet2.fleet_id))
	// fleet1 should still exist and have the ship
	assert(manager.fleets.has(fleet1.fleet_id))
	assert(manager.get_fleet_by_id(fleet1.fleet_id).ships.has(ship))

func test_fleet_splitting_integration():
	should("split fleets and update tracking systems")
	var manager = ShipManager.new()
	var fleet = manager.create_fleet("Original Fleet", "empire_1", "system_1")
	
	// Add multiple ships to fleet
	var design = _create_mock_ship_design("test_design")
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_1", "system_1")
	var ship3 = manager.create_ship(design, "empire_1", "system_1")
	
	manager.assign_ship_to_fleet(ship1.ship_id, fleet.fleet_id)
	manager.assign_ship_to_fleet(ship2.ship_id, fleet.fleet_id)
	manager.assign_ship_to_fleet(ship3.ship_id, fleet.fleet_id)
	
	// Split off 1 ship
	var new_fleet = manager.split_fleet(fleet.fleet_id, 1, "Split Fleet")
	
	assert(new_fleet != null)
	assert(new_fleet.fleet_name == "Split Fleet")
	assert(manager.fleets.has(new_fleet.fleet_id))
	assert(manager.fleets_by_system.has("system_1"))
	assert(manager.fleets_by_system["system_1"].has(new_fleet.fleet_id))
	assert(manager.fleets_by_empire.has("empire_1"))
	assert(manager.fleets_by_empire["empire_1"].has(new_fleet.fleet_id))
	assert(manager.get_fleet_by_id(new_fleet.fleet_id) == new_fleet)
	assert(fleet.ships.size() == 2)
	assert(new_fleet.ships.size() == 1)

func test_ship_design_creation_integration():
	should("create ship designs and register them correctly")
	var manager = ShipManager.new()
	var design_name = "New Design"
	var hull_type = ShipDesign.ShipSize.FRIGATE
	
	var design = manager.create_ship_design(design_name, hull_type)
	
	assert(design != null)
	assert(design.design_id != "")
	assert(design.design_name == design_name)
	assert(design.hull_type == hull_type)
	assert(manager.ship_designs.has(design.design_id))
	assert(manager.get_ship_design(design.design_id) == design)

func test_ship_module_registration_integration():
	should("register ship modules and make them available")
	var manager = ShipManager.new()
	var module = _create_mock_ship_module("test_module")
	
	var success = manager.register_ship_module(module)
	
	assert(success)
	assert(manager.ship_modules.has(module.module_id))
	assert(manager.ship_modules[module.module_id] == module)
	assert(manager.get_ship_module(module.module_id) == module)

func test_get_ships_by_empire_integration():
	should("get all ships for an empire correctly")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	
	// Create ships for the same empire
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_1", "system_2")
	
	// Create ship for different empire
	var ship3 = manager.create_ship(design, "empire_2", "system_1")
	
	var empire_ships = manager.get_ships_by_empire("empire_1")
	
	assert(empire_ships.size() == 2)
	assert(empire_ships.has(ship1))
	assert(empire_ships.has(ship2))
	assert(not empire_ships.has(ship3))

func test_get_fleets_by_empire_integration():
	should("get all fleets for an empire correctly")
	var manager = ShipManager.new()
	
	// Create fleets for the same empire
	var fleet1 = manager.create_fleet("Fleet 1", "empire_1", "system_1")
	var fleet2 = manager.create_fleet("Fleet 2", "empire_1", "system_2")
	
	// Create fleet for different empire
	var fleet3 = manager.create_fleet("Fleet 3", "empire_2", "system_1")
	
	var empire_fleets = manager.get_fleets_by_empire("empire_1")
	
	assert(empire_fleets.size() == 2)
	assert(empire_fleets.has(fleet1))
	assert(empire_fleets.has(fleet2))
	assert(not empire_fleets.has(fleet3))

func test_get_ships_in_system_integration():
	should("get all ships in a system correctly")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	
	// Create ships in the same system
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_2", "system_1")
	
	// Create ship in different system
	var ship3 = manager.create_ship(design, "empire_1", "system_2")
	
	var system_ships = manager.get_ships_in_system("system_1")
	
	assert(system_ships.size() == 2)
	assert(system_ships.has(ship1))
	assert(system_ships.has(ship2))
	assert(not system_ships.has(ship3))

func test_get_ships_at_planet_integration():
	should("get all ships docked at a planet correctly")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_2", "system_1")
	var planet_id = "planet_1"
	
	// Dock ships at planet
	manager.dock_ship_at_planet(ship1.ship_id, planet_id)
	manager.dock_ship_at_planet(ship2.ship_id, planet_id)
	
	var planet_ships = manager.get_ships_at_planet(planet_id)
	
	assert(planet_ships.size() == 2)
	assert(planet_ships.has(ship1))
	assert(planet_ships.has(ship2))
	assert(manager.ships_by_planet.has(planet_id))
	assert(manager.ships_by_planet[planet_id].size() == 2)

func test_get_fleets_in_system_integration():
	should("get all fleets in a system correctly")
	var manager = ShipManager.new()
	
	// Create fleets in the same system
	var fleet1 = manager.create_fleet("Fleet 1", "empire_1", "system_1")
	var fleet2 = manager.create_fleet("Fleet 2", "empire_2", "system_1")
	
	// Create fleet in different system
	var fleet3 = manager.create_fleet("Fleet 3", "empire_1", "system_2")
	
	var system_fleets = manager.get_fleets_in_system("system_1")
	
	assert(system_fleets.size() == 2)
	assert(system_fleets.has(fleet1))
	assert(system_fleets.has(fleet2))
	assert(not system_fleets.has(fleet3))
	assert(manager.fleets_by_system.has("system_1"))
	assert(manager.fleets_by_system["system_1"].size() == 2)

func test_combat_initiation_integration():
	should("initiate combat between fleets and update statuses")
	var manager = ShipManager.new()
	var attacking_fleet = manager.create_fleet("Attacker", "empire_1", "system_1")
	var defending_fleet = manager.create_fleet("Defender", "empire_2", "system_1")
	
	var success = manager.initiate_combat(attacking_fleet.fleet_id, defending_fleet.fleet_id)
	
	assert(success)
	// Both fleets should be in combat status
	assert(attacking_fleet.fleet_status == Fleet.FleetStatus.IN_COMBAT)
	assert(defending_fleet.fleet_status == Fleet.FleetStatus.IN_COMBAT)
	assert(manager.active_combats.size() == 1)

func test_combat_resolution_integration():
	should("resolve combat and update fleet statuses")
	var manager = ShipManager.new()
	var attacking_fleet = manager.create_fleet("Attacker", "empire_1", "system_1")
	var defending_fleet = manager.create_fleet("Defender", "empire_2", "system_1")
	
	manager.initiate_combat(attacking_fleet.fleet_id, defending_fleet.fleet_id)
	
	// For testing, we'll assume attacking fleet wins
	var success = manager.resolve_combat("combat_placeholder", true)
	
	assert(success)
	// Both fleets should be back to idle status
	assert(attacking_fleet.fleet_status == Fleet.FleetStatus.IDLE)
	assert(defending_fleet.fleet_status == Fleet.FleetStatus.IDLE)
	assert(manager.active_combats.is_empty())

func test_ship_value_calculation_integration():
	should("calculate ship value correctly through manager")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	
	var value = manager.get_ship_value(ship.ship_id)
	
	assert(value > 0)
	// Value should be reasonable (not negative, not absurdly high)
	assert(value > 10)
	assert(value < 10000)

func test_ship_utility_functions_integration():
	should("provide correct utility function results through manager")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	
	// Create multiple ships for empire_1
	manager.create_ship(design, "empire_1", "system_1")
	manager.create_ship(design, "empire_1", "system_2")
	
	// Create ship for different empire
	manager.create_ship(design, "empire_2", "system_1")
	
	var ship_count = manager.get_ship_count_by_empire("empire_1")
	var total_value = manager.get_total_ship_value_by_empire("empire_1")
	
	assert(ship_count == 2)
	assert(total_value > 0)

func test_fleet_utility_functions_integration():
	should("provide correct fleet utility function results through manager")
	var manager = ShipManager.new()
	
	// Create multiple fleets for empire_1
	var fleet1 = manager.create_fleet("Fleet 1", "empire_1", "system_1")
	var fleet2 = manager.create_fleet("Fleet 2", "empire_1", "system_2")
	
	// Create fleet for different empire
	var fleet3 = manager.create_fleet("Fleet 3", "empire_2", "system_1")
	
	var fleet_count = manager.get_fleet_count_by_empire("empire_1")
	
	assert(fleet_count == 2)

func test_combat_status_checks_integration():
	should("correctly check combat status for ships and fleets through manager")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	
	// Initially, ship and fleet should not be in combat
	var ship_in_combat = manager.is_ship_in_combat(ship.ship_id)
	var fleet_in_combat = manager.is_fleet_in_combat(fleet.fleet_id)
	
	assert(not ship_in_combat)
	assert(not fleet_in_combat)
	
	// Put fleet in combat
	fleet.fleet_status = Fleet.FleetStatus.IN_COMBAT
	
	// Now fleet should be in combat
	fleet_in_combat = manager.is_fleet_in_combat(fleet.fleet_id)
	assert(fleet_in_combat)

func test_static_factory_methods_integration():
	should("create managers with factory methods correctly")
	var default_manager = ShipManager.create_default_ship_manager()
	var test_manager = ShipManager.create_test_ship_manager()
	
	assert(default_manager != null)
	assert(test_manager != null)
	assert(default_manager.ship_designs.size() > 0)
	assert(test_manager.ship_modules.size() > 0)
	assert(default_manager.ships.is_empty())
	assert(test_manager.ships.is_empty())

func test_save_load_functionality_integration():
	should("handle save/load data correctly through manager")
	var manager = ShipManager.new()
	var save_data = manager.get_save_data()
	
	// Should return a dictionary with all the expected keys
	assert(save_data.has("ships"))
	assert(save_data.has("fleets"))
	assert(save_data.has("ship_designs"))
	assert(save_data.has("ship_modules"))
	assert(save_data.has("active_combats"))
	assert(save_data.has("ships_by_system"))
	assert(save_data.has("ships_by_fleet"))
	assert(save_data.has("ships_by_planet"))
	assert(save_data.has("fleets_by_system"))
	assert(save_data.has("fleets_by_empire"))

func test_building_system_integration():
	should("integrate building system with ship/fleet management")
	var manager = ShipManager.new()
	var design = _create_mock_ship_design("test_design")
	var ship = manager.create_ship(design, "empire_1", "system_1")
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	
	// Test that ships can be assigned to fleets
	var success = manager.assign_ship_to_fleet(ship.ship_id, fleet.fleet_id)
	assert(success)
	assert(ship.current_fleet_id == fleet.fleet_id)
	assert(fleet.ships.has(ship))
	
	// Test that fleets can be moved
	success = manager.move_fleet(fleet.fleet_id, "system_2")
	assert(success)
	assert(fleet.current_system_id == "system_2")
	
	// Test that ships can be docked at planets
	success = manager.dock_ship_at_planet(ship.ship_id, "planet_1")
	assert(success)
	assert(ship.docked_at_planet_id == "planet_1")
	
	// Test that ships can be undocked
	success = manager.undock_ship_from_planet(ship.ship_id)
	assert(success)
	assert(ship.docked_at_planet_id == "")
	
	// Test that ships can be repaired
	var initial_hull = ship.hull_integrity
	ship.hull_integrity = 0.5  // Damage the ship
	var repaired = manager.repair_ship(ship.ship_id, 0.2)
	assert(repaired > 0)
	assert(ship.hull_integrity > 0.5)
	
	// Test that ships can be refueled
	var initial_fuel = ship.fuel_level
	ship.fuel_level = 50.0  // Use some fuel
	var refueled = manager.refuel_ship(ship.ship_id, 25.0)
	assert(refueled > 0)
	assert(ship.fuel_level > 50.0)

func test_ship_module_system_integration():
	should("integrate ship modules with ship design and construction")
	var manager = ShipManager.new()
	var design = manager.create_ship_design("Test Design", ShipDesign.ShipSize.FRIGATE)
	
	// Register some modules
	var weapon_module = _create_mock_ship_module("laser_weapon")
	weapon_module.module_type = ShipModule.ModuleType.LIGHT_WEAPON
	weapon_module.is_weapon = true
	weapon_module.damage = 10
	weapon_module.range = 8
	weapon_module.accuracy = 0.8
	weapon_module.fire_rate = 1.5
	
	var shield_module = _create_mock_ship_module("basic_shield")
	shield_module.module_type = ShipModule.ModuleType.SHIELD
	shield_module.shield_bonus = 25
	shield_module.shield_recharge_bonus = 2.0
	
	var engine_module = _create_mock_ship_module("ion_engine")
	engine_module.module_type = ShipModule.ModuleType.ENGINE
	engine_module.speed_bonus = 1.0
	engine_module.turn_rate_bonus = 0.2
	
	manager.register_ship_module(weapon_module)
	manager.register_ship_module(shield_module)
	manager.register_ship_module(engine_module)
	
	// Create a ship with the design
	var ship = manager.create_ship(design, "empire_1", "system_1")
	
	// Add modules to ship
	var weapon_success = ship.add_weapon_module(weapon_module)
	var shield_success = ship.add_shield_module(shield_module)
	var engine_success = ship.add_engine_module(engine_module)
	
	assert(weapon_success)
	assert(shield_success)
	assert(engine_success)
	
	// Verify modules were added
	assert(ship.weapon_hardpoints.size() == 1)
	assert(ship.shield_generators.size() == 1)
	assert(ship.engines.size() == 1)
	
	// Verify module effects are applied
	assert(ship.get_total_weapon_damage() > 0)
	assert(ship.get_total_shield_capacity() > design.total_shield_capacity)
	assert(ship.get_total_speed() > design.total_speed)

func test_fleet_ship_management_integration():
	should("manage fleet ship assignments and operations correctly")
	var manager = ShipManager.new()
	var design = manager.create_ship_design("Test Design", ShipDesign.ShipSize.FRIGATE)
	
	// Create multiple ships
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_1", "system_1")
	var ship3 = manager.create_ship(design, "empire_1", "system_1")
	
	// Create fleet
	var fleet = manager.create_fleet("Test Fleet", "empire_1", "system_1")
	
	// Assign ships to fleet
	var success1 = manager.assign_ship_to_fleet(ship1.ship_id, fleet.fleet_id)
	var success2 = manager.assign_ship_to_fleet(ship2.ship_id, fleet.fleet_id)
	var success3 = manager.assign_ship_to_fleet(ship3.ship_id, fleet.fleet_id)
	
	assert(success1)
	assert(success2)
	assert(success3)
	assert(fleet.ships.size() == 3)
	
	// Verify ship-fleet relationships
	assert(ship1.current_fleet_id == fleet.fleet_id)
	assert(ship2.current_fleet_id == fleet.fleet_id)
	assert(ship3.current_fleet_id == fleet.fleet_id)
	
	// Remove one ship from fleet
	var remove_success = manager.remove_ship_from_fleet(ship2.ship_id)
	
	assert(remove_success)
	assert(fleet.ships.size() == 2)
	assert(ship2.current_fleet_id == "")
	assert(not fleet.ships.has(ship2))

func test_ship_cargo_system_integration():
	should("handle ship cargo operations correctly")
	var manager = ShipManager.new()
	var design = manager.create_ship_design("Cargo Ship", ShipDesign.ShipSize.FRIGATE)
	design.total_cargo_capacity = 100
	
	var ship1 = manager.create_ship(design, "empire_1", "system_1")
	var ship2 = manager.create_ship(design, "empire_1", "system_1")
	
	// Add cargo to ship1
	var add_success = ship1.add_cargo("ore", 30)
	assert(add_success)
	assert(ship1.get_cargo_weight() == 30)
	assert(ship1.get_cargo_free() == 70)
	
	// Transfer cargo to ship2
	var transfer_success = manager.transfer_cargo_between_ships(ship1.ship_id, ship2.ship_id, "ore", 15)
	
	assert(transfer_success)
	assert(ship1.get_cargo_weight() == 15)
	assert(ship2.get_cargo_weight() == 15)
	assert(ship1.get_cargo_free() == 85)
	assert(ship2.get_cargo_free() == 85)

func test_fleet_combat_system_integration():
	should("handle fleet combat operations correctly")
	var manager = ShipManager.new()
	var design = manager.create_ship_design("Combat Ship", ShipDesign.ShipSize.FRIGATE)
	
	var attacking_fleet = manager.create_fleet("Attacker", "empire_1", "system_1")
	var defending_fleet = manager.create_fleet("Defender", "empire_2", "system_1")
	
	// Add ships to fleets
	var attacker_ship = manager.create_ship(design, "empire_1", "system_1")
	var defender_ship = manager.create_ship(design, "empire_2", "system_1")
	
	manager.assign_ship_to_fleet(attacker_ship.ship_id, attacking_fleet.fleet_id)
	manager.assign_ship_to_fleet(defender_ship.ship_id, defending_fleet.fleet_id)
	
	// Initiate combat
	var combat_success = manager.initiate_combat(attacking_fleet.fleet_id, defending_fleet.fleet_id)
	
	assert(combat_success)
	assert(attacking_fleet.fleet_status == Fleet.FleetStatus.IN_COMBAT)
	assert(defending_fleet.fleet_status == Fleet.FleetStatus.IN_COMBAT)
	assert(manager.active_combats.size() == 1)
	
	// Resolve combat (attacker wins)
	var resolve_success = manager.resolve_combat("combat_placeholder", true)
	
	assert(resolve_success)
	assert(attacking_fleet.fleet_status == Fleet.FleetStatus.IDLE)
	assert(defending_fleet.fleet_status == Fleet.FleetStatus.IDLE)
	assert(manager.active_combats.is_empty())

func test_ship_design_factory_methods_integration():
	should("create standard ship designs with factory methods")
	var manager = ShipManager.new()
	
	// Test scout ship creation
	var scout_design = ShipDesign.create_scout_ship()
	assert(scout_design.design_id == "ship_scout")
	assert(scout_design.design_name == "Scout Ship")
	assert(scout_design.hull_type == ShipDesign.ShipSize.SCOUT)
	assert(scout_design.speed > 5.0)  // Scouts should be fast
	assert(scout_design.sensor_range > 15)  // Scouts should have good sensors
	
	// Test frigate creation
	var frigate_design = ShipDesign.create_frigate_ship()
	assert(frigate_design.design_id == "ship_frigate")
	assert(frigate_design.design_name == "Frigate")
	assert(frigate_design.hull_type == ShipDesign.ShipSize.FRIGATE)
	assert(frigate_design.speed > 3.0)
	assert(frigate_design.weapon_hardpoints.size() > 0)
	
	// Test destroyer creation
	var destroyer_design = ShipDesign.create_destroyer_ship()
	assert(destroyer_design.design_id == "ship_destroyer")
	assert(destroyer_design.design_name == "Destroyer")
	assert(destroyer_design.hull_type == ShipDesign.ShipSize.DESTROYER)
	assert(destroyer_design.total_hull_points > 200)  // Destroyers should be tough
	assert(destroyer_design.total_shield_capacity > 100)
	assert(destroyer_design.total_armor_value > 50)

func test_ship_module_factory_methods_integration():
	should("create standard ship modules with factory methods")
	var manager = ShipManager.new()
	
	// Test weapon module creation
	var laser_module = ShipModule.create_light_laser()
	assert(laser_module.module_id == "mod_light_laser_mk1")
	assert(laser_module.display_name == "Light Laser")
	assert(laser_module.module_type == ShipModule.ModuleType.LIGHT_WEAPON)
	assert(laser_module.is_weapon == true)
	assert(laser_module.damage == 5)
	assert(laser_module.range == 8)
	assert(laser_module.accuracy == 0.85)
	assert(laser_module.fire_rate == 2.0)
	
	// Test shield module creation
	var shield_module = ShipModule.create_basic_shield()
	assert(shield_module.module_id == "mod_basic_shield_mk1")
	assert(shield_module.display_name == "Basic Shield Generator")
	assert(shield_module.module_type == ShipModule.ModuleType.SHIELD)
	assert(shield_module.shield_bonus == 25)
	assert(shield_module.shield_recharge_bonus == 2.0)
	
	// Test armor module creation
	var armor_module = ShipModule.create_basic_armor()
	assert(armor_module.module_id == "mod_basic_armor_mk1")
	assert(armor_module.display_name == "Reinforced Armor")
	assert(armor_module.module_type == ShipModule.ModuleType.ARMOR)
	assert(armor_module.armor_bonus == 15)
	assert(armor_module.armor_repair_bonus == 1.0)
	
	// Test engine module creation
	var engine_module = ShipModule.create_basic_engine()
	assert(engine_module.module_id == "mod_basic_engine_mk1")
	assert(engine_module.display_name == "Ion Thruster")
	assert(engine_module.module_type == ShipModule.ModuleType.ENGINE)
	assert(engine_module.speed_bonus == 1.0)
	assert(engine_module.turn_rate_bonus == 0.2)
	
	// Test sensor module creation
	var sensor_module = ShipModule.create_sensor_array()
	assert(sensor_module.module_id == "mod_sensor_array_mk1")
	assert(sensor_module.display_name == "Sensor Array")
	assert(sensor_module.module_type == ShipModule.ModuleType.SENSOR)
	assert(sensor_module.sensor_bonus == 5)
	assert(sensor_module.range_bonus == 3)

func test_building_data_integration():
	should("integrate building data with ship/fleet systems")
	var manager = ShipManager.new()
	var design = manager.create_ship_design("Colony Ship", ShipDesign.ShipSize.FRIGATE)
	
	// Create a colony ship that can build buildings
	var colony_ship = manager.create_ship(design, "empire_1", "system_1")
	
	// Test building construction capabilities
	var building_design = BuildingData.create_hydroponics_farm()
	assert(building_design != null)
	assert(building_design.design_id == "bldg_hydroponics")
	assert(building_design.display_name == "Hydroponics Farm")
	assert(building_design.food_modifier > 0)
	
	// Test building can be built in colony
	var mock_colony = _create_mock_colony()
	var mock_empire = _create_mock_empire()
	mock_empire.unlocked_techs.append("tech_hydroponics")
	
	var can_build = building_design.can_build_in_colony(mock_colony, mock_empire.unlocked_techs)
	assert(can_build)
	
	// Test building effects
	var effects = building_design.get_effect_description()
	assert(effects.contains("Food: +50%"))
	assert(effects.contains("Production: +75%"))
	assert(effects.contains("Research: +25%"))

func _create_mock_ship_design(design_id: String) -> ShipDesign:
	"""Create a mock ship design for testing"""
	var design = ShipDesign.new()
	design.design_id = design_id
	design.design_name = "Test Design %s" % design_id
	design.hull_type = ShipDesign.ShipSize.FRIGATE
	design.total_hull_points = 100
	design.total_shield_capacity = 50
	design.total_armor_value = 25
	design.total_speed = 5.0
	design.total_turn_rate = 1.0
	design.total_sensor_range = 15
	design.total_cargo_capacity = 50
	design.total_fuel_capacity = 100
	design.total_crew_required = 25
	return design

func _create_mock_ship_module(module_id: String) -> ShipModule:
	"""Create a mock ship module for testing"""
	var module = ShipModule.new()
	module.module_id = module_id
	module.display_name = "Test Module %s" % module_id
	module.module_type = ShipModule.ModuleType.LIGHT_WEAPON
	module.is_weapon = true
	module.damage = 10
	module.range = 8
	module.accuracy = 0.8
	module.fire_rate = 1.5
	module.production_cost = 25
	module.production_time = 2
	return module

func _create_mock_ship(ship_id: String) -> ShipData:
	"""Create a mock ship for testing"""
	var ship = ShipData.new()
	ship.ship_id = ship_id
	ship.ship_name = "Test Ship %s" % ship_id
	ship.owner_empire_id = "empire_1"
	ship.current_system_id = "system_1"
	ship.current_fleet_id = ""
	ship.hull_points = 100
	ship.max_hull_points = 100
	ship.shield_capacity = 50
	ship.max_shield_capacity = 50
	ship.armor_value = 25
	ship.max_armor_value = 25
	ship.speed = 5.0
	ship.turn_rate = 1.0
	ship.sensor_range = 15
	ship.cargo_capacity = 50
	ship.fuel_capacity = 100
	ship.fuel_level = 100
	ship.crew_count = 25
	ship.hull_integrity = 1.0
	ship.shield_strength = 1.0
	ship.armor_integrity = 1.0
	ship.crew_morale = 1.0
	ship.crew_experience = 0.5
	ship.crew_training = 0.5
	return ship

func _create_mock_empire(empire_id: String) -> Empire:
	"""Create a mock empire for testing"""
	var empire = Empire.new()
	empire.id = empire_id
	empire.display_name = "Test Empire %s" % empire_id
	empire.treasury = 1000
	empire.income_per_turn = 100
	empire.research_points = 50
	empire.research_per_turn = 25
	empire.unlocked_techs = []
	empire.is_ai_controlled = false
	empire.home_system_id = "home_system"
	empire.owned_ships = {}
	empire.owned_colonies = {}
	empire.diplomatic_statuses = {}
	empire.race_preset = null
	empire.leader = null
	empire.government_type = Empire.GovernmentType.DEMOCRACY
	empire.military_strength = 0
	empire.economic_power = 0
	empire.technological_advancement = 0
	empire.cultural_influence = 0
	empire.spy_networks = {}
	empire.council_votes = 0
	empire.council_resolutions = []
	empire.achievements = []
	return empire

func _create_mock_planet(planet_id: String) -> PlanetData:
	"""Create a mock planet for testing"""
	var planet = PlanetData.new()
	planet.system_id = "test_system"
	planet.orbital_slot = 1
	planet.planet_type = PlanetData.PlanetType.TERRAN
	planet.max_population = 20
	planet.owner_id = "empire_1"
	planet.celestial_body_type = PlanetData.CelestialBodyType.PLANET
	return planet

func _create_mock_colony() -> ColonyData:
	"""Create a mock colony for testing"""
	var colony = ColonyData.new()
	colony.system_id = "test_system"
	colony.orbital_slot = 1
	colony.current_population = 10
	colony.farmers = 5
	colony.workers = 3
	colony.scientists = 2
	colony.food_produced = 0
	colony.production_produced = 0
	colony.research_produced = 0
	colony.buildings = []
	colony.construction_queue = []
	colony.pollution = 0
	colony.morale = 50
	colony.growth_progress = 0
	colony.owner_id = "empire_1"
	return colony

</final_file_content>

IMPORTANT: For any future changes to this file, use the final_file_content shown above as your reference. This content reflects the current state of the file, including any auto-formatting (e.g., if you used single quotes but the formatter converted them to double quotes). Always base your SEARCH/REPLACE operations on this final version to ensure accuracy.



<environment_details>
# VSCode Visible Files
ui/hud/hud.gd
ui/hud/hud.gd
tests/test_building_system.gd

# VSCode Open Tabs
ui/screens/tech_base_screen.tscn
ui/components/tech_entry.gd.uid
ui/screens/tech_screen.gd
gamedata/game_data.gd
tests/test_galaxy.gd
.github/workflows/ci.yml
open_question.txt
gamedata/buildings/building_data.gd
gamedata/colonies.gd
tests/test_colony_management.gd
ui/components/building_icon.gd
ui/components/building_icon.tscn
scripts/managers/GameManager.gd
tests/test_council_manager.gd
tests/test_ai_manager.gd
scripts/managers/EmpireManager.gd
gamedata/races/race_preset.gd
scripts/managers/AIManager.gd
scripts/managers/ColonyManager.gd
tests/test_technology_effect_manager.gd
scripts/managers/turn_manager.gd
tests/test_turn_interruption.gd
ui/main_theme.tres
ui/hud/hud.gd
gamedata/spies/spy_data.gd
gamedata/spies/spy_network_data.gd
scripts/managers/espionage_manager.gd
ui/screens/espionage_screen.tscn
ui/screens/espionage_screen.gd
tests/test_espionage.gd
project_antares_plan.txt
DEVELOPMENT_TASKS.md
gamedata/game_setup_data.gd
tests/test_game_setup.gd
scripts/managers/SaveLoadManager.gd
tests/test_save_load_versioning.gd
tests/test_turn_manager.gd
tests/test_colony_manager.gd
ui/components/building_selection_entry.gd
ui/components/building_selection_entry.tscn
ui/screens/colonies_screen.gd
ui/screens/colonies_screen.tscn
scripts/managers/PathfindingManager.gd
tests/test_pathfinding.gd
ui/components/turn_advancement_button.gd
ui/components/turn_advancement_button.tscn
ui/hud/hud.tscn
scripts/managers/TechnologyEffectManager.gd
tests/test_technology_system.gd
gamedata/ships/ship_design.gd
gamedata/ships/ship_module.gd
gamedata/ships/fleet.gd
gamedata/ships/ship_data.gd
scripts/managers/ShipManager.gd
tests/test_ship_management.gd
tests/test_building_system.gd
ui/screens/ship_design_screen.gd
ui/screens/fleet_management_screen.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
.clinerules/godot rules.md
scripts/utils/AssetLoader.gd
scripts/managers/DataManager.gd
scripts/managers/AudioManager.gd
ui/main_menu.gd
tests/test_harness.tscn
tests/test_main_menu.gd
tests/test_galaxy_manager.gd
scripts/galaxy/GalaxyGenerator.gd
scripts/Ship.gd
tests/test_combat.gd
project.godot
gut_config.json
addons/gut/addons/gut/utils.gd
addons/gut/addons/gut/lazy_loader.gd
addons/gut/addons/gut/gui/editor_globals.gd
addons/gut/addons/gut/gut.gd
ui/themes/bordered_panel_style.tres
ui/components/system_planet_list_entry.tscn
ui/components/system_planet_list_entry.gd
gamedata/buildings/buildable_item.gd
gamedata/ships/ship_data.gd
scenes/starmap_objects/star_system_view.tscn
ui/popups/system_view_popup.tscn
scenes/system_view_objects/planet_view.tscn
scenes/system_view_objects/planet_view.gd
scenes/starmap/starmap.tscn
gamedata/technologies/tech_tree_classic.json
scripts/managers/SceneManager.gd
ui/screens/system_info_popup.gd
ui/screens/planets_screen.tscn
ui/screens/ships_screen.tscn
ui/screens/ships_screen.gd
ui/screens/NPCs_screen.tscn
ui/screens/NPCs_screen.gd
tests/test_ship_fleet_integration.gd
scripts/managers/ShipManager.gd
gamedata/diplomacy/diplomatic_status.gd
scripts/managers/diplomacy_manager.gd
ui/screens/diplomacy_screen.gd
ui/screens/diplomacy_screen.tscn
tests/test_diplomacy_system.gd
gamedata/council/council_session_data.gd
gamedata/council/resolution_data.gd
scripts/managers/council_manager.gd
ui/screens/council_screen.tscn
ui/screens/council_screen.gd
tests/test_council_system.gd
gamedata/leaders/leader_data.gd
scripts/managers/leader_manager.gd
ui/screens/leaders_screen.tscn
ui/screens/leaders_screen.gd
tests/test_leader_system.gd
test_demo.gd
scripts/galaxy/GalaxyBuilder.gd
gamedata/empires/empire.gd
ui/screens/research_screen.tscn
ui/screens/research_screen.gd
ui/components/tech_entry.tscn
scripts/managers/player_manager.gd
ui/screens/settings_screen.tscn
ui/screens/settings_screen.gd
ui/screens/load_game_screen.gd
ui/main_menu.tscn
tests/test_audio_manager.gd
tests/test_debug_manager.gd
tests/test_empire_manager.gd
tests/test_game_manager.gd
gamedata/celestial_bodies/planet_data.gd
gamedata/celestial_bodies/moon_data.gd
gamedata/celestial_bodies/celestial_body_data.gd
ui/screens/load_game_screen.tscn
scenes/starmap/starmap.gd
ui/popups/system_view_popup.gd
scripts/managers/DemoManager.gd
run_ci.bat
tests/test_data_manager.gd
tests/test_static_analysis.gd
ui/debug/debug_overlay.tscn
ui/debug/debug_overlay.gd
scripts/managers/DebugManager.gd
tests/test_scene_validator.gd
tests/test_turns_integration_cycle.gd
tests/test_ui_layouts.gd
scripts/GalaxyGenerator.gd
gamedata/celestial_bodies/nebula_data.gd
gamedata/celestial_bodies/black_hole_data.gd
gamedata/celestial_bodies/wormhole_data.gd
scripts/managers/galaxymanager.gd
scripts/generators/celestial_body_generator.gd
gamedata/ships/ship_hull.gd
gamedata/celestial_bodies/celestial_body_data.gd
gamedata/technologies/tech_tree.json
../../Users/User/Documents/Cline/Rules/diataxis.txt
.clinerules/rules.md
../../Users/User/Documents/Cline/Workflows/new feature request.md
../../Users/User/Documents/Cline/Workflows/fix bug.md
../../Users/User/Documents/Cline/Workflows/refector request.md
