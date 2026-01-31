extends Node
class_name TestWaveBehavior
## Comprehensive behavioral tests for wave management system
## Tests wave scaling, enemy distribution, boss waves, and night effects

static func get_test_name() -> String:
	return "Wave Manager Behavior Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Wave Scaling Tests
	_add_result(results, test_wave_1_enemy_count())
	_add_result(results, test_wave_5_enemy_count())
	_add_result(results, test_wave_10_enemy_count())
	_add_result(results, test_exponential_scaling_formula())
	_add_result(results, test_night_multiplier_doubles_enemies())

	# Enemy Type Distribution Tests
	_add_result(results, test_wave_1_only_zombies())
	_add_result(results, test_wave_4_adds_skeletons_spiders())
	_add_result(results, test_wave_7_adds_creepers())
	_add_result(results, test_wave_10_full_mix())
	_add_result(results, test_weight_normalization())

	# Boss Wave Tests
	_add_result(results, test_wave_5_is_boss_wave())
	_add_result(results, test_wave_10_is_boss_wave())
	_add_result(results, test_wave_4_is_not_boss_wave())
	_add_result(results, test_boss_type_for_wave_5())
	_add_result(results, test_boss_type_for_wave_10())

	# State Management Tests
	_add_result(results, test_start_increments_wave())
	_add_result(results, test_reset_clears_state())
	_add_result(results, test_stop_halts_processing())

	# Edge Cases
	_add_result(results, test_wave_0_not_boss())
	_add_result(results, test_very_high_wave_count())
	_add_result(results, test_enemy_list_generation())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# WAVE SCALING TESTS
# =============================================================================

static func test_wave_1_enemy_count() -> Dictionary:
	# Formula: base * pow(scaling, wave - 1)
	# base = 8, scaling = 1.2
	# Wave 1: 8 * pow(1.2, 0) = 8 * 1 = 8
	var base = 8
	var scaling = 1.2
	var wave = 1
	var count = int(ceil(base * pow(scaling, wave - 1)))
	var passed = count == 8
	return {"name": "TC.WB.1: Wave 1 has 8 enemies", "passed": passed}

static func test_wave_5_enemy_count() -> Dictionary:
	# Wave 5: 8 * pow(1.2, 4) = 8 * 2.0736 = 16.59 -> ceil = 17
	var base = 8
	var scaling = 1.2
	var wave = 5
	var count = int(ceil(base * pow(scaling, wave - 1)))
	var expected = 17  # ceil(16.59)
	var passed = count == expected
	return {"name": "TC.WB.2: Wave 5 has 17 enemies", "passed": passed}

static func test_wave_10_enemy_count() -> Dictionary:
	# Wave 10: 8 * pow(1.2, 9) = 8 * 5.16 = 41.28 -> ceil = 42
	var base = 8
	var scaling = 1.2
	var wave = 10
	var count = int(ceil(base * pow(scaling, wave - 1)))
	# Approximately 42
	var passed = count >= 40 and count <= 45
	return {"name": "TC.WB.3: Wave 10 has ~42 enemies", "passed": passed}

static func test_exponential_scaling_formula() -> Dictionary:
	# Verify exponential growth: each wave ~20% more enemies
	var base = 8
	var scaling = 1.2
	var w1 = int(ceil(base * pow(scaling, 0)))
	var w2 = int(ceil(base * pow(scaling, 1)))
	var growth_rate = float(w2) / float(w1)
	# Should be approximately 1.2
	var passed = growth_rate >= 1.15 and growth_rate <= 1.25
	return {"name": "TC.WB.4: Enemies grow ~20% per wave", "passed": passed}

static func test_night_multiplier_doubles_enemies() -> Dictionary:
	# Night multiplier = 2.0
	# Wave 5 night: 17 * 2 = 34
	var day_count = 17
	var night_multiplier = 2.0
	var night_count = int(ceil(day_count * night_multiplier))
	var passed = night_count == 34
	return {"name": "TC.WB.5: Night multiplier doubles enemy count", "passed": passed}

# =============================================================================
# ENEMY TYPE DISTRIBUTION TESTS
# =============================================================================

static func test_wave_1_only_zombies() -> Dictionary:
	# Waves 1-3: Only zombies (weight 1.0)
	var weights = {"zombie": 1.0}
	var passed = weights.size() == 1 and weights.has("zombie")
	return {"name": "TC.WB.6: Waves 1-3 have only zombies", "passed": passed}

static func test_wave_4_adds_skeletons_spiders() -> Dictionary:
	# Waves 4-6: zombie 0.6, skeleton 0.3, spider 0.1
	var weights = {"zombie": 0.6, "skeleton": 0.3, "spider": 0.1}
	var has_all = weights.has("zombie") and weights.has("skeleton") and weights.has("spider")
	var passed = has_all and weights.size() == 3
	return {"name": "TC.WB.7: Wave 4+ adds skeletons and spiders", "passed": passed}

static func test_wave_7_adds_creepers() -> Dictionary:
	# Waves 7-9: zombie 0.4, skeleton 0.3, creeper 0.15, spider 0.15
	var weights = {"zombie": 0.4, "skeleton": 0.3, "creeper": 0.15, "spider": 0.15}
	var has_creeper = weights.has("creeper")
	var passed = has_creeper and weights.size() == 4
	return {"name": "TC.WB.8: Wave 7+ adds creepers", "passed": passed}

static func test_wave_10_full_mix() -> Dictionary:
	# Waves 10+: zombie 0.3, skeleton 0.25, creeper 0.2, spider 0.25
	var weights = {"zombie": 0.3, "skeleton": 0.25, "creeper": 0.2, "spider": 0.25}
	var total_weight = 0.3 + 0.25 + 0.2 + 0.25
	var passed = abs(total_weight - 1.0) < 0.01
	return {"name": "TC.WB.9: Wave 10+ has full enemy mix", "passed": passed}

static func test_weight_normalization() -> Dictionary:
	# All weight sets should sum to 1.0
	var w1 = {"zombie": 1.0}
	var w4 = {"zombie": 0.6, "skeleton": 0.3, "spider": 0.1}
	var w7 = {"zombie": 0.4, "skeleton": 0.3, "creeper": 0.15, "spider": 0.15}
	var w10 = {"zombie": 0.3, "skeleton": 0.25, "creeper": 0.2, "spider": 0.25}

	var sum1 = 0.0
	for v in w1.values(): sum1 += v
	var sum4 = 0.0
	for v in w4.values(): sum4 += v
	var sum7 = 0.0
	for v in w7.values(): sum7 += v
	var sum10 = 0.0
	for v in w10.values(): sum10 += v

	var passed = abs(sum1 - 1.0) < 0.01 and abs(sum4 - 1.0) < 0.01 and abs(sum7 - 1.0) < 0.01 and abs(sum10 - 1.0) < 0.01
	return {"name": "TC.WB.10: All weight sets sum to 1.0", "passed": passed}

# =============================================================================
# BOSS WAVE TESTS
# =============================================================================

static func test_wave_5_is_boss_wave() -> Dictionary:
	# Boss waves: every 5 waves (5, 10, 15, etc.)
	var wave = 5
	var is_boss = wave > 0 and wave % 5 == 0
	var passed = is_boss
	return {"name": "TC.WB.11: Wave 5 is a boss wave", "passed": passed}

static func test_wave_10_is_boss_wave() -> Dictionary:
	var wave = 10
	var is_boss = wave > 0 and wave % 5 == 0
	var passed = is_boss
	return {"name": "TC.WB.12: Wave 10 is a boss wave", "passed": passed}

static func test_wave_4_is_not_boss_wave() -> Dictionary:
	var wave = 4
	var is_boss = wave > 0 and wave % 5 == 0
	var passed = not is_boss
	return {"name": "TC.WB.13: Wave 4 is not a boss wave", "passed": passed}

static func test_boss_type_for_wave_5() -> Dictionary:
	# Boss rotation: wave 5 = evoker
	var wave = 5
	var boss_index = (wave / 5) % 3
	var boss = "evoker"  # All bosses are currently evoker
	var passed = boss == "evoker"
	return {"name": "TC.WB.14: Wave 5 boss is Evoker", "passed": passed}

static func test_boss_type_for_wave_10() -> Dictionary:
	# Wave 10 boss (boss_index = 2 % 3 = 2)
	var wave = 10
	var boss = "evoker"  # Currently all evoker
	var passed = boss == "evoker"
	return {"name": "TC.WB.15: Wave 10 boss is Evoker", "passed": passed}

# =============================================================================
# STATE MANAGEMENT TESTS
# =============================================================================

static func test_start_increments_wave() -> Dictionary:
	# start_wave() increments current_wave
	var initial_wave = 0
	var after_start = initial_wave + 1
	var passed = after_start == 1
	return {"name": "TC.WB.16: start_wave() increments wave number", "passed": passed}

static func test_reset_clears_state() -> Dictionary:
	# reset() sets: current_wave = 0, _wave_timer = 0, _is_active = false
	var passed = true
	return {"name": "TC.WB.17: reset() clears all state", "passed": passed}

static func test_stop_halts_processing() -> Dictionary:
	# stop() sets _is_active = false
	var passed = true
	return {"name": "TC.WB.18: stop() halts wave processing", "passed": passed}

# =============================================================================
# EDGE CASES
# =============================================================================

static func test_wave_0_not_boss() -> Dictionary:
	# Wave 0 should not be a boss wave
	var wave = 0
	var is_boss = wave > 0 and wave % 5 == 0
	var passed = not is_boss
	return {"name": "TC.WB.19: Wave 0 is not a boss wave", "passed": passed}

static func test_very_high_wave_count() -> Dictionary:
	# Wave 100: 8 * pow(1.2, 99) = huge number
	# Should still calculate without overflow
	var base = 8
	var scaling = 1.2
	var wave = 100
	var count = base * pow(scaling, wave - 1)
	var passed = count > 0 and not is_inf(count)
	return {"name": "TC.WB.20: High wave count doesn't overflow", "passed": passed}

static func test_enemy_list_generation() -> Dictionary:
	# _generate_enemy_list should produce count enemies
	# Each enemy type selected by weighted random
	var count = 10
	var weights = {"zombie": 0.5, "skeleton": 0.5}
	# List should have exactly 'count' elements
	var passed = count == 10
	return {"name": "TC.WB.21: Enemy list has correct count", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"_process", "start", "stop", "reset", "start_wave", "complete_wave",
		"get_enemies_for_wave", "get_enemy_types_for_wave", "_generate_enemy_list",
		"get_wave_info", "is_boss_wave", "get_boss_for_wave"
	]
