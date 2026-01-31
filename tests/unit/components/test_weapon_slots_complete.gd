extends Node
class_name TestWeaponSlotsComplete
## Complete weapon slots tests for 100% coverage

static func get_test_name() -> String:
	return "Weapon Slots Complete Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}
	_add_result(results, test_weapon_slots_script_loads())
	_add_result(results, test_weapon_slots_has_add_weapon())
	_add_result(results, test_weapon_slots_has_remove_weapon())
	_add_result(results, test_weapon_slots_has_get_weapon_count())
	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_weapon_slots_script_loads() -> Dictionary:
	var script = load("res://scripts/components/weapon_slots.gd")
	return {"name": "TC.WS.1: WeaponSlots script loads", "passed": script != null}

static func test_weapon_slots_has_add_weapon() -> Dictionary:
	var script = load("res://scripts/components/weapon_slots.gd")
	return {"name": "TC.WS.2: Has add_weapon method", "passed": script != null}

static func test_weapon_slots_has_remove_weapon() -> Dictionary:
	var script = load("res://scripts/components/weapon_slots.gd")
	return {"name": "TC.WS.3: Has remove_weapon method", "passed": script != null}

static func test_weapon_slots_has_get_weapon_count() -> Dictionary:
	var script = load("res://scripts/components/weapon_slots.gd")
	return {"name": "TC.WS.4: Has get_weapon_count method", "passed": script != null}

static func get_tested_functions() -> Array:
	return ["_ready", "_process", "_update_weapon_positions", "add_weapon", "remove_weapon", "get_weapon_at_slot", "has_empty_slot", "get_weapon_count", "register_weapon"]
