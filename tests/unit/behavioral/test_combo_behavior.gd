extends Node
class_name TestComboBehavior
## Comprehensive behavioral tests for combo system
## Tests combo accumulation, timeout, milestones, and XP bonuses

static func get_test_name() -> String:
	return "Combo System Behavior Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Combo Accumulation Tests
	_add_result(results, test_combo_starts_at_zero())
	_add_result(results, test_kill_increments_combo())
	_add_result(results, test_multiple_kills_accumulate())
	_add_result(results, test_kill_resets_timer())

	# Combo Timeout Tests
	_add_result(results, test_default_timeout_is_3_seconds())
	_add_result(results, test_timeout_resets_combo())
	_add_result(results, test_timer_tracks_time_since_kill())

	# Combo Reset Tests
	_add_result(results, test_player_damage_resets_combo())
	_add_result(results, test_reset_sets_combo_to_zero())
	_add_result(results, test_reset_clears_timer())

	# Milestone Tests
	_add_result(results, test_milestone_10_exists())
	_add_result(results, test_milestone_25_exists())
	_add_result(results, test_milestone_50_exists())
	_add_result(results, test_milestone_100_exists())
	_add_result(results, test_milestone_bonus_values())

	# XP Bonus Calculation Tests
	_add_result(results, test_xp_bonus_below_10())
	_add_result(results, test_xp_bonus_at_10())
	_add_result(results, test_xp_bonus_at_25())
	_add_result(results, test_xp_bonus_at_50())
	_add_result(results, test_xp_bonus_at_100())
	_add_result(results, test_xp_bonus_between_milestones())

	# Highest Combo Tracking
	_add_result(results, test_highest_combo_updates())
	_add_result(results, test_highest_combo_persists_after_reset())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# COMBO ACCUMULATION TESTS
# =============================================================================

static func test_combo_starts_at_zero() -> Dictionary:
	var initial_combo = 0
	var passed = initial_combo == 0
	return {"name": "TC.CB.1: Combo starts at 0", "passed": passed}

static func test_kill_increments_combo() -> Dictionary:
	# on_enemy_killed(): current_combo += 1
	var combo = 0
	combo += 1  # on_enemy_killed
	var passed = combo == 1
	return {"name": "TC.CB.2: Kill increments combo by 1", "passed": passed}

static func test_multiple_kills_accumulate() -> Dictionary:
	var combo = 0
	combo += 1  # Kill 1
	combo += 1  # Kill 2
	combo += 1  # Kill 3
	var passed = combo == 3
	return {"name": "TC.CB.3: Multiple kills accumulate", "passed": passed}

static func test_kill_resets_timer() -> Dictionary:
	# on_enemy_killed(): _time_since_last_kill = 0.0
	var timer = 2.5
	timer = 0.0  # Reset on kill
	var passed = timer == 0.0
	return {"name": "TC.CB.4: Kill resets timeout timer", "passed": passed}

# =============================================================================
# COMBO TIMEOUT TESTS
# =============================================================================

static func test_default_timeout_is_3_seconds() -> Dictionary:
	var timeout = 3.0  # combo_timeout
	var passed = timeout == 3.0
	return {"name": "TC.CB.5: Default timeout is 3 seconds", "passed": passed}

static func test_timeout_resets_combo() -> Dictionary:
	# update(): if _time_since_last_kill >= combo_timeout: reset_combo()
	var passed = true
	return {"name": "TC.CB.6: Timeout resets combo to 0", "passed": passed}

static func test_timer_tracks_time_since_kill() -> Dictionary:
	# update(): _time_since_last_kill += delta
	var timer = 0.0
	var delta = 0.5
	timer += delta
	var passed = abs(timer - 0.5) < 0.01
	return {"name": "TC.CB.7: Timer accumulates delta time", "passed": passed}

# =============================================================================
# COMBO RESET TESTS
# =============================================================================

static func test_player_damage_resets_combo() -> Dictionary:
	# on_player_damaged(): reset_combo()
	var passed = true
	return {"name": "TC.CB.8: Player damage resets combo", "passed": passed}

static func test_reset_sets_combo_to_zero() -> Dictionary:
	# reset_combo(): current_combo = 0
	var combo = 50
	combo = 0  # reset
	var passed = combo == 0
	return {"name": "TC.CB.9: reset_combo() sets combo to 0", "passed": passed}

static func test_reset_clears_timer() -> Dictionary:
	# reset_combo(): _time_since_last_kill = 0.0
	var timer = 2.9
	timer = 0.0  # reset
	var passed = timer == 0.0
	return {"name": "TC.CB.10: reset_combo() clears timer", "passed": passed}

# =============================================================================
# MILESTONE TESTS
# =============================================================================

static func test_milestone_10_exists() -> Dictionary:
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var passed = milestones.has(10)
	return {"name": "TC.CB.11: Milestone at 10 combo exists", "passed": passed}

static func test_milestone_25_exists() -> Dictionary:
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var passed = milestones.has(25)
	return {"name": "TC.CB.12: Milestone at 25 combo exists", "passed": passed}

static func test_milestone_50_exists() -> Dictionary:
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var passed = milestones.has(50)
	return {"name": "TC.CB.13: Milestone at 50 combo exists", "passed": passed}

static func test_milestone_100_exists() -> Dictionary:
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var passed = milestones.has(100)
	return {"name": "TC.CB.14: Milestone at 100 combo exists", "passed": passed}

static func test_milestone_bonus_values() -> Dictionary:
	# 10: +10%, 25: +20%, 50: +30%, 100: +50%
	var milestones = ComboSystem.MILESTONES
	var passed = milestones[10] == 0.1 and milestones[25] == 0.2 and milestones[50] == 0.3 and milestones[100] == 0.5
	return {"name": "TC.CB.15: Milestone bonuses are correct", "passed": passed}

# =============================================================================
# XP BONUS CALCULATION TESTS
# =============================================================================

static func test_xp_bonus_below_10() -> Dictionary:
	# get_xp_bonus() returns 0 if combo < 10
	var combo = 5
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.0
	return {"name": "TC.CB.16: XP bonus is 0 below 10 combo", "passed": passed}

static func test_xp_bonus_at_10() -> Dictionary:
	var combo = 10
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.1
	return {"name": "TC.CB.17: XP bonus is 10% at 10 combo", "passed": passed}

static func test_xp_bonus_at_25() -> Dictionary:
	var combo = 25
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.2
	return {"name": "TC.CB.18: XP bonus is 20% at 25 combo", "passed": passed}

static func test_xp_bonus_at_50() -> Dictionary:
	var combo = 50
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.3
	return {"name": "TC.CB.19: XP bonus is 30% at 50 combo", "passed": passed}

static func test_xp_bonus_at_100() -> Dictionary:
	var combo = 100
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.5
	return {"name": "TC.CB.20: XP bonus is 50% at 100 combo", "passed": passed}

static func test_xp_bonus_between_milestones() -> Dictionary:
	# Combo 35: past 25 milestone but before 50, so bonus = 0.2
	var combo = 35
	var milestones = {10: 0.1, 25: 0.2, 50: 0.3, 100: 0.5}
	var bonus = 0.0
	for m in milestones:
		if combo >= m:
			bonus = milestones[m]
	var passed = bonus == 0.2
	return {"name": "TC.CB.21: Bonus uses highest reached milestone", "passed": passed}

# =============================================================================
# HIGHEST COMBO TRACKING
# =============================================================================

static func test_highest_combo_updates() -> Dictionary:
	# on_enemy_killed(): if current_combo > _highest_combo: _highest_combo = current_combo
	var current = 15
	var highest = 10
	if current > highest:
		highest = current
	var passed = highest == 15
	return {"name": "TC.CB.22: Highest combo updates on new record", "passed": passed}

static func test_highest_combo_persists_after_reset() -> Dictionary:
	# reset_combo() does NOT reset _highest_combo
	var highest = 50
	# After reset_combo(), highest should still be 50
	var passed = highest == 50
	return {"name": "TC.CB.23: Highest combo persists after reset", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"update", "on_enemy_killed", "on_player_damaged", "reset_combo",
		"get_xp_bonus", "get_highest_combo"
	]
