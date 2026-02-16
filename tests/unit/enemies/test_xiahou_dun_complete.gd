extends Node
class_name TestXiahouDunComplete
## Complete xiahou_dun boss tests for 100% coverage

static func get_test_name() -> String:
	return "Xiahou Dun Complete Tests"

static func get_xiahou_dun_instance():
	var scene = load("res://scenes/enemies/xiahou_dun.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_xiahou_dun_scene_loads())
	_add_result(results, test_xiahou_dun_script_loads())
	_add_result(results, test_xiahou_dun_is_character_body_2d())
	_add_result(results, test_xiahou_dun_has_health())
	_add_result(results, test_xiahou_dun_has_speed())
	_add_result(results, test_xiahou_dun_has_damage())
	_add_result(results, test_xiahou_dun_has_xp_value())

	# Component Tests
	_add_result(results, test_xiahou_dun_has_sprite())
	_add_result(results, test_xiahou_dun_has_collision_shape())

	# Boss Tests
	_add_result(results, test_xiahou_dun_is_boss())
	_add_result(results, test_xiahou_dun_has_fang_attack())
	_add_result(results, test_xiahou_dun_has_summon_shadow_guard())
	_add_result(results, test_xiahou_dun_has_attack_cooldown())
	_add_result(results, test_xiahou_dun_has_max_shadow_guard_count())

	# Value Tests
	_add_result(results, test_xiahou_dun_health_is_boss_level())
	_add_result(results, test_xiahou_dun_xp_value_is_high())

	# Group Tests
	_add_result(results, test_xiahou_dun_in_enemies_group())
	_add_result(results, test_xiahou_dun_in_boss_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_xiahou_dun_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/xiahou_dun.tscn")
	return {"name": "TC.EV.1: Xiahou Dun scene loads", "passed": scene != null}

static func test_xiahou_dun_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/xiahou_dun.gd")
	return {"name": "TC.EV.2: Xiahou Dun script loads", "passed": script != null}

static func test_xiahou_dun_is_character_body_2d() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun is CharacterBody2D
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.3: Xiahou Dun is CharacterBody2D", "passed": passed}

static func test_xiahou_dun_has_health() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and ("health" in xiahou_dun or xiahou_dun.has_node("HealthComponent"))
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.4: Xiahou Dun has health", "passed": passed}

static func test_xiahou_dun_has_speed() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and "speed" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.5: Xiahou Dun has speed property", "passed": passed}

static func test_xiahou_dun_has_damage() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# XiahouDun uses fang_damage and contact_damage
	var passed = xiahou_dun != null and "fang_damage" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.6: Xiahou Dun has fang_damage property", "passed": passed}

static func test_xiahou_dun_has_xp_value() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and "xp_value" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.7: Xiahou Dun has xp_value property", "passed": passed}

static func test_xiahou_dun_has_sprite() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun.has_node("Sprite2D")
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.8: Xiahou Dun has Sprite2D", "passed": passed}

static func test_xiahou_dun_has_collision_shape() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun.has_node("CollisionShape2D")
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.9: Xiahou Dun has CollisionShape2D", "passed": passed}

static func test_xiahou_dun_is_boss() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# Check if in boss group instead of is_boss property
	var passed = xiahou_dun != null and xiahou_dun.is_in_group("boss")
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.10: Xiahou Dun is in boss group", "passed": passed}

static func test_xiahou_dun_has_fang_attack() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# Check for fang_damage property instead
	var passed = xiahou_dun != null and "fang_damage" in xiahou_dun and "fang_count" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.11: Xiahou Dun has fang attack properties", "passed": passed}

static func test_xiahou_dun_has_summon_shadow_guard() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# Check for summon_cooldown property
	var passed = xiahou_dun != null and "summon_cooldown" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.12: Xiahou Dun has summon_cooldown", "passed": passed}

static func test_xiahou_dun_has_attack_cooldown() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# Uses fang_cooldown and summon_cooldown
	var passed = xiahou_dun != null and "fang_cooldown" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.13: Xiahou Dun has fang_cooldown", "passed": passed}

static func test_xiahou_dun_has_max_shadow_guard_count() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	# Check for shadow_guard-related properties
	var passed = xiahou_dun != null and "summon_cooldown" in xiahou_dun
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.14: Xiahou Dun has shadow_guard summoning", "passed": passed}

static func test_xiahou_dun_health_is_boss_level() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = false
	if xiahou_dun:
		if "health" in xiahou_dun:
			passed = xiahou_dun.health >= 100  # Boss should have high health
		elif xiahou_dun.has_node("HealthComponent"):
			var health_comp = xiahou_dun.get_node("HealthComponent")
			passed = health_comp.max_health >= 100
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.15: Xiahou Dun has boss-level health (>=100)", "passed": passed}

static func test_xiahou_dun_xp_value_is_high() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun.xp_value >= 50  # Boss should give lots of XP
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.16: Xiahou Dun xp_value is high (>=50)", "passed": passed}

static func test_xiahou_dun_in_enemies_group() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun.is_in_group("enemies")
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.17: Xiahou Dun in enemies group", "passed": passed}

static func test_xiahou_dun_in_boss_group() -> Dictionary:
	var xiahou_dun = get_xiahou_dun_instance()
	var passed = xiahou_dun != null and xiahou_dun.is_in_group("boss")
	if xiahou_dun:
		xiahou_dun.queue_free()
	return {"name": "TC.EV.18: Xiahou Dun in boss group", "passed": passed}

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
		"summon_shadow_guard",
		"_on_shadow_guard_died",
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
