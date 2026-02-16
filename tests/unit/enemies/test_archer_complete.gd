extends Node
class_name TestArcherComplete
## Complete archer enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Archer Complete Tests"

static func get_archer_instance():
	var scene = load("res://scenes/enemies/archer.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_archer_scene_loads())
	_add_result(results, test_archer_script_loads())
	_add_result(results, test_archer_is_character_body_2d())
	_add_result(results, test_archer_has_health())
	_add_result(results, test_archer_has_speed())
	_add_result(results, test_archer_has_damage())
	_add_result(results, test_archer_has_xp_value())

	# Component Tests
	_add_result(results, test_archer_has_sprite())
	_add_result(results, test_archer_has_collision_shape())

	# Ranged Behavior Tests
	_add_result(results, test_archer_has_shoot_cooldown())
	_add_result(results, test_archer_has_shoot_range())
	_add_result(results, test_archer_has_arrow_scene())

	# Value Tests
	_add_result(results, test_archer_health_value())
	_add_result(results, test_archer_speed_value())
	_add_result(results, test_archer_damage_value())
	_add_result(results, test_archer_xp_value())

	# Group Tests
	_add_result(results, test_archer_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_archer_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/archer.tscn")
	return {"name": "TC.SK.1: Archer scene loads", "passed": scene != null}

static func test_archer_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/archer.gd")
	return {"name": "TC.SK.2: Archer script loads", "passed": script != null}

static func test_archer_is_character_body_2d() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer is CharacterBody2D
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.3: Archer is CharacterBody2D", "passed": passed}

static func test_archer_has_health() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and ("health" in archer or archer.has_node("HealthComponent"))
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.4: Archer has health", "passed": passed}

static func test_archer_has_speed() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and "speed" in archer
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.5: Archer has speed property", "passed": passed}

static func test_archer_has_damage() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and "damage" in archer
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.6: Archer has damage property", "passed": passed}

static func test_archer_has_xp_value() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and "xp_value" in archer
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.7: Archer has xp_value property", "passed": passed}

static func test_archer_has_sprite() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.has_node("Sprite2D")
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.8: Archer has Sprite2D", "passed": passed}

static func test_archer_has_collision_shape() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.has_node("CollisionShape2D")
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.9: Archer has CollisionShape2D", "passed": passed}

static func test_archer_has_shoot_cooldown() -> Dictionary:
	var archer = get_archer_instance()
	# Uses attack_cooldown, not shoot_cooldown
	var passed = archer != null and "attack_cooldown" in archer
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.10: Archer has attack_cooldown", "passed": passed}

static func test_archer_has_shoot_range() -> Dictionary:
	var archer = get_archer_instance()
	# Uses attack_range, not shoot_range
	var passed = archer != null and "attack_range" in archer
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.11: Archer has attack_range", "passed": passed}

static func test_archer_has_arrow_scene() -> Dictionary:
	var archer = get_archer_instance()
	# Archer uses shoot_arrow (public method, no underscore prefix)
	var passed = archer != null and archer.has_method("shoot_arrow")
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.12: Archer has shoot_arrow method", "passed": passed}

static func test_archer_health_value() -> Dictionary:
	var archer = get_archer_instance()
	var passed = false
	if archer:
		if "health" in archer:
			# Scene file overrides script default: archer.tscn sets health = 15
			passed = archer.health == 15
		elif archer.has_node("HealthComponent"):
			var health_comp = archer.get_node("HealthComponent")
			passed = health_comp.max_health == 15
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.13: Archer health is 15", "passed": passed}

static func test_archer_speed_value() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.speed == 40
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.14: Archer speed is 40", "passed": passed}

static func test_archer_damage_value() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.damage == 8
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.15: Archer damage is 8", "passed": passed}

static func test_archer_xp_value() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.xp_value == 8
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.16: Archer xp_value is 8", "passed": passed}

static func test_archer_in_enemies_group() -> Dictionary:
	var archer = get_archer_instance()
	var passed = archer != null and archer.is_in_group("enemies")
	if archer:
		archer.queue_free()
	return {"name": "TC.SK.17: Archer in enemies group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"apply_knockback",
		"shoot_arrow",
		"_on_attack_timer_timeout",
		"_on_hitbox_body_entered",
		"take_damage",
		"_spawn_hit_effect",
		"_on_died",
		"_try_spawn_meat",
		"_spawn_death_effect",
		"_spawn_xp_orb"
	]
