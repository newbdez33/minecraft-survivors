extends Node
class_name TestHealthComplete
## Complete health component tests for 100% coverage
## Tests damage/heal boundaries, signals, and death state

static func get_test_name() -> String:
	return "Health Component Complete Tests"

static func get_health_instance():
	var script = load("res://scripts/components/health.gd")
	if not script:
		return null
	var health = Node.new()
	health.set_script(script)
	return health

## Run all health component tests and return results
static func run_tests() -> Dictionary:
	var results = {
		"passed": 0,
		"failed": 0,
		"tests": []
	}

	# Property Tests
	_add_result(results, test_health_has_max_health())
	_add_result(results, test_health_has_current_health())
	_add_result(results, test_health_default_max_is_100())

	# Damage Tests
	_add_result(results, test_take_damage_reduces_health())
	_add_result(results, test_take_damage_zero_does_nothing())
	_add_result(results, test_take_damage_negative_does_nothing())
	_add_result(results, test_take_damage_cannot_go_below_zero())
	_add_result(results, test_take_damage_large_amount())

	# Heal Tests
	_add_result(results, test_heal_increases_health())
	_add_result(results, test_heal_zero_does_nothing())
	_add_result(results, test_heal_negative_does_nothing())
	_add_result(results, test_heal_cannot_exceed_max())
	_add_result(results, test_heal_when_full_does_nothing())

	# State Tests
	_add_result(results, test_is_dead_false_initially())
	_add_result(results, test_is_dead_true_at_zero_health())
	_add_result(results, test_get_health_percent())
	_add_result(results, test_get_health_percent_at_half())
	_add_result(results, test_reset_restores_to_max())

	# Signal Tests
	_add_result(results, test_has_health_changed_signal())
	_add_result(results, test_has_damaged_signal())
	_add_result(results, test_has_healed_signal())
	_add_result(results, test_has_died_signal())
	_add_result(results, test_health_changed_emits_on_damage())
	_add_result(results, test_damaged_emits_correct_amount())
	_add_result(results, test_healed_emits_actual_amount())
	_add_result(results, test_died_emits_at_zero_health())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# PROPERTY TESTS
# =============================================================================

static func test_health_has_max_health() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and "max_health" in health
	if health:
		health.free()
	return {"name": "TC.H.1: Health has max_health property", "passed": passed}

static func test_health_has_current_health() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and "current_health" in health
	if health:
		health.free()
	return {"name": "TC.H.2: Health has current_health property", "passed": passed}

static func test_health_default_max_is_100() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and health.max_health == 100
	if health:
		health.free()
	return {"name": "TC.H.3: Default max_health is 100", "passed": passed}

# =============================================================================
# DAMAGE TESTS
# =============================================================================

static func test_take_damage_reduces_health() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.4: take_damage reduces health", "passed": false}

	health.current_health = 100
	health.take_damage(25)
	var passed = health.current_health == 75
	health.free()
	return {"name": "TC.H.4: take_damage reduces health", "passed": passed}

static func test_take_damage_zero_does_nothing() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.5: take_damage(0) does nothing", "passed": false}

	health.current_health = 100
	health.take_damage(0)
	var passed = health.current_health == 100
	health.free()
	return {"name": "TC.H.5: take_damage(0) does nothing", "passed": passed}

static func test_take_damage_negative_does_nothing() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.6: take_damage(-5) does nothing", "passed": false}

	health.current_health = 100
	health.take_damage(-5)
	var passed = health.current_health == 100
	health.free()
	return {"name": "TC.H.6: take_damage(-5) does nothing", "passed": passed}

static func test_take_damage_cannot_go_below_zero() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.7: Health cannot go below zero", "passed": false}

	health.current_health = 50
	health.take_damage(100)
	var passed = health.current_health == 0
	health.free()
	return {"name": "TC.H.7: Health cannot go below zero", "passed": passed}

static func test_take_damage_large_amount() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.8: Large damage caps at zero", "passed": false}

	health.current_health = 100
	health.take_damage(99999)
	var passed = health.current_health == 0
	health.free()
	return {"name": "TC.H.8: Large damage caps at zero", "passed": passed}

# =============================================================================
# HEAL TESTS
# =============================================================================

static func test_heal_increases_health() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.9: heal increases health", "passed": false}

	health.current_health = 50
	health.heal(20)
	var passed = health.current_health == 70
	health.free()
	return {"name": "TC.H.9: heal increases health", "passed": passed}

static func test_heal_zero_does_nothing() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.10: heal(0) does nothing", "passed": false}

	health.current_health = 50
	health.heal(0)
	var passed = health.current_health == 50
	health.free()
	return {"name": "TC.H.10: heal(0) does nothing", "passed": passed}

static func test_heal_negative_does_nothing() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.11: heal(-5) does nothing", "passed": false}

	health.current_health = 50
	health.heal(-5)
	var passed = health.current_health == 50
	health.free()
	return {"name": "TC.H.11: heal(-5) does nothing", "passed": passed}

static func test_heal_cannot_exceed_max() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.12: heal cannot exceed max_health", "passed": false}

	health.current_health = 90
	health.heal(50)
	var passed = health.current_health == health.max_health
	health.free()
	return {"name": "TC.H.12: heal cannot exceed max_health", "passed": passed}

static func test_heal_when_full_does_nothing() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.13: heal when full does nothing", "passed": false}

	health.current_health = 100
	health.heal(50)
	var passed = health.current_health == 100
	health.free()
	return {"name": "TC.H.13: heal when full does nothing", "passed": passed}

# =============================================================================
# STATE TESTS
# =============================================================================

static func test_is_dead_false_initially() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.14: is_dead() false initially", "passed": false}

	health.current_health = 100
	var passed = health.is_dead() == false
	health.free()
	return {"name": "TC.H.14: is_dead() false initially", "passed": passed}

static func test_is_dead_true_at_zero_health() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.15: is_dead() true at zero", "passed": false}

	health.current_health = 0
	var passed = health.is_dead() == true
	health.free()
	return {"name": "TC.H.15: is_dead() true at zero", "passed": passed}

static func test_get_health_percent() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.16: get_health_percent() at full", "passed": false}

	health.current_health = 100
	health.max_health = 100
	var passed = health.get_health_percent() == 1.0
	health.free()
	return {"name": "TC.H.16: get_health_percent() at full", "passed": passed}

static func test_get_health_percent_at_half() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.17: get_health_percent() at half", "passed": false}

	health.current_health = 50
	health.max_health = 100
	var passed = health.get_health_percent() == 0.5
	health.free()
	return {"name": "TC.H.17: get_health_percent() at half", "passed": passed}

static func test_reset_restores_to_max() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.18: reset() restores to max", "passed": false}

	health.current_health = 25
	health.max_health = 100
	health.reset()
	var passed = health.current_health == health.max_health
	health.free()
	return {"name": "TC.H.18: reset() restores to max", "passed": passed}

# =============================================================================
# SIGNAL TESTS
# =============================================================================

static func test_has_health_changed_signal() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and health.has_signal("health_changed")
	if health:
		health.free()
	return {"name": "TC.H.19: Has health_changed signal", "passed": passed}

static func test_has_damaged_signal() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and health.has_signal("damaged")
	if health:
		health.free()
	return {"name": "TC.H.20: Has damaged signal", "passed": passed}

static func test_has_healed_signal() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and health.has_signal("healed")
	if health:
		health.free()
	return {"name": "TC.H.21: Has healed signal", "passed": passed}

static func test_has_died_signal() -> Dictionary:
	var health = get_health_instance()
	var passed = health != null and health.has_signal("died")
	if health:
		health.free()
	return {"name": "TC.H.22: Has died signal", "passed": passed}

static func test_health_changed_emits_on_damage() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.23: health_changed emits on damage", "passed": false}

	health.current_health = 100
	var signal_received = false
	health.health_changed.connect(func(_c, _m): signal_received = true)
	health.take_damage(10)
	var passed = signal_received
	health.free()
	return {"name": "TC.H.23: health_changed emits on damage", "passed": passed}

static func test_damaged_emits_correct_amount() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.24: damaged emits correct amount", "passed": false}

	health.current_health = 100
	var damage_amount = 0
	health.damaged.connect(func(amt): damage_amount = amt)
	health.take_damage(15)
	var passed = damage_amount == 15
	health.free()
	return {"name": "TC.H.24: damaged emits correct amount", "passed": passed}

static func test_healed_emits_actual_amount() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.25: healed emits actual amount", "passed": false}

	health.current_health = 50
	health.max_health = 100
	var heal_amount = 0
	health.healed.connect(func(amt): heal_amount = amt)
	health.heal(20)
	var passed = heal_amount == 20
	health.free()
	return {"name": "TC.H.25: healed emits actual amount", "passed": passed}

static func test_died_emits_at_zero_health() -> Dictionary:
	var health = get_health_instance()
	if not health:
		return {"name": "TC.H.26: died emits at zero health", "passed": false}

	health.current_health = 10
	var died_emitted = false
	health.died.connect(func(): died_emitted = true)
	health.take_damage(10)
	var passed = died_emitted and health.current_health == 0
	health.free()
	return {"name": "TC.H.26: died emits at zero health", "passed": passed}

## Get functions tested by this test file (for coverage tracking)
static func get_tested_functions() -> Array:
	return [
		"_ready",
		"take_damage",
		"heal",
		"is_dead",
		"get_health_percent",
		"reset",
	]
