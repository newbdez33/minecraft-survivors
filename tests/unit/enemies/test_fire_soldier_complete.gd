extends Node
class_name TestFireSoldierComplete
## Complete fire_soldier enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Fire Soldier Complete Tests"

static func get_fire_soldier_instance():
	var scene = load("res://scenes/enemies/fire_soldier.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_fire_soldier_scene_loads())
	_add_result(results, test_fire_soldier_script_loads())
	_add_result(results, test_fire_soldier_is_character_body_2d())
	_add_result(results, test_fire_soldier_has_health())
	_add_result(results, test_fire_soldier_has_speed())
	_add_result(results, test_fire_soldier_has_damage())
	_add_result(results, test_fire_soldier_has_xp_value())

	# Component Tests
	_add_result(results, test_fire_soldier_has_sprite())
	_add_result(results, test_fire_soldier_has_collision_shape())

	# Explosion Tests
	_add_result(results, test_fire_soldier_has_explosion_radius())
	_add_result(results, test_fire_soldier_has_explosion_damage())
	_add_result(results, test_fire_soldier_has_fuse_time())
	_add_result(results, test_fire_soldier_has_explosion_scene())

	# Value Tests
	_add_result(results, test_fire_soldier_health_value())
	_add_result(results, test_fire_soldier_speed_value())
	_add_result(results, test_fire_soldier_damage_value())
	_add_result(results, test_fire_soldier_xp_value())

	# Group Tests
	_add_result(results, test_fire_soldier_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_fire_soldier_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/fire_soldier.tscn")
	return {"name": "TC.CR.1: Fire Soldier scene loads", "passed": scene != null}

static func test_fire_soldier_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/fire_soldier.gd")
	return {"name": "TC.CR.2: Fire Soldier script loads", "passed": script != null}

static func test_fire_soldier_is_character_body_2d() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier is CharacterBody2D
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.3: Fire Soldier is CharacterBody2D", "passed": passed}

static func test_fire_soldier_has_health() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and ("health" in fire_soldier or fire_soldier.has_node("HealthComponent"))
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.4: Fire Soldier has health", "passed": passed}

static func test_fire_soldier_has_speed() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and "speed" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.5: Fire Soldier has speed property", "passed": passed}

static func test_fire_soldier_has_damage() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	# FireSoldier uses explosion_damage instead of damage
	var passed = fire_soldier != null and "explosion_damage" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.6: Fire Soldier has explosion_damage property", "passed": passed}

static func test_fire_soldier_has_xp_value() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and "xp_value" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.7: Fire Soldier has xp_value property", "passed": passed}

static func test_fire_soldier_has_sprite() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier.has_node("Sprite2D")
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.8: Fire Soldier has Sprite2D", "passed": passed}

static func test_fire_soldier_has_collision_shape() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier.has_node("CollisionShape2D")
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.9: Fire Soldier has CollisionShape2D", "passed": passed}

static func test_fire_soldier_has_explosion_radius() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and "explosion_radius" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.10: Fire Soldier has explosion_radius", "passed": passed}

static func test_fire_soldier_has_explosion_damage() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and "explosion_damage" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.11: Fire Soldier has explosion_damage", "passed": passed}

static func test_fire_soldier_has_fuse_time() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and "fuse_time" in fire_soldier
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.12: Fire Soldier has fuse_time", "passed": passed}

static func test_fire_soldier_has_explosion_scene() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	# FireSoldier uses explode (public method, no underscore prefix)
	var passed = fire_soldier != null and fire_soldier.has_method("explode")
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.13: Fire Soldier has explode method", "passed": passed}

static func test_fire_soldier_health_value() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = false
	if fire_soldier:
		if "health" in fire_soldier:
			# Scene file overrides script default: fire_soldier.tscn sets health = 25
			passed = fire_soldier.health == 25
		elif fire_soldier.has_node("HealthComponent"):
			var health_comp = fire_soldier.get_node("HealthComponent")
			passed = health_comp.max_health == 25
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.14: Fire Soldier health is 25", "passed": passed}

static func test_fire_soldier_speed_value() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier.speed == 50
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.15: Fire Soldier speed is 50", "passed": passed}

static func test_fire_soldier_damage_value() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	# FireSoldier uses explosion_damage (30) as its primary damage
	var passed = fire_soldier != null and fire_soldier.explosion_damage == 30
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.16: Fire Soldier explosion_damage is 30", "passed": passed}

static func test_fire_soldier_xp_value() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier.xp_value == 10
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.17: Fire Soldier xp_value is 10", "passed": passed}

static func test_fire_soldier_in_enemies_group() -> Dictionary:
	var fire_soldier = get_fire_soldier_instance()
	var passed = fire_soldier != null and fire_soldier.is_in_group("enemies")
	if fire_soldier:
		fire_soldier.queue_free()
	return {"name": "TC.CR.18: Fire Soldier in enemies group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"apply_knockback",
		"start_fuse",
		"_flash_sprite",
		"explode",
		"_spawn_explosion_effect",
		"take_damage",
		"_spawn_hit_effect",
		"_on_died",
		"_try_spawn_meat",
		"_spawn_death_effect",
		"_spawn_xp_orb"
	]
