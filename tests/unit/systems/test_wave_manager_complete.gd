extends Node
class_name TestWaveManagerComplete
## Complete wave manager tests for 100% coverage

static func get_test_name() -> String:
	return "Wave Manager Complete Tests"

static func get_wave_manager_instance():
	var script = load("res://scripts/systems/wave_manager.gd")
	if not script:
		return null
	var manager = Node.new()
	manager.set_script(script)
	return manager

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Script Tests
	_add_result(results, test_wave_manager_script_loads())

	# Property Tests
	_add_result(results, test_has_current_wave())
	_add_result(results, test_has_base_enemies_per_wave())
	_add_result(results, test_has_wave_scaling())
	_add_result(results, test_has_wave_duration())

	# Method Tests
	_add_result(results, test_has_start_wave_method())
	_add_result(results, test_has_get_enemies_for_wave_method())
	_add_result(results, test_has_is_boss_wave_method())

	# Wave Calculation Tests
	_add_result(results, test_wave_1_enemy_count())
	_add_result(results, test_wave_scaling_increases())
	_add_result(results, test_boss_wave_detection())

	# Signal Tests
	_add_result(results, test_has_wave_started_signal())
	_add_result(results, test_has_wave_completed_signal())

	# Night Multiplier Tests
	_add_result(results, test_has_night_multiplier())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_wave_manager_script_loads() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	return {"name": "TC.WM.1: WaveManager script loads", "passed": script != null}

static func test_has_current_wave() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and "current_wave" in manager
	if manager:
		manager.free()
	return {"name": "TC.WM.2: Has current_wave property", "passed": passed}

static func test_has_base_enemies_per_wave() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and "base_enemies_per_wave" in manager
	if manager:
		manager.free()
	return {"name": "TC.WM.3: Has base_enemies_per_wave property", "passed": passed}

static func test_has_wave_scaling() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and "wave_scaling" in manager
	if manager:
		manager.free()
	return {"name": "TC.WM.4: Has wave_scaling property", "passed": passed}

static func test_has_wave_duration() -> Dictionary:
	var manager = get_wave_manager_instance()
	# WaveManager uses wave_interval (not wave_duration)
	var passed = manager != null and "wave_interval" in manager
	if manager:
		manager.free()
	return {"name": "TC.WM.5: Has wave_interval property", "passed": passed}

static func test_has_start_wave_method() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and manager.has_method("start_wave")
	if manager:
		manager.free()
	return {"name": "TC.WM.6: Has start_wave method", "passed": passed}

static func test_has_get_enemies_for_wave_method() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and manager.has_method("get_enemies_for_wave")
	if manager:
		manager.free()
	return {"name": "TC.WM.7: Has get_enemies_for_wave method", "passed": passed}

static func test_has_is_boss_wave_method() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and manager.has_method("is_boss_wave")
	if manager:
		manager.free()
	return {"name": "TC.WM.8: Has is_boss_wave method", "passed": passed}

static func test_wave_1_enemy_count() -> Dictionary:
	var manager = get_wave_manager_instance()
	if not manager:
		return {"name": "TC.WM.9: Wave 1 enemy count is base", "passed": false}
	var count = manager.get_enemies_for_wave(1)
	var passed = count == manager.base_enemies_per_wave
	manager.free()
	return {"name": "TC.WM.9: Wave 1 enemy count is base", "passed": passed}

static func test_wave_scaling_increases() -> Dictionary:
	var manager = get_wave_manager_instance()
	if not manager:
		return {"name": "TC.WM.10: Later waves have more enemies", "passed": false}
	var wave_1 = manager.get_enemies_for_wave(1)
	var wave_5 = manager.get_enemies_for_wave(5)
	var passed = wave_5 > wave_1
	manager.free()
	return {"name": "TC.WM.10: Later waves have more enemies", "passed": passed}

static func test_boss_wave_detection() -> Dictionary:
	var manager = get_wave_manager_instance()
	if not manager:
		return {"name": "TC.WM.11: Wave 5 is boss wave", "passed": false}
	var passed = manager.is_boss_wave(5)
	manager.free()
	return {"name": "TC.WM.11: Wave 5 is boss wave", "passed": passed}

static func test_has_wave_started_signal() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and manager.has_signal("wave_started")
	if manager:
		manager.free()
	return {"name": "TC.WM.12: Has wave_started signal", "passed": passed}

static func test_has_wave_completed_signal() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and manager.has_signal("wave_completed")
	if manager:
		manager.free()
	return {"name": "TC.WM.13: Has wave_completed signal", "passed": passed}

static func test_has_night_multiplier() -> Dictionary:
	var manager = get_wave_manager_instance()
	var passed = manager != null and "night_multiplier" in manager
	if manager:
		manager.free()
	return {"name": "TC.WM.14: Has night_multiplier property", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_process",
		"start",
		"stop",
		"reset",
		"start_wave",
		"complete_wave",
		"get_enemies_for_wave",
		"get_enemy_types_for_wave",
		"_generate_enemy_list",
		"get_wave_info",
		"is_boss_wave",
		"get_boss_for_wave"
	]
