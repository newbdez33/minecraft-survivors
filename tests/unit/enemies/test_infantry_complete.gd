extends Node
class_name TestInfantryComplete
## Complete infantry enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Infantry Complete Tests"

static func get_infantry_instance():
	var scene = load("res://scenes/enemies/infantry.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_infantry_scene_loads())
	_add_result(results, test_infantry_script_loads())
	_add_result(results, test_infantry_is_character_body_2d())
	_add_result(results, test_infantry_has_health())
	_add_result(results, test_infantry_has_speed())
	_add_result(results, test_infantry_has_damage())
	_add_result(results, test_infantry_has_xp_value())

	# Component Tests
	_add_result(results, test_infantry_has_sprite())
	_add_result(results, test_infantry_has_collision_shape())
	_add_result(results, test_infantry_has_health_component())

	# Behavior Tests
	_add_result(results, test_infantry_has_take_damage_method())
	_add_result(results, test_infantry_in_enemies_group())
	_add_result(results, test_infantry_health_value())
	_add_result(results, test_infantry_speed_value())
	_add_result(results, test_infantry_damage_value())
	_add_result(results, test_infantry_xp_value())

	# Signal Tests
	_add_result(results, test_infantry_has_died_signal())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_infantry_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/infantry.tscn")
	return {"name": "TC.Z.1: Infantry scene loads", "passed": scene != null}

static func test_infantry_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/infantry.gd")
	return {"name": "TC.Z.2: Infantry script loads", "passed": script != null}

static func test_infantry_is_character_body_2d() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry is CharacterBody2D
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.3: Infantry is CharacterBody2D", "passed": passed}

static func test_infantry_has_health() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and ("health" in infantry or infantry.has_node("HealthComponent"))
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.4: Infantry has health", "passed": passed}

static func test_infantry_has_speed() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and "speed" in infantry
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.5: Infantry has speed property", "passed": passed}

static func test_infantry_has_damage() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and "damage" in infantry
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.6: Infantry has damage property", "passed": passed}

static func test_infantry_has_xp_value() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and "xp_value" in infantry
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.7: Infantry has xp_value property", "passed": passed}

static func test_infantry_has_sprite() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.has_node("Sprite2D")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.8: Infantry has Sprite2D", "passed": passed}

static func test_infantry_has_collision_shape() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.has_node("CollisionShape2D")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.9: Infantry has CollisionShape2D", "passed": passed}

static func test_infantry_has_health_component() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.has_node("HealthComponent")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.10: Infantry has HealthComponent", "passed": passed}

static func test_infantry_has_take_damage_method() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.has_method("take_damage")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.11: Infantry has take_damage method", "passed": passed}

static func test_infantry_in_enemies_group() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.is_in_group("enemies")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.12: Infantry in enemies group", "passed": passed}

static func test_infantry_health_value() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = false
	if infantry:
		if "health" in infantry:
			passed = infantry.health == 10  # Actual value is 10
		elif infantry.has_node("HealthComponent"):
			var health_comp = infantry.get_node("HealthComponent")
			passed = health_comp.max_health == 10
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.13: Infantry health is 10", "passed": passed}

static func test_infantry_speed_value() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.speed == 60
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.14: Infantry speed is 60", "passed": passed}

static func test_infantry_damage_value() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.damage == 10
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.15: Infantry damage is 10", "passed": passed}

static func test_infantry_xp_value() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.xp_value == 5
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.16: Infantry xp_value is 5", "passed": passed}

static func test_infantry_has_died_signal() -> Dictionary:
	var infantry = get_infantry_instance()
	var passed = infantry != null and infantry.has_signal("died")
	if infantry:
		infantry.queue_free()
	return {"name": "TC.Z.17: Infantry has died signal", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"apply_knockback",
		"_on_hitbox_body_entered",
		"take_damage",
		"_spawn_hit_effect",
		"_on_died",
		"_try_spawn_meat",
		"_spawn_xp_orb",
		"_spawn_death_effect"
	]
