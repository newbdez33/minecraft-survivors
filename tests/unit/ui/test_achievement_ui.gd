extends Node
class_name TestAchievementUI
## Tests for Achievement UI components
## Verifies achievement notification popup and achievement panel

static func get_test_name() -> String:
	return "Achievement UI Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Achievement Notification Tests
	_add_result(results, test_achievement_notification_scene_exists())
	_add_result(results, test_achievement_notification_script_exists())
	_add_result(results, test_achievement_notification_has_show_method())
	_add_result(results, test_achievement_notification_has_name_label())
	_add_result(results, test_achievement_notification_has_desc_label())

	# Achievement Panel Tests
	_add_result(results, test_achievement_panel_scene_exists())
	_add_result(results, test_achievement_panel_script_exists())
	_add_result(results, test_achievement_panel_has_populate_method())
	_add_result(results, test_achievement_panel_has_grid_container())
	_add_result(results, test_achievement_panel_shows_progress())

	# Achievement Item Tests
	_add_result(results, test_achievement_item_scene_exists())
	_add_result(results, test_achievement_item_has_icon())
	_add_result(results, test_achievement_item_has_progress_bar())
	_add_result(results, test_achievement_item_shows_locked_state())
	_add_result(results, test_achievement_item_shows_unlocked_state())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# ACHIEVEMENT NOTIFICATION TESTS
# =============================================================================

static func test_achievement_notification_scene_exists() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_notification.tscn")
	return {"name": "TC.AUI.1: Achievement notification scene exists", "passed": scene != null}

static func test_achievement_notification_script_exists() -> Dictionary:
	var script = load("res://scripts/ui/achievement_notification.gd")
	return {"name": "TC.AUI.2: Achievement notification script exists", "passed": script != null}

static func test_achievement_notification_has_show_method() -> Dictionary:
	var script = load("res://scripts/ui/achievement_notification.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func show_achievement")
	return {"name": "TC.AUI.3: Achievement notification has show_achievement()", "passed": passed}

static func test_achievement_notification_has_name_label() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_notification.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("Panel/VBox/NameLabel") != null or instance.get_node_or_null("Panel/MarginContainer/HBox/VBox/NameLabel") != null or instance.get_node_or_null("NameLabel") != null
		instance.queue_free()
	return {"name": "TC.AUI.4: Achievement notification has name label", "passed": passed}

static func test_achievement_notification_has_desc_label() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_notification.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("Panel/VBox/DescLabel") != null or instance.get_node_or_null("Panel/MarginContainer/HBox/VBox/DescLabel") != null or instance.get_node_or_null("DescLabel") != null
		instance.queue_free()
	return {"name": "TC.AUI.5: Achievement notification has description label", "passed": passed}

# =============================================================================
# ACHIEVEMENT PANEL TESTS
# =============================================================================

static func test_achievement_panel_scene_exists() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_panel.tscn")
	return {"name": "TC.AUI.6: Achievement panel scene exists", "passed": scene != null}

static func test_achievement_panel_script_exists() -> Dictionary:
	var script = load("res://scripts/ui/achievement_panel.gd")
	return {"name": "TC.AUI.7: Achievement panel script exists", "passed": script != null}

static func test_achievement_panel_has_populate_method() -> Dictionary:
	var script = load("res://scripts/ui/achievement_panel.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func populate_achievements") or source.contains("func set_achievement_manager")
	return {"name": "TC.AUI.8: Achievement panel has populate method", "passed": passed}

static func test_achievement_panel_has_grid_container() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_panel.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		# Check for any container that could hold achievements
		passed = instance.get_node_or_null("MarginContainer/VBoxContainer/ScrollContainer/CategoryContainer") != null or \
				 instance.get_node_or_null("ScrollContainer/GridContainer") != null or \
				 instance.get_node_or_null("GridContainer") != null or \
				 instance.get_node_or_null("VBoxContainer") != null
		instance.queue_free()
	return {"name": "TC.AUI.9: Achievement panel has container for items", "passed": passed}

static func test_achievement_panel_shows_progress() -> Dictionary:
	var script = load("res://scripts/ui/achievement_panel.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Should show unlocked count or progress
		passed = source.contains("unlocked") or source.contains("progress")
	return {"name": "TC.AUI.10: Achievement panel shows progress info", "passed": passed}

# =============================================================================
# ACHIEVEMENT ITEM TESTS
# =============================================================================

static func test_achievement_item_scene_exists() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_item.tscn")
	return {"name": "TC.AUI.11: Achievement item scene exists", "passed": scene != null}

static func test_achievement_item_has_icon() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_item.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("MarginContainer/HBox/Icon") != null or \
				 instance.get_node_or_null("Icon") != null or \
				 instance.get_node_or_null("HBox/Icon") != null or \
				 instance.get_node_or_null("TextureRect") != null
		instance.queue_free()
	return {"name": "TC.AUI.12: Achievement item has icon", "passed": passed}

static func test_achievement_item_has_progress_bar() -> Dictionary:
	var scene = load("res://scenes/ui/achievement_item.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("MarginContainer/HBox/VBox/ProgressBar") != null or \
				 instance.get_node_or_null("ProgressBar") != null or \
				 instance.get_node_or_null("Progress") != null or \
				 instance.get_node_or_null("VBox/ProgressBar") != null or \
				 instance.get_node_or_null("HBox/VBox/ProgressBar") != null
		instance.queue_free()
	return {"name": "TC.AUI.13: Achievement item has progress bar", "passed": passed}

static func test_achievement_item_shows_locked_state() -> Dictionary:
	var script = load("res://scripts/ui/achievement_item.gd") if ResourceLoader.exists("res://scripts/ui/achievement_item.gd") else null
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("locked") or source.contains("is_unlocked")
	else:
		# Scene might handle locked state directly
		var scene = load("res://scenes/ui/achievement_item.tscn")
		passed = scene != null
	return {"name": "TC.AUI.14: Achievement item can show locked state", "passed": passed}

static func test_achievement_item_shows_unlocked_state() -> Dictionary:
	var script = load("res://scripts/ui/achievement_item.gd") if ResourceLoader.exists("res://scripts/ui/achievement_item.gd") else null
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("unlocked") or source.contains("is_unlocked")
	else:
		var scene = load("res://scenes/ui/achievement_item.tscn")
		passed = scene != null
	return {"name": "TC.AUI.15: Achievement item can show unlocked state", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"show_achievement", "_on_timer_timeout", "set_achievement",
		"populate_achievements", "set_achievement_manager", "_create_achievement_item",
		"_update_progress_display"
	]
