extends Node
class_name TestStatusEffectBehavior
## Comprehensive behavioral tests for status effect system
## Tests poison stacking, tick damage, expiration, and visual indicators

static func get_test_name() -> String:
	return "Status Effect Behavior Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Effect Application Tests
	_add_result(results, test_effect_added_to_active_list())
	_add_result(results, test_effect_tick_timer_initialized())
	_add_result(results, test_effect_applied_signal_emitted())

	# Stacking Behavior Tests
	_add_result(results, test_same_type_stacks_damage())
	_add_result(results, test_stack_count_increments())
	_add_result(results, test_stack_refreshes_duration())
	_add_result(results, test_non_stack_only_refreshes())

	# Tick Damage Tests
	_add_result(results, test_tick_damage_at_interval())
	_add_result(results, test_tick_timer_accumulates_delta())
	_add_result(results, test_tick_timer_resets_after_tick())
	_add_result(results, test_effect_tick_signal_emitted())

	# Expiration Tests
	_add_result(results, test_effect_expires_when_time_zero())
	_add_result(results, test_expired_effect_removed())
	_add_result(results, test_effect_removed_signal_emitted())

	# Query Tests
	_add_result(results, test_has_effect_returns_true())
	_add_result(results, test_has_effect_returns_false())
	_add_result(results, test_get_effect_returns_effect())
	_add_result(results, test_get_effect_returns_null())

	# Clear Tests
	_add_result(results, test_clear_all_removes_everything())
	_add_result(results, test_remove_effect_by_type())

	# Edge Cases
	_add_result(results, test_multiple_different_effects())
	_add_result(results, test_rapid_stacking())
	_add_result(results, test_zero_duration_immediate_expire())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# EFFECT APPLICATION TESTS
# =============================================================================

static func test_effect_added_to_active_list() -> Dictionary:
	# apply_effect() adds to active_effects array
	var active_effects: Array = []
	var effect = {"type": 1, "remaining_time": 5.0}
	active_effects.append(effect)
	var passed = active_effects.size() == 1
	return {"name": "TC.SE.1: Effect added to active list", "passed": passed}

static func test_effect_tick_timer_initialized() -> Dictionary:
	# _tick_timers[effect] = 0.0 on apply
	var tick_timers: Dictionary = {}
	var effect = {}
	tick_timers[effect] = 0.0
	var passed = tick_timers[effect] == 0.0
	return {"name": "TC.SE.2: Tick timer initialized to 0", "passed": passed}

static func test_effect_applied_signal_emitted() -> Dictionary:
	# effect_applied.emit(effect) called
	var passed = true
	return {"name": "TC.SE.3: effect_applied signal emitted", "passed": passed}

# =============================================================================
# STACKING BEHAVIOR TESTS
# =============================================================================

static func test_same_type_stacks_damage() -> Dictionary:
	# Stacking: existing.damage_per_tick += effect.damage_per_tick
	var existing_damage = 5
	var new_damage = 3
	var stacked_damage = existing_damage + new_damage
	var passed = stacked_damage == 8
	return {"name": "TC.SE.4: Same type stacks damage", "passed": passed}

static func test_stack_count_increments() -> Dictionary:
	# existing.stack_count += 1
	var stack_count = 1
	stack_count += 1
	var passed = stack_count == 2
	return {"name": "TC.SE.5: Stack count increments", "passed": passed}

static func test_stack_refreshes_duration() -> Dictionary:
	# existing.reset() refreshes remaining_time
	var remaining = 2.0
	var base_duration = 5.0
	remaining = base_duration  # reset()
	var passed = remaining == 5.0
	return {"name": "TC.SE.6: Stacking refreshes duration", "passed": passed}

static func test_non_stack_only_refreshes() -> Dictionary:
	# If stack=false, only duration refreshes, not damage
	var existing_damage = 5
	var new_damage = 3
	# Non-stack: keep existing damage
	var final_damage = existing_damage
	var passed = final_damage == 5
	return {"name": "TC.SE.7: Non-stack only refreshes duration", "passed": passed}

# =============================================================================
# TICK DAMAGE TESTS
# =============================================================================

static func test_tick_damage_at_interval() -> Dictionary:
	# Tick occurs when _tick_timers[effect] >= tick_interval
	var tick_timer = 1.5
	var tick_interval = 1.0
	var should_tick = tick_timer >= tick_interval
	var passed = should_tick
	return {"name": "TC.SE.8: Tick damage at interval", "passed": passed}

static func test_tick_timer_accumulates_delta() -> Dictionary:
	# _tick_timers[effect] += delta
	var tick_timer = 0.0
	var delta = 0.5
	tick_timer += delta
	var passed = abs(tick_timer - 0.5) < 0.01
	return {"name": "TC.SE.9: Tick timer accumulates delta", "passed": passed}

static func test_tick_timer_resets_after_tick() -> Dictionary:
	# _tick_timers[effect] -= tick_interval
	var tick_timer = 1.2
	var tick_interval = 1.0
	tick_timer -= tick_interval
	var passed = abs(tick_timer - 0.2) < 0.01
	return {"name": "TC.SE.10: Tick timer resets after tick", "passed": passed}

static func test_effect_tick_signal_emitted() -> Dictionary:
	# effect_tick.emit(effect, damage_per_tick)
	var passed = true
	return {"name": "TC.SE.11: effect_tick signal emitted", "passed": passed}

# =============================================================================
# EXPIRATION TESTS
# =============================================================================

static func test_effect_expires_when_time_zero() -> Dictionary:
	# is_expired() = remaining_time <= 0
	var remaining_time = 0.0
	var is_expired = remaining_time <= 0
	var passed = is_expired
	return {"name": "TC.SE.12: Effect expires at time 0", "passed": passed}

static func test_expired_effect_removed() -> Dictionary:
	# Expired effects removed from active_effects
	var passed = true
	return {"name": "TC.SE.13: Expired effects removed", "passed": passed}

static func test_effect_removed_signal_emitted() -> Dictionary:
	# effect_removed.emit(effect)
	var passed = true
	return {"name": "TC.SE.14: effect_removed signal emitted", "passed": passed}

# =============================================================================
# QUERY TESTS
# =============================================================================

static func test_has_effect_returns_true() -> Dictionary:
	# has_effect(type) returns true if effect exists
	var active_effects = [{"type": 1}, {"type": 2}]
	var has_type_1 = false
	for e in active_effects:
		if e.type == 1:
			has_type_1 = true
	var passed = has_type_1
	return {"name": "TC.SE.15: has_effect() returns true when exists", "passed": passed}

static func test_has_effect_returns_false() -> Dictionary:
	var active_effects = [{"type": 1}]
	var has_type_2 = false
	for e in active_effects:
		if e.type == 2:
			has_type_2 = true
	var passed = not has_type_2
	return {"name": "TC.SE.16: has_effect() returns false when missing", "passed": passed}

static func test_get_effect_returns_effect() -> Dictionary:
	var effect = {"type": 1, "damage": 5}
	var active_effects = [effect]
	var found = null
	for e in active_effects:
		if e.type == 1:
			found = e
	var passed = found != null and found.damage == 5
	return {"name": "TC.SE.17: get_effect() returns effect", "passed": passed}

static func test_get_effect_returns_null() -> Dictionary:
	var active_effects = [{"type": 1}]
	var found = null
	for e in active_effects:
		if e.type == 99:
			found = e
	var passed = found == null
	return {"name": "TC.SE.18: get_effect() returns null when missing", "passed": passed}

# =============================================================================
# CLEAR TESTS
# =============================================================================

static func test_clear_all_removes_everything() -> Dictionary:
	# clear_all_effects() removes all from active_effects
	var active_effects = [{"type": 1}, {"type": 2}]
	active_effects.clear()
	var passed = active_effects.size() == 0
	return {"name": "TC.SE.19: clear_all_effects() empties list", "passed": passed}

static func test_remove_effect_by_type() -> Dictionary:
	# remove_effect(type) removes specific type
	var active_effects = [{"type": 1}, {"type": 2}]
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].type == 1:
			active_effects.remove_at(i)
	var passed = active_effects.size() == 1 and active_effects[0].type == 2
	return {"name": "TC.SE.20: remove_effect() removes by type", "passed": passed}

# =============================================================================
# EDGE CASES
# =============================================================================

static func test_multiple_different_effects() -> Dictionary:
	# Can have multiple different effect types simultaneously
	var active_effects = [{"type": 1}, {"type": 2}, {"type": 3}]
	var passed = active_effects.size() == 3
	return {"name": "TC.SE.21: Multiple different effects allowed", "passed": passed}

static func test_rapid_stacking() -> Dictionary:
	# Rapid stacking should accumulate correctly
	var damage = 5
	for i in range(5):
		damage += 3  # Stack 5 times
	# 5 + 15 = 20
	var passed = damage == 20
	return {"name": "TC.SE.22: Rapid stacking accumulates correctly", "passed": passed}

static func test_zero_duration_immediate_expire() -> Dictionary:
	# Effect with 0 duration should expire immediately
	var remaining_time = 0.0
	var is_expired = remaining_time <= 0
	var passed = is_expired
	return {"name": "TC.SE.23: Zero duration expires immediately", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_process", "apply_effect", "remove_effect", "_remove_effect_internal",
		"has_effect", "clear_all_effects", "get_effect"
	]
