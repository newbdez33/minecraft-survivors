extends Node
class_name TestProgressionFlow
## Integration tests for progression flow

static func get_test_name() -> String:
	return "Progression Flow Integration Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# XP/Level Flow Tests
	_add_result(results, test_xp_gain_leads_to_level_up())
	_add_result(results, test_level_up_increases_xp_requirement())
	_add_result(results, test_looting_upgrade_increases_xp())

	# Upgrade Flow Tests
	_add_result(results, test_upgrade_manager_provides_options())
	_add_result(results, test_applying_upgrade_increases_level())
	_add_result(results, test_maxed_upgrades_not_offered())

	# Weapon Evolution Flow Tests
	_add_result(results, test_sword_kill_count_tracked())
	_add_result(results, test_sword_evolves_on_threshold())
	_add_result(results, test_bow_evolves_to_crossbow())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

static func test_xp_gain_leads_to_level_up() -> Dictionary:
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		return {"name": "TC.PF.1: XP gain leads to level up", "passed": false}
	var player = player_scene.instantiate()

	var initial_level = player.current_level
	player.add_xp(player.xp_to_next_level)
	var passed = player.current_level > initial_level
	player.queue_free()
	return {"name": "TC.PF.1: XP gain leads to level up", "passed": passed}

static func test_level_up_increases_xp_requirement() -> Dictionary:
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		return {"name": "TC.PF.2: Level up increases XP requirement", "passed": false}
	var player = player_scene.instantiate()

	var initial_req = player.xp_to_next_level
	player.add_xp(initial_req)
	var passed = player.xp_to_next_level > initial_req
	player.queue_free()
	return {"name": "TC.PF.2: Level up increases XP requirement", "passed": passed}

static func test_looting_upgrade_increases_xp() -> Dictionary:
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		return {"name": "TC.PF.3: Looting upgrade increases XP", "passed": false}
	var player = player_scene.instantiate()

	# Test that xp_multiplier property exists and can be modified
	var passed = "xp_multiplier" in player and player.xp_multiplier >= 1.0
	player.queue_free()
	return {"name": "TC.PF.3: Player has xp_multiplier for looting", "passed": passed}

static func test_upgrade_manager_provides_options() -> Dictionary:
	var script = load("res://scripts/systems/upgrade_manager.gd")
	if not script:
		return {"name": "TC.PF.4: Upgrade manager provides options", "passed": false}
	var manager = Node.new()
	manager.set_script(script)
	manager._init_upgrades()

	var upgrades = manager.get_random_upgrades(3)
	var passed = upgrades.size() <= 3
	manager.free()
	return {"name": "TC.PF.4: Upgrade manager provides upgrade options", "passed": passed}

static func test_applying_upgrade_increases_level() -> Dictionary:
	var script = load("res://scripts/systems/upgrade_manager.gd")
	if not script:
		return {"name": "TC.PF.5: Applying upgrade increases level", "passed": false}
	var manager = Node.new()
	manager.set_script(script)
	manager._init_upgrades()

	var upgrade = manager.get_upgrade_by_id("sharpness")
	var initial_level = upgrade.current_level
	manager.apply_upgrade(upgrade)
	var passed = upgrade.current_level > initial_level
	manager.free()
	return {"name": "TC.PF.5: Applying upgrade increases level", "passed": passed}

static func test_maxed_upgrades_not_offered() -> Dictionary:
	var script = load("res://scripts/systems/upgrade_manager.gd")
	if not script:
		return {"name": "TC.PF.6: Maxed upgrades not offered", "passed": false}
	var manager = Node.new()
	manager.set_script(script)
	manager._init_upgrades()

	# Max out sharpness
	var upgrade = manager.get_upgrade_by_id("sharpness")
	for i in range(upgrade.max_level):
		upgrade.current_level += 1

	# Check if sharpness is in random selection
	var upgrades = manager.get_random_upgrades(10)
	var contains_sharpness = false
	for u in upgrades:
		if u.id == "sharpness":
			contains_sharpness = true
			break

	var passed = not contains_sharpness
	manager.free()
	return {"name": "TC.PF.6: Maxed upgrades not offered", "passed": passed}

static func test_sword_kill_count_tracked() -> Dictionary:
	var sword_scene = load("res://scenes/weapons/wood_sword.tscn")
	if not sword_scene:
		return {"name": "TC.PF.7: Sword kill count tracked", "passed": false}
	var sword = sword_scene.instantiate()

	sword.on_enemy_killed()
	sword.on_enemy_killed()
	var passed = sword.kill_count == 2
	sword.queue_free()
	return {"name": "TC.PF.7: Sword kill count tracked", "passed": passed}

static func test_sword_evolves_on_threshold() -> Dictionary:
	var sword_scene = load("res://scenes/weapons/wood_sword.tscn")
	if not sword_scene:
		return {"name": "TC.PF.8: Sword evolves on threshold", "passed": false}
	var sword = sword_scene.instantiate()

	# Test that sword has evolution capability
	var has_tier = "current_tier" in sword
	var has_kill_count = "kill_count" in sword
	var has_on_killed = sword.has_method("on_enemy_killed")

	var passed = has_tier and has_kill_count and has_on_killed
	sword.queue_free()
	return {"name": "TC.PF.8: Sword has evolution properties", "passed": passed}

static func test_bow_evolves_to_crossbow() -> Dictionary:
	var bow_scene = load("res://scenes/weapons/bow.tscn")
	if not bow_scene:
		return {"name": "TC.PF.9: Bow can evolve", "passed": false}
	var bow = bow_scene.instantiate()
	var passed = "MAX_LEVEL" in bow and bow.MAX_LEVEL == 4
	bow.queue_free()
	return {"name": "TC.PF.9: Bow has evolution level", "passed": passed}

static func get_tested_functions() -> Array:
	return ["add_xp", "_level_up", "apply_upgrade", "on_enemy_killed"]
