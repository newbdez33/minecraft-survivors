extends Node
class_name TestAchievementUIBehavior
## BDD Tests for Achievement System UI Integration
##
## Tests cover:
## - Main menu achievements button and panel
## - Pause menu achievements button and panel
## - Achievement notification popup
## - Localization of achievement UI
## - Achievement SFX preset
## - Missing event wiring (combo, poison, no-damage)
## - Persistence integration

static func get_test_name() -> String:
	return "Achievement UI Behavior BDD Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# =========================================================================
	# Feature: Main Menu Achievement Button
	# =========================================================================
	_add_result(results, test_main_menu_has_achievements_button())
	_add_result(results, test_main_menu_has_achievement_panel())
	_add_result(results, test_main_menu_has_achievements_label())
	_add_result(results, test_main_menu_script_has_achievements_handler())

	# =========================================================================
	# Feature: Pause Menu Achievement Button
	# =========================================================================
	_add_result(results, test_pause_menu_has_achievements_button())
	_add_result(results, test_pause_menu_has_achievement_panel())
	_add_result(results, test_pause_menu_script_has_achievements_handler())
	_add_result(results, test_pause_menu_has_set_achievement_manager())

	# =========================================================================
	# Feature: Achievement Notification in Game
	# =========================================================================
	_add_result(results, test_game_script_has_notification_instantiation())
	_add_result(results, test_game_script_uses_notification_for_unlock())
	_add_result(results, test_notification_has_process_mode_always())

	# =========================================================================
	# Feature: Localization Keys Exist
	# =========================================================================
	_add_result(results, test_achievements_translation_key_exists())
	_add_result(results, test_ach_progress_translation_key_exists())
	_add_result(results, test_ach_unlocked_translation_key_exists())
	_add_result(results, test_ach_unlocked_title_translation_key_exists())
	_add_result(results, test_achievement_name_keys_exist())

	# =========================================================================
	# Feature: Localization in UI Scripts
	# =========================================================================
	_add_result(results, test_panel_uses_tr_for_title())
	_add_result(results, test_panel_connects_language_changed())
	_add_result(results, test_item_uses_tr_for_names())
	_add_result(results, test_notification_uses_tr_for_title())

	# =========================================================================
	# Feature: Achievement SFX
	# =========================================================================
	_add_result(results, test_sfx_generator_has_achievement_unlock())
	_add_result(results, test_audio_manager_caches_achievement_unlock())
	_add_result(results, test_game_plays_sfx_on_achievement())

	# =========================================================================
	# Feature: Missing Event Wiring
	# =========================================================================
	_add_result(results, test_game_has_combo_system())
	_add_result(results, test_game_tracks_poison_survived())
	_add_result(results, test_game_tracks_no_damage_time())
	_add_result(results, test_game_passes_achievement_manager_to_pause_menu())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# MAIN MENU TESTS
# =============================================================================

static func test_main_menu_has_achievements_button() -> Dictionary:
	## GIVEN a main menu scene
	## WHEN it is loaded
	## THEN it should have an AchievementsButton node
	var scene = load("res://scenes/ui/main_menu.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("Container/VBox/AchievementsButton") != null
		instance.queue_free()
	return {"name": "BDD.ACHUI.1: Main menu has AchievementsButton", "passed": passed}

static func test_main_menu_has_achievement_panel() -> Dictionary:
	## GIVEN a main menu scene
	## WHEN it is loaded
	## THEN it should have an AchievementPanel child
	var scene = load("res://scenes/ui/main_menu.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("AchievementPanel") != null
		instance.queue_free()
	return {"name": "BDD.ACHUI.2: Main menu has AchievementPanel", "passed": passed}

static func test_main_menu_has_achievements_label() -> Dictionary:
	## GIVEN a main menu scene
	## WHEN it is loaded
	## THEN the AchievementsButton should have a Label child
	var scene = load("res://scenes/ui/main_menu.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		var label = instance.get_node_or_null("Container/VBox/AchievementsButton/Label")
		passed = label != null
		instance.queue_free()
	return {"name": "BDD.ACHUI.3: Main menu AchievementsButton has Label", "passed": passed}

static func test_main_menu_script_has_achievements_handler() -> Dictionary:
	## GIVEN the main_menu.gd script
	## WHEN inspected
	## THEN it should have _on_achievements_pressed handler
	var script = load("res://scripts/ui/main_menu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func _on_achievements_pressed")
	return {"name": "BDD.ACHUI.4: Main menu has _on_achievements_pressed()", "passed": passed}

# =============================================================================
# PAUSE MENU TESTS
# =============================================================================

static func test_pause_menu_has_achievements_button() -> Dictionary:
	## GIVEN a pause menu scene
	## WHEN it is loaded
	## THEN it should have an AchievementsButton node
	var scene = load("res://scenes/ui/pause_menu.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("CenterContainer/VBoxContainer/AchievementsButton") != null
		instance.queue_free()
	return {"name": "BDD.ACHUI.5: Pause menu has AchievementsButton", "passed": passed}

static func test_pause_menu_has_achievement_panel() -> Dictionary:
	## GIVEN a pause menu scene
	## WHEN it is loaded
	## THEN it should have an AchievementPanel child
	var scene = load("res://scenes/ui/pause_menu.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("AchievementPanel") != null
		instance.queue_free()
	return {"name": "BDD.ACHUI.6: Pause menu has AchievementPanel", "passed": passed}

static func test_pause_menu_script_has_achievements_handler() -> Dictionary:
	## GIVEN the pause_menu.gd script
	## WHEN inspected
	## THEN it should have _on_achievements_pressed handler
	var script = load("res://scripts/ui/pause_menu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func _on_achievements_pressed")
	return {"name": "BDD.ACHUI.7: Pause menu has _on_achievements_pressed()", "passed": passed}

static func test_pause_menu_has_set_achievement_manager() -> Dictionary:
	## GIVEN the pause_menu.gd script
	## WHEN inspected
	## THEN it should have set_achievement_manager method
	var script = load("res://scripts/ui/pause_menu.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func set_achievement_manager")
	return {"name": "BDD.ACHUI.8: Pause menu has set_achievement_manager()", "passed": passed}

# =============================================================================
# ACHIEVEMENT NOTIFICATION TESTS
# =============================================================================

static func test_game_script_has_notification_instantiation() -> Dictionary:
	## GIVEN game.gd
	## WHEN inspected
	## THEN it should instantiate AchievementNotification scene
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("achievement_notification") and source.contains("show_achievement")
	return {"name": "BDD.ACHUI.9: Game instantiates AchievementNotification", "passed": passed}

static func test_game_script_uses_notification_for_unlock() -> Dictionary:
	## GIVEN game.gd _on_achievement_unlocked
	## WHEN an achievement unlocks
	## THEN it should call show_achievement on the notification
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("_achievement_notification") and source.contains("show_achievement")
	return {"name": "BDD.ACHUI.10: Game uses notification for unlocks", "passed": passed}

static func test_notification_has_process_mode_always() -> Dictionary:
	## GIVEN the achievement notification script
	## WHEN loaded
	## THEN it should set process_mode to PROCESS_MODE_ALWAYS
	var script = load("res://scripts/ui/achievement_notification.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("PROCESS_MODE_ALWAYS")
	return {"name": "BDD.ACHUI.11: Notification has PROCESS_MODE_ALWAYS", "passed": passed}

# =============================================================================
# LOCALIZATION KEY TESTS
# =============================================================================

static func test_achievements_translation_key_exists() -> Dictionary:
	## GIVEN the translations CSV
	## WHEN loaded
	## THEN it should contain the ACHIEVEMENTS key
	var passed = _csv_has_key("ACHIEVEMENTS")
	return {"name": "BDD.ACHUI.12: ACHIEVEMENTS translation key exists", "passed": passed}

static func test_ach_progress_translation_key_exists() -> Dictionary:
	var passed = _csv_has_key("ACH_PROGRESS")
	return {"name": "BDD.ACHUI.13: ACH_PROGRESS translation key exists", "passed": passed}

static func test_ach_unlocked_translation_key_exists() -> Dictionary:
	var passed = _csv_has_key("ACH_UNLOCKED")
	return {"name": "BDD.ACHUI.14: ACH_UNLOCKED translation key exists", "passed": passed}

static func test_ach_unlocked_title_translation_key_exists() -> Dictionary:
	var passed = _csv_has_key("ACH_UNLOCKED_TITLE")
	return {"name": "BDD.ACHUI.15: ACH_UNLOCKED_TITLE translation key exists", "passed": passed}

static func test_achievement_name_keys_exist() -> Dictionary:
	## GIVEN the translations CSV
	## WHEN checked for achievement name keys
	## THEN all 23 achievement name keys should exist
	var required_keys = [
		"ACH_FIRST_KILL_NAME", "ACH_KILLS_100_NAME", "ACH_KILLS_1000_NAME",
		"ACH_SURVIVE_60_NAME", "ACH_SURVIVE_300_NAME", "ACH_SURVIVE_600_NAME", "ACH_SURVIVE_900_NAME",
		"ACH_LEVEL_5_NAME", "ACH_LEVEL_10_NAME", "ACH_LEVEL_20_NAME",
		"ACH_WAVE_3_NAME", "ACH_WAVE_5_NAME", "ACH_WAVE_10_NAME",
		"ACH_POISON_SURVIVE_NAME", "ACH_COMBO_50_NAME", "ACH_COMBO_100_NAME",
		"ACH_NO_DAMAGE_60_NAME", "ACH_UNLOCK_ALEX_NAME", "ACH_UNLOCK_BOW_NAME",
		"ACH_EVOLVE_WEAPON_NAME", "ACH_IDLE_MASTER_NAME"
	]
	var all_found = true
	for key in required_keys:
		if not _csv_has_key(key):
			all_found = false
			break
	return {"name": "BDD.ACHUI.16: All 21 achievement name keys exist in CSV", "passed": all_found}

# =============================================================================
# LOCALIZATION IN UI SCRIPTS TESTS
# =============================================================================

static func test_panel_uses_tr_for_title() -> Dictionary:
	## GIVEN achievement_panel.gd
	## WHEN inspected
	## THEN it should use tr("ACHIEVEMENTS") for the title
	var script = load("res://scripts/ui/achievement_panel.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains('tr("ACHIEVEMENTS")')
	return {"name": "BDD.ACHUI.17: Panel uses tr() for title", "passed": passed}

static func test_panel_connects_language_changed() -> Dictionary:
	## GIVEN achievement_panel.gd
	## WHEN inspected
	## THEN it should connect to language_changed signal
	var script = load("res://scripts/ui/achievement_panel.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("language_changed")
	return {"name": "BDD.ACHUI.18: Panel connects language_changed signal", "passed": passed}

static func test_item_uses_tr_for_names() -> Dictionary:
	## GIVEN achievement_item.gd
	## WHEN inspected
	## THEN it should use tr() for achievement names
	var script = load("res://scripts/ui/achievement_item.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("ACH_") and source.contains("_NAME")
	return {"name": "BDD.ACHUI.19: Item uses tr() with ACH_*_NAME keys", "passed": passed}

static func test_notification_uses_tr_for_title() -> Dictionary:
	## GIVEN achievement_notification.gd
	## WHEN inspected
	## THEN it should use tr("ACH_UNLOCKED_TITLE") for the title
	var script = load("res://scripts/ui/achievement_notification.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains('tr("ACH_UNLOCKED_TITLE")')
	return {"name": "BDD.ACHUI.20: Notification uses tr() for unlock title", "passed": passed}

# =============================================================================
# SFX TESTS
# =============================================================================

static func test_sfx_generator_has_achievement_unlock() -> Dictionary:
	## GIVEN sfx_generator.gd
	## WHEN inspected
	## THEN it should have achievement_unlock preset
	var script = load("res://scripts/systems/sfx_generator.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func achievement_unlock")
	return {"name": "BDD.ACHUI.21: SFX generator has achievement_unlock preset", "passed": passed}

static func test_audio_manager_caches_achievement_unlock() -> Dictionary:
	## GIVEN audio_manager.gd
	## WHEN inspected
	## THEN it should cache "achievement_unlock" sound
	var script = load("res://scripts/systems/audio_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains('"achievement_unlock"')
	return {"name": "BDD.ACHUI.22: AudioManager caches achievement_unlock", "passed": passed}

static func test_game_plays_sfx_on_achievement() -> Dictionary:
	## GIVEN game.gd _on_achievement_unlocked
	## WHEN an achievement is unlocked
	## THEN it should play achievement_unlock SFX
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("achievement_unlock") and source.contains("play_sfx")
	return {"name": "BDD.ACHUI.23: Game plays achievement_unlock SFX on unlock", "passed": passed}

# =============================================================================
# MISSING EVENT WIRING TESTS
# =============================================================================

static func test_game_has_combo_system() -> Dictionary:
	## GIVEN game.gd
	## WHEN inspected
	## THEN it should create and wire a ComboSystem
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("_combo_system") and source.contains("combo_changed")
	return {"name": "BDD.ACHUI.24: Game wires ComboSystem for combo achievements", "passed": passed}

static func test_game_tracks_poison_survived() -> Dictionary:
	## GIVEN game.gd
	## WHEN inspected
	## THEN it should track poison survived count
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("_poison_survived_count") and source.contains("check_poison_survived")
	return {"name": "BDD.ACHUI.25: Game tracks poison survived for achievement", "passed": passed}

static func test_game_tracks_no_damage_time() -> Dictionary:
	## GIVEN game.gd
	## WHEN inspected
	## THEN it should track no-damage time and check achievement
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("_no_damage_time") and source.contains("check_no_damage_time")
	return {"name": "BDD.ACHUI.26: Game tracks no-damage time for achievement", "passed": passed}

static func test_game_passes_achievement_manager_to_pause_menu() -> Dictionary:
	## GIVEN game.gd
	## WHEN inspected
	## THEN it should pass achievement_manager to pause_menu
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("set_achievement_manager") and source.contains("pause_menu")
	return {"name": "BDD.ACHUI.27: Game passes achievement_manager to pause menu", "passed": passed}

# =============================================================================
# HELPERS
# =============================================================================

static func _csv_has_key(key: String) -> bool:
	if not FileAccess.file_exists("res://localization/translations.csv"):
		return false
	var file = FileAccess.open("res://localization/translations.csv", FileAccess.READ)
	if not file:
		return false
	var content = file.get_as_text()
	file.close()
	# Check that the key exists at the start of a line
	for line in content.split("\n"):
		if line.begins_with(key + ","):
			return true
	return false

static func get_tested_functions() -> Array:
	return [
		"_on_achievements_pressed", "set_achievement_manager",
		"show_achievement", "show_panel", "hide_panel",
		"_update_texts", "_on_language_changed",
		"populate_achievements", "_update_display",
		"_on_achievement_unlocked", "_on_combo_changed",
		"_on_poison_effect_removed", "achievement_unlock"
	]
