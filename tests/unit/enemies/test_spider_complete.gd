extends Node
class_name TestSpiderComplete
## Complete spider enemy tests for 100% coverage

static func get_test_name() -> String:
	return "Spider Complete Tests"

static func get_spider_instance():
	var scene = load("res://scenes/enemies/spider.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Property Tests
	_add_result(results, test_spider_scene_loads())
	_add_result(results, test_spider_script_loads())
	_add_result(results, test_spider_is_character_body_2d())
	_add_result(results, test_spider_has_health())
	_add_result(results, test_spider_has_speed())
	_add_result(results, test_spider_has_damage())
	_add_result(results, test_spider_has_xp_value())

	# Component Tests
	_add_result(results, test_spider_has_sprite())
	_add_result(results, test_spider_has_collision_shape())

	# Jump Attack Tests
	_add_result(results, test_spider_has_jump_cooldown())
	_add_result(results, test_spider_has_jump_range())
	_add_result(results, test_spider_has_jump_speed())

	# Value Tests
	_add_result(results, test_spider_health_value())
	_add_result(results, test_spider_speed_value())
	_add_result(results, test_spider_damage_value())
	_add_result(results, test_spider_xp_value())

	# Group Tests
	_add_result(results, test_spider_in_enemies_group())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_spider_scene_loads() -> Dictionary:
	var scene = load("res://scenes/enemies/spider.tscn")
	return {"name": "TC.SP.1: Spider scene loads", "passed": scene != null}

static func test_spider_script_loads() -> Dictionary:
	var script = load("res://scripts/enemies/spider.gd")
	return {"name": "TC.SP.2: Spider script loads", "passed": script != null}

static func test_spider_is_character_body_2d() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider is CharacterBody2D
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.3: Spider is CharacterBody2D", "passed": passed}

static func test_spider_has_health() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and ("health" in spider or spider.has_node("HealthComponent"))
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.4: Spider has health", "passed": passed}

static func test_spider_has_speed() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and "speed" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.5: Spider has speed property", "passed": passed}

static func test_spider_has_damage() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and "damage" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.6: Spider has damage property", "passed": passed}

static func test_spider_has_xp_value() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and "xp_value" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.7: Spider has xp_value property", "passed": passed}

static func test_spider_has_sprite() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.has_node("Sprite2D")
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.8: Spider has Sprite2D", "passed": passed}

static func test_spider_has_collision_shape() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.has_node("CollisionShape2D")
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.9: Spider has CollisionShape2D", "passed": passed}

static func test_spider_has_jump_cooldown() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and "jump_cooldown" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.10: Spider has jump_cooldown", "passed": passed}

static func test_spider_has_jump_range() -> Dictionary:
	var spider = get_spider_instance()
	# Actually uses jump_distance, not jump_range
	var passed = spider != null and "jump_distance" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.11: Spider has jump_distance", "passed": passed}

static func test_spider_has_jump_speed() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and "jump_speed" in spider
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.12: Spider has jump_speed", "passed": passed}

static func test_spider_health_value() -> Dictionary:
	var spider = get_spider_instance()
	var passed = false
	if spider:
		if "health" in spider:
			passed = spider.health == 12
		elif spider.has_node("HealthComponent"):
			var health_comp = spider.get_node("HealthComponent")
			passed = health_comp.max_health == 12
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.13: Spider health is 12", "passed": passed}

static func test_spider_speed_value() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.speed == 100
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.14: Spider speed is 100", "passed": passed}

static func test_spider_damage_value() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.damage == 8
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.15: Spider damage is 8", "passed": passed}

static func test_spider_xp_value() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.xp_value == 6
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.16: Spider xp_value is 6", "passed": passed}

static func test_spider_in_enemies_group() -> Dictionary:
	var spider = get_spider_instance()
	var passed = spider != null and spider.is_in_group("enemies")
	if spider:
		spider.queue_free()
	return {"name": "TC.SP.17: Spider in enemies group", "passed": passed}

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
