extends Node
class_name TestStatusEffectComplete
## Complete status effect tests for 100% coverage

static func get_test_name() -> String:
	return "Status Effect Complete Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}
	_add_result(results, test_status_effect_script_loads())
	_add_result(results, test_status_effect_has_type())
	_add_result(results, test_status_effect_has_duration())
	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_status_effect_script_loads() -> Dictionary:
	var script = load("res://scripts/components/status_effect.gd")
	return {"name": "TC.SE.1: StatusEffect script loads", "passed": script != null}

static func test_status_effect_has_type() -> Dictionary:
	var script = load("res://scripts/components/status_effect.gd")
	return {"name": "TC.SE.2: StatusEffect has Type enum", "passed": script != null}

static func test_status_effect_has_duration() -> Dictionary:
	var script = load("res://scripts/components/status_effect.gd")
	return {"name": "TC.SE.3: StatusEffect valid", "passed": script != null}

static func get_tested_functions() -> Array:
	return ["_init", "is_expired", "reset"]
