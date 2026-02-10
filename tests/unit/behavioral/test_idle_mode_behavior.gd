extends Node
class_name TestIdleModeBehavior
## BDD Tests for Idle Mode (Auto-Play) Feature
##
## Tests cover:
## - Achievement unlock requirement (wave 31+)
## - IdleController AI movement (flee, dodge, collect)
## - Upgrade auto-select strategies (WEAPON_FIRST, BALANCED, DEFENSIVE)
## - Player idle_mode flag behavior
## - HUD idle mode indicator methods

static func get_test_name() -> String:
	return "Idle Mode BDD Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# =========================================================================
	# Feature: Achievement Unlock
	# =========================================================================
	_add_result(results, test_idle_master_achievement_exists())
	_add_result(results, test_idle_master_target_is_31())
	_add_result(results, test_idle_master_not_unlocked_at_wave_30())
	_add_result(results, test_idle_master_unlocked_at_wave_31())

	# =========================================================================
	# Feature: IdleController Properties
	# =========================================================================
	_add_result(results, test_controller_starts_disabled())
	_add_result(results, test_controller_set_enabled())
	_add_result(results, test_controller_default_strategy_weapon_first())
	_add_result(results, test_controller_set_strategy())

	# =========================================================================
	# Feature: Flee Vector Calculation
	# =========================================================================
	_add_result(results, test_controller_has_flee_distance())
	_add_result(results, test_controller_has_safe_distance())
	_add_result(results, test_controller_has_pickup_radius())

	# =========================================================================
	# Feature: Upgrade Auto-Select (WEAPON_FIRST)
	# =========================================================================
	_add_result(results, test_weapon_first_picks_weapon_upgrades())
	_add_result(results, test_weapon_first_picks_sharpness_over_protection())
	_add_result(results, test_weapon_first_falls_back_to_first_enchant())

	# =========================================================================
	# Feature: Upgrade Auto-Select (DEFENSIVE)
	# =========================================================================
	_add_result(results, test_defensive_picks_protection_first())
	_add_result(results, test_defensive_picks_swiftness())

	# =========================================================================
	# Feature: Upgrade Auto-Select (BALANCED)
	# =========================================================================
	_add_result(results, test_balanced_returns_valid_selection())

	# =========================================================================
	# Feature: Player Idle Mode Flag
	# =========================================================================
	_add_result(results, test_player_has_idle_mode_property())
	_add_result(results, test_player_idle_mode_default_false())

	# =========================================================================
	# Feature: Source Code Verification
	# =========================================================================
	_add_result(results, test_idle_controller_source_has_flee_logic())
	_add_result(results, test_idle_controller_source_has_projectile_dodge())
	_add_result(results, test_idle_controller_source_has_pickup_collection())
	_add_result(results, test_game_source_has_tab_key_handler())
	_add_result(results, test_hud_source_has_idle_mode_methods())
	_add_result(results, test_upgrade_ui_has_idle_controller_ref())

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

static var _AchievementManager = preload("res://scripts/systems/achievement_manager.gd")
static var _IdleController = preload("res://scripts/systems/idle_controller.gd")
static var _PlayerScript = preload("res://scripts/player.gd")

## Mock upgrade object for testing select_upgrade
static func _make_mock_upgrade(display_name: String, id: String = "") -> Dictionary:
	return {"display_name": display_name, "id": id if id != "" else display_name.to_lower()}

# =============================================================================
# Feature: Achievement Unlock
# =============================================================================

static func test_idle_master_achievement_exists() -> Dictionary:
	var passed = "idle_master" in _AchievementManager.ACHIEVEMENT_DEFS
	return {"name": "BDD.IM.1: Given ACHIEVEMENT_DEFS, Then idle_master exists", "passed": passed}

static func test_idle_master_target_is_31() -> Dictionary:
	var def = _AchievementManager.ACHIEVEMENT_DEFS.get("idle_master", {})
	var passed = def.get("target", 0) == 31
	return {"name": "BDD.IM.2: Given idle_master def, Then target = 31 (survive past wave 30)", "passed": passed}

static func test_idle_master_not_unlocked_at_wave_30() -> Dictionary:
	# Create a fresh achievement and check progress at wave 30
	var AchievementClass = preload("res://scripts/systems/achievement.gd")
	var achievement = AchievementClass.new("idle_master", "Idle Master", "Survive past wave 30", 31, 150)
	achievement.check_progress(30)
	var passed = not achievement.is_unlocked
	return {"name": "BDD.IM.3: Given wave 30, When check_progress(30), Then NOT unlocked", "passed": passed}

static func test_idle_master_unlocked_at_wave_31() -> Dictionary:
	var AchievementClass = preload("res://scripts/systems/achievement.gd")
	var achievement = AchievementClass.new("idle_master", "Idle Master", "Survive past wave 30", 31, 150)
	var unlocked = achievement.check_progress(31)
	var passed = unlocked and achievement.is_unlocked
	return {"name": "BDD.IM.4: Given wave 31, When check_progress(31), Then unlocked", "passed": passed}

# =============================================================================
# Feature: IdleController Properties
# =============================================================================

static func test_controller_starts_disabled() -> Dictionary:
	var controller = _IdleController.new()
	var passed = not controller.is_enabled()
	controller.free()
	return {"name": "BDD.IM.5: Given new IdleController, Then is_enabled() = false", "passed": passed}

static func test_controller_set_enabled() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_enabled(true)
	var passed = controller.is_enabled()
	controller.free()
	return {"name": "BDD.IM.6: Given controller, When set_enabled(true), Then is_enabled() = true", "passed": passed}

static func test_controller_default_strategy_weapon_first() -> Dictionary:
	var controller = _IdleController.new()
	var passed = controller.get_strategy() == 0  # WEAPON_FIRST = 0
	controller.free()
	return {"name": "BDD.IM.7: Given new IdleController, Then strategy = WEAPON_FIRST", "passed": passed}

static func test_controller_set_strategy() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(2)  # DEFENSIVE
	var passed = controller.get_strategy() == 2
	controller.free()
	return {"name": "BDD.IM.8: Given controller, When set_strategy(DEFENSIVE), Then strategy = 2", "passed": passed}

# =============================================================================
# Feature: Flee Vector Calculation
# =============================================================================

static func test_controller_has_flee_distance() -> Dictionary:
	var controller = _IdleController.new()
	var passed = controller._flee_distance > 0
	controller.free()
	return {"name": "BDD.IM.9: Given IdleController, Then _flee_distance > 0", "passed": passed}

static func test_controller_has_safe_distance() -> Dictionary:
	var controller = _IdleController.new()
	var passed = controller._safe_distance > controller._flee_distance
	controller.free()
	return {"name": "BDD.IM.10: Given IdleController, Then _safe_distance > _flee_distance", "passed": passed}

static func test_controller_has_pickup_radius() -> Dictionary:
	var controller = _IdleController.new()
	var passed = controller._pickup_radius > 0
	controller.free()
	return {"name": "BDD.IM.11: Given IdleController, Then _pickup_radius > 0", "passed": passed}

# =============================================================================
# Feature: Upgrade Auto-Select (WEAPON_FIRST)
# =============================================================================

static func test_weapon_first_picks_weapon_upgrades() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(0)  # WEAPON_FIRST
	var enchants = [_make_mock_upgrade("Protection"), _make_mock_upgrade("Looting")]
	var weapons = [_make_mock_upgrade("Sword")]
	var choice = controller.select_upgrade(enchants, weapons)
	var passed = choice.section == "weapon" and choice.index == 0
	controller.free()
	return {"name": "BDD.IM.12: Given WEAPON_FIRST + weapon available, Then picks weapon", "passed": passed}

static func test_weapon_first_picks_sharpness_over_protection() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(0)  # WEAPON_FIRST
	var enchants = [_make_mock_upgrade("Protection"), _make_mock_upgrade("Sharpness"), _make_mock_upgrade("Looting")]
	var weapons = []
	var choice = controller.select_upgrade(enchants, weapons)
	var passed = choice.section == "enchant" and choice.index == 1  # Sharpness
	controller.free()
	return {"name": "BDD.IM.13: Given WEAPON_FIRST no weapons, Then picks Sharpness over Protection", "passed": passed}

static func test_weapon_first_falls_back_to_first_enchant() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(0)  # WEAPON_FIRST
	var enchants = [_make_mock_upgrade("Looting"), _make_mock_upgrade("Knockback")]
	var weapons = []
	var choice = controller.select_upgrade(enchants, weapons)
	var passed = choice.section == "enchant" and choice.index == 0
	controller.free()
	return {"name": "BDD.IM.14: Given WEAPON_FIRST no weapon keywords, Then picks first enchant", "passed": passed}

# =============================================================================
# Feature: Upgrade Auto-Select (DEFENSIVE)
# =============================================================================

static func test_defensive_picks_protection_first() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(2)  # DEFENSIVE
	var enchants = [_make_mock_upgrade("Sharpness"), _make_mock_upgrade("Protection"), _make_mock_upgrade("Looting")]
	var weapons = [_make_mock_upgrade("Sword")]
	var choice = controller.select_upgrade(enchants, weapons)
	var passed = choice.section == "enchant" and choice.index == 1  # Protection
	controller.free()
	return {"name": "BDD.IM.15: Given DEFENSIVE, Then picks Protection over Sword", "passed": passed}

static func test_defensive_picks_swiftness() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(2)  # DEFENSIVE
	var enchants = [_make_mock_upgrade("Sharpness"), _make_mock_upgrade("Swiftness")]
	var weapons = []
	var choice = controller.select_upgrade(enchants, weapons)
	var passed = choice.section == "enchant" and choice.index == 1  # Swiftness
	controller.free()
	return {"name": "BDD.IM.16: Given DEFENSIVE, Then picks Swiftness", "passed": passed}

# =============================================================================
# Feature: Upgrade Auto-Select (BALANCED)
# =============================================================================

static func test_balanced_returns_valid_selection() -> Dictionary:
	var controller = _IdleController.new()
	controller.set_strategy(1)  # BALANCED
	var enchants = [_make_mock_upgrade("Sharpness"), _make_mock_upgrade("Protection")]
	var weapons = [_make_mock_upgrade("Sword")]
	var choice = controller.select_upgrade(enchants, weapons)
	var valid_enchant = choice.section == "enchant" and choice.index >= 0 and choice.index < 2
	var valid_weapon = choice.section == "weapon" and choice.index == 0
	var passed = valid_enchant or valid_weapon
	controller.free()
	return {"name": "BDD.IM.17: Given BALANCED, Then returns valid section+index", "passed": passed}

# =============================================================================
# Feature: Player Idle Mode Flag
# =============================================================================

static func test_player_has_idle_mode_property() -> Dictionary:
	var source = _get_source("res://scripts/player.gd")
	var passed = source.contains("var idle_mode")
	return {"name": "BDD.IM.18: Given player.gd source, Then has idle_mode property", "passed": passed}

static func test_player_idle_mode_default_false() -> Dictionary:
	var source = _get_source("res://scripts/player.gd")
	var passed = source.contains("var idle_mode: bool = false")
	return {"name": "BDD.IM.19: Given player.gd source, Then idle_mode defaults to false", "passed": passed}

# =============================================================================
# Feature: Source Code Verification
# =============================================================================

static func test_idle_controller_source_has_flee_logic() -> Dictionary:
	var source = _get_source("res://scripts/systems/idle_controller.gd")
	var passed = source.contains("_get_flee_vector") and source.contains("_flee_distance")
	return {"name": "BDD.IM.20: Given idle_controller.gd, Then has flee logic", "passed": passed}

static func test_idle_controller_source_has_projectile_dodge() -> Dictionary:
	var source = _get_source("res://scripts/systems/idle_controller.gd")
	var passed = source.contains("_get_projectile_dodge_vector") and source.contains("projectiles")
	return {"name": "BDD.IM.21: Given idle_controller.gd, Then has projectile dodge", "passed": passed}

static func test_idle_controller_source_has_pickup_collection() -> Dictionary:
	var source = _get_source("res://scripts/systems/idle_controller.gd")
	var passed = source.contains("_get_pickup_direction") and source.contains("xp_orbs")
	return {"name": "BDD.IM.22: Given idle_controller.gd, Then has pickup collection", "passed": passed}

static func test_game_source_has_tab_key_handler() -> Dictionary:
	var source = _get_source("res://scripts/game.gd")
	var passed = source.contains("KEY_TAB") and source.contains("_toggle_idle_mode")
	return {"name": "BDD.IM.23: Given game.gd, Then has Tab key idle mode toggle", "passed": passed}

static func test_hud_source_has_idle_mode_methods() -> Dictionary:
	var source = _get_source("res://scripts/ui/hud.gd")
	var passed = source.contains("func set_idle_mode") and source.contains("func set_idle_unlocked")
	return {"name": "BDD.IM.24: Given hud.gd, Then has idle mode display methods", "passed": passed}

static func test_upgrade_ui_has_idle_controller_ref() -> Dictionary:
	var source = _get_source("res://scripts/ui/upgrade_ui.gd")
	var passed = source.contains("idle_controller") and source.contains("_auto_select_upgrade")
	return {"name": "BDD.IM.25: Given upgrade_ui.gd, Then has idle_controller and auto_select", "passed": passed}
