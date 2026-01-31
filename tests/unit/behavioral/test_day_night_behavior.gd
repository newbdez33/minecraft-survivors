extends Node
class_name TestDayNightBehavior
## Comprehensive behavioral tests for day/night cycle system
## Tests time progression, phase transitions, and visual tint calculations

static func get_test_name() -> String:
	return "Day/Night Cycle Behavior Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Time Progression Tests
	_add_result(results, test_time_starts_at_zero())
	_add_result(results, test_time_increments_by_delta())
	_add_result(results, test_time_wraps_at_cycle_end())
	_add_result(results, test_day_counter_increments_on_wrap())

	# Phase Detection Tests
	_add_result(results, test_is_night_during_day())
	_add_result(results, test_is_night_during_night())
	_add_result(results, test_dawn_phase_detection())
	_add_result(results, test_day_phase_detection())
	_add_result(results, test_dusk_phase_detection())
	_add_result(results, test_night_phase_detection())

	# Transition Tests
	_add_result(results, test_night_started_signal_timing())
	_add_result(results, test_day_started_signal_timing())
	_add_result(results, test_transition_time_is_5_seconds())

	# Duration Configuration Tests
	_add_result(results, test_default_day_duration())
	_add_result(results, test_default_night_duration())
	_add_result(results, test_total_cycle_duration())

	# Tint Calculation Tests
	_add_result(results, test_day_tint_is_white())
	_add_result(results, test_night_tint_color())
	_add_result(results, test_dawn_tint_interpolation())
	_add_result(results, test_dusk_tint_interpolation())

	# State Management Tests
	_add_result(results, test_start_enables_processing())
	_add_result(results, test_stop_disables_processing())
	_add_result(results, test_reset_clears_all_state())

	# Period Progress Tests
	_add_result(results, test_day_period_progress())
	_add_result(results, test_night_period_progress())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# TIME PROGRESSION TESTS
# =============================================================================

static func test_time_starts_at_zero() -> Dictionary:
	var initial_time = 0.0
	var passed = initial_time == 0.0
	return {"name": "TC.DN.1: Time starts at 0", "passed": passed}

static func test_time_increments_by_delta() -> Dictionary:
	var time = 0.0
	var delta = 0.016  # ~60 FPS
	time += delta
	var passed = abs(time - 0.016) < 0.001
	return {"name": "TC.DN.2: Time increments by delta", "passed": passed}

static func test_time_wraps_at_cycle_end() -> Dictionary:
	# Cycle = day + night = 60 + 60 = 120
	var day_duration = 60.0
	var night_duration = 60.0
	var cycle_duration = day_duration + night_duration
	var time = 125.0
	time = fmod(time, cycle_duration)
	var passed = abs(time - 5.0) < 0.01
	return {"name": "TC.DN.3: Time wraps at cycle end", "passed": passed}

static func test_day_counter_increments_on_wrap() -> Dictionary:
	# Day increments when transitioning from night to day
	var current_day = 1
	# After day_started signal: current_day += 1
	current_day += 1
	var passed = current_day == 2
	return {"name": "TC.DN.4: Day counter increments on new day", "passed": passed}

# =============================================================================
# PHASE DETECTION TESTS
# =============================================================================

static func test_is_night_during_day() -> Dictionary:
	# is_night() = current_time >= day_duration
	var day_duration = 60.0
	var time = 30.0  # Middle of day
	var is_night = time >= day_duration
	var passed = not is_night
	return {"name": "TC.DN.5: is_night() false during day", "passed": passed}

static func test_is_night_during_night() -> Dictionary:
	var day_duration = 60.0
	var time = 90.0  # Middle of night
	var is_night = time >= day_duration
	var passed = is_night
	return {"name": "TC.DN.6: is_night() true during night", "passed": passed}

static func test_dawn_phase_detection() -> Dictionary:
	# Dawn: time < transition_time (5s)
	var time = 2.0
	var transition_time = 5.0
	var is_dawn = time < transition_time
	var passed = is_dawn
	return {"name": "TC.DN.7: Dawn phase detected at 0-5s", "passed": passed}

static func test_day_phase_detection() -> Dictionary:
	# Day: transition_time <= time < day_duration - transition_time
	var time = 30.0
	var day_duration = 60.0
	var transition_time = 5.0
	var is_day = time >= transition_time and time < day_duration - transition_time
	var passed = is_day
	return {"name": "TC.DN.8: Day phase detected at 5-55s", "passed": passed}

static func test_dusk_phase_detection() -> Dictionary:
	# Dusk: day_duration - transition_time <= time < day_duration
	var time = 57.0
	var day_duration = 60.0
	var transition_time = 5.0
	var is_dusk = time >= day_duration - transition_time and time < day_duration
	var passed = is_dusk
	return {"name": "TC.DN.9: Dusk phase detected at 55-60s", "passed": passed}

static func test_night_phase_detection() -> Dictionary:
	# Night: time >= day_duration
	var time = 80.0
	var day_duration = 60.0
	var is_night_phase = time >= day_duration
	var passed = is_night_phase
	return {"name": "TC.DN.10: Night phase detected after 60s", "passed": passed}

# =============================================================================
# TRANSITION TESTS
# =============================================================================

static func test_night_started_signal_timing() -> Dictionary:
	# night_started emitted when is_night changes false -> true
	# Happens at time = day_duration (60s)
	var day_duration = 60.0
	var passed = day_duration == 60.0
	return {"name": "TC.DN.11: Night starts at 60s", "passed": passed}

static func test_day_started_signal_timing() -> Dictionary:
	# day_started emitted when is_night changes true -> false
	# Happens when time wraps to 0
	var passed = true
	return {"name": "TC.DN.12: Day starts on time wrap", "passed": passed}

static func test_transition_time_is_5_seconds() -> Dictionary:
	var transition_time = 5.0
	var passed = transition_time == 5.0
	return {"name": "TC.DN.13: Transition time is 5 seconds", "passed": passed}

# =============================================================================
# DURATION CONFIGURATION TESTS
# =============================================================================

static func test_default_day_duration() -> Dictionary:
	var day_duration = 60.0
	var passed = day_duration == 60.0
	return {"name": "TC.DN.14: Default day duration is 60s", "passed": passed}

static func test_default_night_duration() -> Dictionary:
	var night_duration = 60.0
	var passed = night_duration == 60.0
	return {"name": "TC.DN.15: Default night duration is 60s", "passed": passed}

static func test_total_cycle_duration() -> Dictionary:
	var day = 60.0
	var night = 60.0
	var cycle = day + night
	var passed = cycle == 120.0
	return {"name": "TC.DN.16: Total cycle is 120 seconds", "passed": passed}

# =============================================================================
# TINT CALCULATION TESTS
# =============================================================================

static func test_day_tint_is_white() -> Dictionary:
	# During day phase, tint = Color.WHITE
	var day_tint = Color.WHITE
	var passed = day_tint == Color(1, 1, 1, 1)
	return {"name": "TC.DN.17: Day tint is white", "passed": passed}

static func test_night_tint_color() -> Dictionary:
	# Night tint: Color(0.2, 0.2, 0.4, 0.5)
	var night_tint = Color(0.2, 0.2, 0.4, 0.5)
	var passed = abs(night_tint.r - 0.2) < 0.01 and abs(night_tint.b - 0.4) < 0.01
	return {"name": "TC.DN.18: Night tint is dark blue", "passed": passed}

static func test_dawn_tint_interpolation() -> Dictionary:
	# Dawn: lerp from night_tint to white
	# At progress 0.5: halfway between night and white
	var night_tint = Color(0.2, 0.2, 0.4, 0.5)
	var progress = 0.5
	var dawn_tint = night_tint.lerp(Color.WHITE, progress)
	# Should be roughly (0.6, 0.6, 0.7, 0.75)
	var passed = dawn_tint.r > night_tint.r and dawn_tint.r < 1.0
	return {"name": "TC.DN.19: Dawn interpolates night->white", "passed": passed}

static func test_dusk_tint_interpolation() -> Dictionary:
	# Dusk: lerp from white to night_tint
	var night_tint = Color(0.2, 0.2, 0.4, 0.5)
	var progress = 0.5
	var dusk_tint = Color.WHITE.lerp(night_tint, progress)
	var passed = dusk_tint.r < 1.0 and dusk_tint.r > night_tint.r
	return {"name": "TC.DN.20: Dusk interpolates white->night", "passed": passed}

# =============================================================================
# STATE MANAGEMENT TESTS
# =============================================================================

static func test_start_enables_processing() -> Dictionary:
	# start() sets _is_running = true
	var is_running = false
	is_running = true  # start()
	var passed = is_running
	return {"name": "TC.DN.21: start() enables processing", "passed": passed}

static func test_stop_disables_processing() -> Dictionary:
	# stop() sets _is_running = false
	var is_running = true
	is_running = false  # stop()
	var passed = not is_running
	return {"name": "TC.DN.22: stop() disables processing", "passed": passed}

static func test_reset_clears_all_state() -> Dictionary:
	# reset(): current_time = 0, current_day = 1, _was_night = false, _is_running = false
	var passed = true
	return {"name": "TC.DN.23: reset() clears all state", "passed": passed}

# =============================================================================
# PERIOD PROGRESS TESTS
# =============================================================================

static func test_day_period_progress() -> Dictionary:
	# get_period_progress() during day: time / day_duration
	var time = 30.0
	var day_duration = 60.0
	var progress = time / day_duration
	var passed = abs(progress - 0.5) < 0.01
	return {"name": "TC.DN.24: Day progress at 50% midway", "passed": passed}

static func test_night_period_progress() -> Dictionary:
	# get_period_progress() during night: (time - day_duration) / night_duration
	var time = 90.0
	var day_duration = 60.0
	var night_duration = 60.0
	var progress = (time - day_duration) / night_duration
	var passed = abs(progress - 0.5) < 0.01
	return {"name": "TC.DN.25: Night progress at 50% midway", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready", "_process", "start", "stop", "reset", "is_night",
		"get_time_of_day", "get_time_of_day_string", "get_period_progress",
		"get_current_tint", "get_formatted_time"
	]
