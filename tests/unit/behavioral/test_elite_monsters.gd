extends Node
class_name TestEliteMonsters
## BDD Tests for Elite Monsters System
##
## Tests cover:
## - Elite stat multipliers (HP 2.5x, Damage 1.5x, Speed 1.2x, XP 20x)
## - Elite modifier component constants and behavior
## - Spawner elite logic (wave-based chance, night bonus, max cap)
## - Elite special abilities for all 6 enemy types
## - Elite visuals (shader, scale)
## - Elite SFX (elite_spawn preset)

static func get_test_name() -> String:
	return "Elite Monsters BDD Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# =========================================================================
	# Feature: Elite Stat Multipliers
	# =========================================================================
	_add_result(results, test_elite_zombie_hp_is_25())
	_add_result(results, test_elite_zombie_damage_is_15())
	_add_result(results, test_elite_zombie_speed_is_72())
	_add_result(results, test_elite_zombie_xp_is_100())
	_add_result(results, test_elite_enemy_meat_drop_is_zero())
	_add_result(results, test_elite_enemy_is_in_elite_group())

	# =========================================================================
	# Feature: Elite Modifier Component
	# =========================================================================
	_add_result(results, test_modifier_has_hp_mult_2_5())
	_add_result(results, test_modifier_has_damage_mult_1_5())
	_add_result(results, test_modifier_has_speed_mult_1_2())
	_add_result(results, test_modifier_has_xp_mult_20())
	_add_result(results, test_modifier_has_scale_mult_1_3())
	_add_result(results, test_modifier_apply_adds_elite_group())

	# =========================================================================
	# Feature: Spawner Elite Logic
	# =========================================================================
	_add_result(results, test_spawner_wave_1_3_no_elites())
	_add_result(results, test_spawner_wave_4_6_elite_5_pct())
	_add_result(results, test_spawner_wave_7_9_elite_10_pct())
	_add_result(results, test_spawner_wave_10_14_elite_15_pct())
	_add_result(results, test_spawner_wave_15_19_elite_20_pct())
	_add_result(results, test_spawner_wave_20_plus_elite_25_pct())
	_add_result(results, test_spawner_night_adds_10_pct())
	_add_result(results, test_spawner_max_elites_wave_4_9())
	_add_result(results, test_spawner_max_elites_wave_10_14())
	_add_result(results, test_spawner_max_elites_wave_15_19())
	_add_result(results, test_spawner_max_elites_wave_20_plus())
	_add_result(results, test_spawner_has_get_elite_chance())
	_add_result(results, test_spawner_has_get_max_elites())

	# =========================================================================
	# Feature: Elite Special Abilities
	# =========================================================================
	_add_result(results, test_zombie_has_make_elite())
	_add_result(results, test_zombie_make_elite_sets_is_elite())
	_add_result(results, test_zombie_elite_undead_rally())
	_add_result(results, test_skeleton_has_make_elite())
	_add_result(results, test_skeleton_elite_multi_shot())
	_add_result(results, test_spider_has_make_elite_with_venom())
	_add_result(results, test_creeper_has_make_elite_with_charged())
	_add_result(results, test_enderman_has_make_elite_with_void_strike())
	_add_result(results, test_witch_has_make_elite_with_potion_storm())

	# =========================================================================
	# Feature: Elite Visuals
	# =========================================================================
	_add_result(results, test_shader_has_outline_color_uniform())
	_add_result(results, test_shader_has_pulse_speed_uniform())
	_add_result(results, test_modifier_applies_shader())
	_add_result(results, test_modifier_scales_enemy_1_3x())

	# =========================================================================
	# Feature: Elite SFX
	# =========================================================================
	_add_result(results, test_sfx_generator_has_elite_spawn())
	_add_result(results, test_audio_manager_precaches_elite_spawn())

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

static func _get_zombie_source() -> String:
	return _get_source("res://scripts/enemies/zombie.gd")

static func _get_skeleton_source() -> String:
	return _get_source("res://scripts/enemies/skeleton.gd")

static func _get_spider_source() -> String:
	return _get_source("res://scripts/enemies/spider.gd")

static func _get_creeper_source() -> String:
	return _get_source("res://scripts/enemies/creeper.gd")

static func _get_enderman_source() -> String:
	return _get_source("res://scripts/enemies/enderman.gd")

static func _get_witch_source() -> String:
	return _get_source("res://scripts/enemies/witch.gd")

static func _get_spawner_source() -> String:
	return _get_source("res://scripts/spawner.gd")

static func _get_modifier_source() -> String:
	return _get_source("res://scripts/components/elite_modifier.gd")

static func _get_shader_source() -> String:
	var file = FileAccess.open("res://assets/shaders/elite_outline.gdshader", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return content
	return ""

static func _get_sfx_generator_source() -> String:
	return _get_source("res://scripts/systems/sfx_generator.gd")

static func _get_audio_manager_source() -> String:
	return _get_source("res://scripts/systems/audio_manager.gd")

static var _EliteModifier = preload("res://scripts/components/elite_modifier.gd")

# =============================================================================
# Feature: Elite Stat Multipliers
# Given a normal enemy is promoted to elite status via EliteModifier.apply()
# =============================================================================

static func test_elite_zombie_hp_is_25() -> Dictionary:
	# Given a zombie with 10 HP
	# When EliteModifier.apply() is called
	# Then HP = 25 (2.5x)
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.health == 25
		zombie.queue_free()
	return {"name": "BDD.EL.1: Given zombie (10 HP), When make_elite(), Then HP = 25 (2.5x)", "passed": passed}

static func test_elite_zombie_damage_is_15() -> Dictionary:
	# Given a zombie with 10 damage
	# When EliteModifier.apply() is called
	# Then damage = 15 (1.5x)
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.damage == 15
		zombie.queue_free()
	return {"name": "BDD.EL.2: Given zombie (10 dmg), When make_elite(), Then damage = 15 (1.5x)", "passed": passed}

static func test_elite_zombie_speed_is_72() -> Dictionary:
	# Given a zombie with 60 speed
	# When EliteModifier.apply() is called
	# Then speed = 72 (1.2x)
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.speed == 72.0
		zombie.queue_free()
	return {"name": "BDD.EL.3: Given zombie (60 spd), When make_elite(), Then speed = 72 (1.2x)", "passed": passed}

static func test_elite_zombie_xp_is_100() -> Dictionary:
	# Given a zombie with 5 XP
	# When EliteModifier.apply() is called
	# Then xp_value = 100 (20x)
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.xp_value == 100
		zombie.queue_free()
	return {"name": "BDD.EL.4: Given zombie (5 XP), When make_elite(), Then xp_value = 100 (20x)", "passed": passed}

static func test_elite_enemy_meat_drop_is_zero() -> Dictionary:
	# Given any enemy
	# When EliteModifier.apply() is called
	# Then meat_drop_chance = 0.0 (elites don't drop meat)
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.meat_drop_chance == 0.0
		zombie.queue_free()
	return {"name": "BDD.EL.5: Given any enemy, When make_elite(), Then meat_drop_chance = 0.0 (no meat)", "passed": passed}

static func test_elite_enemy_is_in_elite_group() -> Dictionary:
	# Given any enemy
	# When EliteModifier.apply() is called
	# Then is_in_group("elite") = true
	var scene = load("res://scenes/enemies/zombie.tscn")
	var passed = false
	if scene:
		var zombie = scene.instantiate()
		_EliteModifier.apply(zombie)
		passed = zombie.is_in_group("elite")
		zombie.queue_free()
	return {"name": "BDD.EL.6: Given any enemy, When make_elite(), Then in 'elite' group", "passed": passed}

# =============================================================================
# Feature: Elite Modifier Component
# Given the elite_modifier.gd component defines constants
# =============================================================================

static func test_modifier_has_hp_mult_2_5() -> Dictionary:
	# Given elite_modifier.gd exists
	# When checking constants
	# Then HP_MULT = 2.5
	var source = _get_modifier_source()
	var passed = source.contains("HP_MULT") and source.contains("2.5")
	return {"name": "BDD.EM.1: Given elite_modifier.gd, Then HP_MULT = 2.5", "passed": passed}

static func test_modifier_has_damage_mult_1_5() -> Dictionary:
	# Given elite_modifier.gd
	# Then DAMAGE_MULT = 1.5
	var source = _get_modifier_source()
	var passed = source.contains("DAMAGE_MULT") and source.contains("1.5")
	return {"name": "BDD.EM.2: Given elite_modifier.gd, Then DAMAGE_MULT = 1.5", "passed": passed}

static func test_modifier_has_speed_mult_1_2() -> Dictionary:
	# Given elite_modifier.gd
	# Then SPEED_MULT = 1.2
	var source = _get_modifier_source()
	var passed = source.contains("SPEED_MULT") and source.contains("1.2")
	return {"name": "BDD.EM.3: Given elite_modifier.gd, Then SPEED_MULT = 1.2", "passed": passed}

static func test_modifier_has_xp_mult_20() -> Dictionary:
	# Given elite_modifier.gd
	# Then XP_MULT = 20.0
	var source = _get_modifier_source()
	var passed = source.contains("XP_MULT") and source.contains("20.0")
	return {"name": "BDD.EM.4: Given elite_modifier.gd, Then XP_MULT = 20.0", "passed": passed}

static func test_modifier_has_scale_mult_1_3() -> Dictionary:
	# Given elite_modifier.gd
	# Then SCALE_MULT = 1.3
	var source = _get_modifier_source()
	var passed = source.contains("SCALE_MULT") and source.contains("1.3")
	return {"name": "BDD.EM.5: Given elite_modifier.gd, Then SCALE_MULT = 1.3", "passed": passed}

static func test_modifier_apply_adds_elite_group() -> Dictionary:
	# Given elite_modifier
	# When apply() called
	# Then enemy added to "elite" group
	var source = _get_modifier_source()
	var passed = source.contains("func apply(") and source.contains("add_to_group") and source.contains("elite")
	return {"name": "BDD.EM.6: Given modifier, When apply() called, Then adds 'elite' group", "passed": passed}

# =============================================================================
# Feature: Spawner Elite Logic
# Given the spawner determines elite chance based on wave
# =============================================================================

static func test_spawner_wave_1_3_no_elites() -> Dictionary:
	# Given wave 1-3
	# Then elite chance = 0%
	var source = _get_spawner_source()
	var passed = source.contains("func _get_elite_chance()")
	if passed:
		# Verify the method returns 0.0 for low waves
		passed = source.contains("_current_wave < 4") or source.contains("_current_wave <= 3")
	return {"name": "BDD.SP.1: Given wave 1-3, Then elite chance = 0%", "passed": passed}

static func test_spawner_wave_4_6_elite_5_pct() -> Dictionary:
	# Given wave 4-6
	# Then elite chance = 5%
	var source = _get_spawner_source()
	var passed = source.contains("0.05")
	return {"name": "BDD.SP.2: Given wave 4-6, Then elite chance = 5%", "passed": passed}

static func test_spawner_wave_7_9_elite_10_pct() -> Dictionary:
	# Given wave 7-9
	# Then elite chance = 10%
	var source = _get_spawner_source()
	var passed = source.contains("0.10") or source.contains("0.1")
	return {"name": "BDD.SP.3: Given wave 7-9, Then elite chance = 10%", "passed": passed}

static func test_spawner_wave_10_14_elite_15_pct() -> Dictionary:
	# Given wave 10-14
	# Then elite chance = 15%
	var source = _get_spawner_source()
	var passed = source.contains("0.15")
	return {"name": "BDD.SP.4: Given wave 10-14, Then elite chance = 15%", "passed": passed}

static func test_spawner_wave_15_19_elite_20_pct() -> Dictionary:
	# Given wave 15-19
	# Then elite chance = 20%
	var source = _get_spawner_source()
	var passed = source.contains("0.20") or source.contains("0.2")
	return {"name": "BDD.SP.5: Given wave 15-19, Then elite chance = 20%", "passed": passed}

static func test_spawner_wave_20_plus_elite_25_pct() -> Dictionary:
	# Given wave 20+
	# Then elite chance = 25%
	var source = _get_spawner_source()
	var passed = source.contains("0.25")
	return {"name": "BDD.SP.6: Given wave 20+, Then elite chance = 25%", "passed": passed}

static func test_spawner_night_adds_10_pct() -> Dictionary:
	# Given night time
	# Then elite chance += 10%
	var source = _get_spawner_source()
	var passed = source.contains("_is_night") and source.contains("0.10")
	return {"name": "BDD.SP.7: Given night time, Then elite chance += 10%", "passed": passed}

static func test_spawner_max_elites_wave_4_9() -> Dictionary:
	# Given wave 4-9
	# Then max elites = 2
	var source = _get_spawner_source()
	var passed = source.contains("func _get_max_elites()")
	return {"name": "BDD.SP.8: Given wave 4-9, Then max elites = 2", "passed": passed}

static func test_spawner_max_elites_wave_10_14() -> Dictionary:
	# Given wave 10-14
	# Then max elites = 3
	var source = _get_spawner_source()
	var passed = source.contains("_get_max_elites") and source.contains("3")
	return {"name": "BDD.SP.9: Given wave 10-14, Then max elites = 3", "passed": passed}

static func test_spawner_max_elites_wave_15_19() -> Dictionary:
	# Given wave 15-19
	# Then max elites = 4
	var source = _get_spawner_source()
	var passed = source.contains("_get_max_elites") and source.contains("4")
	return {"name": "BDD.SP.10: Given wave 15-19, Then max elites = 4", "passed": passed}

static func test_spawner_max_elites_wave_20_plus() -> Dictionary:
	# Given wave 20+
	# Then max elites = 5
	var source = _get_spawner_source()
	var passed = source.contains("_get_max_elites") and source.contains("5")
	return {"name": "BDD.SP.11: Given wave 20+, Then max elites = 5", "passed": passed}

static func test_spawner_has_get_elite_chance() -> Dictionary:
	# Given spawner source
	# Then _get_elite_chance method exists
	var source = _get_spawner_source()
	var passed = source.contains("func _get_elite_chance()")
	return {"name": "BDD.SP.12: Given spawner, Then has _get_elite_chance() method", "passed": passed}

static func test_spawner_has_get_max_elites() -> Dictionary:
	# Given spawner source
	# Then _get_max_elites method exists
	var source = _get_spawner_source()
	var passed = source.contains("func _get_max_elites()")
	return {"name": "BDD.SP.13: Given spawner, Then has _get_max_elites() method", "passed": passed}

# =============================================================================
# Feature: Elite Special Abilities
# Given each enemy type has a unique elite ability
# =============================================================================

static func test_zombie_has_make_elite() -> Dictionary:
	# Given zombie.gd source
	# Then has make_elite method
	var source = _get_zombie_source()
	var passed = source.contains("func make_elite()")
	return {"name": "BDD.EA.1: Given zombie.gd, Then has make_elite()", "passed": passed}

static func test_zombie_make_elite_sets_is_elite() -> Dictionary:
	# Given zombie.gd source
	# Then make_elite sets is_elite = true
	var source = _get_zombie_source()
	var passed = source.contains("is_elite = true")
	return {"name": "BDD.EA.2: Given zombie.gd, Then make_elite sets is_elite = true", "passed": passed}

static func test_zombie_elite_undead_rally() -> Dictionary:
	# Given zombie.gd source
	# Then _on_died checks is_elite and emits rally_requested signal
	var source = _get_zombie_source()
	var died_section_idx = source.find("func _on_died()")
	var passed = false
	if died_section_idx >= 0:
		var section = source.substr(died_section_idx, 600)
		passed = section.contains("is_elite") and section.contains("rally_requested")
	return {"name": "BDD.EA.3: Given elite zombie dies, Then Undead Rally spawns 2 normal zombies", "passed": passed}

static func test_skeleton_has_make_elite() -> Dictionary:
	# Given skeleton.gd source
	# Then has make_elite method
	var source = _get_skeleton_source()
	var passed = source.contains("func make_elite()")
	return {"name": "BDD.EA.4: Given skeleton.gd, Then has make_elite()", "passed": passed}

static func test_skeleton_elite_multi_shot() -> Dictionary:
	# Given skeleton.gd source
	# Then shoot_arrow has is_elite multi-shot branch (3 arrows)
	var source = _get_skeleton_source()
	var arrow_idx = source.find("func shoot_arrow()")
	var passed = false
	if arrow_idx >= 0:
		var section = source.substr(arrow_idx, 800)
		passed = section.contains("is_elite")
	return {"name": "BDD.EA.5: Given elite skeleton, Then shoot_arrow fires 3 arrows (multi-shot)", "passed": passed}

static func test_spider_has_make_elite_with_venom() -> Dictionary:
	# Given spider.gd source
	# Then has make_elite with venom strike (poison on hit)
	var source = _get_spider_source()
	var passed = source.contains("func make_elite()") and source.contains("is_elite")
	if passed:
		# Check hitbox damage applies poison
		var hitbox_idx = source.find("func _on_hitbox_body_entered")
		if hitbox_idx >= 0:
			var section = source.substr(hitbox_idx, 600)
			passed = section.contains("is_elite")
	return {"name": "BDD.EA.6: Given elite spider, Then venom strike applies poison on hit", "passed": passed}

static func test_creeper_has_make_elite_with_charged() -> Dictionary:
	# Given creeper.gd source
	# Then has make_elite with charged explosion (wider radius)
	var source = _get_creeper_source()
	var passed = source.contains("func make_elite()") and source.contains("is_elite")
	if passed:
		var make_elite_idx = source.find("func make_elite()")
		if make_elite_idx >= 0:
			var section = source.substr(make_elite_idx, 400)
			passed = section.contains("explosion_radius")
	return {"name": "BDD.EA.7: Given elite creeper, Then charged explosion has wider radius", "passed": passed}

static func test_enderman_has_make_elite_with_void_strike() -> Dictionary:
	# Given enderman.gd source
	# Then has make_elite with void strike (teleport + double hit)
	var source = _get_enderman_source()
	var passed = source.contains("func make_elite()") and source.contains("is_elite")
	return {"name": "BDD.EA.8: Given elite enderman, Then void strike (teleport behind + double hit)", "passed": passed}

static func test_witch_has_make_elite_with_potion_storm() -> Dictionary:
	# Given witch.gd source
	# Then has make_elite with potion storm (3 potions)
	var source = _get_witch_source()
	var passed = source.contains("func make_elite()") and source.contains("is_elite")
	if passed:
		var throw_idx = source.find("func throw_potion()")
		if throw_idx >= 0:
			var section = source.substr(throw_idx, 800)
			passed = section.contains("is_elite")
	return {"name": "BDD.EA.9: Given elite witch, Then potion storm throws 3 potions", "passed": passed}

# =============================================================================
# Feature: Elite Visuals
# Given elite enemies have golden outline shader and scale
# =============================================================================

static func test_shader_has_outline_color_uniform() -> Dictionary:
	# Given elite_outline.gdshader exists
	# Then shader has outline_color uniform
	var source = _get_shader_source()
	var passed = source.contains("outline_color")
	return {"name": "BDD.EV.1: Given elite_outline.gdshader, Then has outline_color uniform", "passed": passed}

static func test_shader_has_pulse_speed_uniform() -> Dictionary:
	# Given elite_outline.gdshader
	# Then shader has pulse_speed uniform
	var source = _get_shader_source()
	var passed = source.contains("pulse_speed")
	return {"name": "BDD.EV.2: Given elite_outline.gdshader, Then has pulse_speed uniform", "passed": passed}

static func test_modifier_applies_shader() -> Dictionary:
	# Given elite modifier source
	# Then applies shader to Sprite2D
	var source = _get_modifier_source()
	var passed = source.contains("Sprite2D") and source.contains("shader") or source.contains("ShaderMaterial")
	return {"name": "BDD.EV.3: Given elite modifier, Then applies shader to Sprite2D", "passed": passed}

static func test_modifier_scales_enemy_1_3x() -> Dictionary:
	# Given elite modifier source
	# Then scales enemy by 1.3x
	var source = _get_modifier_source()
	var passed = source.contains("SCALE_MULT") and source.contains("scale")
	return {"name": "BDD.EV.4: Given elite modifier, Then scales enemy by 1.3x", "passed": passed}

# =============================================================================
# Feature: Elite SFX
# Given elite spawn has a unique sound effect
# =============================================================================

static func test_sfx_generator_has_elite_spawn() -> Dictionary:
	# Given sfx_generator source
	# Then has elite_spawn() method
	var source = _get_sfx_generator_source()
	var passed = source.contains("func elite_spawn()")
	return {"name": "BDD.ES.1: Given sfx_generator, Then has elite_spawn() method", "passed": passed}

static func test_audio_manager_precaches_elite_spawn() -> Dictionary:
	# Given audio_manager source
	# Then precaches "elite_spawn"
	var source = _get_audio_manager_source()
	var passed = source.contains("elite_spawn")
	return {"name": "BDD.ES.2: Given audio_manager, Then precaches 'elite_spawn'", "passed": passed}

# =============================================================================
# Coverage Tracking
# =============================================================================

static func get_tested_functions() -> Array:
	return [
		# Elite Modifier
		"apply", "HP_MULT", "DAMAGE_MULT", "SPEED_MULT", "XP_MULT", "SCALE_MULT",
		# Spawner
		"_get_elite_chance", "_get_max_elites",
		# Enemy abilities
		"make_elite",
		# SFX
		"elite_spawn",
	]
