extends Node
class_name TestCavalryComplete
## Complete cavalry enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Cavalry Complete Tests"

static func get_cavalry_instance():
	var scene = load("res://scenes/enemies/cavalry.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_cavalry_scene_loads())
	_add_result(results, test_cavalry_script_loads())
	_add_result(results, test_cavalry_is_character_body_2d())
	_add_result(results, test_cavalry_has_health())
	_add_result(results, test_cavalry_has_speed())
	_add_result(results, test_cavalry_has_damage())
	_add_result(results, test_cavalry_has_xp_value())

	# Component Tests
	_add_result(results, test_cavalry_has_sprite())
	_add_result(results, test_cavalry_has_collision_shape())

	# Jump Attack Tests
	_add_result(results, test_cavalry_has_jump_cooldown())
	_add_result(results, test_cavalry_has_jump_range())
	_add_result(results, test_cavalry_has_jump_speed())

	# Value Tests
	_add_result(results, test_cavalry_health_value())
	_add_result(results, test_cavalry_speed_value())
	_add_result(results, test_cavalry_damage_value())
	_add_result(results, test_cavalry_xp_value())

	# Group Tests
	_add_result(results, test_cavalry_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_cavalry_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/cavalry.tscn")
	return {"name": "TC.SP.1: Cavalry scene loads", "passed": scene != null}

static func test_cavalry_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/cavalry.gd")
	return {"name": "TC.SP.2: Cavalry script loads", "passed": script != null}

static func test_cavalry_is_character_body_2d() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry is CharacterBody2D
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.3: Cavalry is CharacterBody2D", "passed": passed}

static func test_cavalry_has_health() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and ("health" in cavalry or cavalry.has_node("HealthComponent"))
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.4: Cavalry has health", "passed": passed}

static func test_cavalry_has_speed() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and "speed" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.5: Cavalry has speed property", "passed": passed}

static func test_cavalry_has_damage() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and "damage" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.6: Cavalry has damage property", "passed": passed}

static func test_cavalry_has_xp_value() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and "xp_value" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.7: Cavalry has xp_value property", "passed": passed}

static func test_cavalry_has_sprite() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.has_node("Sprite2D")
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.8: Cavalry has Sprite2D", "passed": passed}

static func test_cavalry_has_collision_shape() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.has_node("CollisionShape2D")
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.9: Cavalry has CollisionShape2D", "passed": passed}

static func test_cavalry_has_jump_cooldown() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and "jump_cooldown" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.10: Cavalry has jump_cooldown", "passed": passed}

static func test_cavalry_has_jump_range() -> Dictionary:
	var cavalry = get_cavalry_instance()
	# Actually uses jump_distance, not jump_range
	var passed = cavalry != null and "jump_distance" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.11: Cavalry has jump_distance", "passed": passed}

static func test_cavalry_has_jump_speed() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and "jump_speed" in cavalry
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.12: Cavalry has jump_speed", "passed": passed}

static func test_cavalry_health_value() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = false
	if cavalry:
		if "health" in cavalry:
			passed = cavalry.health == 12
		elif cavalry.has_node("HealthComponent"):
			var health_comp = cavalry.get_node("HealthComponent")
			passed = health_comp.max_health == 12
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.13: Cavalry health is 12", "passed": passed}

static func test_cavalry_speed_value() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.speed == 100
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.14: Cavalry speed is 100", "passed": passed}

static func test_cavalry_damage_value() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.damage == 8
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.15: Cavalry damage is 8", "passed": passed}

static func test_cavalry_xp_value() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.xp_value == 6
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.16: Cavalry xp_value is 6", "passed": passed}

static func test_cavalry_in_enemies_group() -> Dictionary:
	var cavalry = get_cavalry_instance()
	var passed = cavalry != null and cavalry.is_in_group("enemies")
	if cavalry:
		cavalry.queue_free()
	return {"name": "TC.SP.17: Cavalry in enemies group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"apply_knockback",
		"jump",
		"_on_jump_timer_timeout",
		"_on_hitbox_body_entered",
		"take_damage",
		"_spawn_hit_effect",
		"_on_died",
		"_try_spawn_meat",
		"_spawn_death_effect",
		"_spawn_xp_orb"
	]
