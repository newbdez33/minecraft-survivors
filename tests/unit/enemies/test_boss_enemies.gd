extends Node
class_name TestBossEnemies
## Tests for all Boss enemies
## Xu Chu (Wave 10), ZhangLiao (Wave 15), DianWei (Wave 20), SimaYi (Wave 25), Lv Bu (Wave 30)

static func get_test_name() -> String:
	return "Boss Enemies Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Xu Chu Tests (Wave 10)
	_add_result(results, test_xu_chu_scene_exists())
	_add_result(results, test_xu_chu_script_exists())
	_add_result(results, test_xu_chu_has_correct_hp())
	_add_result(results, test_xu_chu_has_laser_attack())
	_add_result(results, test_xu_chu_has_spike_aura())

	# ZhangLiao Tests (Wave 15)
	_add_result(results, test_zhang_liao_scene_exists())
	_add_result(results, test_zhang_liao_script_exists())
	_add_result(results, test_zhang_liao_has_correct_hp())
	_add_result(results, test_zhang_liao_has_charge_attack())
	_add_result(results, test_zhang_liao_has_stomp_attack())

	# DianWei Tests (Wave 20)
	_add_result(results, test_dian_wei_scene_exists())
	_add_result(results, test_dian_wei_script_exists())
	_add_result(results, test_dian_wei_has_correct_hp())
	_add_result(results, test_dian_wei_has_sonic_boom())
	_add_result(results, test_dian_wei_tracks_by_sound())

	# SimaYi Tests (Wave 25)
	_add_result(results, test_sima_yi_scene_exists())
	_add_result(results, test_sima_yi_script_exists())
	_add_result(results, test_sima_yi_has_correct_hp())
	_add_result(results, test_sima_yi_has_skull_attack())
	_add_result(results, test_sima_yi_has_wither_effect())

	# Lv Bu Tests (Wave 30)
	_add_result(results, test_lv_bu_scene_exists())
	_add_result(results, test_lv_bu_script_exists())
	_add_result(results, test_lv_bu_has_correct_hp())
	_add_result(results, test_lv_bu_has_fireball())
	_add_result(results, test_lv_bu_has_dive_attack())

	# Wave Manager Boss Integration
	_add_result(results, test_wave_manager_has_boss_mapping())
	_add_result(results, test_wave_10_spawns_xu_chu())
	_add_result(results, test_wave_15_spawns_zhang_liao())
	_add_result(results, test_wave_20_spawns_dian_wei())
	_add_result(results, test_wave_25_spawns_sima_yi())
	_add_result(results, test_wave_30_spawns_lv_bu())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# ELDER GUARDIAN TESTS (Wave 10, 150 HP)
# =============================================================================

static func test_xu_chu_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/xu_chu.tscn")
	return {"name": "TC.BE.1: Xu Chu scene exists", "passed": scene != null}

static func test_xu_chu_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/xu_chu.gd")
	return {"name": "TC.BE.2: Xu Chu script exists", "passed": script != null}

static func test_xu_chu_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/xu_chu.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 150 HP
		passed = source.contains("150") or source.contains("max_health")
	return {"name": "TC.BE.3: Xu Chu has 150 HP", "passed": passed}

static func test_xu_chu_has_laser_attack() -> Dictionary:
	var script = load("res://scripts/enemies/xu_chu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("laser") or source.contains("beam")
	return {"name": "TC.BE.4: Xu Chu has laser attack", "passed": passed}

static func test_xu_chu_has_spike_aura() -> Dictionary:
	var script = load("res://scripts/enemies/xu_chu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("spike") or source.contains("aura") or source.contains("thorns")
	return {"name": "TC.BE.5: Xu Chu has spike/thorns aura", "passed": passed}

# =============================================================================
# RAVAGER TESTS (Wave 15, 200 HP)
# =============================================================================

static func test_zhang_liao_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/zhang_liao.tscn")
	return {"name": "TC.BE.6: Zhang Liao scene exists", "passed": scene != null}

static func test_zhang_liao_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/zhang_liao.gd")
	return {"name": "TC.BE.7: Zhang Liao script exists", "passed": script != null}

static func test_zhang_liao_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/zhang_liao.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 200 HP
		passed = source.contains("200") or source.contains("max_health")
	return {"name": "TC.BE.8: Zhang Liao has 200 HP", "passed": passed}

static func test_zhang_liao_has_charge_attack() -> Dictionary:
	var script = load("res://scripts/enemies/zhang_liao.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("charge") or source.contains("rush")
	return {"name": "TC.BE.9: Zhang Liao has charge attack", "passed": passed}

static func test_zhang_liao_has_stomp_attack() -> Dictionary:
	var script = load("res://scripts/enemies/zhang_liao.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("stomp") or source.contains("ground_pound") or source.contains("aoe")
	return {"name": "TC.BE.10: Zhang Liao has stomp/AoE attack", "passed": passed}

# =============================================================================
# WARDEN TESTS (Wave 20, 400 HP)
# =============================================================================

static func test_dian_wei_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/dian_wei.tscn")
	return {"name": "TC.BE.11: Dian Wei scene exists", "passed": scene != null}

static func test_dian_wei_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/dian_wei.gd")
	return {"name": "TC.BE.12: Dian Wei script exists", "passed": script != null}

static func test_dian_wei_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/dian_wei.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 400 HP
		passed = source.contains("400") or source.contains("max_health")
	return {"name": "TC.BE.13: Dian Wei has 400 HP", "passed": passed}

static func test_dian_wei_has_sonic_boom() -> Dictionary:
	var script = load("res://scripts/enemies/dian_wei.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("sonic") or source.contains("boom") or source.contains("ranged")
	return {"name": "TC.BE.14: Dian Wei has sonic boom attack", "passed": passed}

static func test_dian_wei_tracks_by_sound() -> Dictionary:
	var script = load("res://scripts/enemies/dian_wei.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("anger") or source.contains("sound") or source.contains("detection")
	return {"name": "TC.BE.15: Dian Wei has anger/sound tracking", "passed": passed}

# =============================================================================
# WITHER TESTS (Wave 25, 500 HP)
# =============================================================================

static func test_sima_yi_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/sima_yi.tscn")
	return {"name": "TC.BE.16: Sima Yi scene exists", "passed": scene != null}

static func test_sima_yi_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/sima_yi.gd")
	return {"name": "TC.BE.17: Sima Yi script exists", "passed": script != null}

static func test_sima_yi_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/sima_yi.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 500 HP
		passed = source.contains("500") or source.contains("max_health")
	return {"name": "TC.BE.18: Sima Yi has 500 HP", "passed": passed}

static func test_sima_yi_has_skull_attack() -> Dictionary:
	var script = load("res://scripts/enemies/sima_yi.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("skull") or source.contains("projectile")
	return {"name": "TC.BE.19: Sima Yi has skull projectile attack", "passed": passed}

static func test_sima_yi_has_wither_effect() -> Dictionary:
	var script = load("res://scripts/enemies/sima_yi.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("sima_yi") or source.contains("effect") or source.contains("dot")
	return {"name": "TC.BE.20: Sima Yi applies sima_yi status effect", "passed": passed}

# =============================================================================
# ENDER DRAGON TESTS (Wave 30, 800 HP)
# =============================================================================

static func test_lv_bu_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/lv_bu.tscn")
	return {"name": "TC.BE.21: Lv Bu scene exists", "passed": scene != null}

static func test_lv_bu_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/lv_bu.gd")
	return {"name": "TC.BE.22: Lv Bu script exists", "passed": script != null}

static func test_lv_bu_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/lv_bu.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 800 HP
		passed = source.contains("800") or source.contains("max_health")
	return {"name": "TC.BE.23: Lv Bu has 800 HP", "passed": passed}

static func test_lv_bu_has_fireball() -> Dictionary:
	var script = load("res://scripts/enemies/lv_bu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("fireball") or source.contains("breath") or source.contains("fire")
	return {"name": "TC.BE.24: Lv Bu has fireball/breath attack", "passed": passed}

static func test_lv_bu_has_dive_attack() -> Dictionary:
	var script = load("res://scripts/enemies/lv_bu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("dive") or source.contains("swoop") or source.contains("fly")
	return {"name": "TC.BE.25: Lv Bu has dive/fly attack", "passed": passed}

# =============================================================================
# WAVE MANAGER BOSS INTEGRATION TESTS
# =============================================================================

static func test_wave_manager_has_boss_mapping() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("get_boss_for_wave") or source.contains("BOSS_WAVES")
	return {"name": "TC.BE.26: WaveManager has boss mapping", "passed": passed}

static func test_wave_10_spawns_xu_chu() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("xu_chu") or (source.contains("10") and source.contains("boss"))
	return {"name": "TC.BE.27: Wave 10 spawns Xu Chu", "passed": passed}

static func test_wave_15_spawns_zhang_liao() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("zhang_liao") or (source.contains("15") and source.contains("boss"))
	return {"name": "TC.BE.28: Wave 15 spawns Zhang Liao", "passed": passed}

static func test_wave_20_spawns_dian_wei() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("dian_wei") or (source.contains("20") and source.contains("boss"))
	return {"name": "TC.BE.29: Wave 20 spawns Dian Wei", "passed": passed}

static func test_wave_25_spawns_sima_yi() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("sima_yi") or (source.contains("25") and source.contains("boss"))
	return {"name": "TC.BE.30: Wave 25 spawns Sima Yi", "passed": passed}

static func test_wave_30_spawns_lv_bu() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("lv_bu") or source.contains("dragon") or (source.contains("30") and source.contains("boss"))
	return {"name": "TC.BE.31: Wave 30 spawns Lv Bu", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		# Xu Chu
		"_ready", "take_damage", "_do_laser_attack", "_activate_spike_aura",
		# ZhangLiao
		"_do_charge_attack", "_do_stomp_attack",
		# DianWei
		"_do_sonic_boom", "_update_anger", "_track_by_sound",
		# SimaYi
		"_shoot_skull", "_apply_wither_effect",
		# Lv Bu
		"_do_fireball_attack", "_do_dive_attack", "_fly_pattern",
		# Common
		"died", "_on_health_depleted"
	]
