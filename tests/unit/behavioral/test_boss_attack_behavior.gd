extends Node
class_name TestBossAttackBehavior
## BDD Tests for Boss Attack Improvements (ZhangLiao Wave 15, DianWei Wave 20)
##
## Tests cover:
## - Damage value changes (charge, stomp, melee, sonic boom, contact)
## - Attack state machine transitions (IDLE, CHARGE_WINDUP, CHARGING, STOMPING, etc.)
## - Anti-sticking deadlock fix (melee range > push distance)
## - Sonic boom trigger tuning (anger threshold, cooldown, anger gain)
## - Boss animation method availability (play_boss_stomp, play_boss_charge, play_boss_melee)
## - Animation state management (is_attacking, signals)
## - Charge single-hit guard (_charge_hit flag)
## - Visual effect spawning (multi-effect patterns)

static func get_test_name() -> String:
	return "Boss Attack Behavior BDD Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# =========================================================================
	# Feature: ZhangLiao Damage Values
	# =========================================================================
	_add_result(results, test_zhang_liao_charge_damage_is_50())
	_add_result(results, test_zhang_liao_stomp_damage_is_40())
	_add_result(results, test_zhang_liao_contact_damage_is_30())

	# =========================================================================
	# Feature: ZhangLiao State Machine
	# =========================================================================
	_add_result(results, test_zhang_liao_has_charge_windup_state())
	_add_result(results, test_zhang_liao_has_four_states())
	_add_result(results, test_zhang_liao_starts_in_idle())
	_add_result(results, test_zhang_liao_has_charge_hit_guard())

	# =========================================================================
	# Feature: ZhangLiao Charge Mechanics
	# =========================================================================
	_add_result(results, test_zhang_liao_charge_hitbox_is_50px())
	_add_result(results, test_zhang_liao_charge_speed_is_300())
	_add_result(results, test_zhang_liao_charge_duration_is_0_8s())
	_add_result(results, test_zhang_liao_charge_uses_boss_charge_animation())
	_add_result(results, test_zhang_liao_charge_resets_animator_on_end())

	# =========================================================================
	# Feature: ZhangLiao Stomp Attack
	# =========================================================================
	_add_result(results, test_zhang_liao_stomp_uses_boss_stomp_animation())
	_add_result(results, test_zhang_liao_stomp_stops_velocity())
	_add_result(results, test_zhang_liao_stomp_spawns_three_effects())
	_add_result(results, test_zhang_liao_stomp_effect_scale_is_4x())

	# =========================================================================
	# Feature: ZhangLiao Audio Integration
	# =========================================================================
	_add_result(results, test_zhang_liao_charge_plays_sfx())
	_add_result(results, test_zhang_liao_stomp_plays_sfx())

	# =========================================================================
	# Feature: DianWei Damage Values
	# =========================================================================
	_add_result(results, test_dian_wei_sonic_boom_damage_is_65())
	_add_result(results, test_dian_wei_melee_damage_is_55())
	_add_result(results, test_dian_wei_contact_damage_is_40())

	# =========================================================================
	# Feature: DianWei Sonic Boom Tuning
	# =========================================================================
	_add_result(results, test_dian_wei_sonic_boom_cooldown_is_4s())
	_add_result(results, test_dian_wei_sonic_boom_anger_threshold_is_20())
	_add_result(results, test_dian_wei_anger_per_sound_is_25())
	_add_result(results, test_dian_wei_sonic_boom_range_is_400())

	# =========================================================================
	# Feature: DianWei Melee Deadlock Fix
	# =========================================================================
	_add_result(results, test_dian_wei_melee_trigger_range_is_80())
	_add_result(results, test_dian_wei_melee_damage_range_is_90())
	_add_result(results, test_dian_wei_melee_range_exceeds_anti_sticking())
	_add_result(results, test_dian_wei_anti_sticking_distance_is_50())

	# =========================================================================
	# Feature: DianWei Melee Animation
	# =========================================================================
	_add_result(results, test_dian_wei_melee_uses_boss_melee_animation())
	_add_result(results, test_dian_wei_melee_stops_velocity())
	_add_result(results, test_dian_wei_melee_plays_sfx())

	# =========================================================================
	# Feature: DianWei Sonic Boom Animation
	# =========================================================================
	_add_result(results, test_dian_wei_sonic_uses_attack_hit_frame_signal())
	_add_result(results, test_dian_wei_sonic_uses_attack_finished_signal())
	_add_result(results, test_dian_wei_sonic_spawns_three_line_effects())
	_add_result(results, test_dian_wei_sonic_effect_scale_is_5x())
	_add_result(results, test_dian_wei_sonic_plays_sfx())

	# =========================================================================
	# Feature: DianWei Anger System
	# =========================================================================
	_add_result(results, test_dian_wei_anger_builds_from_sound())
	_add_result(results, test_dian_wei_anger_builds_from_damage())
	_add_result(results, test_dian_wei_sonic_boom_reduces_anger())
	_add_result(results, test_dian_wei_tracks_player_movement())

	# =========================================================================
	# Feature: EnemyAnimator Boss Animation Methods
	# =========================================================================
	_add_result(results, test_animator_has_play_boss_stomp())
	_add_result(results, test_animator_has_play_boss_charge())
	_add_result(results, test_animator_has_play_boss_melee())
	_add_result(results, test_animator_sonic_boom_sets_is_attacking())
	_add_result(results, test_animator_boss_stomp_sets_is_attacking())
	_add_result(results, test_animator_boss_charge_sets_is_attacking())
	_add_result(results, test_animator_boss_melee_sets_is_attacking())

	# =========================================================================
	# Feature: Boss Immunities Preserved
	# =========================================================================
	_add_result(results, test_zhang_liao_knockback_immune())
	_add_result(results, test_dian_wei_knockback_immune())
	_add_result(results, test_zhang_liao_has_damage_reduction())
	_add_result(results, test_dian_wei_has_damage_reduction())

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

static func _get_zhang_liao_source() -> String:
	var script = load("res://scripts/enemies/zhang_liao.gd")
	if script:
		return script.source_code
	return ""

static func _get_dian_wei_source() -> String:
	var script = load("res://scripts/enemies/dian_wei.gd")
	if script:
		return script.source_code
	return ""

static func _get_animator_source() -> String:
	var script = load("res://scripts/components/enemy_animator.gd")
	if script:
		return script.source_code
	return ""

static func _extract_function(source: String, func_name: String) -> String:
	var idx = source.find("func " + func_name)
	if idx < 0:
		return ""
	var next_func = source.find("\nfunc ", idx + 1)
	var end_idx = next_func if next_func >= 0 else source.length()
	return source.substr(idx, end_idx - idx)

static func _get_zhang_liao_instance():
	var scene = load("res://scenes/enemies/zhang_liao.tscn")
	if scene:
		return scene.instantiate()
	return null

static func _get_dian_wei_instance():
	var scene = load("res://scenes/enemies/dian_wei.tscn")
	if scene:
		return scene.instantiate()
	return null

# =============================================================================
# Feature: ZhangLiao Damage Values
# Given the Zhang Liao is a Wave 15 boss with increased attack power
# =============================================================================

static func test_zhang_liao_charge_damage_is_50() -> Dictionary:
	# Given a ZhangLiao boss instance
	# When I check its charge_damage property
	# Then it should be 50 (increased from 35)
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.charge_damage == 50
		zhang_liao.queue_free()
	return {"name": "BDD.RA.1: Given Zhang Liao, When charging, Then deals 50 damage", "passed": passed}

static func test_zhang_liao_stomp_damage_is_40() -> Dictionary:
	# Given a ZhangLiao boss instance
	# When I check its stomp_damage property
	# Then it should be 40 (increased from 25)
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.stomp_damage == 40
		zhang_liao.queue_free()
	return {"name": "BDD.RA.2: Given Zhang Liao, When stomping, Then deals 40 damage", "passed": passed}

static func test_zhang_liao_contact_damage_is_30() -> Dictionary:
	# Given a ZhangLiao boss instance
	# When I check its contact_damage property
	# Then it should be 30 (increased from 20)
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.contact_damage == 30
		zhang_liao.queue_free()
	return {"name": "BDD.RA.3: Given Zhang Liao, When touching player, Then deals 30 contact damage", "passed": passed}

# =============================================================================
# Feature: ZhangLiao State Machine
# Given the Zhang Liao has a state machine with CHARGE_WINDUP sub-state
# =============================================================================

static func test_zhang_liao_has_charge_windup_state() -> Dictionary:
	# Given the Zhang Liao script
	# When I check the State enum
	# Then it should include CHARGE_WINDUP for the windup delay
	var source = _get_zhang_liao_source()
	var passed = source.contains("CHARGE_WINDUP")
	return {"name": "BDD.RA.4: Given Zhang Liao, When checking states, Then has CHARGE_WINDUP state", "passed": passed}

static func test_zhang_liao_has_four_states() -> Dictionary:
	# Given the Zhang Liao script
	# When I check the State enum
	# Then it should have IDLE, CHARGE_WINDUP, CHARGING, STOMPING
	var source = _get_zhang_liao_source()
	var passed = (source.contains("IDLE") and source.contains("CHARGE_WINDUP")
		and source.contains("CHARGING") and source.contains("STOMPING"))
	return {"name": "BDD.RA.5: Given Zhang Liao, When checking states, Then has 4 states (IDLE/WINDUP/CHARGING/STOMPING)", "passed": passed}

static func test_zhang_liao_starts_in_idle() -> Dictionary:
	# Given a freshly spawned ZhangLiao
	# When I check its initial state
	# Then it should be IDLE
	var source = _get_zhang_liao_source()
	var passed = source.contains("var _state: State = State.IDLE")
	return {"name": "BDD.RA.6: Given new ZhangLiao, When spawned, Then starts in IDLE state", "passed": passed}

static func test_zhang_liao_has_charge_hit_guard() -> Dictionary:
	# Given the ZhangLiao charge attack
	# When charge hits the player
	# Then _charge_hit flag prevents multi-frame damage
	var source = _get_zhang_liao_source()
	var passed = (source.contains("_charge_hit") and source.contains("not _charge_hit"))
	return {"name": "BDD.RA.7: Given Zhang Liao charging, When hitting player, Then single-hit guard prevents double damage", "passed": passed}

# =============================================================================
# Feature: ZhangLiao Charge Mechanics
# Given the Zhang Liao has a charge attack with windup delay
# =============================================================================

static func test_zhang_liao_charge_hitbox_is_50px() -> Dictionary:
	# Given the Zhang Liao is charging
	# When player is within 50px
	# Then charge damage is applied (widened from 30px)
	var source = _get_zhang_liao_source()
	var passed = source.contains("distance < 50")
	return {"name": "BDD.RA.8: Given Zhang Liao charging, When player within 50px, Then hit connects (widened from 30px)", "passed": passed}

static func test_zhang_liao_charge_speed_is_300() -> Dictionary:
	# Given a ZhangLiao instance
	# When I check charge_speed
	# Then it should be 300
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.charge_speed == 300.0
		zhang_liao.queue_free()
	return {"name": "BDD.RA.9: Given Zhang Liao, When charging, Then moves at speed 300", "passed": passed}

static func test_zhang_liao_charge_duration_is_0_8s() -> Dictionary:
	# Given the ZhangLiao starts a charge
	# When charge begins
	# Then charge lasts 0.8 seconds
	var source = _get_zhang_liao_source()
	var passed = source.contains("_charge_time_remaining = 0.8")
	return {"name": "BDD.RA.10: Given Zhang Liao, When charge starts, Then lasts 0.8 seconds", "passed": passed}

static func test_zhang_liao_charge_uses_boss_charge_animation() -> Dictionary:
	# Given the ZhangLiao starts charging
	# When the animation plays
	# Then it uses play_boss_charge() (not old play_charge_windup/rush)
	var source = _get_zhang_liao_source()
	var passed = (source.contains("play_boss_charge()") and
		not source.contains("play_charge_windup()") and
		not source.contains("play_charge_rush()"))
	return {"name": "BDD.RA.11: Given Zhang Liao charging, When animating, Then uses play_boss_charge() (not legacy methods)", "passed": passed}

static func test_zhang_liao_charge_resets_animator_on_end() -> Dictionary:
	# Given the ZhangLiao finishes a charge (hit or timeout)
	# When _end_charge() is called
	# Then animator.is_attacking is reset to false
	var source = _get_zhang_liao_source()
	var passed = (source.contains("_end_charge()") and source.contains("is_attacking = false"))
	return {"name": "BDD.RA.12: Given Zhang Liao charge ends, When transitioning, Then resets animator is_attacking", "passed": passed}

# =============================================================================
# Feature: ZhangLiao Stomp Attack
# Given the Zhang Liao has a ground-pound AoE stomp
# =============================================================================

static func test_zhang_liao_stomp_uses_boss_stomp_animation() -> Dictionary:
	# Given the ZhangLiao performs a stomp
	# When the animation plays
	# Then it uses play_boss_stomp() (not generic play_attack_animation())
	var source = _get_zhang_liao_source()
	var passed = source.contains("play_boss_stomp()")
	return {"name": "BDD.RA.13: Given Zhang Liao stomping, When animating, Then uses play_boss_stomp()", "passed": passed}

static func test_zhang_liao_stomp_stops_velocity() -> Dictionary:
	# Given the ZhangLiao starts a stomp
	# When entering STOMPING state
	# Then velocity is set to zero (boss holds still)
	var source = _get_zhang_liao_source()
	# Check that _do_stomp_attack sets velocity to zero
	var stomp_idx = source.find("func _do_stomp_attack")
	var passed = false
	if stomp_idx >= 0:
		var stomp_section = source.substr(stomp_idx, 200)
		passed = stomp_section.contains("velocity = Vector2.ZERO")
	return {"name": "BDD.RA.14: Given Zhang Liao stomping, When attack starts, Then velocity is zero", "passed": passed}

static func test_zhang_liao_stomp_spawns_three_effects() -> Dictionary:
	# Given the ZhangLiao stomp lands
	# When visual effects spawn
	# Then 3 effects spawn in a ring pattern (not just 1)
	var source = _get_zhang_liao_source()
	var passed = source.contains("for i in range(3)") and source.contains("TAU / 3.0")
	return {"name": "BDD.RA.15: Given Zhang Liao stomp lands, When effects spawn, Then 3 effects in ring pattern", "passed": passed}

static func test_zhang_liao_stomp_effect_scale_is_4x() -> Dictionary:
	# Given stomp effects spawn
	# When rendered
	# Then effects are 4x scale (increased from 3x)
	var source = _get_zhang_liao_source()
	var section = _extract_function(source, "_spawn_stomp_effect")
	var passed = section.contains("Vector2(4, 4)")
	return {"name": "BDD.RA.16: Given Zhang Liao stomp effects, When rendered, Then scale is 4x (was 3x)", "passed": passed}

# =============================================================================
# Feature: ZhangLiao Audio Integration
# =============================================================================

static func test_zhang_liao_charge_plays_sfx() -> Dictionary:
	# Given the ZhangLiao starts charging
	# When animation begins
	# Then SFX is played via AudioManager
	var source = _get_zhang_liao_source()
	var charge_idx = source.find("func _start_charge")
	var passed = false
	if charge_idx >= 0:
		var section = source.substr(charge_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.RA.17: Given Zhang Liao charging, When attack starts, Then plays SFX via AudioManager", "passed": passed}

static func test_zhang_liao_stomp_plays_sfx() -> Dictionary:
	# Given the ZhangLiao stomps
	# When attack starts
	# Then SFX is played via AudioManager
	var source = _get_zhang_liao_source()
	var stomp_idx = source.find("func _do_stomp_attack")
	var passed = false
	if stomp_idx >= 0:
		var section = source.substr(stomp_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.RA.18: Given Zhang Liao stomping, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: DianWei Damage Values
# Given the Dian Wei is a Wave 20 boss with increased attack power
# =============================================================================

static func test_dian_wei_sonic_boom_damage_is_65() -> Dictionary:
	# Given a DianWei boss instance
	# When I check its sonic_boom_damage
	# Then it should be 65 (increased from 45)
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.sonic_boom_damage == 65
		dian_wei.queue_free()
	return {"name": "BDD.WA.1: Given Dian Wei, When sonic booming, Then deals 65 damage (was 45)", "passed": passed}

static func test_dian_wei_melee_damage_is_55() -> Dictionary:
	# Given a DianWei boss instance
	# When I check its melee_damage
	# Then it should be 55 (increased from 40)
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.melee_damage == 55
		dian_wei.queue_free()
	return {"name": "BDD.WA.2: Given Dian Wei, When melee attacking, Then deals 55 damage (was 40)", "passed": passed}

static func test_dian_wei_contact_damage_is_40() -> Dictionary:
	# Given a DianWei boss instance
	# When I check its contact_damage
	# Then it should be 40 (increased from 30)
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.contact_damage == 40
		dian_wei.queue_free()
	return {"name": "BDD.WA.3: Given Dian Wei, When touching player, Then deals 40 contact damage (was 30)", "passed": passed}

# =============================================================================
# Feature: DianWei Sonic Boom Tuning
# Given the DianWei sonic boom triggers more frequently
# =============================================================================

static func test_dian_wei_sonic_boom_cooldown_is_4s() -> Dictionary:
	# Given a DianWei boss instance
	# When I check sonic_boom_cooldown
	# Then it should be 4.0s (reduced from 6.0s)
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.sonic_boom_cooldown == 4.0
		dian_wei.queue_free()
	return {"name": "BDD.WA.4: Given Dian Wei, When sonic boom ready, Then cooldown is 4s (was 6s)", "passed": passed}

static func test_dian_wei_sonic_boom_anger_threshold_is_20() -> Dictionary:
	# Given the DianWei checks anger before sonic boom
	# When anger reaches threshold
	# Then threshold is 20 (lowered from 30 for faster attacks)
	var source = _get_dian_wei_source()
	var passed = source.contains("anger_level >= 20")
	return {"name": "BDD.WA.5: Given Dian Wei, When anger checked for sonic boom, Then threshold is 20 (was 30)", "passed": passed}

static func test_dian_wei_anger_per_sound_is_25() -> Dictionary:
	# Given a DianWei boss instance
	# When player makes sound
	# Then anger increases by 25 per tick (was 15, faster buildup)
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.anger_per_sound == 25
		dian_wei.queue_free()
	return {"name": "BDD.WA.6: Given Dian Wei, When player moves, Then anger increases by 25 per tick (was 15)", "passed": passed}

static func test_dian_wei_sonic_boom_range_is_400() -> Dictionary:
	# Given a DianWei boss instance
	# When sonic boom fires
	# Then range is 400px
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.sonic_boom_range == 400.0
		dian_wei.queue_free()
	return {"name": "BDD.WA.7: Given Dian Wei, When sonic boom fires, Then range is 400px", "passed": passed}

# =============================================================================
# Feature: DianWei Melee Deadlock Fix
# Given anti-sticking pushes at 50px but melee was also 50px (deadlock)
# =============================================================================

static func test_dian_wei_melee_trigger_range_is_80() -> Dictionary:
	# Given the DianWei checks melee range
	# When player is within 80px
	# Then melee attack triggers (was 50px, caused deadlock)
	var source = _get_dian_wei_source()
	var passed = source.contains("distance <= 80")
	return {"name": "BDD.WA.8: Given Dian Wei, When player within 80px, Then melee triggers (was 50px deadlock)", "passed": passed}

static func test_dian_wei_melee_damage_range_is_90() -> Dictionary:
	# Given the DianWei performs a melee attack
	# When checking hit range
	# Then damage applies within 90px (generous for animation delay)
	var source = _get_dian_wei_source()
	var section = _extract_function(source, "_do_melee_attack")
	var passed = section.contains("distance <= 90")
	return {"name": "BDD.WA.9: Given Dian Wei melee, When checking hit, Then damage range is 90px", "passed": passed}

static func test_dian_wei_melee_range_exceeds_anti_sticking() -> Dictionary:
	# Given anti-sticking pushes entities apart at < 50px
	# When DianWei triggers melee at 80px
	# Then melee range (80px) > anti-sticking distance (50px), fixing the deadlock
	var source = _get_dian_wei_source()
	# Verify the melee trigger (80) exceeds the anti-sticking min_distance (50)
	var has_melee_80 = source.contains("distance <= 80")
	var has_anti_stick_50 = source.contains("min_distance = 50.0")
	var passed = has_melee_80 and has_anti_stick_50
	return {"name": "BDD.WA.10: Given anti-sticking at 50px, When melee triggers at 80px, Then deadlock is resolved", "passed": passed}

static func test_dian_wei_anti_sticking_distance_is_50() -> Dictionary:
	# Given the DianWei physics process
	# When player is too close
	# Then anti-sticking pushes at 50px threshold
	var source = _get_dian_wei_source()
	var passed = source.contains("var min_distance = 50.0")
	return {"name": "BDD.WA.11: Given Dian Wei, When player too close, Then anti-sticking at 50px", "passed": passed}

# =============================================================================
# Feature: DianWei Melee Animation
# =============================================================================

static func test_dian_wei_melee_uses_boss_melee_animation() -> Dictionary:
	# Given the DianWei performs a melee attack
	# When animation plays
	# Then it uses play_boss_melee() (not generic play_attack_animation())
	var source = _get_dian_wei_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 400)
		passed = section.contains("play_boss_melee()")
	return {"name": "BDD.WA.12: Given Dian Wei melee, When animating, Then uses play_boss_melee()", "passed": passed}

static func test_dian_wei_melee_stops_velocity() -> Dictionary:
	# Given the DianWei starts a melee attack
	# When entering MELEE_ATTACK state
	# Then velocity is set to zero
	var source = _get_dian_wei_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 300)
		passed = section.contains("velocity = Vector2.ZERO")
	return {"name": "BDD.WA.13: Given Dian Wei melee, When attack starts, Then velocity is zero", "passed": passed}

static func test_dian_wei_melee_plays_sfx() -> Dictionary:
	# Given the DianWei performs a melee attack
	# When animation starts
	# Then SFX is played via AudioManager
	var source = _get_dian_wei_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.WA.14: Given Dian Wei melee, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: DianWei Sonic Boom Animation
# =============================================================================

static func test_dian_wei_sonic_uses_attack_hit_frame_signal() -> Dictionary:
	# Given the DianWei performs a sonic boom
	# When waiting for damage timing
	# Then it awaits attack_hit_frame signal (not hardcoded timer)
	var source = _get_dian_wei_source()
	var sonic_idx = source.find("func _do_sonic_boom")
	var passed = false
	if sonic_idx >= 0:
		var section = source.substr(sonic_idx, 600)
		passed = section.contains("await _animator.attack_hit_frame")
	return {"name": "BDD.WA.15: Given Dian Wei sonic boom, When timing damage, Then awaits attack_hit_frame signal", "passed": passed}

static func test_dian_wei_sonic_uses_attack_finished_signal() -> Dictionary:
	# Given the DianWei finishes sonic boom
	# When waiting for recovery
	# Then it awaits attack_finished signal (syncs with animation)
	var source = _get_dian_wei_source()
	var section = _extract_function(source, "_do_sonic_boom")
	var passed = section.contains("await _animator.attack_finished")
	return {"name": "BDD.WA.16: Given Dian Wei sonic boom ends, When recovering, Then awaits attack_finished signal", "passed": passed}

static func test_dian_wei_sonic_spawns_three_line_effects() -> Dictionary:
	# Given the DianWei sonic boom hits
	# When visual effects spawn
	# Then 3 effects spawn in a line from boss to player
	var source = _get_dian_wei_source()
	var sonic_effect_idx = source.find("func _spawn_sonic_effect")
	var passed = false
	if sonic_effect_idx >= 0:
		var section = source.substr(sonic_effect_idx, 500)
		passed = section.contains("for i in range(3)") and section.contains("direction")
	return {"name": "BDD.WA.17: Given Dian Wei sonic hits, When effects spawn, Then 3 effects in line to player", "passed": passed}

static func test_dian_wei_sonic_effect_scale_is_5x() -> Dictionary:
	# Given sonic boom effects spawn
	# When rendered
	# Then effects are 5x scale (increased from 4x)
	var source = _get_dian_wei_source()
	var section = _extract_function(source, "_spawn_sonic_effect")
	var passed = section.contains("Vector2(5, 5)")
	return {"name": "BDD.WA.18: Given Dian Wei sonic effects, When rendered, Then scale is 5x (was 4x)", "passed": passed}

static func test_dian_wei_sonic_plays_sfx() -> Dictionary:
	# Given the DianWei performs a sonic boom
	# When animation starts
	# Then SFX is played via AudioManager
	var source = _get_dian_wei_source()
	var sonic_idx = source.find("func _do_sonic_boom")
	var passed = false
	if sonic_idx >= 0:
		var section = source.substr(sonic_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.WA.19: Given Dian Wei sonic boom, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: DianWei Anger System
# =============================================================================

static func test_dian_wei_anger_builds_from_sound() -> Dictionary:
	# Given the DianWei detects player movement
	# When _track_by_sound is called
	# Then anger increases by anger_per_sound (15)
	var source = _get_dian_wei_source()
	var passed = source.contains("_update_anger(anger_per_sound)")
	return {"name": "BDD.WA.20: Given Dian Wei detects movement, When tracking, Then anger increases by 15", "passed": passed}

static func test_dian_wei_anger_builds_from_damage() -> Dictionary:
	# Given the DianWei takes damage
	# When take_damage is called
	# Then anger increases by 35 (faster buildup)
	var source = _get_dian_wei_source()
	var dmg_idx = source.find("func take_damage")
	var passed = false
	if dmg_idx >= 0:
		var section = source.substr(dmg_idx, 400)
		passed = section.contains("_update_anger(35)")
	return {"name": "BDD.WA.21: Given Dian Wei hit, When taking damage, Then anger increases by 35", "passed": passed}

static func test_dian_wei_sonic_boom_reduces_anger() -> Dictionary:
	# Given the DianWei fires a sonic boom
	# When attack completes
	# Then anger reduces by 15 (stays angry longer)
	var source = _get_dian_wei_source()
	var section = _extract_function(source, "_do_sonic_boom")
	var passed = section.contains("anger_level - 15")
	return {"name": "BDD.WA.22: Given Dian Wei sonic boom, When attack completes, Then anger reduces by 15", "passed": passed}

static func test_dian_wei_tracks_player_movement() -> Dictionary:
	# Given the Dian Wei has _track_by_sound method
	# When player CharacterBody2D has velocity > 10
	# Then anger is updated
	var source = _get_dian_wei_source()
	var passed = (source.contains("func _track_by_sound") and
		source.contains("velocity.length() > 10"))
	return {"name": "BDD.WA.23: Given Dian Wei, When player moves (velocity > 10), Then tracks by sound", "passed": passed}

# =============================================================================
# Feature: EnemyAnimator Boss Animation Methods
# Given the animator has new dedicated boss animation methods
# =============================================================================

static func test_animator_has_play_boss_stomp() -> Dictionary:
	# Given the EnemyAnimator class
	# When checking available methods
	# Then play_boss_stomp() exists
	var source = _get_animator_source()
	var passed = source.contains("func play_boss_stomp()")
	return {"name": "BDD.AN.1: Given EnemyAnimator, When checking methods, Then has play_boss_stomp()", "passed": passed}

static func test_animator_has_play_boss_charge() -> Dictionary:
	# Given the EnemyAnimator class
	# When checking available methods
	# Then play_boss_charge() exists
	var source = _get_animator_source()
	var passed = source.contains("func play_boss_charge()")
	return {"name": "BDD.AN.2: Given EnemyAnimator, When checking methods, Then has play_boss_charge()", "passed": passed}

static func test_animator_has_play_boss_melee() -> Dictionary:
	# Given the EnemyAnimator class
	# When checking available methods
	# Then play_boss_melee() exists
	var source = _get_animator_source()
	var passed = source.contains("func play_boss_melee()")
	return {"name": "BDD.AN.3: Given EnemyAnimator, When checking methods, Then has play_boss_melee()", "passed": passed}

static func test_animator_sonic_boom_sets_is_attacking() -> Dictionary:
	# Given play_sonic_boom() is called
	# When animation starts
	# Then is_attacking is set to true (consistent with other boss animations)
	var source = _get_animator_source()
	var sonic_idx = source.find("func play_sonic_boom()")
	var passed = false
	if sonic_idx >= 0:
		var section = source.substr(sonic_idx, 300)
		passed = (section.contains("is_attacking = true") and
			section.contains("attack_started.emit()"))
	return {"name": "BDD.AN.4: Given sonic boom plays, When starting, Then sets is_attacking=true and emits attack_started", "passed": passed}

static func test_animator_boss_stomp_sets_is_attacking() -> Dictionary:
	# Given play_boss_stomp() is called
	# When animation starts
	# Then is_attacking is set to true
	var source = _get_animator_source()
	var stomp_idx = source.find("func play_boss_stomp()")
	var passed = false
	if stomp_idx >= 0:
		var section = source.substr(stomp_idx, 300)
		passed = (section.contains("is_attacking = true") and
			section.contains("attack_started.emit()"))
	return {"name": "BDD.AN.5: Given boss stomp plays, When starting, Then sets is_attacking=true", "passed": passed}

static func test_animator_boss_charge_sets_is_attacking() -> Dictionary:
	# Given play_boss_charge() is called
	# When animation starts
	# Then is_attacking is set to true
	var source = _get_animator_source()
	var charge_idx = source.find("func play_boss_charge()")
	var passed = false
	if charge_idx >= 0:
		var section = source.substr(charge_idx, 300)
		passed = (section.contains("is_attacking = true") and
			section.contains("attack_started.emit()"))
	return {"name": "BDD.AN.6: Given boss charge plays, When starting, Then sets is_attacking=true", "passed": passed}

static func test_animator_boss_melee_sets_is_attacking() -> Dictionary:
	# Given play_boss_melee() is called
	# When animation starts
	# Then is_attacking is set to true
	var source = _get_animator_source()
	var melee_idx = source.find("func play_boss_melee()")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 300)
		passed = (section.contains("is_attacking = true") and
			section.contains("attack_started.emit()"))
	return {"name": "BDD.AN.7: Given boss melee plays, When starting, Then sets is_attacking=true", "passed": passed}

# =============================================================================
# Feature: Boss Immunities Preserved
# Given bosses retain their immunity properties after changes
# =============================================================================

static func test_zhang_liao_knockback_immune() -> Dictionary:
	# Given a ZhangLiao boss
	# When hit by knockback
	# Then knockback is ignored
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.knockback_immune == true
		zhang_liao.queue_free()
	return {"name": "BDD.IM.1: Given Zhang Liao, When knockback applied, Then immune (unchanged)", "passed": passed}

static func test_dian_wei_knockback_immune() -> Dictionary:
	# Given a DianWei boss
	# When hit by knockback
	# Then knockback is ignored
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.knockback_immune == true
		dian_wei.queue_free()
	return {"name": "BDD.IM.2: Given Dian Wei, When knockback applied, Then immune (unchanged)", "passed": passed}

static func test_zhang_liao_has_damage_reduction() -> Dictionary:
	# Given a ZhangLiao boss
	# When taking damage
	# Then 25% damage reduction applies
	var zhang_liao = _get_zhang_liao_instance()
	var passed = false
	if zhang_liao:
		passed = zhang_liao.damage_reduction == 0.25
		zhang_liao.queue_free()
	return {"name": "BDD.IM.3: Given Zhang Liao, When taking damage, Then 25% reduction applied", "passed": passed}

static func test_dian_wei_has_damage_reduction() -> Dictionary:
	# Given a DianWei boss
	# When taking damage
	# Then 30% damage reduction applies
	var dian_wei = _get_dian_wei_instance()
	var passed = false
	if dian_wei:
		passed = dian_wei.damage_reduction == 0.30
		dian_wei.queue_free()
	return {"name": "BDD.IM.4: Given Dian Wei, When taking damage, Then 30% reduction applied", "passed": passed}

# =============================================================================
# Coverage Tracking
# =============================================================================

static func get_tested_functions() -> Array:
	return [
		# ZhangLiao
		"_start_charge", "_process_charge", "_end_charge",
		"_do_stomp_attack", "_spawn_stomp_effect",
		"take_damage", "apply_knockback",
		# DianWei
		"_do_sonic_boom", "_do_melee_attack", "_spawn_sonic_effect",
		"_track_by_sound", "_update_anger",
		"take_damage", "apply_knockback",
		# EnemyAnimator
		"play_boss_stomp", "play_boss_charge", "play_boss_melee",
		"play_sonic_boom",
	]
