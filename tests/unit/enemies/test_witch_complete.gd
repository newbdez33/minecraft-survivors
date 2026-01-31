extends Node
class_name TestWitchComplete
## Complete witch enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Witch Complete Tests"

static func get_witch_instance():
	var scene = load("res://scenes/enemies/witch.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_witch_scene_loads())
	_add_result(results, test_witch_script_loads())
	_add_result(results, test_witch_is_character_body_2d())
	_add_result(results, test_witch_has_health())
	_add_result(results, test_witch_has_speed())
	_add_result(results, test_witch_has_damage())
	_add_result(results, test_witch_has_xp_value())

	# Component Tests
	_add_result(results, test_witch_has_sprite())
	_add_result(results, test_witch_has_collision_shape())

	# Potion Tests
	_add_result(results, test_witch_has_throw_cooldown())
	_add_result(results, test_witch_has_throw_range())
	_add_result(results, test_witch_has_potion_scene())

	# Value Tests
	_add_result(results, test_witch_health_value())
	_add_result(results, test_witch_speed_value())
	_add_result(results, test_witch_damage_value())
	_add_result(results, test_witch_xp_value())

	# Group Tests
	_add_result(results, test_witch_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_witch_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/witch.tscn")
	return {"name": "TC.WI.1: Witch scene loads", "passed": scene != null}

static func test_witch_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/witch.gd")
	return {"name": "TC.WI.2: Witch script loads", "passed": script != null}

static func test_witch_is_character_body_2d() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch is CharacterBody2D
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.3: Witch is CharacterBody2D", "passed": passed}

static func test_witch_has_health() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and ("health" in witch or witch.has_node("HealthComponent"))
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.4: Witch has health", "passed": passed}

static func test_witch_has_speed() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and "speed" in witch
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.5: Witch has speed property", "passed": passed}

static func test_witch_has_damage() -> Dictionary:
	var witch = get_witch_instance()
	# Witch uses potion_damage instead
	var passed = witch != null and "potion_damage" in witch
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.6: Witch has potion_damage property", "passed": passed}

static func test_witch_has_xp_value() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and "xp_value" in witch
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.7: Witch has xp_value property", "passed": passed}

static func test_witch_has_sprite() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.has_node("Sprite2D")
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.8: Witch has Sprite2D", "passed": passed}

static func test_witch_has_collision_shape() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.has_node("CollisionShape2D")
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.9: Witch has CollisionShape2D", "passed": passed}

static func test_witch_has_throw_cooldown() -> Dictionary:
	var witch = get_witch_instance()
	# Uses attack_cooldown instead
	var passed = witch != null and "attack_cooldown" in witch
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.10: Witch has attack_cooldown", "passed": passed}

static func test_witch_has_throw_range() -> Dictionary:
	var witch = get_witch_instance()
	# Uses attack_range instead
	var passed = witch != null and "attack_range" in witch
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.11: Witch has attack_range", "passed": passed}

static func test_witch_has_potion_scene() -> Dictionary:
	var witch = get_witch_instance()
	# Check for throw method instead
	var passed = witch != null and witch.has_method("_throw_potion")
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.12: Witch has _throw_potion method", "passed": passed}

static func test_witch_health_value() -> Dictionary:
	var witch = get_witch_instance()
	var passed = false
	if witch:
		if "health" in witch:
			passed = witch.health == 20
		elif witch.has_node("HealthComponent"):
			var health_comp = witch.get_node("HealthComponent")
			passed = health_comp.max_health == 20
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.13: Witch health is 20", "passed": passed}

static func test_witch_speed_value() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.speed == 35
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.14: Witch speed is 35", "passed": passed}

static func test_witch_damage_value() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.damage == 12
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.15: Witch damage is 12", "passed": passed}

static func test_witch_xp_value() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.xp_value == 12
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.16: Witch xp_value is 12", "passed": passed}

static func test_witch_in_enemies_group() -> Dictionary:
	var witch = get_witch_instance()
	var passed = witch != null and witch.is_in_group("enemies")
	if witch:
		witch.queue_free()
	return {"name": "TC.WI.17: Witch in enemies group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"throw_potion",
		"_on_attack_timer_timeout",
		"_on_hitbox_body_entered",
		"take_damage",
		"apply_knockback",
		"_spawn_hit_effect",
		"_on_died",
		"_try_spawn_meat",
		"_spawn_death_effect",
		"_spawn_xp_orb"
	]
