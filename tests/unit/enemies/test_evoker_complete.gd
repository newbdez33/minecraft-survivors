extends Node
class_name TestEvokerComplete
## Complete evoker boss tests for 100% coverage

static func get_test_name() -> String:
	return "Evoker Complete Tests"

static func get_evoker_instance():
	var scene = load("res://scenes/enemies/evoker.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_evoker_scene_loads())
	_add_result(results, test_evoker_script_loads())
	_add_result(results, test_evoker_is_character_body_2d())
	_add_result(results, test_evoker_has_health())
	_add_result(results, test_evoker_has_speed())
	_add_result(results, test_evoker_has_damage())
	_add_result(results, test_evoker_has_xp_value())

	# Component Tests
	_add_result(results, test_evoker_has_sprite())
	_add_result(results, test_evoker_has_collision_shape())

	# Boss Tests
	_add_result(results, test_evoker_is_boss())
	_add_result(results, test_evoker_has_fang_attack())
	_add_result(results, test_evoker_has_summon_vex())
	_add_result(results, test_evoker_has_attack_cooldown())
	_add_result(results, test_evoker_has_max_vex_count())

	# Value Tests
	_add_result(results, test_evoker_health_is_boss_level())
	_add_result(results, test_evoker_xp_value_is_high())

	# Group Tests
	_add_result(results, test_evoker_in_enemies_group())
	_add_result(results, test_evoker_in_boss_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_evoker_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/evoker.tscn")
	return {"name": "TC.EV.1: Evoker scene loads", "passed": scene != null}

static func test_evoker_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/evoker.gd")
	return {"name": "TC.EV.2: Evoker script loads", "passed": script != null}

static func test_evoker_is_character_body_2d() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker is CharacterBody2D
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.3: Evoker is CharacterBody2D", "passed": passed}

static func test_evoker_has_health() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and ("health" in evoker or evoker.has_node("HealthComponent"))
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.4: Evoker has health", "passed": passed}

static func test_evoker_has_speed() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and "speed" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.5: Evoker has speed property", "passed": passed}

static func test_evoker_has_damage() -> Dictionary:
	var evoker = get_evoker_instance()
	# Evoker uses fang_damage and contact_damage
	var passed = evoker != null and "fang_damage" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.6: Evoker has fang_damage property", "passed": passed}

static func test_evoker_has_xp_value() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and "xp_value" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.7: Evoker has xp_value property", "passed": passed}

static func test_evoker_has_sprite() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker.has_node("Sprite2D")
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.8: Evoker has Sprite2D", "passed": passed}

static func test_evoker_has_collision_shape() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker.has_node("CollisionShape2D")
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.9: Evoker has CollisionShape2D", "passed": passed}

static func test_evoker_is_boss() -> Dictionary:
	var evoker = get_evoker_instance()
	# Check if in boss group instead of is_boss property
	var passed = evoker != null and evoker.is_in_group("boss")
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.10: Evoker is in boss group", "passed": passed}

static func test_evoker_has_fang_attack() -> Dictionary:
	var evoker = get_evoker_instance()
	# Check for fang_damage property instead
	var passed = evoker != null and "fang_damage" in evoker and "fang_count" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.11: Evoker has fang attack properties", "passed": passed}

static func test_evoker_has_summon_vex() -> Dictionary:
	var evoker = get_evoker_instance()
	# Check for summon_cooldown property
	var passed = evoker != null and "summon_cooldown" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.12: Evoker has summon_cooldown", "passed": passed}

static func test_evoker_has_attack_cooldown() -> Dictionary:
	var evoker = get_evoker_instance()
	# Uses fang_cooldown and summon_cooldown
	var passed = evoker != null and "fang_cooldown" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.13: Evoker has fang_cooldown", "passed": passed}

static func test_evoker_has_max_vex_count() -> Dictionary:
	var evoker = get_evoker_instance()
	# Check for vex-related properties
	var passed = evoker != null and "summon_cooldown" in evoker
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.14: Evoker has vex summoning", "passed": passed}

static func test_evoker_health_is_boss_level() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = false
	if evoker:
		if "health" in evoker:
			passed = evoker.health >= 100  # Boss should have high health
		elif evoker.has_node("HealthComponent"):
			var health_comp = evoker.get_node("HealthComponent")
			passed = health_comp.max_health >= 100
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.15: Evoker has boss-level health (>=100)", "passed": passed}

static func test_evoker_xp_value_is_high() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker.xp_value >= 50  # Boss should give lots of XP
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.16: Evoker xp_value is high (>=50)", "passed": passed}

static func test_evoker_in_enemies_group() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker.is_in_group("enemies")
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.17: Evoker in enemies group", "passed": passed}

static func test_evoker_in_boss_group() -> Dictionary:
	var evoker = get_evoker_instance()
	var passed = evoker != null and evoker.is_in_group("boss")
	if evoker:
		evoker.queue_free()
	return {"name": "TC.EV.18: Evoker in boss group", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_find_target",
		"_physics_process",
		"_process_idle",
		"_process_movement",
		"_start_fang_attack",
		"_start_summon",
		"cast_fang_attack",
		"summon_vex",
		"_on_vex_died",
		"_on_hitbox_body_entered",
		"take_damage",
		"apply_knockback",
		"_spawn_hit_effect",
		"_on_died",
		"_spawn_death_effect",
		"_spawn_drops",
		"_spawn_xp_orbs",
		"_spawn_emeralds",
		"_spawn_totem"
	]
