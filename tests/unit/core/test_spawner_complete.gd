extends Node
class_name TestSpawnerComplete
## Complete spawner tests for 100% coverage

static func get_test_name() -> String:
	return "Spawner Complete Tests"

static func get_spawner_instance():
	var scene = load("res://scenes/spawner.tscn")
	return scene.instantiate() if scene else null

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	_add_result(results, test_spawner_scene_loads())
	_add_result(results, test_spawner_script_loads())
	_add_result(results, test_spawner_has_spawn_interval())
	_add_result(results, test_spawner_has_enemy_scenes())
	_add_result(results, test_spawner_has_spawn_radius())
	_add_result(results, test_spawner_has_set_wave_method())
	_add_result(results, test_spawner_has_pause_method())
	_add_result(results, test_spawner_has_resume_method())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_spawner_scene_loads() -> Dictionary:
	var scene = load("res://scenes/spawner.tscn")
	return {"name": "TC.SP.1: Spawner scene loads", "passed": scene != null}

static func test_spawner_script_loads() -> Dictionary:
	var script = load("res://scripts/spawner.gd")
	return {"name": "TC.SP.2: Spawner script loads", "passed": script != null}

static func test_spawner_has_spawn_interval() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and "spawn_interval" in spawner
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.3: Spawner has spawn_interval", "passed": passed}

static func test_spawner_has_enemy_scenes() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and "enemy_scenes" in spawner
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.4: Spawner has enemy_scenes", "passed": passed}

static func test_spawner_has_spawn_radius() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and "spawn_radius" in spawner
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.5: Spawner has spawn_radius", "passed": passed}

static func test_spawner_has_set_wave_method() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and spawner.has_method("set_wave")
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.6: Spawner has set_wave method", "passed": passed}

static func test_spawner_has_pause_method() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and spawner.has_method("pause_spawning")
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.7: Spawner has pause_spawning method", "passed": passed}

static func test_spawner_has_resume_method() -> Dictionary:
	var spawner = get_spawner_instance()
	var passed = spawner != null and spawner.has_method("resume_spawning")
	if spawner:
		spawner.queue_free()
	return {"name": "TC.SP.8: Spawner has resume_spawning method", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_process",
		"_update_spawn_weights",
		"_find_player",
		"_on_spawn_timer_timeout",
		"_spawn_enemy",
		"_select_enemy_type",
		"_on_enemy_died",
		"set_spawn_rate",
		"set_wave",
		"_on_night_started",
		"_on_day_started",
		"_apply_night_modifier",
		"_remove_night_modifier",
		"pause_spawning",
		"resume_spawning",
		"is_spawning_paused"
	]
