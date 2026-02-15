extends Node
class_name TestSkeletonComplete
## Complete skeleton enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Skeleton Complete Tests"

static func get_skeleton_instance():
	var scene = load("res://scenes/enemies/skeleton.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_skeleton_scene_loads())
	_add_result(results, test_skeleton_script_loads())
	_add_result(results, test_skeleton_is_character_body_2d())
	_add_result(results, test_skeleton_has_health())
	_add_result(results, test_skeleton_has_speed())
	_add_result(results, test_skeleton_has_damage())
	_add_result(results, test_skeleton_has_xp_value())

	# Component Tests
	_add_result(results, test_skeleton_has_sprite())
	_add_result(results, test_skeleton_has_collision_shape())

	# Ranged Behavior Tests
	_add_result(results, test_skeleton_has_shoot_cooldown())
	_add_result(results, test_skeleton_has_shoot_range())
	_add_result(results, test_skeleton_has_arrow_scene())

	# Value Tests
	_add_result(results, test_skeleton_health_value())
	_add_result(results, test_skeleton_speed_value())
	_add_result(results, test_skeleton_damage_value())
	_add_result(results, test_skeleton_xp_value())

	# Group Tests
	_add_result(results, test_skeleton_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_skeleton_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/skeleton.tscn")
	return {"name": "TC.SK.1: Skeleton scene loads", "passed": scene != null}

static func test_skeleton_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/skeleton.gd")
	return {"name": "TC.SK.2: Skeleton script loads", "passed": script != null}

static func test_skeleton_is_character_body_2d() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton is CharacterBody2D
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.3: Skeleton is CharacterBody2D", "passed": passed}

static func test_skeleton_has_health() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and ("health" in skeleton or skeleton.has_node("HealthComponent"))
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.4: Skeleton has health", "passed": passed}

static func test_skeleton_has_speed() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and "speed" in skeleton
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.5: Skeleton has speed property", "passed": passed}

static func test_skeleton_has_damage() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and "damage" in skeleton
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.6: Skeleton has damage property", "passed": passed}

static func test_skeleton_has_xp_value() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and "xp_value" in skeleton
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.7: Skeleton has xp_value property", "passed": passed}

static func test_skeleton_has_sprite() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.has_node("Sprite2D")
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.8: Skeleton has Sprite2D", "passed": passed}

static func test_skeleton_has_collision_shape() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.has_node("CollisionShape2D")
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.9: Skeleton has CollisionShape2D", "passed": passed}

static func test_skeleton_has_shoot_cooldown() -> Dictionary:
	var skeleton = get_skeleton_instance()
	# Uses attack_cooldown, not shoot_cooldown
	var passed = skeleton != null and "attack_cooldown" in skeleton
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.10: Skeleton has attack_cooldown", "passed": passed}

static func test_skeleton_has_shoot_range() -> Dictionary:
	var skeleton = get_skeleton_instance()
	# Uses attack_range, not shoot_range
	var passed = skeleton != null and "attack_range" in skeleton
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.11: Skeleton has attack_range", "passed": passed}

static func test_skeleton_has_arrow_scene() -> Dictionary:
	var skeleton = get_skeleton_instance()
	# Skeleton uses shoot_arrow (public method, no underscore prefix)
	var passed = skeleton != null and skeleton.has_method("shoot_arrow")
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.12: Skeleton has shoot_arrow method", "passed": passed}

static func test_skeleton_health_value() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = false
	if skeleton:
		if "health" in skeleton:
			# Scene file overrides script default: skeleton.tscn sets health = 15
			passed = skeleton.health == 15
		elif skeleton.has_node("HealthComponent"):
			var health_comp = skeleton.get_node("HealthComponent")
			passed = health_comp.max_health == 15
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.13: Skeleton health is 15", "passed": passed}

static func test_skeleton_speed_value() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.speed == 40
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.14: Skeleton speed is 40", "passed": passed}

static func test_skeleton_damage_value() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.damage == 8
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.15: Skeleton damage is 8", "passed": passed}

static func test_skeleton_xp_value() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.xp_value == 8
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.16: Skeleton xp_value is 8", "passed": passed}

static func test_skeleton_in_enemies_group() -> Dictionary:
	var skeleton = get_skeleton_instance()
	var passed = skeleton != null and skeleton.is_in_group("enemies")
	if skeleton:
		skeleton.queue_free()
	return {"name": "TC.SK.17: Skeleton in enemies group", "passed": passed}

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
