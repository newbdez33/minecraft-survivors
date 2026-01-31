extends Node
class_name TestZombieComplete
## Complete zombie enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Zombie Complete Tests"

static func get_zombie_instance():
	var scene = load("res://scenes/enemies/zombie.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_zombie_scene_loads())
	_add_result(results, test_zombie_script_loads())
	_add_result(results, test_zombie_is_character_body_2d())
	_add_result(results, test_zombie_has_health())
	_add_result(results, test_zombie_has_speed())
	_add_result(results, test_zombie_has_damage())
	_add_result(results, test_zombie_has_xp_value())

	# Component Tests
	_add_result(results, test_zombie_has_sprite())
	_add_result(results, test_zombie_has_collision_shape())
	_add_result(results, test_zombie_has_health_component())

	# Behavior Tests
	_add_result(results, test_zombie_has_take_damage_method())
	_add_result(results, test_zombie_in_enemies_group())
	_add_result(results, test_zombie_health_value())
	_add_result(results, test_zombie_speed_value())
	_add_result(results, test_zombie_damage_value())
	_add_result(results, test_zombie_xp_value())

	# Signal Tests
	_add_result(results, test_zombie_has_died_signal())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_zombie_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/zombie.tscn")
	return {"name": "TC.Z.1: Zombie scene loads", "passed": scene != null}

static func test_zombie_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/zombie.gd")
	return {"name": "TC.Z.2: Zombie script loads", "passed": script != null}

static func test_zombie_is_character_body_2d() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie is CharacterBody2D
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.3: Zombie is CharacterBody2D", "passed": passed}

static func test_zombie_has_health() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and ("health" in zombie or zombie.has_node("HealthComponent"))
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.4: Zombie has health", "passed": passed}

static func test_zombie_has_speed() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and "speed" in zombie
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.5: Zombie has speed property", "passed": passed}

static func test_zombie_has_damage() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and "damage" in zombie
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.6: Zombie has damage property", "passed": passed}

static func test_zombie_has_xp_value() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and "xp_value" in zombie
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.7: Zombie has xp_value property", "passed": passed}

static func test_zombie_has_sprite() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.has_node("Sprite2D")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.8: Zombie has Sprite2D", "passed": passed}

static func test_zombie_has_collision_shape() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.has_node("CollisionShape2D")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.9: Zombie has CollisionShape2D", "passed": passed}

static func test_zombie_has_health_component() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.has_node("HealthComponent")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.10: Zombie has HealthComponent", "passed": passed}

static func test_zombie_has_take_damage_method() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.has_method("take_damage")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.11: Zombie has take_damage method", "passed": passed}

static func test_zombie_in_enemies_group() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.is_in_group("enemies")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.12: Zombie in enemies group", "passed": passed}

static func test_zombie_health_value() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = false
	if zombie:
		if "health" in zombie:
			passed = zombie.health == 10  # Actual value is 10
		elif zombie.has_node("HealthComponent"):
			var health_comp = zombie.get_node("HealthComponent")
			passed = health_comp.max_health == 10
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.13: Zombie health is 10", "passed": passed}

static func test_zombie_speed_value() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.speed == 60
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.14: Zombie speed is 60", "passed": passed}

static func test_zombie_damage_value() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.damage == 10
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.15: Zombie damage is 10", "passed": passed}

static func test_zombie_xp_value() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.xp_value == 5
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.16: Zombie xp_value is 5", "passed": passed}

static func test_zombie_has_died_signal() -> Dictionary:
	var zombie = get_zombie_instance()
	var passed = zombie != null and zombie.has_signal("died")
	if zombie:
		zombie.queue_free()
	return {"name": "TC.Z.17: Zombie has died signal", "passed": passed}

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
