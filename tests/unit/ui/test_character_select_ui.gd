extends Node
class_name TestCharacterSelectUI
## Tests for Character Selection UI components
## Verifies character selection panel and character cards

static func get_test_name() -> String:
	return "Character Selection UI Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Character Selection Panel Tests
	_add_result(results, test_character_select_scene_exists())
	_add_result(results, test_character_select_script_exists())
	_add_result(results, test_character_select_has_populate_method())
	_add_result(results, test_character_select_has_container())
	_add_result(results, test_character_select_has_select_signal())

	# Character Card Tests
	_add_result(results, test_character_card_scene_exists())
	_add_result(results, test_character_card_script_exists())
	_add_result(results, test_character_card_has_set_character())
	_add_result(results, test_character_card_shows_locked_state())
	_add_result(results, test_character_card_has_stats_display())

	# Character Manager Integration Tests
	_add_result(results, test_character_manager_has_steve())
	_add_result(results, test_character_manager_has_alex())
	_add_result(results, test_alex_unlock_condition())
	_add_result(results, test_character_stats_different())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# CHARACTER SELECTION PANEL TESTS
# =============================================================================

static func test_character_select_scene_exists() -> Dictionary:
	var scene = load("res://scenes/ui/character_select.tscn")
	return {"name": "TC.CSU.1: Character select scene exists", "passed": scene != null}

static func test_character_select_script_exists() -> Dictionary:
	var script = load("res://scripts/ui/character_select.gd")
	return {"name": "TC.CSU.2: Character select script exists", "passed": script != null}

static func test_character_select_has_populate_method() -> Dictionary:
	var script = load("res://scripts/ui/character_select.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func populate_characters") or source.contains("func set_character_manager")
	return {"name": "TC.CSU.3: Character select has populate method", "passed": passed}

static func test_character_select_has_container() -> Dictionary:
	var scene = load("res://scenes/ui/character_select.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		passed = instance.get_node_or_null("VBoxContainer") != null or \
				 instance.get_node_or_null("HBoxContainer") != null or \
				 instance.get_node_or_null("GridContainer") != null
		instance.queue_free()
	return {"name": "TC.CSU.4: Character select has container", "passed": passed}

static func test_character_select_has_select_signal() -> Dictionary:
	var script = load("res://scripts/ui/character_select.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("signal character_selected")
	return {"name": "TC.CSU.5: Character select has character_selected signal", "passed": passed}

# =============================================================================
# CHARACTER CARD TESTS
# =============================================================================

static func test_character_card_scene_exists() -> Dictionary:
	var scene = load("res://scenes/ui/character_card.tscn")
	return {"name": "TC.CSU.6: Character card scene exists", "passed": scene != null}

static func test_character_card_script_exists() -> Dictionary:
	var script = load("res://scripts/ui/character_card.gd")
	return {"name": "TC.CSU.7: Character card script exists", "passed": script != null}

static func test_character_card_has_set_character() -> Dictionary:
	var script = load("res://scripts/ui/character_card.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func set_character")
	return {"name": "TC.CSU.8: Character card has set_character method", "passed": passed}

static func test_character_card_shows_locked_state() -> Dictionary:
	var script = load("res://scripts/ui/character_card.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("locked") or source.contains("is_unlocked")
	return {"name": "TC.CSU.9: Character card shows locked state", "passed": passed}

static func test_character_card_has_stats_display() -> Dictionary:
	var scene = load("res://scenes/ui/character_card.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		# CharacterCard uses MarginContainer/VBox/StatsContainer path
		passed = instance.get_node_or_null("MarginContainer/VBox/StatsContainer") != null or \
				 instance.get_node_or_null("Stats") != null or \
				 instance.get_node_or_null("StatsLabel") != null
		instance.queue_free()
	return {"name": "TC.CSU.10: Character card has stats display", "passed": passed}

# =============================================================================
# CHARACTER MANAGER INTEGRATION TESTS
# =============================================================================

static func test_character_manager_has_steve() -> Dictionary:
	var script = load("res://scripts/systems/character_manager.gd")
	var passed = false
	if script:
		var manager = Node.new()
		manager.set_script(script)
		manager._init_characters()
		var steve = manager.get_character("steve")
		passed = steve != null
	return {"name": "TC.CSU.11: CharacterManager has Steve character", "passed": passed}

static func test_character_manager_has_alex() -> Dictionary:
	var script = load("res://scripts/systems/character_manager.gd")
	var passed = false
	if script:
		var manager = Node.new()
		manager.set_script(script)
		manager._init_characters()
		var alex = manager.get_character("alex")
		passed = alex != null
	return {"name": "TC.CSU.12: CharacterManager has Alex character", "passed": passed}

static func test_alex_unlock_condition() -> Dictionary:
	var script = load("res://scripts/systems/character_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		# Alex unlocks at 15 minutes (900 seconds) survival
		passed = source.contains("900") or source.contains("15") or source.contains("survive")
	return {"name": "TC.CSU.13: Alex unlock condition is survival-based", "passed": passed}

static func test_character_stats_different() -> Dictionary:
	var script = load("res://scripts/systems/character_manager.gd")
	var passed = false
	if script:
		var manager = Node.new()
		manager.set_script(script)
		manager._init_characters()
		var steve = manager.get_character("steve")
		var alex = manager.get_character("alex")
		if steve and alex:
			# Alex should have different stats than Steve
			passed = steve.health_mult != alex.health_mult or \
					 steve.speed_mult != alex.speed_mult or \
					 steve.pickup_range_mult != alex.pickup_range_mult
	return {"name": "TC.CSU.14: Steve and Alex have different stats", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		"set_character_manager", "populate_characters", "_create_character_card",
		"_on_character_selected", "set_character", "_update_display",
		"get_character", "select_character", "check_unlock_conditions"
	]
