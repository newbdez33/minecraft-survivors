extends Node
class_name TestGameSession
## End-to-end tests for complete game sessions

static func get_test_name() -> String:
	return "Game Session E2E Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Main Scene Tests
	_add_result(results, test_main_scene_loads())
	_add_result(results, test_main_scene_has_player())
	_add_result(results, test_main_scene_has_spawner())
	_add_result(results, test_main_scene_has_hud())
	_add_result(results, test_main_scene_has_camera())

	# Game Flow Tests
	_add_result(results, test_game_has_wave_manager())
	_add_result(results, test_game_has_upgrade_manager())
	_add_result(results, test_game_has_day_night_cycle())

	# Signal Connection Tests
	_add_result(results, test_player_signals_exist())
	_add_result(results, test_spawner_can_spawn())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_main_scene_loads() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	return {"name": "TC.E2E.1: Main scene loads", "passed": scene != null}

static func test_main_scene_has_player() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.2: Main scene has player", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("Player")
	main.queue_free()
	return {"name": "TC.E2E.2: Main scene has Player node", "passed": passed}

static func test_main_scene_has_spawner() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.3: Main scene has spawner", "passed": false}
	var main = scene.instantiate()
	# Check for Spawner or MobSpawner
	var passed = main.has_node("Spawner") or main.has_node("MobSpawner")
	main.queue_free()
	return {"name": "TC.E2E.3: Main scene has Spawner/MobSpawner node", "passed": passed}

static func test_main_scene_has_hud() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.4: Main scene has HUD", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("HUD")
	main.queue_free()
	return {"name": "TC.E2E.4: Main scene has HUD node", "passed": passed}

static func test_main_scene_has_camera() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.5: Main scene has camera", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("Camera2D")
	main.queue_free()
	return {"name": "TC.E2E.5: Main scene has Camera2D node", "passed": passed}

static func test_game_has_wave_manager() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.6: Game has wave manager", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("WaveManager")
	main.queue_free()
	return {"name": "TC.E2E.6: Game has WaveManager node", "passed": passed}

static func test_game_has_upgrade_manager() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.7: Game has upgrade manager", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("UpgradeManager")
	main.queue_free()
	return {"name": "TC.E2E.7: Game has UpgradeManager node", "passed": passed}

static func test_game_has_day_night_cycle() -> Dictionary:
	var scene = load("res://scenes/main.tscn")
	if not scene:
		return {"name": "TC.E2E.8: Game has day/night cycle", "passed": false}
	var main = scene.instantiate()
	var passed = main.has_node("DayNightCycle")
	main.queue_free()
	return {"name": "TC.E2E.8: Game has DayNightCycle node", "passed": passed}

static func test_player_signals_exist() -> Dictionary:
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		return {"name": "TC.E2E.9: Player signals exist", "passed": false}
	var player = player_scene.instantiate()
	var passed = player.has_signal("health_changed") and player.has_signal("died") and player.has_signal("leveled_up")
	player.queue_free()
	return {"name": "TC.E2E.9: Player has required signals", "passed": passed}

static func test_spawner_can_spawn() -> Dictionary:
	var spawner_script = load("res://scripts/spawner.gd")
	if not spawner_script:
		return {"name": "TC.E2E.10: Spawner can spawn", "passed": false}
	var spawner = Node.new()
	spawner.set_script(spawner_script)
	# Check for spawn-related methods
	var passed = spawner.has_method("spawn_enemy") or spawner.has_method("_spawn_enemy")
	spawner.free()
	return {"name": "TC.E2E.10: Spawner has spawn method", "passed": passed}

static func get_tested_functions() -> Array:
	return ["_ready", "spawn_enemy"]
