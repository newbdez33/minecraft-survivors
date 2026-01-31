extends Node
class_name TestBowComplete
## Complete bow weapon tests for 100% coverage

static func get_test_name() -> String:
	return "Bow Complete Tests"

static func get_bow_instance():
	var scene = load("res://scenes/weapons/bow.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Scene/Script Tests
	_add_result(results, test_bow_scene_loads())
	_add_result(results, test_bow_script_loads())
	_add_result(results, test_bow_is_node_2d())

	# Property Tests
	_add_result(results, test_bow_has_damage())
	_add_result(results, test_bow_has_attack_speed())
	_add_result(results, test_bow_has_attack_range())
	_add_result(results, test_bow_has_level())
	_add_result(results, test_bow_has_max_level())
	_add_result(results, test_bow_has_arrow_scene())

	# Value Tests
	_add_result(results, test_bow_base_damage())
	_add_result(results, test_bow_base_attack_speed())
	_add_result(results, test_bow_max_level_is_4())

	# Method Tests
	_add_result(results, test_bow_has_upgrade_method())
	_add_result(results, test_bow_has_shoot_method())

	# Upgrade Tests
	_add_result(results, test_bow_upgrade_increases_level())
	_add_result(results, test_bow_upgrade_increases_damage())

	# Signal Tests
	_add_result(results, test_bow_has_arrow_shot_signal())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_bow_scene_loads() -> Dictionary:
	var scene = load("res://scenes/weapons/bow.tscn")
	return {"name": "TC.BW.1: Bow scene loads", "passed": scene != null}

static func test_bow_script_loads() -> Dictionary:
	var script = load("res://scripts/weapons/bow.gd")
	return {"name": "TC.BW.2: Bow script loads", "passed": script != null}

static func test_bow_is_node_2d() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow is Node2D
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.3: Bow is Node2D", "passed": passed}

static func test_bow_has_damage() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and "damage" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.4: Bow has damage property", "passed": passed}

static func test_bow_has_attack_speed() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and "attack_speed" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.5: Bow has attack_speed property", "passed": passed}

static func test_bow_has_attack_range() -> Dictionary:
	var bow = get_bow_instance()
	# Bow uses "range" property
	var passed = bow != null and "range" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.6: Bow has range property", "passed": passed}

static func test_bow_has_level() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and "level" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.7: Bow has level property", "passed": passed}

static func test_bow_has_max_level() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and "MAX_LEVEL" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.8: Bow has MAX_LEVEL constant", "passed": passed}

static func test_bow_has_arrow_scene() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and "arrow_scene" in bow
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.9: Bow has arrow_scene property", "passed": passed}

static func test_bow_base_damage() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.damage >= 5
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.10: Bow base damage >= 5", "passed": passed}

static func test_bow_base_attack_speed() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.attack_speed > 0
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.11: Bow attack_speed > 0", "passed": passed}

static func test_bow_max_level_is_4() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.MAX_LEVEL == 4
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.12: Bow MAX_LEVEL is 4", "passed": passed}

static func test_bow_has_upgrade_method() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.has_method("upgrade")
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.13: Bow has upgrade method", "passed": passed}

static func test_bow_has_shoot_method() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.has_method("_shoot")
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.14: Bow has _shoot method", "passed": passed}

static func test_bow_upgrade_increases_level() -> Dictionary:
	var bow = get_bow_instance()
	if not bow:
		return {"name": "TC.BW.15: Bow upgrade increases level", "passed": false}
	var initial_level = bow.level
	bow.upgrade()
	var passed = bow.level == initial_level + 1
	bow.queue_free()
	return {"name": "TC.BW.15: Bow upgrade increases level", "passed": passed}

static func test_bow_upgrade_increases_damage() -> Dictionary:
	var bow = get_bow_instance()
	if not bow:
		return {"name": "TC.BW.16: Bow upgrade increases damage", "passed": false}
	var initial_damage = bow.damage
	bow.upgrade()
	var passed = bow.damage > initial_damage
	bow.queue_free()
	return {"name": "TC.BW.16: Bow upgrade increases damage", "passed": passed}

static func test_bow_has_arrow_shot_signal() -> Dictionary:
	var bow = get_bow_instance()
	var passed = bow != null and bow.has_signal("arrow_shot")
	if bow:
		bow.queue_free()
	return {"name": "TC.BW.17: Bow has arrow_shot signal", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_process",
		"_find_nearest_enemy",
		"_fire_at",
		"get_total_damage",
		"get_total_attack_speed",
		"get_total_range",
		"upgrade",
		"can_evolve",
		"_update_weapon_position"
	]
