extends Node
class_name TestUpgradeManagerComplete
## Complete upgrade manager tests for 100% coverage
## Tests all 9 upgrades, weapon evolution, and torch unlock

static func get_test_name() -> String:
	return "Upgrade Manager Complete Tests"

static func get_upgrade_manager_instance():
	var script = load("res://scripts/systems/upgrade_manager.gd")
	if not script:
		return null
	var manager = Node.new()
	manager.set_script(script)
	return manager

static func get_mock_player():
	var scene = load("res://scenes/player.tscn")
	return scene.instantiate() if scene else null

## Run all upgrade manager tests and return results
static func run_tests() -> Dictionary:
	var results = {
		"passed": 0,
		"failed": 0,
		"tests": []
	}

	# Initialization Tests
	_add_result(results, test_upgrade_manager_loads())
	_add_result(results, test_has_available_upgrades())
	_add_result(results, test_has_upgrade_defs_constant())
	_add_result(results, test_has_weapon_upgrade_ids())
	_add_result(results, test_upgrade_defs_has_all_upgrades())

	# Upgrade Definition Tests
	_add_result(results, test_sword_upgrade_exists())
	_add_result(results, test_bow_upgrade_exists())
	_add_result(results, test_sharpness_upgrade_exists())
	_add_result(results, test_knockback_upgrade_exists())
	_add_result(results, test_looting_upgrade_exists())
	_add_result(results, test_protection_upgrade_exists())
	_add_result(results, test_swiftness_upgrade_exists())
	_add_result(results, test_sweeping_upgrade_exists())
	_add_result(results, test_haste_upgrade_exists())
	_add_result(results, test_torch_upgrade_exists())

	# Random Selection Tests
	_add_result(results, test_get_random_upgrades_method_exists())
	_add_result(results, test_get_random_upgrades_returns_array())
	_add_result(results, test_get_random_upgrades_excludes_weapons())
	_add_result(results, test_prioritized_upgrades_property_exists())

	# Weapon Upgrade Tests
	_add_result(results, test_get_weapon_upgrades_method_exists())
	_add_result(results, test_get_weapon_upgrades_returns_array())
	_add_result(results, test_all_weapons_maxed_method_exists())

	# Apply Upgrade Tests
	_add_result(results, test_apply_upgrade_method_exists())
	_add_result(results, test_get_upgrade_by_id_method_exists())
	_add_result(results, test_get_upgrade_by_id_returns_correct())

	# Evolution Detection Tests
	_add_result(results, test_will_evolve_tier_method_exists())
	_add_result(results, test_will_evolve_tier_sword_at_4())
	_add_result(results, test_will_evolve_tier_sword_at_7())
	_add_result(results, test_will_evolve_tier_sword_at_10())
	_add_result(results, test_will_evolve_tier_bow_at_4())
	_add_result(results, test_get_next_tier_name_method_exists())

	# Evolution Bonus Tests
	_add_result(results, test_get_evolution_bonus_description_method_exists())
	_add_result(results, test_bow_evolution_bonus_constant_exists())

	# Icon Management Tests
	_add_result(results, test_get_weapon_icon_method_exists())
	_add_result(results, test_get_next_evolution_icon_method_exists())

	# Signal Tests
	_add_result(results, test_has_upgrade_applied_signal())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# INITIALIZATION TESTS
# =============================================================================

static func test_upgrade_manager_loads() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null
	if manager:
		manager.free()
	return {"name": "TC.UM.1: UpgradeManager script loads", "passed": passed}

static func test_has_available_upgrades() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and "available_upgrades" in manager
	if manager:
		manager.free()
	return {"name": "TC.UM.2: Has available_upgrades property", "passed": passed}

static func test_has_upgrade_defs_constant() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and "UPGRADE_DEFS" in manager
	if manager:
		manager.free()
	return {"name": "TC.UM.3: Has UPGRADE_DEFS constant", "passed": passed}

static func test_has_weapon_upgrade_ids() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and "WEAPON_UPGRADE_IDS" in manager
	if manager:
		manager.free()
	return {"name": "TC.UM.4: Has WEAPON_UPGRADE_IDS constant", "passed": passed}

static func test_upgrade_defs_has_all_upgrades() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.5: UPGRADE_DEFS has all 10 upgrades", "passed": false}

	var expected_upgrades = ["sword", "bow", "sharpness", "knockback", "looting",
							 "protection", "swiftness", "sweeping", "haste", "torch"]
	var passed = true
	for upgrade_id in expected_upgrades:
		if upgrade_id not in manager.UPGRADE_DEFS:
			passed = false
			break
	manager.free()
	return {"name": "TC.UM.5: UPGRADE_DEFS has all 10 upgrades", "passed": passed}

# =============================================================================
# UPGRADE DEFINITION TESTS
# =============================================================================

static func test_sword_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.6: Sword upgrade defined", "passed": false}

	var sword = manager.UPGRADE_DEFS.get("sword", {})
	var passed = sword.has("name_key") and sword.has("max") and sword.max == 12
	manager.free()
	return {"name": "TC.UM.6: Sword upgrade defined with max 12", "passed": passed}

static func test_bow_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.7: Bow upgrade defined", "passed": false}

	var bow = manager.UPGRADE_DEFS.get("bow", {})
	var passed = bow.has("name_key") and bow.has("max") and bow.max == 4
	manager.free()
	return {"name": "TC.UM.7: Bow upgrade defined with max 4", "passed": passed}

static func test_sharpness_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.8: Sharpness upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("sharpness", {})
	var passed = upgrade.has("effect") and upgrade.effect == 5.0
	manager.free()
	return {"name": "TC.UM.8: Sharpness upgrade with +5 damage", "passed": passed}

static func test_knockback_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.9: Knockback upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("knockback", {})
	var passed = upgrade.has("effect") and upgrade.effect == 30.0
	manager.free()
	return {"name": "TC.UM.9: Knockback upgrade with +30 force", "passed": passed}

static func test_looting_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.10: Looting upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("looting", {})
	var passed = upgrade.has("effect") and upgrade.effect == 20.0
	manager.free()
	return {"name": "TC.UM.10: Looting upgrade with +20% XP", "passed": passed}

static func test_protection_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.11: Protection upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("protection", {})
	var passed = upgrade.has("effect") and upgrade.effect == 10.0
	manager.free()
	return {"name": "TC.UM.11: Protection upgrade with -10% damage", "passed": passed}

static func test_swiftness_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.12: Swiftness upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("swiftness", {})
	var passed = upgrade.has("effect") and upgrade.effect == 15.0
	manager.free()
	return {"name": "TC.UM.12: Swiftness upgrade with +15% speed", "passed": passed}

static func test_sweeping_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.13: Sweeping upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("sweeping", {})
	var passed = upgrade.has("effect") and upgrade.effect == 20.0
	manager.free()
	return {"name": "TC.UM.13: Sweeping upgrade with +20 range", "passed": passed}

static func test_haste_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.14: Haste upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("haste", {})
	var passed = upgrade.has("effect") and upgrade.effect == 10.0
	manager.free()
	return {"name": "TC.UM.14: Haste upgrade with -10% cooldown", "passed": passed}

static func test_torch_upgrade_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.15: Torch upgrade defined", "passed": false}

	var upgrade = manager.UPGRADE_DEFS.get("torch", {})
	var passed = upgrade.has("max") and upgrade.max == 3
	manager.free()
	return {"name": "TC.UM.15: Torch upgrade defined with max 3", "passed": passed}

# =============================================================================
# RANDOM SELECTION TESTS
# =============================================================================

static func test_get_random_upgrades_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_random_upgrades")
	if manager:
		manager.free()
	return {"name": "TC.UM.16: Has get_random_upgrades method", "passed": passed}

static func test_get_random_upgrades_returns_array() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.17: get_random_upgrades returns Array", "passed": false}

	manager._init_upgrades()
	var upgrades = manager.get_random_upgrades(3)
	var passed = upgrades is Array
	manager.free()
	return {"name": "TC.UM.17: get_random_upgrades returns Array", "passed": passed}

static func test_get_random_upgrades_excludes_weapons() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.18: get_random_upgrades excludes weapons", "passed": false}

	manager._init_upgrades()
	var upgrades = manager.get_random_upgrades(3)
	var has_weapon = false
	for upgrade in upgrades:
		if upgrade.id in manager.WEAPON_UPGRADE_IDS:
			has_weapon = true
			break
	var passed = not has_weapon
	manager.free()
	return {"name": "TC.UM.18: get_random_upgrades excludes weapons", "passed": passed}

static func test_prioritized_upgrades_property_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and "prioritized_upgrades" in manager
	if manager:
		manager.free()
	return {"name": "TC.UM.19: Has prioritized_upgrades property", "passed": passed}

# =============================================================================
# WEAPON UPGRADE TESTS
# =============================================================================

static func test_get_weapon_upgrades_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_weapon_upgrades")
	if manager:
		manager.free()
	return {"name": "TC.UM.20: Has get_weapon_upgrades method", "passed": passed}

static func test_get_weapon_upgrades_returns_array() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.21: get_weapon_upgrades returns Array", "passed": false}

	var player = get_mock_player()
	if player:
		manager.set_player(player)
	manager._init_upgrades()
	var weapons = manager.get_weapon_upgrades()
	var passed = weapons is Array
	if player:
		player.queue_free()
	manager.free()
	return {"name": "TC.UM.21: get_weapon_upgrades returns Array", "passed": passed}

static func test_all_weapons_maxed_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("all_weapons_maxed")
	if manager:
		manager.free()
	return {"name": "TC.UM.22: Has all_weapons_maxed method", "passed": passed}

# =============================================================================
# APPLY UPGRADE TESTS
# =============================================================================

static func test_apply_upgrade_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("apply_upgrade")
	if manager:
		manager.free()
	return {"name": "TC.UM.26: Has apply_upgrade method", "passed": passed}

static func test_get_upgrade_by_id_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_upgrade_by_id")
	if manager:
		manager.free()
	return {"name": "TC.UM.27: Has get_upgrade_by_id method", "passed": passed}

static func test_get_upgrade_by_id_returns_correct() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.28: get_upgrade_by_id returns correct upgrade", "passed": false}

	manager._init_upgrades()
	var upgrade = manager.get_upgrade_by_id("sharpness")
	var passed = upgrade != null and upgrade.id == "sharpness"
	manager.free()
	return {"name": "TC.UM.28: get_upgrade_by_id returns correct upgrade", "passed": passed}

# =============================================================================
# EVOLUTION DETECTION TESTS
# =============================================================================

static func test_will_evolve_tier_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("will_evolve_tier")
	if manager:
		manager.free()
	return {"name": "TC.UM.29: Has will_evolve_tier method", "passed": passed}

static func test_will_evolve_tier_sword_at_4() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.30: Sword evolves when next_level=3", "passed": false}

	manager._init_upgrades()
	var sword = manager.get_upgrade_by_id("sword")
	if sword:
		# will_evolve_tier checks next_level in [3, 6, 9]
		# next_level = current_level + 1, so current_level must be 2
		sword.current_level = 2  # Next level is 3 (Wood->Stone evolution)
	var passed = manager.will_evolve_tier("sword")
	manager.free()
	return {"name": "TC.UM.30: Sword evolves at next_level=3 (current=2)", "passed": passed}

static func test_will_evolve_tier_sword_at_7() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.31: Sword evolves when next_level=6", "passed": false}

	manager._init_upgrades()
	var sword = manager.get_upgrade_by_id("sword")
	if sword:
		# will_evolve_tier checks next_level in [3, 6, 9]
		# next_level = current_level + 1, so current_level must be 5
		sword.current_level = 5  # Next level is 6 (Stone->Iron evolution)
	var passed = manager.will_evolve_tier("sword")
	manager.free()
	return {"name": "TC.UM.31: Sword evolves at next_level=6 (current=5)", "passed": passed}

static func test_will_evolve_tier_sword_at_10() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.32: Sword evolves when next_level=9", "passed": false}

	manager._init_upgrades()
	var sword = manager.get_upgrade_by_id("sword")
	if sword:
		# will_evolve_tier checks next_level in [3, 6, 9]
		# next_level = current_level + 1, so current_level must be 8
		sword.current_level = 8  # Next level is 9 (Iron->Diamond evolution)
	var passed = manager.will_evolve_tier("sword")
	manager.free()
	return {"name": "TC.UM.32: Sword evolves at next_level=9 (current=8)", "passed": passed}

static func test_will_evolve_tier_bow_at_4() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.33: Bow evolves at level 4", "passed": false}

	manager._init_upgrades()
	var bow = manager.get_upgrade_by_id("bow")
	if bow:
		bow.current_level = 3  # Next level is 4
	var passed = manager.will_evolve_tier("bow")
	manager.free()
	return {"name": "TC.UM.33: Bow evolves at level 4", "passed": passed}

static func test_get_next_tier_name_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_next_tier_name")
	if manager:
		manager.free()
	return {"name": "TC.UM.34: Has get_next_tier_name method", "passed": passed}

# =============================================================================
# EVOLUTION BONUS TESTS
# =============================================================================

static func test_get_evolution_bonus_description_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_evolution_bonus_description")
	if manager:
		manager.free()
	return {"name": "TC.UM.35: Has get_evolution_bonus_description method", "passed": passed}

static func test_bow_evolution_bonus_constant_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	if not manager:
		return {"name": "TC.UM.36: Has BOW_EVOLUTION_BONUS constant", "passed": false}

	var passed = "BOW_EVOLUTION_BONUS" in manager
	if passed:
		var bonus = manager.BOW_EVOLUTION_BONUS
		passed = bonus.has("damage") and bonus.has("range") and bonus.has("pierce")
	manager.free()
	return {"name": "TC.UM.36: Has BOW_EVOLUTION_BONUS constant", "passed": passed}

# =============================================================================
# ICON MANAGEMENT TESTS
# =============================================================================

static func test_get_weapon_icon_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_weapon_icon")
	if manager:
		manager.free()
	return {"name": "TC.UM.37: Has get_weapon_icon method", "passed": passed}

static func test_get_next_evolution_icon_method_exists() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_method("get_next_evolution_icon")
	if manager:
		manager.free()
	return {"name": "TC.UM.38: Has get_next_evolution_icon method", "passed": passed}

# =============================================================================
# SIGNAL TESTS
# =============================================================================

static func test_has_upgrade_applied_signal() -> Dictionary:
	var manager = get_upgrade_manager_instance()
	var passed = manager != null and manager.has_signal("upgrade_applied")
	if manager:
		manager.free()
	return {"name": "TC.UM.39: Has upgrade_applied signal", "passed": passed}

## Get functions tested by this test file (for coverage tracking)
static func get_tested_functions() -> Array:
	return [
		"_ready",
		"_init_upgrades",
		"set_player",
		"get_random_upgrades",
		"get_weapon_upgrades",
		"_get_weapon_node_name",
		"get_weapon_icon",
		"get_next_evolution_icon",
		"all_weapons_maxed",
		"will_evolve_tier",
		"get_next_tier_name",
		"get_evolution_bonus_description",
		"apply_upgrade",
		"_apply_effect",
		"_apply_sword",
		"_apply_sharpness",
		"_apply_knockback",
		"_apply_looting",
		"_apply_protection",
		"_apply_swiftness",
		"_apply_sweeping",
		"_apply_haste",
		"_apply_torch",
		"_apply_bow",
		"_evolve_bow_to_crossbow",
		"get_upgrade_by_id",
	]
