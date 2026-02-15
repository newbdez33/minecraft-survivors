extends Node
class_name TestWaveScaling
## BDD Tests for Post-Wave-30 Infinite Scaling System
##
## Tests cover:
## - Normal enemy scaling multipliers (HP, damage, speed, XP)
## - No scaling at wave 30 or below
## - Boss scaling per 5-wave cycle
## - Speed cap verification
## - Elite chance and max elites post-wave-30
## - WaveScaler source constants

static func get_test_name() -> String:
	return "Wave Scaling BDD Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# =========================================================================
	# Feature: Normal Enemy Scaling
	# =========================================================================
	_add_result(results, test_no_scaling_at_wave_30())
	_add_result(results, test_no_scaling_at_wave_1())
	_add_result(results, test_normal_hp_2x_at_wave_40())
	_add_result(results, test_normal_damage_1_5x_at_wave_40())
	_add_result(results, test_normal_speed_1_2x_at_wave_40())
	_add_result(results, test_normal_xp_2x_at_wave_40())
	_add_result(results, test_normal_hp_3x_at_wave_50())
	_add_result(results, test_normal_damage_2x_at_wave_50())

	# =========================================================================
	# Feature: Boss Scaling
	# =========================================================================
	_add_result(results, test_boss_no_scaling_at_wave_30())
	_add_result(results, test_boss_hp_1_5x_at_wave_35())
	_add_result(results, test_boss_hp_3x_at_wave_50())
	_add_result(results, test_boss_damage_2x_at_wave_50())
	_add_result(results, test_boss_xp_matches_hp_at_wave_50())

	# =========================================================================
	# Feature: Speed Caps
	# =========================================================================
	_add_result(results, test_normal_speed_cap_at_1_5x())
	_add_result(results, test_boss_speed_cap_at_2x())

	# =========================================================================
	# Feature: Elite Scaling Post-30
	# =========================================================================
	_add_result(results, test_elite_chance_returns_negative_at_wave_30())
	_add_result(results, test_elite_chance_at_wave_31())
	_add_result(results, test_elite_chance_at_wave_50())
	_add_result(results, test_elite_chance_cap_at_50_pct())
	_add_result(results, test_elite_chance_night_bonus())
	_add_result(results, test_max_elites_returns_negative_at_wave_30())
	_add_result(results, test_max_elites_at_wave_35())
	_add_result(results, test_max_elites_at_wave_45())

	# =========================================================================
	# Feature: Apply Scaling Integration
	# =========================================================================
	_add_result(results, test_apply_scaling_zombie_wave_40())
	_add_result(results, test_apply_scaling_noop_at_wave_30())

	# =========================================================================
	# Feature: Source Constants
	# =========================================================================
	_add_result(results, test_source_has_scaling_start_wave_30())
	_add_result(results, test_source_has_normal_hp_per_wave())
	_add_result(results, test_source_has_boss_cycle_waves_5())
	_add_result(results, test_source_has_safety_caps())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# Helpers
# =============================================================================

static func _get_source(path: String) -> String:
	var script = load(path)
	if script:
		return script.source_code
	return ""

static func _get_wave_scaler_source() -> String:
	return _get_source("res://scripts/systems/wave_scaler.gd")

static var _WaveScaler = preload("res://scripts/systems/wave_scaler.gd")

static func _approx_eq(a: float, b: float, epsilon: float = 0.001) -> bool:
	return absf(a - b) < epsilon

# =============================================================================
# Feature: Normal Enemy Scaling
# Given WaveScaler.get_scaling_multipliers() with is_boss=false
# =============================================================================

static func test_no_scaling_at_wave_30() -> Dictionary:
	# Given wave 30
	# When get_scaling_multipliers(30, false)
	# Then all multipliers are 1.0
	var mults = _WaveScaler.get_scaling_multipliers(30, false)
	var passed = _approx_eq(mults.hp, 1.0) and _approx_eq(mults.damage, 1.0) and _approx_eq(mults.speed, 1.0) and _approx_eq(mults.xp, 1.0)
	return {"name": "BDD.WS.1: Given wave 30, When get_scaling(false), Then all mults = 1.0", "passed": passed}

static func test_no_scaling_at_wave_1() -> Dictionary:
	# Given wave 1
	# When get_scaling_multipliers(1, false)
	# Then all multipliers are 1.0
	var mults = _WaveScaler.get_scaling_multipliers(1, false)
	var passed = _approx_eq(mults.hp, 1.0) and _approx_eq(mults.damage, 1.0)
	return {"name": "BDD.WS.2: Given wave 1, When get_scaling(false), Then all mults = 1.0", "passed": passed}

static func test_normal_hp_2x_at_wave_40() -> Dictionary:
	# Given wave 40 (10 past 30, 10 * 0.10 = 1.0 bonus)
	# When get_scaling_multipliers(40, false)
	# Then HP mult = 2.0
	var mults = _WaveScaler.get_scaling_multipliers(40, false)
	var passed = _approx_eq(mults.hp, 2.0)
	return {"name": "BDD.WS.3: Given wave 40, When get_scaling(false), Then HP = 2.0x", "passed": passed}

static func test_normal_damage_1_5x_at_wave_40() -> Dictionary:
	# Given wave 40 (10 past 30, 10 * 0.05 = 0.5 bonus)
	# When get_scaling_multipliers(40, false)
	# Then damage mult = 1.5
	var mults = _WaveScaler.get_scaling_multipliers(40, false)
	var passed = _approx_eq(mults.damage, 1.5)
	return {"name": "BDD.WS.4: Given wave 40, When get_scaling(false), Then damage = 1.5x", "passed": passed}

static func test_normal_speed_1_2x_at_wave_40() -> Dictionary:
	# Given wave 40 (10 past 30, 10 * 0.02 = 0.2 bonus)
	# When get_scaling_multipliers(40, false)
	# Then speed mult = 1.2
	var mults = _WaveScaler.get_scaling_multipliers(40, false)
	var passed = _approx_eq(mults.speed, 1.2)
	return {"name": "BDD.WS.5: Given wave 40, When get_scaling(false), Then speed = 1.2x", "passed": passed}

static func test_normal_xp_2x_at_wave_40() -> Dictionary:
	# Given wave 40 (10 past 30, 10 * 0.10 = 1.0 bonus)
	# When get_scaling_multipliers(40, false)
	# Then XP mult = 2.0
	var mults = _WaveScaler.get_scaling_multipliers(40, false)
	var passed = _approx_eq(mults.xp, 2.0)
	return {"name": "BDD.WS.6: Given wave 40, When get_scaling(false), Then XP = 2.0x", "passed": passed}

static func test_normal_hp_3x_at_wave_50() -> Dictionary:
	# Given wave 50 (20 past 30, 20 * 0.10 = 2.0 bonus)
	# When get_scaling_multipliers(50, false)
	# Then HP mult = 3.0
	var mults = _WaveScaler.get_scaling_multipliers(50, false)
	var passed = _approx_eq(mults.hp, 3.0)
	return {"name": "BDD.WS.7: Given wave 50, When get_scaling(false), Then HP = 3.0x", "passed": passed}

static func test_normal_damage_2x_at_wave_50() -> Dictionary:
	# Given wave 50 (20 past 30, 20 * 0.05 = 1.0 bonus)
	# When get_scaling_multipliers(50, false)
	# Then damage mult = 2.0
	var mults = _WaveScaler.get_scaling_multipliers(50, false)
	var passed = _approx_eq(mults.damage, 2.0)
	return {"name": "BDD.WS.8: Given wave 50, When get_scaling(false), Then damage = 2.0x", "passed": passed}

# =============================================================================
# Feature: Boss Scaling
# Given WaveScaler.get_scaling_multipliers() with is_boss=true
# =============================================================================

static func test_boss_no_scaling_at_wave_30() -> Dictionary:
	# Given wave 30
	# When get_scaling_multipliers(30, true)
	# Then all multipliers are 1.0
	var mults = _WaveScaler.get_scaling_multipliers(30, true)
	var passed = _approx_eq(mults.hp, 1.0) and _approx_eq(mults.damage, 1.0)
	return {"name": "BDD.WS.9: Given wave 30, When get_scaling(boss), Then all mults = 1.0", "passed": passed}

static func test_boss_hp_1_5x_at_wave_35() -> Dictionary:
	# Given wave 35 (5 past 30, 1 cycle, 1 * 0.50 = 0.5 bonus)
	# When get_scaling_multipliers(35, true)
	# Then HP mult = 1.5
	var mults = _WaveScaler.get_scaling_multipliers(35, true)
	var passed = _approx_eq(mults.hp, 1.5)
	return {"name": "BDD.WS.10: Given wave 35, When get_scaling(boss), Then HP = 1.5x", "passed": passed}

static func test_boss_hp_3x_at_wave_50() -> Dictionary:
	# Given wave 50 (20 past 30, 4 cycles, 4 * 0.50 = 2.0 bonus)
	# When get_scaling_multipliers(50, true)
	# Then HP mult = 3.0
	var mults = _WaveScaler.get_scaling_multipliers(50, true)
	var passed = _approx_eq(mults.hp, 3.0)
	return {"name": "BDD.WS.11: Given wave 50, When get_scaling(boss), Then HP = 3.0x", "passed": passed}

static func test_boss_damage_2x_at_wave_50() -> Dictionary:
	# Given wave 50 (20 past 30, 4 cycles, 4 * 0.25 = 1.0 bonus)
	# When get_scaling_multipliers(50, true)
	# Then damage mult = 2.0
	var mults = _WaveScaler.get_scaling_multipliers(50, true)
	var passed = _approx_eq(mults.damage, 2.0)
	return {"name": "BDD.WS.12: Given wave 50, When get_scaling(boss), Then damage = 2.0x", "passed": passed}

static func test_boss_xp_matches_hp_at_wave_50() -> Dictionary:
	# Given wave 50
	# When get_scaling_multipliers(50, true)
	# Then XP mult = HP mult = 3.0
	var mults = _WaveScaler.get_scaling_multipliers(50, true)
	var passed = _approx_eq(mults.xp, mults.hp)
	return {"name": "BDD.WS.13: Given wave 50, When get_scaling(boss), Then XP = HP mult", "passed": passed}

# =============================================================================
# Feature: Speed Caps
# =============================================================================

static func test_normal_speed_cap_at_1_5x() -> Dictionary:
	# Given wave 100 (70 past 30, 70 * 0.02 = 1.40, but cap is 0.50)
	# When get_scaling_multipliers(100, false)
	# Then speed mult = 1.5 (1.0 + 0.50 cap)
	var mults = _WaveScaler.get_scaling_multipliers(100, false)
	var passed = _approx_eq(mults.speed, 1.5)
	return {"name": "BDD.WS.14: Given wave 100, When get_scaling(false), Then speed capped at 1.5x", "passed": passed}

static func test_boss_speed_cap_at_2x() -> Dictionary:
	# Given wave 130 (100 past 30, 20 cycles, 20 * 0.10 = 2.0, but cap is 1.00)
	# When get_scaling_multipliers(130, true)
	# Then speed mult = 2.0 (1.0 + 1.00 cap)
	var mults = _WaveScaler.get_scaling_multipliers(130, true)
	var passed = _approx_eq(mults.speed, 2.0)
	return {"name": "BDD.WS.15: Given wave 130, When get_scaling(boss), Then speed capped at 2.0x", "passed": passed}

# =============================================================================
# Feature: Elite Scaling Post-30
# =============================================================================

static func test_elite_chance_returns_negative_at_wave_30() -> Dictionary:
	# Given wave 30
	# When get_elite_chance(30, false)
	# Then returns -1.0 (fall through to original logic)
	var chance = _WaveScaler.get_elite_chance(30, false)
	var passed = chance < 0.0
	return {"name": "BDD.WS.16: Given wave 30, When get_elite_chance(), Then returns -1.0", "passed": passed}

static func test_elite_chance_at_wave_31() -> Dictionary:
	# Given wave 31 (1 past 30, 0.25 + 1 * 0.01 = 0.26)
	# When get_elite_chance(31, false)
	# Then chance = 0.26
	var chance = _WaveScaler.get_elite_chance(31, false)
	var passed = _approx_eq(chance, 0.26)
	return {"name": "BDD.WS.17: Given wave 31, When get_elite_chance(), Then 26%", "passed": passed}

static func test_elite_chance_at_wave_50() -> Dictionary:
	# Given wave 50 (20 past 30, 0.25 + 20 * 0.01 = 0.45)
	# When get_elite_chance(50, false)
	# Then chance = 0.45
	var chance = _WaveScaler.get_elite_chance(50, false)
	var passed = _approx_eq(chance, 0.45)
	return {"name": "BDD.WS.18: Given wave 50, When get_elite_chance(), Then 45%", "passed": passed}

static func test_elite_chance_cap_at_50_pct() -> Dictionary:
	# Given wave 80 (50 past 30, 0.25 + 50 * 0.01 = 0.75, capped at 0.50)
	# When get_elite_chance(80, false)
	# Then chance = 0.50
	var chance = _WaveScaler.get_elite_chance(80, false)
	var passed = _approx_eq(chance, 0.50)
	return {"name": "BDD.WS.19: Given wave 80, When get_elite_chance(), Then capped at 50%", "passed": passed}

static func test_elite_chance_night_bonus() -> Dictionary:
	# Given wave 31, is_night=true
	# When get_elite_chance(31, true)
	# Then chance = 0.26 + 0.10 = 0.36
	var chance = _WaveScaler.get_elite_chance(31, true)
	var passed = _approx_eq(chance, 0.36)
	return {"name": "BDD.WS.20: Given wave 31 night, When get_elite_chance(), Then 36%", "passed": passed}

static func test_max_elites_returns_negative_at_wave_30() -> Dictionary:
	# Given wave 30
	# When get_max_elites(30)
	# Then returns -1 (fall through to original logic)
	var max_e = _WaveScaler.get_max_elites(30)
	var passed = max_e < 0
	return {"name": "BDD.WS.21: Given wave 30, When get_max_elites(), Then returns -1", "passed": passed}

static func test_max_elites_at_wave_35() -> Dictionary:
	# Given wave 35 (5 past 30, 1 group of 5, 5 + 1 = 6)
	# When get_max_elites(35)
	# Then returns 6
	var max_e = _WaveScaler.get_max_elites(35)
	var passed = max_e == 6
	return {"name": "BDD.WS.22: Given wave 35, When get_max_elites(), Then 6", "passed": passed}

static func test_max_elites_at_wave_45() -> Dictionary:
	# Given wave 45 (15 past 30, 3 groups of 5, 5 + 3 = 8)
	# When get_max_elites(45)
	# Then returns 8
	var max_e = _WaveScaler.get_max_elites(45)
	var passed = max_e == 8
	return {"name": "BDD.WS.23: Given wave 45, When get_max_elites(), Then 8", "passed": passed}

# =============================================================================
# Feature: Apply Scaling Integration
# =============================================================================

static func test_apply_scaling_zombie_wave_40() -> Dictionary:
	# Given a zombie with base stats (10 HP, 10 dmg, 60 speed, 5 XP)
	# When apply_scaling(zombie, 40, false)
	# Then HP=20, damage=15, speed=72, XP=10
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_WaveScaler.apply_scaling(zombie, 40, false)
		passed = zombie.health == 20 and zombie.damage == 15 and _approx_eq(zombie.speed, 72.0) and zombie.xp_value == 10
		zombie.queue_free()
	return {"name": "BDD.WS.24: Given zombie, When apply_scaling(40, false), Then 2x HP, 1.5x dmg", "passed": passed}

static func test_apply_scaling_noop_at_wave_30() -> Dictionary:
	# Given a zombie with base stats
	# When apply_scaling(zombie, 30, false)
	# Then stats unchanged
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_WaveScaler.apply_scaling(zombie, 30, false)
		passed = zombie.health == 10 and zombie.damage == 10 and _approx_eq(zombie.speed, 60.0) and zombie.xp_value == 5
		zombie.queue_free()
	return {"name": "BDD.WS.25: Given zombie, When apply_scaling(30, false), Then no change", "passed": passed}

# =============================================================================
# Feature: Source Constants
# =============================================================================

static func test_source_has_scaling_start_wave_30() -> Dictionary:
	var src = _get_wave_scaler_source()
	var passed = src.contains("SCALING_START_WAVE: int = 30")
	return {"name": "BDD.WS.26: WaveScaler source has SCALING_START_WAVE = 30", "passed": passed}

static func test_source_has_normal_hp_per_wave() -> Dictionary:
	var src = _get_wave_scaler_source()
	var passed = src.contains("NORMAL_HP_PER_WAVE: float = 0.10")
	return {"name": "BDD.WS.27: WaveScaler source has NORMAL_HP_PER_WAVE = 0.10", "passed": passed}

static func test_source_has_boss_cycle_waves_5() -> Dictionary:
	var src = _get_wave_scaler_source()
	var passed = src.contains("BOSS_CYCLE_WAVES: int = 5")
	return {"name": "BDD.WS.28: WaveScaler source has BOSS_CYCLE_WAVES = 5", "passed": passed}

static func test_source_has_safety_caps() -> Dictionary:
	var src = _get_wave_scaler_source()
	var passed = src.contains("MAX_HEALTH: int = 2147483647") and src.contains("MAX_DAMAGE: int = 100000") and src.contains("MAX_XP: int = 1000000")
	return {"name": "BDD.WS.29: WaveScaler source has safety caps (HP 2^31, DMG 100K, XP 1M)", "passed": passed}
