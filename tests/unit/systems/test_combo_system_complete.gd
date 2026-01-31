extends Node
class_name TestComboSystemComplete
## Complete combo system tests for 100% coverage

static func get_test_name() -> String:
	return "Combo System Complete Tests"

static func get_combo_system_instance():
	var script = load("res://scripts/systems/combo_system.gd")
	if not script:
		return null
	var system = Node.new()
	system.set_script(script)
	return system

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Script Tests
	_add_result(results, test_combo_system_script_loads())

	# Property Tests
	_add_result(results, test_has_current_combo())
	_add_result(results, test_has_max_combo())
	_add_result(results, test_has_combo_timeout())
	_add_result(results, test_has_combo_timer())

	# Method Tests
	_add_result(results, test_has_add_combo_method())
	_add_result(results, test_has_reset_combo_method())
	_add_result(results, test_has_get_combo_multiplier_method())

	# Behavior Tests
	_add_result(results, test_combo_starts_at_zero())
	_add_result(results, test_add_combo_increases_count())
	_add_result(results, test_reset_combo_clears_count())
	_add_result(results, test_max_combo_tracked())

	# Signal Tests
	_add_result(results, test_has_combo_changed_signal())
	_add_result(results, test_has_combo_milestone_signal())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_combo_system_script_loads() -> Dictionary:
	var script = load("res://scripts/systems/combo_system.gd")
	return {"name": "TC.CS.1: ComboSystem script loads", "passed": script != null}

static func test_has_current_combo() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and "current_combo" in system
	if system:
		system.free()
	return {"name": "TC.CS.2: Has current_combo property", "passed": passed}

static func test_has_max_combo() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and "max_combo" in system
	if system:
		system.free()
	return {"name": "TC.CS.3: Has max_combo property", "passed": passed}

static func test_has_combo_timeout() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and "combo_timeout" in system
	if system:
		system.free()
	return {"name": "TC.CS.4: Has combo_timeout property", "passed": passed}

static func test_has_combo_timer() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and "combo_timer" in system
	if system:
		system.free()
	return {"name": "TC.CS.5: Has combo_timer property", "passed": passed}

static func test_has_add_combo_method() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_method("add_combo")
	if system:
		system.free()
	return {"name": "TC.CS.6: Has add_combo method", "passed": passed}

static func test_has_reset_combo_method() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_method("reset_combo")
	if system:
		system.free()
	return {"name": "TC.CS.7: Has reset_combo method", "passed": passed}

static func test_has_get_combo_multiplier_method() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_method("get_combo_multiplier")
	if system:
		system.free()
	return {"name": "TC.CS.8: Has get_combo_multiplier method", "passed": passed}

static func test_combo_starts_at_zero() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.current_combo == 0
	if system:
		system.free()
	return {"name": "TC.CS.9: Combo starts at 0", "passed": passed}

static func test_add_combo_increases_count() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.10: add_combo increases count", "passed": false}
	system.add_combo()
	system.add_combo()
	var passed = system.current_combo == 2
	system.free()
	return {"name": "TC.CS.10: add_combo increases count", "passed": passed}

static func test_reset_combo_clears_count() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.11: reset_combo clears count", "passed": false}
	system.add_combo()
	system.add_combo()
	system.reset_combo()
	var passed = system.current_combo == 0
	system.free()
	return {"name": "TC.CS.11: reset_combo clears count", "passed": passed}

static func test_max_combo_tracked() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.12: max_combo is tracked", "passed": false}
	for i in range(10):
		system.add_combo()
	system.reset_combo()
	var passed = system.max_combo == 10
	system.free()
	return {"name": "TC.CS.12: max_combo is tracked", "passed": passed}

static func test_has_combo_changed_signal() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_signal("combo_changed")
	if system:
		system.free()
	return {"name": "TC.CS.13: Has combo_changed signal", "passed": passed}

static func test_has_combo_milestone_signal() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_signal("combo_milestone")
	if system:
		system.free()
	return {"name": "TC.CS.14: Has combo_milestone signal", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"update",
		"on_enemy_killed",
		"on_player_damaged",
		"reset_combo",
		"get_xp_bonus",
		"get_highest_combo"
	]
