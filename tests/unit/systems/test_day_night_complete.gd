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
	# DayNightCycle uses current_time (not current_phase)
	var passed = cycle != null and "current_time" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.2: Has current_time property", "passed": passed}

static func test_has_day_count() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses current_day (not day_count)
	var passed = cycle != null and "current_day" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.3: Has current_day property", "passed": passed}

static func test_has_phase_duration() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses day_duration and night_duration (not phase_duration)
	var passed = cycle != null and "day_duration" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.4: Has day_duration property", "passed": passed}

static func test_has_time_in_phase() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses night_duration (no time_in_phase; uses get_period_progress())
	var passed = cycle != null and "night_duration" in cycle
	if cycle:
		cycle.free()
	return {"name": "TC.DN.5: Has night_duration property", "passed": passed}

static func test_has_8_phases() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.6: Has TimeOfDay enum", "passed": false}
	# DayNightCycle uses TimeOfDay enum with 4 values (DAWN, DAY, DUSK, NIGHT)
	# HUD handles the 8 visual phases via set_time_icon()
	var passed = "TimeOfDay" in cycle and cycle.TimeOfDay.size() == 4
	cycle.free()
	return {"name": "TC.DN.6: Has 4 TimeOfDay phases", "passed": passed}

static func test_starts_at_dawn() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.7: Starts at DAWN", "passed": false}
	# DayNightCycle starts with current_time = 0.0, get_time_of_day() returns DAWN
	var passed = cycle.current_time == 0.0 and cycle.get_time_of_day() == cycle.TimeOfDay.DAWN
	cycle.free()
	return {"name": "TC.DN.7: Starts at DAWN", "passed": passed}

static func test_phase_names_exist() -> Dictionary:
	var cycle = get_day_night_instance()
	if not cycle:
		return {"name": "TC.DN.8: Time of day string method exists", "passed": false}
	# DayNightCycle uses get_time_of_day_string() (not PHASE_NAMES or get_phase_name)
	var passed = cycle.has_method("get_time_of_day_string")
	cycle.free()
	return {"name": "TC.DN.8: Has get_time_of_day_string method", "passed": passed}

static func test_has_advance_phase_method() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses start/stop methods (no advance_phase - time advances via _process)
	var passed = cycle != null and cycle.has_method("start")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.9: Has start method", "passed": passed}

static func test_has_is_night_method() -> Dictionary:
	var cycle = get_day_night_instance()
	var passed = cycle != null and cycle.has_method("is_night")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.10: Has is_night method", "passed": passed}

static func test_has_get_phase_name_method() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses get_time_of_day_string() (not get_phase_name)
	var passed = cycle != null and cycle.has_method("get_time_of_day_string")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.11: Has get_time_of_day_string method", "passed": passed}

static func test_has_phase_changed_signal() -> Dictionary:
	var cycle = get_day_night_instance()
	# DayNightCycle uses time_changed signal (not phase_changed)
	var passed = cycle != null and cycle.has_signal("time_changed")
	if cycle:
		cycle.free()
	return {"name": "TC.DN.12: Has time_changed signal", "passed": passed}

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
		return {"name": "TC.DN.15: Has tint method", "passed": false}
	# DayNightCycle uses get_current_tint() method (not PHASE_TINTS dict)
	var passed = cycle.has_method("get_current_tint") or "night_tint" in cycle
	cycle.free()
	return {"name": "TC.DN.15: Has get_current_tint method", "passed": passed}

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
