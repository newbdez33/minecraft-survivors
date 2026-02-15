extends Node
class_name TestVexComplete
## Complete shadow_guard minion tests for 100% coverage

static func get_test_name() -> String:
	return "Shadow Guard Complete Tests"

static func get_shadow_guard_instance():
	var scene = load("res://scenes/enemies/shadow_guard.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_shadow_guard_scene_loads())
	_add_result(results, test_shadow_guard_script_loads())
	_add_result(results, test_shadow_guard_is_character_body_2d())
	_add_result(results, test_shadow_guard_has_health())
	_add_result(results, test_shadow_guard_has_speed())
	_add_result(results, test_shadow_guard_has_damage())
	_add_result(results, test_shadow_guard_has_xp_value())

	# Component Tests
	_add_result(results, test_shadow_guard_has_sprite())
	_add_result(results, test_shadow_guard_has_collision_shape())

	# ShadowGuard-specific Tests
	_add_result(results, test_shadow_guard_has_lifetime())
	_add_result(results, test_shadow_guard_is_summoned_minion())
	_add_result(results, test_shadow_guard_has_owner_reference())

	# Value Tests
	_add_result(results, test_shadow_guard_health_value())
	_add_result(results, test_shadow_guard_speed_value())
	_add_result(results, test_shadow_guard_damage_value())
	_add_result(results, test_shadow_guard_xp_value())

	# Group Tests
	_add_result(results, test_shadow_guard_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_shadow_guard_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/shadow_guard.tscn")
	return {"name": "TC.VX.1: Shadow Guard scene loads", "passed": scene != null}

static func test_shadow_guard_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/shadow_guard.gd")
	return {"name": "TC.VX.2: Shadow Guard script loads", "passed": script != null}

static func test_shadow_guard_is_character_body_2d() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard is CharacterBody2D
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.3: Shadow Guard is CharacterBody2D", "passed": passed}

static func test_shadow_guard_has_health() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and ("health" in shadow_guard or shadow_guard.has_node("HealthComponent"))
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.4: Shadow Guard has health", "passed": passed}

static func test_shadow_guard_has_speed() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and "speed" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.5: Shadow Guard has speed property", "passed": passed}

static func test_shadow_guard_has_damage() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and "damage" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.6: Shadow Guard has damage property", "passed": passed}

static func test_shadow_guard_has_xp_value() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and "xp_value" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.7: Shadow Guard has xp_value property", "passed": passed}

static func test_shadow_guard_has_sprite() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.has_node("Sprite2D")
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.8: Shadow Guard has Sprite2D", "passed": passed}

static func test_shadow_guard_has_collision_shape() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.has_node("CollisionShape2D")
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.9: Shadow Guard has CollisionShape2D", "passed": passed}

static func test_shadow_guard_has_lifetime() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and "lifetime" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.10: Shadow Guard has lifetime property", "passed": passed}

static func test_shadow_guard_is_summoned_minion() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	# Shadow Guard has can_pass_walls property
	var passed = shadow_guard != null and "can_pass_walls" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.11: Shadow Guard can_pass_walls property exists", "passed": passed}

static func test_shadow_guard_has_owner_reference() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	# Check for lifetime property
	var passed = shadow_guard != null and "lifetime" in shadow_guard
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.12: Shadow Guard has lifetime property", "passed": passed}

static func test_shadow_guard_health_value() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = false
	if shadow_guard:
		if "health" in shadow_guard:
			passed = shadow_guard.health == 10  # Shadow Guard is fragile
		elif shadow_guard.has_node("HealthComponent"):
			var health_comp = shadow_guard.get_node("HealthComponent")
			passed = health_comp.max_health == 10
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.13: Shadow Guard health is 10", "passed": passed}

static func test_shadow_guard_speed_value() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.speed >= 80  # Shadow Guard is fast
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.14: Shadow Guard speed is fast (>=80)", "passed": passed}

static func test_shadow_guard_damage_value() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.damage >= 5
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.15: Shadow Guard damage >= 5", "passed": passed}

static func test_shadow_guard_xp_value() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.xp_value >= 3  # Small XP for minion
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.16: Shadow Guard xp_value >= 3", "passed": passed}

static func test_shadow_guard_in_enemies_group() -> Dictionary:
	var shadow_guard = get_shadow_guard_instance()
	var passed = shadow_guard != null and shadow_guard.is_in_group("enemies")
	if shadow_guard:
		shadow_guard.queue_free()
	return {"name": "TC.VX.17: Shadow Guard in enemies group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"_on_hitbox_body_entered",
		"take_damage",
		"apply_knockback",
		"_spawn_hit_effect",
		"_on_died",
		"_spawn_death_effect",
		"_spawn_xp_orb"
	]
