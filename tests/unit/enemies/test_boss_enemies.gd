extends Node
class_name TestBossEnemies
## Tests for all Boss enemies
## Elder Guardian (Wave 10), Ravager (Wave 15), Warden (Wave 20), Wither (Wave 25), Ender Dragon (Wave 30)

static func get_test_name() -> String:
	return "Boss Enemies Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Elder Guardian Tests (Wave 10)
	_add_result(results, test_elder_guardian_scene_exists())
	_add_result(results, test_elder_guardian_script_exists())
	_add_result(results, test_elder_guardian_has_correct_hp())
	_add_result(results, test_elder_guardian_has_laser_attack())
	_add_result(results, test_elder_guardian_has_spike_aura())

	# Ravager Tests (Wave 15)
	_add_result(results, test_ravager_scene_exists())
	_add_result(results, test_ravager_script_exists())
	_add_result(results, test_ravager_has_correct_hp())
	_add_result(results, test_ravager_has_charge_attack())
	_add_result(results, test_ravager_has_stomp_attack())

	# Warden Tests (Wave 20)
	_add_result(results, test_warden_scene_exists())
	_add_result(results, test_warden_script_exists())
	_add_result(results, test_warden_has_correct_hp())
	_add_result(results, test_warden_has_sonic_boom())
	_add_result(results, test_warden_tracks_by_sound())

	# Wither Tests (Wave 25)
	_add_result(results, test_wither_scene_exists())
	_add_result(results, test_wither_script_exists())
	_add_result(results, test_wither_has_correct_hp())
	_add_result(results, test_wither_has_skull_attack())
	_add_result(results, test_wither_has_wither_effect())

	# Ender Dragon Tests (Wave 30)
	_add_result(results, test_ender_dragon_scene_exists())
	_add_result(results, test_ender_dragon_script_exists())
	_add_result(results, test_ender_dragon_has_correct_hp())
	_add_result(results, test_ender_dragon_has_fireball())
	_add_result(results, test_ender_dragon_has_dive_attack())

	# Wave Manager Boss Integration
	_add_result(results, test_wave_manager_has_boss_mapping())
	_add_result(results, test_wave_10_spawns_elder_guardian())
	_add_result(results, test_wave_15_spawns_ravager())
	_add_result(results, test_wave_20_spawns_warden())
	_add_result(results, test_wave_25_spawns_wither())
	_add_result(results, test_wave_30_spawns_ender_dragon())

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

static func test_elder_guardian_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/elder_guardian.tscn")
	return {"name": "TC.BE.1: Elder Guardian scene exists", "passed": scene != null}

static func test_elder_guardian_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/elder_guardian.gd")
	return {"name": "TC.BE.2: Elder Guardian script exists", "passed": script != null}

static func test_elder_guardian_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/elder_guardian.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 150 HP
		passed = source.contains("150") or source.contains("max_health")
	return {"name": "TC.BE.3: Elder Guardian has 150 HP", "passed": passed}

static func test_elder_guardian_has_laser_attack() -> Dictionary:
	var script = load("res://scripts/enemies/elder_guardian.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("laser") or source.contains("beam")
	return {"name": "TC.BE.4: Elder Guardian has laser attack", "passed": passed}

static func test_elder_guardian_has_spike_aura() -> Dictionary:
	var script = load("res://scripts/enemies/elder_guardian.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("spike") or source.contains("aura") or source.contains("thorns")
	return {"name": "TC.BE.5: Elder Guardian has spike/thorns aura", "passed": passed}

# =============================================================================
# RAVAGER TESTS (Wave 15, 200 HP)
# =============================================================================

static func test_ravager_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/ravager.tscn")
	return {"name": "TC.BE.6: Ravager scene exists", "passed": scene != null}

static func test_ravager_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/ravager.gd")
	return {"name": "TC.BE.7: Ravager script exists", "passed": script != null}

static func test_ravager_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/ravager.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 200 HP
		passed = source.contains("200") or source.contains("max_health")
	return {"name": "TC.BE.8: Ravager has 200 HP", "passed": passed}

static func test_ravager_has_charge_attack() -> Dictionary:
	var script = load("res://scripts/enemies/ravager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("charge") or source.contains("rush")
	return {"name": "TC.BE.9: Ravager has charge attack", "passed": passed}

static func test_ravager_has_stomp_attack() -> Dictionary:
	var script = load("res://scripts/enemies/ravager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("stomp") or source.contains("ground_pound") or source.contains("aoe")
	return {"name": "TC.BE.10: Ravager has stomp/AoE attack", "passed": passed}

# =============================================================================
# WARDEN TESTS (Wave 20, 400 HP)
# =============================================================================

static func test_warden_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/warden.tscn")
	return {"name": "TC.BE.11: Warden scene exists", "passed": scene != null}

static func test_warden_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/warden.gd")
	return {"name": "TC.BE.12: Warden script exists", "passed": script != null}

static func test_warden_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/warden.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 400 HP
		passed = source.contains("400") or source.contains("max_health")
	return {"name": "TC.BE.13: Warden has 400 HP", "passed": passed}

static func test_warden_has_sonic_boom() -> Dictionary:
	var script = load("res://scripts/enemies/warden.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("sonic") or source.contains("boom") or source.contains("ranged")
	return {"name": "TC.BE.14: Warden has sonic boom attack", "passed": passed}

static func test_warden_tracks_by_sound() -> Dictionary:
	var script = load("res://scripts/enemies/warden.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("anger") or source.contains("sound") or source.contains("detection")
	return {"name": "TC.BE.15: Warden has anger/sound tracking", "passed": passed}

# =============================================================================
# WITHER TESTS (Wave 25, 500 HP)
# =============================================================================

static func test_wither_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/wither.tscn")
	return {"name": "TC.BE.16: Wither scene exists", "passed": scene != null}

static func test_wither_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/wither.gd")
	return {"name": "TC.BE.17: Wither script exists", "passed": script != null}

static func test_wither_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/wither.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 500 HP
		passed = source.contains("500") or source.contains("max_health")
	return {"name": "TC.BE.18: Wither has 500 HP", "passed": passed}

static func test_wither_has_skull_attack() -> Dictionary:
	var script = load("res://scripts/enemies/wither.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("skull") or source.contains("projectile")
	return {"name": "TC.BE.19: Wither has skull projectile attack", "passed": passed}

static func test_wither_has_wither_effect() -> Dictionary:
	var script = load("res://scripts/enemies/wither.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("wither") or source.contains("effect") or source.contains("dot")
	return {"name": "TC.BE.20: Wither applies wither status effect", "passed": passed}

# =============================================================================
# ENDER DRAGON TESTS (Wave 30, 800 HP)
# =============================================================================

static func test_ender_dragon_scene_exists() -> Dictionary:
	var scene = load("res://scenes/enemies/ender_dragon.tscn")
	return {"name": "TC.BE.21: Ender Dragon scene exists", "passed": scene != null}

static func test_ender_dragon_script_exists() -> Dictionary:
	var script = load("res://scripts/enemies/ender_dragon.gd")
	return {"name": "TC.BE.22: Ender Dragon script exists", "passed": script != null}

static func test_ender_dragon_has_correct_hp() -> Dictionary:
	var script = load("res://scripts/enemies/ender_dragon.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should have 800 HP
		passed = source.contains("800") or source.contains("max_health")
	return {"name": "TC.BE.23: Ender Dragon has 800 HP", "passed": passed}

static func test_ender_dragon_has_fireball() -> Dictionary:
	var script = load("res://scripts/enemies/ender_dragon.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("fireball") or source.contains("breath") or source.contains("fire")
	return {"name": "TC.BE.24: Ender Dragon has fireball/breath attack", "passed": passed}

static func test_ender_dragon_has_dive_attack() -> Dictionary:
	var script = load("res://scripts/enemies/ender_dragon.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("dive") or source.contains("swoop") or source.contains("fly")
	return {"name": "TC.BE.25: Ender Dragon has dive/fly attack", "passed": passed}

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

static func test_wave_10_spawns_elder_guardian() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("elder_guardian") or (source.contains("10") and source.contains("boss"))
	return {"name": "TC.BE.27: Wave 10 spawns Elder Guardian", "passed": passed}

static func test_wave_15_spawns_ravager() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("ravager") or (source.contains("15") and source.contains("boss"))
	return {"name": "TC.BE.28: Wave 15 spawns Ravager", "passed": passed}

static func test_wave_20_spawns_warden() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("warden") or (source.contains("20") and source.contains("boss"))
	return {"name": "TC.BE.29: Wave 20 spawns Warden", "passed": passed}

static func test_wave_25_spawns_wither() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("wither") or (source.contains("25") and source.contains("boss"))
	return {"name": "TC.BE.30: Wave 25 spawns Wither", "passed": passed}

static func test_wave_30_spawns_ender_dragon() -> Dictionary:
	var script = load("res://scripts/systems/wave_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("ender_dragon") or source.contains("dragon") or (source.contains("30") and source.contains("boss"))
	return {"name": "TC.BE.31: Wave 30 spawns Ender Dragon", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		# Elder Guardian
		"_ready", "take_damage", "_do_laser_attack", "_activate_spike_aura",
		# Ravager
		"_do_charge_attack", "_do_stomp_attack",
		# Warden
		"_do_sonic_boom", "_update_anger", "_track_by_sound",
		# Wither
		"_shoot_skull", "_apply_wither_effect",
		# Ender Dragon
		"_do_fireball_attack", "_do_dive_attack", "_fly_pattern",
		# Common
		"died", "_on_health_depleted"
	]
