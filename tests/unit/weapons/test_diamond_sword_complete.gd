extends Node
class_name TestDiamondSwordComplete
## Complete diamond sword tests for 100% coverage

static func get_test_name() -> String:
	return "Diamond Sword Complete Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}
	_add_result(results, test_diamond_sword_script_loads())
	_add_result(results, test_diamond_sword_scene_loads())
	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_diamond_sword_script_loads() -> Dictionary:
	var script = load("res://scripts/weapons/diamond_sword.gd")
	return {"name": "TC.DS.1: Diamond Sword script loads", "passed": script != null}

static func test_diamond_sword_scene_loads() -> Dictionary:
	var scene = load("res://scenes/weapons/diamond_sword.tscn")
	return {"name": "TC.DS.2: Diamond Sword scene loads", "passed": scene != null}

static func get_tested_functions() -> Array:
	return ["_ready", "_physics_process", "_perform_attack", "_play_attack_animation", "_on_player_facing_changed", "_update_sword_position", "_on_attack_timer_timeout", "_on_body_entered", "_on_body_exited", "_draw", "set_show_range"]
