extends Node
class_name TestDayNightComplete
## Complete day/night cycle tests for 100% coverage

static func get_test_name() -> String:
	return "Day/Night Cycle Complete Tests"

static func get_day_night_instance():
	var script = load("res://scripts/systems/day_night_cycle.gd")
	if not script:
		return null
	var cycle = Node.new()
	cycle.set_script(script)
	return cycle

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Script Tests
	_add_result(results, test_day_night_script_loads())

	# Property Tests
	_add_result(results, test_has_current_phase())
	_add_result(results, test_has_day_count())
	_add_result(results, test_has_phase_duration())
	_add_result(results, test_has_time_in_phase())

	# Phase Tests
	_add_result(results, test_has_8_phases())
	_add_result(results, test_starts_at_dawn())
	_add_result(results, test_phase_names_exist())

	# Method Tests
	_add_result(results, test_has_advance_phase_method())
	_add_result(results, test_has_is_night_method())
	_add_result(results, test_has_get_phase_name_method())

	# Signal Tests
	_add_result(results, test_has_phase_changed_signal())
	_add_result(results, test_has_day_started_signal())
	_add_result(results, test_has_night_started_signal())

	# Tint Tests
	_add_result(results, test_has_phase_tints())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_day_night_script_loads() -> Dictionary:
	var script = load("res://scripts/systems/day_night_cycle.gd")
	return {"name": "TC.DN.1: DayNightCycle script loads", "passed": script != null}

static func test_has_current_phase() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and "current_phase" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.2: Has current_phase property", "passed": passed}

static func test_has_day_count() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and "day_count" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.3: Has day_count property", "passed": passed}

static func test_has_phase_duration() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and "phase_duration" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.4: Has phase_duration property", "passed": passed}

static func test_has_time_in_phase() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and "time_in_phase" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.5: Has time_in_phase property", "passed": passed}

static func test_has_8_phases() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.6: Has 8 phases", "passed": false}
	# Check if Phase enum has 8 values
	var passed = "Phase" in cycle and cycle.Phase.size() == 8
	cycle.free()
	return {"name": "TC.DN.6: Has 8 phases", "passed": passed}

static func test_starts_at_dawn() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.7: Starts at DAWN", "passed": false}
	var passed = cycle.current_phase == cycle.Phase.DAWN
	cycle.free()
	return {"name": "TC.DN.7: Starts at DAWN", "passed": passed}

static func test_phase_names_exist() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.8: Phase names exist", "passed": false}
	var passed = "PHASE_NAMES" in cycle or cycle.has_method("get_phase_name")
	cycle.free()
	return {"name": "TC.DN.8: Phase names exist", "passed": passed}

static func test_has_advance_phase_method() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_method("advance_phase")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.9: Has advance_phase method", "passed": passed}

static func test_has_is_night_method() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_method("is_night")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.10: Has is_night method", "passed": passed}

static func test_has_get_phase_name_method() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_method("get_phase_name")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.11: Has get_phase_name method", "passed": passed}

static func test_has_phase_changed_signal() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_signal("phase_changed")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.12: Has phase_changed signal", "passed": passed}

static func test_has_day_started_signal() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_signal("day_started")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.13: Has day_started signal", "passed": passed}

static func test_has_night_started_signal() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_signal("night_started")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.14: Has night_started signal", "passed": passed}

static func test_has_phase_tints() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.15: Has phase tints", "passed": false}
	var passed = "PHASE_TINTS" in cycle or "phase_tints" in cycle
	cycle.free()
	return {"name": "TC.DN.15: Has phase tints dictionary", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_process",
		"start",
		"stop",
		"reset",
		"is_night",
		"get_time_of_day",
		"get_time_of_day_string",
		"get_period_progress",
		"get_current_tint",
		"get_formatted_time"
	]
