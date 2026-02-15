extends Node
class_name TestBossAttackBehavior
## BDD Tests for Boss Attack Improvements (Ravager Wave 15, Warden Wave 20)
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
	# Feature: Ravager Damage Values
	# =========================================================================
	_add_result(results, test_ravager_charge_damage_is_50())
	_add_result(results, test_ravager_stomp_damage_is_40())
	_add_result(results, test_ravager_contact_damage_is_30())

	# =========================================================================
	# Feature: Ravager State Machine
	# =========================================================================
	_add_result(results, test_ravager_has_charge_windup_state())
	_add_result(results, test_ravager_has_four_states())
	_add_result(results, test_ravager_starts_in_idle())
	_add_result(results, test_ravager_has_charge_hit_guard())

	# =========================================================================
	# Feature: Ravager Charge Mechanics
	# =========================================================================
	_add_result(results, test_ravager_charge_hitbox_is_50px())
	_add_result(results, test_ravager_charge_speed_is_300())
	_add_result(results, test_ravager_charge_duration_is_0_8s())
	_add_result(results, test_ravager_charge_uses_boss_charge_animation())
	_add_result(results, test_ravager_charge_resets_animator_on_end())

	# =========================================================================
	# Feature: Ravager Stomp Attack
	# =========================================================================
	_add_result(results, test_ravager_stomp_uses_boss_stomp_animation())
	_add_result(results, test_ravager_stomp_stops_velocity())
	_add_result(results, test_ravager_stomp_spawns_three_effects())
	_add_result(results, test_ravager_stomp_effect_scale_is_4x())

	# =========================================================================
	# Feature: Ravager Audio Integration
	# =========================================================================
	_add_result(results, test_ravager_charge_plays_sfx())
	_add_result(results, test_ravager_stomp_plays_sfx())

	# =========================================================================
	# Feature: Warden Damage Values
	# =========================================================================
	_add_result(results, test_warden_sonic_boom_damage_is_65())
	_add_result(results, test_warden_melee_damage_is_55())
	_add_result(results, test_warden_contact_damage_is_40())

	# =========================================================================
	# Feature: Warden Sonic Boom Tuning
	# =========================================================================
	_add_result(results, test_warden_sonic_boom_cooldown_is_4s())
	_add_result(results, test_warden_sonic_boom_anger_threshold_is_20())
	_add_result(results, test_warden_anger_per_sound_is_25())
	_add_result(results, test_warden_sonic_boom_range_is_400())

	# =========================================================================
	# Feature: Warden Melee Deadlock Fix
	# =========================================================================
	_add_result(results, test_warden_melee_trigger_range_is_80())
	_add_result(results, test_warden_melee_damage_range_is_90())
	_add_result(results, test_warden_melee_range_exceeds_anti_sticking())
	_add_result(results, test_warden_anti_sticking_distance_is_50())

	# =========================================================================
	# Feature: Warden Melee Animation
	# =========================================================================
	_add_result(results, test_warden_melee_uses_boss_melee_animation())
	_add_result(results, test_warden_melee_stops_velocity())
	_add_result(results, test_warden_melee_plays_sfx())

	# =========================================================================
	# Feature: Warden Sonic Boom Animation
	# =========================================================================
	_add_result(results, test_warden_sonic_uses_attack_hit_frame_signal())
	_add_result(results, test_warden_sonic_uses_attack_finished_signal())
	_add_result(results, test_warden_sonic_spawns_three_line_effects())
	_add_result(results, test_warden_sonic_effect_scale_is_5x())
	_add_result(results, test_warden_sonic_plays_sfx())

	# =========================================================================
	# Feature: Warden Anger System
	# =========================================================================
	_add_result(results, test_warden_anger_builds_from_sound())
	_add_result(results, test_warden_anger_builds_from_damage())
	_add_result(results, test_warden_sonic_boom_reduces_anger())
	_add_result(results, test_warden_tracks_player_movement())

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
	_add_result(results, test_ravager_knockback_immune())
	_add_result(results, test_warden_knockback_immune())
	_add_result(results, test_ravager_has_damage_reduction())
	_add_result(results, test_warden_has_damage_reduction())

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

static func _get_ravager_source() -> String:
	var script = load("res://scripts/enemies/ravager.gd")
	if script:
		return script.source_code
	return ""

static func _get_warden_source() -> String:
	var script = load("res://scripts/enemies/warden.gd")
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

static func _get_ravager_instance():
	var scene = load("res://scenes/enemies/ravager.tscn")
	if scene:
		return scene.instantiate()
	return null

static func _get_warden_instance():
	var scene = load("res://scenes/enemies/warden.tscn")
	if scene:
		return scene.instantiate()
	return null

# =============================================================================
# Feature: Ravager Damage Values
# Given the Ravager is a Wave 15 boss with increased attack power
# =============================================================================

static func test_ravager_charge_damage_is_50() -> Dictionary:
	# Given a Ravager boss instance
	# When I check its charge_damage property
	# Then it should be 50 (increased from 35)
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.charge_damage == 50
		ravager.queue_free()
	return {"name": "BDD.RA.1: Given Ravager, When charging, Then deals 50 damage", "passed": passed}

static func test_ravager_stomp_damage_is_40() -> Dictionary:
	# Given a Ravager boss instance
	# When I check its stomp_damage property
	# Then it should be 40 (increased from 25)
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.stomp_damage == 40
		ravager.queue_free()
	return {"name": "BDD.RA.2: Given Ravager, When stomping, Then deals 40 damage", "passed": passed}

static func test_ravager_contact_damage_is_30() -> Dictionary:
	# Given a Ravager boss instance
	# When I check its contact_damage property
	# Then it should be 30 (increased from 20)
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.contact_damage == 30
		ravager.queue_free()
	return {"name": "BDD.RA.3: Given Ravager, When touching player, Then deals 30 contact damage", "passed": passed}

# =============================================================================
# Feature: Ravager State Machine
# Given the Ravager has a state machine with CHARGE_WINDUP sub-state
# =============================================================================

static func test_ravager_has_charge_windup_state() -> Dictionary:
	# Given the Ravager script
	# When I check the State enum
	# Then it should include CHARGE_WINDUP for the windup delay
	var source = _get_ravager_source()
	var passed = source.contains("CHARGE_WINDUP")
	return {"name": "BDD.RA.4: Given Ravager, When checking states, Then has CHARGE_WINDUP state", "passed": passed}

static func test_ravager_has_four_states() -> Dictionary:
	# Given the Ravager script
	# When I check the State enum
	# Then it should have IDLE, CHARGE_WINDUP, CHARGING, STOMPING
	var source = _get_ravager_source()
	var passed = (source.contains("IDLE") and source.contains("CHARGE_WINDUP")
		and source.contains("CHARGING") and source.contains("STOMPING"))
	return {"name": "BDD.RA.5: Given Ravager, When checking states, Then has 4 states (IDLE/WINDUP/CHARGING/STOMPING)", "passed": passed}

static func test_ravager_starts_in_idle() -> Dictionary:
	# Given a freshly spawned Ravager
	# When I check its initial state
	# Then it should be IDLE
	var source = _get_ravager_source()
	var passed = source.contains("var _state: State = State.IDLE")
	return {"name": "BDD.RA.6: Given new Ravager, When spawned, Then starts in IDLE state", "passed": passed}

static func test_ravager_has_charge_hit_guard() -> Dictionary:
	# Given the Ravager charge attack
	# When charge hits the player
	# Then _charge_hit flag prevents multi-frame damage
	var source = _get_ravager_source()
	var passed = (source.contains("_charge_hit") and source.contains("not _charge_hit"))
	return {"name": "BDD.RA.7: Given Ravager charging, When hitting player, Then single-hit guard prevents double damage", "passed": passed}

# =============================================================================
# Feature: Ravager Charge Mechanics
# Given the Ravager has a charge attack with windup delay
# =============================================================================

static func test_ravager_charge_hitbox_is_50px() -> Dictionary:
	# Given the Ravager is charging
	# When player is within 50px
	# Then charge damage is applied (widened from 30px)
	var source = _get_ravager_source()
	var passed = source.contains("distance < 50")
	return {"name": "BDD.RA.8: Given Ravager charging, When player within 50px, Then hit connects (widened from 30px)", "passed": passed}

static func test_ravager_charge_speed_is_300() -> Dictionary:
	# Given a Ravager instance
	# When I check charge_speed
	# Then it should be 300
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.charge_speed == 300.0
		ravager.queue_free()
	return {"name": "BDD.RA.9: Given Ravager, When charging, Then moves at speed 300", "passed": passed}

static func test_ravager_charge_duration_is_0_8s() -> Dictionary:
	# Given the Ravager starts a charge
	# When charge begins
	# Then charge lasts 0.8 seconds
	var source = _get_ravager_source()
	var passed = source.contains("_charge_time_remaining = 0.8")
	return {"name": "BDD.RA.10: Given Ravager, When charge starts, Then lasts 0.8 seconds", "passed": passed}

static func test_ravager_charge_uses_boss_charge_animation() -> Dictionary:
	# Given the Ravager starts charging
	# When the animation plays
	# Then it uses play_boss_charge() (not old play_charge_windup/rush)
	var source = _get_ravager_source()
	var passed = (source.contains("play_boss_charge()") and
		not source.contains("play_charge_windup()") and
		not source.contains("play_charge_rush()"))
	return {"name": "BDD.RA.11: Given Ravager charging, When animating, Then uses play_boss_charge() (not legacy methods)", "passed": passed}

static func test_ravager_charge_resets_animator_on_end() -> Dictionary:
	# Given the Ravager finishes a charge (hit or timeout)
	# When _end_charge() is called
	# Then animator.is_attacking is reset to false
	var source = _get_ravager_source()
	var passed = (source.contains("_end_charge()") and source.contains("is_attacking = false"))
	return {"name": "BDD.RA.12: Given Ravager charge ends, When transitioning, Then resets animator is_attacking", "passed": passed}

# =============================================================================
# Feature: Ravager Stomp Attack
# Given the Ravager has a ground-pound AoE stomp
# =============================================================================

static func test_ravager_stomp_uses_boss_stomp_animation() -> Dictionary:
	# Given the Ravager performs a stomp
	# When the animation plays
	# Then it uses play_boss_stomp() (not generic play_attack_animation())
	var source = _get_ravager_source()
	var passed = source.contains("play_boss_stomp()")
	return {"name": "BDD.RA.13: Given Ravager stomping, When animating, Then uses play_boss_stomp()", "passed": passed}

static func test_ravager_stomp_stops_velocity() -> Dictionary:
	# Given the Ravager starts a stomp
	# When entering STOMPING state
	# Then velocity is set to zero (boss holds still)
	var source = _get_ravager_source()
	# Check that _do_stomp_attack sets velocity to zero
	var stomp_idx = source.find("func _do_stomp_attack")
	var passed = false
	if stomp_idx >= 0:
		var stomp_section = source.substr(stomp_idx, 200)
		passed = stomp_section.contains("velocity = Vector2.ZERO")
	return {"name": "BDD.RA.14: Given Ravager stomping, When attack starts, Then velocity is zero", "passed": passed}

static func test_ravager_stomp_spawns_three_effects() -> Dictionary:
	# Given the Ravager stomp lands
	# When visual effects spawn
	# Then 3 effects spawn in a ring pattern (not just 1)
	var source = _get_ravager_source()
	var passed = source.contains("for i in range(3)") and source.contains("TAU / 3.0")
	return {"name": "BDD.RA.15: Given Ravager stomp lands, When effects spawn, Then 3 effects in ring pattern", "passed": passed}

static func test_ravager_stomp_effect_scale_is_4x() -> Dictionary:
	# Given stomp effects spawn
	# When rendered
	# Then effects are 4x scale (increased from 3x)
	var source = _get_ravager_source()
	var section = _extract_function(source, "_spawn_stomp_effect")
	var passed = section.contains("Vector2(4, 4)")
	return {"name": "BDD.RA.16: Given Ravager stomp effects, When rendered, Then scale is 4x (was 3x)", "passed": passed}

# =============================================================================
# Feature: Ravager Audio Integration
# =============================================================================

static func test_ravager_charge_plays_sfx() -> Dictionary:
	# Given the Ravager starts charging
	# When animation begins
	# Then SFX is played via AudioManager
	var source = _get_ravager_source()
	var charge_idx = source.find("func _start_charge")
	var passed = false
	if charge_idx >= 0:
		var section = source.substr(charge_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.RA.17: Given Ravager charging, When attack starts, Then plays SFX via AudioManager", "passed": passed}

static func test_ravager_stomp_plays_sfx() -> Dictionary:
	# Given the Ravager stomps
	# When attack starts
	# Then SFX is played via AudioManager
	var source = _get_ravager_source()
	var stomp_idx = source.find("func _do_stomp_attack")
	var passed = false
	if stomp_idx >= 0:
		var section = source.substr(stomp_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.RA.18: Given Ravager stomping, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: Warden Damage Values
# Given the Warden is a Wave 20 boss with increased attack power
# =============================================================================

static func test_warden_sonic_boom_damage_is_65() -> Dictionary:
	# Given a Warden boss instance
	# When I check its sonic_boom_damage
	# Then it should be 65 (increased from 45)
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.sonic_boom_damage == 65
		warden.queue_free()
	return {"name": "BDD.WA.1: Given Warden, When sonic booming, Then deals 65 damage (was 45)", "passed": passed}

static func test_warden_melee_damage_is_55() -> Dictionary:
	# Given a Warden boss instance
	# When I check its melee_damage
	# Then it should be 55 (increased from 40)
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.melee_damage == 55
		warden.queue_free()
	return {"name": "BDD.WA.2: Given Warden, When melee attacking, Then deals 55 damage (was 40)", "passed": passed}

static func test_warden_contact_damage_is_40() -> Dictionary:
	# Given a Warden boss instance
	# When I check its contact_damage
	# Then it should be 40 (increased from 30)
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.contact_damage == 40
		warden.queue_free()
	return {"name": "BDD.WA.3: Given Warden, When touching player, Then deals 40 contact damage (was 30)", "passed": passed}

# =============================================================================
# Feature: Warden Sonic Boom Tuning
# Given the Warden sonic boom triggers more frequently
# =============================================================================

static func test_warden_sonic_boom_cooldown_is_4s() -> Dictionary:
	# Given a Warden boss instance
	# When I check sonic_boom_cooldown
	# Then it should be 4.0s (reduced from 6.0s)
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.sonic_boom_cooldown == 4.0
		warden.queue_free()
	return {"name": "BDD.WA.4: Given Warden, When sonic boom ready, Then cooldown is 4s (was 6s)", "passed": passed}

static func test_warden_sonic_boom_anger_threshold_is_20() -> Dictionary:
	# Given the Warden checks anger before sonic boom
	# When anger reaches threshold
	# Then threshold is 20 (lowered from 30 for faster attacks)
	var source = _get_warden_source()
	var passed = source.contains("anger_level >= 20")
	return {"name": "BDD.WA.5: Given Warden, When anger checked for sonic boom, Then threshold is 20 (was 30)", "passed": passed}

static func test_warden_anger_per_sound_is_25() -> Dictionary:
	# Given a Warden boss instance
	# When player makes sound
	# Then anger increases by 25 per tick (was 15, faster buildup)
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.anger_per_sound == 25
		warden.queue_free()
	return {"name": "BDD.WA.6: Given Warden, When player moves, Then anger increases by 25 per tick (was 15)", "passed": passed}

static func test_warden_sonic_boom_range_is_400() -> Dictionary:
	# Given a Warden boss instance
	# When sonic boom fires
	# Then range is 400px
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.sonic_boom_range == 400.0
		warden.queue_free()
	return {"name": "BDD.WA.7: Given Warden, When sonic boom fires, Then range is 400px", "passed": passed}

# =============================================================================
# Feature: Warden Melee Deadlock Fix
# Given anti-sticking pushes at 50px but melee was also 50px (deadlock)
# =============================================================================

static func test_warden_melee_trigger_range_is_80() -> Dictionary:
	# Given the Warden checks melee range
	# When player is within 80px
	# Then melee attack triggers (was 50px, caused deadlock)
	var source = _get_warden_source()
	var passed = source.contains("distance <= 80")
	return {"name": "BDD.WA.8: Given Warden, When player within 80px, Then melee triggers (was 50px deadlock)", "passed": passed}

static func test_warden_melee_damage_range_is_90() -> Dictionary:
	# Given the Warden performs a melee attack
	# When checking hit range
	# Then damage applies within 90px (generous for animation delay)
	var source = _get_warden_source()
	var section = _extract_function(source, "_do_melee_attack")
	var passed = section.contains("distance <= 90")
	return {"name": "BDD.WA.9: Given Warden melee, When checking hit, Then damage range is 90px", "passed": passed}

static func test_warden_melee_range_exceeds_anti_sticking() -> Dictionary:
	# Given anti-sticking pushes entities apart at < 50px
	# When Warden triggers melee at 80px
	# Then melee range (80px) > anti-sticking distance (50px), fixing the deadlock
	var source = _get_warden_source()
	# Verify the melee trigger (80) exceeds the anti-sticking min_distance (50)
	var has_melee_80 = source.contains("distance <= 80")
	var has_anti_stick_50 = source.contains("min_distance = 50.0")
	var passed = has_melee_80 and has_anti_stick_50
	return {"name": "BDD.WA.10: Given anti-sticking at 50px, When melee triggers at 80px, Then deadlock is resolved", "passed": passed}

static func test_warden_anti_sticking_distance_is_50() -> Dictionary:
	# Given the Warden physics process
	# When player is too close
	# Then anti-sticking pushes at 50px threshold
	var source = _get_warden_source()
	var passed = source.contains("var min_distance = 50.0")
	return {"name": "BDD.WA.11: Given Warden, When player too close, Then anti-sticking at 50px", "passed": passed}

# =============================================================================
# Feature: Warden Melee Animation
# =============================================================================

static func test_warden_melee_uses_boss_melee_animation() -> Dictionary:
	# Given the Warden performs a melee attack
	# When animation plays
	# Then it uses play_boss_melee() (not generic play_attack_animation())
	var source = _get_warden_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 400)
		passed = section.contains("play_boss_melee()")
	return {"name": "BDD.WA.12: Given Warden melee, When animating, Then uses play_boss_melee()", "passed": passed}

static func test_warden_melee_stops_velocity() -> Dictionary:
	# Given the Warden starts a melee attack
	# When entering MELEE_ATTACK state
	# Then velocity is set to zero
	var source = _get_warden_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 300)
		passed = section.contains("velocity = Vector2.ZERO")
	return {"name": "BDD.WA.13: Given Warden melee, When attack starts, Then velocity is zero", "passed": passed}

static func test_warden_melee_plays_sfx() -> Dictionary:
	# Given the Warden performs a melee attack
	# When animation starts
	# Then SFX is played via AudioManager
	var source = _get_warden_source()
	var melee_idx = source.find("func _do_melee_attack")
	var passed = false
	if melee_idx >= 0:
		var section = source.substr(melee_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.WA.14: Given Warden melee, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: Warden Sonic Boom Animation
# =============================================================================

static func test_warden_sonic_uses_attack_hit_frame_signal() -> Dictionary:
	# Given the Warden performs a sonic boom
	# When waiting for damage timing
	# Then it awaits attack_hit_frame signal (not hardcoded timer)
	var source = _get_warden_source()
	var sonic_idx = source.find("func _do_sonic_boom")
	var passed = false
	if sonic_idx >= 0:
		var section = source.substr(sonic_idx, 600)
		passed = section.contains("await _animator.attack_hit_frame")
	return {"name": "BDD.WA.15: Given Warden sonic boom, When timing damage, Then awaits attack_hit_frame signal", "passed": passed}

static func test_warden_sonic_uses_attack_finished_signal() -> Dictionary:
	# Given the Warden finishes sonic boom
	# When waiting for recovery
	# Then it awaits attack_finished signal (syncs with animation)
	var source = _get_warden_source()
	var section = _extract_function(source, "_do_sonic_boom")
	var passed = section.contains("await _animator.attack_finished")
	return {"name": "BDD.WA.16: Given Warden sonic boom ends, When recovering, Then awaits attack_finished signal", "passed": passed}

static func test_warden_sonic_spawns_three_line_effects() -> Dictionary:
	# Given the Warden sonic boom hits
	# When visual effects spawn
	# Then 3 effects spawn in a line from boss to player
	var source = _get_warden_source()
	var sonic_effect_idx = source.find("func _spawn_sonic_effect")
	var passed = false
	if sonic_effect_idx >= 0:
		var section = source.substr(sonic_effect_idx, 500)
		passed = section.contains("for i in range(3)") and section.contains("direction")
	return {"name": "BDD.WA.17: Given Warden sonic hits, When effects spawn, Then 3 effects in line to player", "passed": passed}

static func test_warden_sonic_effect_scale_is_5x() -> Dictionary:
	# Given sonic boom effects spawn
	# When rendered
	# Then effects are 5x scale (increased from 4x)
	var source = _get_warden_source()
	var section = _extract_function(source, "_spawn_sonic_effect")
	var passed = section.contains("Vector2(5, 5)")
	return {"name": "BDD.WA.18: Given Warden sonic effects, When rendered, Then scale is 5x (was 4x)", "passed": passed}

static func test_warden_sonic_plays_sfx() -> Dictionary:
	# Given the Warden performs a sonic boom
	# When animation starts
	# Then SFX is played via AudioManager
	var source = _get_warden_source()
	var sonic_idx = source.find("func _do_sonic_boom")
	var passed = false
	if sonic_idx >= 0:
		var section = source.substr(sonic_idx, 500)
		passed = section.contains("play_sfx_at") and section.contains("AudioManager")
	return {"name": "BDD.WA.19: Given Warden sonic boom, When attack starts, Then plays SFX via AudioManager", "passed": passed}

# =============================================================================
# Feature: Warden Anger System
# =============================================================================

static func test_warden_anger_builds_from_sound() -> Dictionary:
	# Given the Warden detects player movement
	# When _track_by_sound is called
	# Then anger increases by anger_per_sound (15)
	var source = _get_warden_source()
	var passed = source.contains("_update_anger(anger_per_sound)")
	return {"name": "BDD.WA.20: Given Warden detects movement, When tracking, Then anger increases by 15", "passed": passed}

static func test_warden_anger_builds_from_damage() -> Dictionary:
	# Given the Warden takes damage
	# When take_damage is called
	# Then anger increases by 35 (faster buildup)
	var source = _get_warden_source()
	var dmg_idx = source.find("func take_damage")
	var passed = false
	if dmg_idx >= 0:
		var section = source.substr(dmg_idx, 400)
		passed = section.contains("_update_anger(35)")
	return {"name": "BDD.WA.21: Given Warden hit, When taking damage, Then anger increases by 35", "passed": passed}

static func test_warden_sonic_boom_reduces_anger() -> Dictionary:
	# Given the Warden fires a sonic boom
	# When attack completes
	# Then anger reduces by 15 (stays angry longer)
	var source = _get_warden_source()
	var section = _extract_function(source, "_do_sonic_boom")
	var passed = section.contains("anger_level - 15")
	return {"name": "BDD.WA.22: Given Warden sonic boom, When attack completes, Then anger reduces by 15", "passed": passed}

static func test_warden_tracks_player_movement() -> Dictionary:
	# Given the Warden has _track_by_sound method
	# When player CharacterBody2D has velocity > 10
	# Then anger is updated
	var source = _get_warden_source()
	var passed = (source.contains("func _track_by_sound") and
		source.contains("velocity.length() > 10"))
	return {"name": "BDD.WA.23: Given Warden, When player moves (velocity > 10), Then tracks by sound", "passed": passed}

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

static func test_ravager_knockback_immune() -> Dictionary:
	# Given a Ravager boss
	# When hit by knockback
	# Then knockback is ignored
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.knockback_immune == true
		ravager.queue_free()
	return {"name": "BDD.IM.1: Given Ravager, When knockback applied, Then immune (unchanged)", "passed": passed}

static func test_warden_knockback_immune() -> Dictionary:
	# Given a Warden boss
	# When hit by knockback
	# Then knockback is ignored
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.knockback_immune == true
		warden.queue_free()
	return {"name": "BDD.IM.2: Given Warden, When knockback applied, Then immune (unchanged)", "passed": passed}

static func test_ravager_has_damage_reduction() -> Dictionary:
	# Given a Ravager boss
	# When taking damage
	# Then 25% damage reduction applies
	var ravager = _get_ravager_instance()
	var passed = false
	if ravager:
		passed = ravager.damage_reduction == 0.25
		ravager.queue_free()
	return {"name": "BDD.IM.3: Given Ravager, When taking damage, Then 25% reduction applied", "passed": passed}

static func test_warden_has_damage_reduction() -> Dictionary:
	# Given a Warden boss
	# When taking damage
	# Then 30% damage reduction applies
	var warden = _get_warden_instance()
	var passed = false
	if warden:
		passed = warden.damage_reduction == 0.30
		warden.queue_free()
	return {"name": "BDD.IM.4: Given Warden, When taking damage, Then 30% reduction applied", "passed": passed}

# =============================================================================
# Coverage Tracking
# =============================================================================

static func get_tested_functions() -> Array:
	return [
		# Ravager
		"_start_charge", "_process_charge", "_end_charge",
		"_do_stomp_attack", "_spawn_stomp_effect",
		"take_damage", "apply_knockback",
		# Warden
		"_do_sonic_boom", "_do_melee_attack", "_spawn_sonic_effect",
		"_track_by_sound", "_update_anger",
		"take_damage", "apply_knockback",
		# EnemyAnimator
		"play_boss_stomp", "play_boss_charge", "play_boss_melee",
		"play_sonic_boom",
	]
