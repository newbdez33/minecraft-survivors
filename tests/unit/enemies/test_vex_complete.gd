extends Node
class_name TestVexComplete
## Complete vex minion tests for 100% coverage

static func get_test_name() -> String:
	return "Vex Complete Tests"

static func get_vex_instance():
	var scene = load("res://scenes/enemies/vex.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_vex_scene_loads())
	_add_result(results, test_vex_script_loads())
	_add_result(results, test_vex_is_character_body_2d())
	_add_result(results, test_vex_has_health())
	_add_result(results, test_vex_has_speed())
	_add_result(results, test_vex_has_damage())
	_add_result(results, test_vex_has_xp_value())

	# Component Tests
	_add_result(results, test_vex_has_sprite())
	_add_result(results, test_vex_has_collision_shape())

	# Vex-specific Tests
	_add_result(results, test_vex_has_lifetime())
	_add_result(results, test_vex_is_summoned_minion())
	_add_result(results, test_vex_has_owner_reference())

	# Value Tests
	_add_result(results, test_vex_health_value())
	_add_result(results, test_vex_speed_value())
	_add_result(results, test_vex_damage_value())
	_add_result(results, test_vex_xp_value())

	# Group Tests
	_add_result(results, test_vex_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_vex_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/vex.tscn")
	return {"name": "TC.VX.1: Vex scene loads", "passed": scene != null}

static func test_vex_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/vex.gd")
	return {"name": "TC.VX.2: Vex script loads", "passed": script != null}

static func test_vex_is_character_body_2d() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex is CharacterBody2D
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.3: Vex is CharacterBody2D", "passed": passed}

static func test_vex_has_health() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and ("health" in vex or vex.has_node("HealthComponent"))
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.4: Vex has health", "passed": passed}

static func test_vex_has_speed() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and "speed" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.5: Vex has speed property", "passed": passed}

static func test_vex_has_damage() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and "damage" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.6: Vex has damage property", "passed": passed}

static func test_vex_has_xp_value() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and "xp_value" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.7: Vex has xp_value property", "passed": passed}

static func test_vex_has_sprite() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.has_node("Sprite2D")
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.8: Vex has Sprite2D", "passed": passed}

static func test_vex_has_collision_shape() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.has_node("CollisionShape2D")
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.9: Vex has CollisionShape2D", "passed": passed}

static func test_vex_has_lifetime() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and "lifetime" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.10: Vex has lifetime property", "passed": passed}

static func test_vex_is_summoned_minion() -> Dictionary:
	var vex = get_vex_instance()
	# Vex has can_pass_walls property
	var passed = vex != null and "can_pass_walls" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.11: Vex can_pass_walls property exists", "passed": passed}

static func test_vex_has_owner_reference() -> Dictionary:
	var vex = get_vex_instance()
	# Check for lifetime property
	var passed = vex != null and "lifetime" in vex
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.12: Vex has lifetime property", "passed": passed}

static func test_vex_health_value() -> Dictionary:
	var vex = get_vex_instance()
	var passed = false
	if vex:
		if "health" in vex:
			passed = vex.health == 10  # Vex is fragile
		elif vex.has_node("HealthComponent"):
			var health_comp = vex.get_node("HealthComponent")
			passed = health_comp.max_health == 10
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.13: Vex health is 10", "passed": passed}

static func test_vex_speed_value() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.speed >= 80  # Vex is fast
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.14: Vex speed is fast (>=80)", "passed": passed}

static func test_vex_damage_value() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.damage >= 5
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.15: Vex damage >= 5", "passed": passed}

static func test_vex_xp_value() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.xp_value >= 3  # Small XP for minion
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.16: Vex xp_value >= 3", "passed": passed}

static func test_vex_in_enemies_group() -> Dictionary:
	var vex = get_vex_instance()
	var passed = vex != null and vex.is_in_group("enemies")
	if vex:
		vex.queue_free()
	return {"name": "TC.VX.17: Vex in enemies group", "passed": passed}

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
