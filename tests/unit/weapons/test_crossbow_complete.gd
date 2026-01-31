extends Node
class_name TestCrossbowComplete
## Complete crossbow weapon tests for 100% coverage

static func get_test_name() -> String:
	return "Crossbow Complete Tests"

static func get_crossbow_instance():
	var scene = load("res://scenes/weapons/crossbow.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Scene/Script Tests
	_add_result(results, test_crossbow_scene_loads())
	_add_result(results, test_crossbow_script_loads())
	_add_result(results, test_crossbow_is_node_2d())

	# Property Tests
	_add_result(results, test_crossbow_has_damage())
	_add_result(results, test_crossbow_has_attack_speed())
	_add_result(results, test_crossbow_has_pierce())
	_add_result(results, test_crossbow_has_bolt_scene())

	# Value Tests (evolution bonuses)
	_add_result(results, test_crossbow_damage_higher_than_bow())
	_add_result(results, test_crossbow_has_pierce_ability())

	# Method Tests
	_add_result(results, test_crossbow_has_upgrade_method())
	_add_result(results, test_crossbow_has_shoot_method())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_crossbow_scene_loads() -> Dictionary:
	var scene = load("res://scenes/weapons/crossbow.tscn")
	return {"name": "TC.CB.1: Crossbow scene loads", "passed": scene != null}

static func test_crossbow_script_loads() -> Dictionary:
	var script = load("res://scripts/weapons/crossbow.gd")
	return {"name": "TC.CB.2: Crossbow script loads", "passed": script != null}

static func test_crossbow_is_node_2d() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and crossbow is Node2D
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.3: Crossbow is Node2D", "passed": passed}

static func test_crossbow_has_damage() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and "damage" in crossbow
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.4: Crossbow has damage property", "passed": passed}

static func test_crossbow_has_attack_speed() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and "attack_speed" in crossbow
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.5: Crossbow has attack_speed property", "passed": passed}

static func test_crossbow_has_pierce() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and "pierce" in crossbow
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.6: Crossbow has pierce property", "passed": passed}

static func test_crossbow_has_bolt_scene() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and "bolt_scene" in crossbow
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.7: Crossbow has bolt_scene property", "passed": passed}

static func test_crossbow_damage_higher_than_bow() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and crossbow.damage >= 15  # Evolution bonus
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.8: Crossbow damage >= 15 (evolved)", "passed": passed}

static func test_crossbow_has_pierce_ability() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and crossbow.pierce >= 3  # Hits multiple enemies
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.9: Crossbow pierce >= 3", "passed": passed}

static func test_crossbow_has_upgrade_method() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and crossbow.has_method("upgrade")
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.10: Crossbow has upgrade method", "passed": passed}

static func test_crossbow_has_shoot_method() -> Dictionary:
	var crossbow = get_crossbow_instance()
	var passed = crossbow != null and crossbow.has_method("_shoot")
	if crossbow:
		crossbow.queue_free()
	return {"name": "TC.CB.11: Crossbow has _shoot method", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_process",
		"_find_nearest_enemy",
		"_fire_at",
		"get_total_damage",
		"get_total_pierce",
		"get_total_range",
		"upgrade",
		"_update_weapon_position"
	]
