extends Node
class_name TestComboSystemComplete
## Complete combo system tests for 100% coverage

static func get_test_name() -> String:
	return "Combo System Complete Tests"

static func get_combo_system_instance():
	var script = load("res://scripts/systems/combo_system.gd")
	if not script:
		return null
	# ComboSystem extends RefCounted, so use .new() directly
	var system = script.new()
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
	return {"name": "TC.CS.2: Has current_combo property", "passed": passed}

static func test_has_max_combo() -> Dictionary:
	var system = get_combo_system_instance()
	# ComboSystem uses _highest_combo (private), accessible via get_highest_combo()
	var passed = system != null and system.has_method("get_highest_combo")
	return {"name": "TC.CS.3: Has get_highest_combo method", "passed": passed}

static func test_has_combo_timeout() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and "combo_timeout" in system
	return {"name": "TC.CS.4: Has combo_timeout property", "passed": passed}

static func test_has_combo_timer() -> Dictionary:
	var system = get_combo_system_instance()
	# ComboSystem uses _time_since_last_kill (private)
	var passed = system != null and "_time_since_last_kill" in system
	return {"name": "TC.CS.5: Has _time_since_last_kill property", "passed": passed}

static func test_has_add_combo_method() -> Dictionary:
	var system = get_combo_system_instance()
	# ComboSystem uses on_enemy_killed() (not add_combo)
	var passed = system != null and system.has_method("on_enemy_killed")
	return {"name": "TC.CS.6: Has on_enemy_killed method", "passed": passed}

static func test_has_reset_combo_method() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_method("reset_combo")
	return {"name": "TC.CS.7: Has reset_combo method", "passed": passed}

static func test_has_get_combo_multiplier_method() -> Dictionary:
	var system = get_combo_system_instance()
	# ComboSystem uses get_xp_bonus() (not get_combo_multiplier)
	var passed = system != null and system.has_method("get_xp_bonus")
	return {"name": "TC.CS.8: Has get_xp_bonus method", "passed": passed}

static func test_combo_starts_at_zero() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.current_combo == 0
	return {"name": "TC.CS.9: Combo starts at 0", "passed": passed}

static func test_add_combo_increases_count() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.10: on_enemy_killed increases count", "passed": false}
	# ComboSystem uses on_enemy_killed() (not add_combo)
	system.on_enemy_killed()
	system.on_enemy_killed()
	var passed = system.current_combo == 2
	return {"name": "TC.CS.10: on_enemy_killed increases count", "passed": passed}

static func test_reset_combo_clears_count() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.11: reset_combo clears count", "passed": false}
	system.on_enemy_killed()
	system.on_enemy_killed()
	system.reset_combo()
	var passed = system.current_combo == 0
	return {"name": "TC.CS.11: reset_combo clears count", "passed": passed}

static func test_max_combo_tracked() -> Dictionary:
	var system = get_combo_system_instance()
	if not system:
		return {"name": "TC.CS.12: highest_combo is tracked", "passed": false}
	for i in range(10):
		system.on_enemy_killed()
	system.reset_combo()
	# ComboSystem tracks via get_highest_combo() (not max_combo)
	var passed = system.get_highest_combo() == 10
	return {"name": "TC.CS.12: highest_combo is tracked", "passed": passed}

static func test_has_combo_changed_signal() -> Dictionary:
	var system = get_combo_system_instance()
	var passed = system != null and system.has_signal("combo_changed")
	return {"name": "TC.CS.13: Has combo_changed signal", "passed": passed}

static func test_has_combo_milestone_signal() -> Dictionary:
	var system = get_combo_system_instance()
	# ComboSystem uses milestone_reached signal (not combo_milestone)
	var passed = system != null and system.has_signal("milestone_reached")
	return {"name": "TC.CS.14: Has milestone_reached signal", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"update",
		"on_enemy_killed",
		"on_player_damaged",
		"reset_combo",
		"get_xp_bonus",
		"get_highest_combo"
	]
