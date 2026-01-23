extends SceneTree
## Test Runner for Minecraft Survivors (TDD)
## Run with: godot --headless --script tests/test_runner.gd
##
## TDD Workflow:
## 1. Write tests (Red) - Tests fail
## 2. Implement (Green) - Tests pass
## 3. Refactor - Keep tests passing

var tests_passed: int = 0
var tests_failed: int = 0
var tests_skipped: int = 0
var test_results: Array = []

# Set to true to run Phase 2 tests (will fail until implemented)
const RUN_PHASE2_TESTS: bool = true
# Set to true to run Phase 3 tests (TDD - will fail until implemented)
const RUN_PHASE3_TESTS: bool = true
# Set to true to run Phase 4 tests (TDD - will fail until implemented)
const RUN_PHASE4_TESTS: bool = true

func _init() -> void:
	print("\n" + "=".repeat(60))
	print("  MINECRAFT SURVIVORS - TEST SUITE (TDD)")
	print("=".repeat(60) + "\n")

	# Phase 1 Tests (should all pass)
	print("[PHASE 1: Core Foundation]")
	print("")
	_run_test_suite("Player Tests", _test_player)
	_run_test_suite("Camera Tests", _test_camera)
	_run_test_suite("Arena Tests", _test_arena)
	_run_test_suite("Asset Tests", _test_assets)

	# Phase 2 Tests (TDD - write first, implement later)
	if RUN_PHASE2_TESTS:
		print("[PHASE 2: Combat Basics - TDD]")
		print("")
		_run_test_suite("Health Component Tests", _test_health_component)
		_run_test_suite("Zombie Tests", _test_zombie)
		_run_test_suite("Diamond Sword Tests", _test_diamond_sword)
		_run_test_suite("Mob Spawner Tests", _test_spawner)
		_run_test_suite("HUD Tests", _test_hud)

	# Phase 3 Tests (TDD - write first, implement later)
	if RUN_PHASE3_TESTS:
		print("[PHASE 3: Progression Loop - TDD]")
		print("")
		_run_test_suite("XP Orb Tests", _test_xp_orb)
		_run_test_suite("XP/Level System Tests", _test_xp_level_system)
		_run_test_suite("XP Bar HUD Tests", _test_xp_bar)
		_run_test_suite("Upgrade System Tests", _test_upgrade_system)
		_run_test_suite("Upgrade UI Tests", _test_upgrade_ui)
		_run_test_suite("Skeleton Tests", _test_skeleton)
		_run_test_suite("Arrow Tests", _test_arrow)
		_run_test_suite("Creeper Tests", _test_creeper)
		_run_test_suite("Spider Tests", _test_spider)

	# Phase 4 Tests (TDD - write first, implement later)
	if RUN_PHASE4_TESTS:
		print("[PHASE 4: Game Feel - TDD]")
		print("")
		_run_test_suite("Game Stats Tests", _test_game_stats)
		_run_test_suite("Day/Night Cycle Tests", _test_day_night_cycle)
		_run_test_suite("Wave Manager Tests", _test_wave_manager)
		_run_test_suite("Game Over UI Tests", _test_game_over_ui)
		_run_test_suite("Localization Tests", _test_localization)

	# Print summary
	_print_summary()

	# Exit with appropriate code
	quit(0 if tests_failed == 0 else 1)

func _run_test_suite(suite_name: String, test_func: Callable) -> void:
	print("[SUITE] " + suite_name)
	print("-".repeat(40))
	test_func.call()
	print("")

func _assert_true(condition: bool, test_name: String) -> void:
	if condition:
		tests_passed += 1
		test_results.append({"name": test_name, "passed": true})
		print("  ✓ " + test_name)
	else:
		tests_failed += 1
		test_results.append({"name": test_name, "passed": false})
		print("  ✗ " + test_name + " [FAILED]")

func _assert_false(condition: bool, test_name: String) -> void:
	_assert_true(not condition, test_name)

func _assert_equal(actual, expected, test_name: String) -> void:
	var passed = actual == expected
	if passed:
		_assert_true(true, test_name)
	else:
		_assert_true(false, test_name + " (expected: " + str(expected) + ", got: " + str(actual) + ")")

func _assert_not_null(value, test_name: String) -> void:
	_assert_true(value != null, test_name)

func _assert_null(value, test_name: String) -> void:
	_assert_true(value == null, test_name)

func _skip_test(test_name: String, reason: String = "") -> void:
	tests_skipped += 1
	var msg = "  ○ " + test_name + " [SKIPPED]"
	if reason:
		msg += " - " + reason
	print(msg)

func _print_summary() -> void:
	print("=".repeat(60))
	print("  TEST SUMMARY")
	print("=".repeat(60))
	print("  Passed:  " + str(tests_passed))
	print("  Failed:  " + str(tests_failed))
	print("  Skipped: " + str(tests_skipped))
	print("  Total:   " + str(tests_passed + tests_failed + tests_skipped))
	print("")
	if tests_failed == 0:
		print("  ✓ ALL TESTS PASSED!")
	else:
		print("  ✗ " + str(tests_failed) + " TEST(S) FAILED")
		print("")
		print("  TDD Tip: Implement features to make tests pass!")
	print("=".repeat(60) + "\n")

# =============================================================================
# PHASE 1: CORE FOUNDATION TESTS
# =============================================================================

func _test_player() -> void:
	var player_script = load("res://scripts/player.gd")
	_assert_not_null(player_script, "Player script loads")

	var player_scene = load("res://scenes/player.tscn")
	_assert_not_null(player_scene, "Player scene loads")

	if player_scene:
		var player = player_scene.instantiate()
		_assert_not_null(player, "Player can be instantiated")
		_assert_true(player.has_node("Sprite2D"), "Player has Sprite2D")
		_assert_true(player.has_node("CollisionShape2D"), "Player has CollisionShape2D")
		_assert_true(player.speed > 0, "Player has positive speed")
		_assert_true(player is CharacterBody2D, "Player is CharacterBody2D")
		player.free()

func _test_camera() -> void:
	var camera_script = load("res://scripts/camera.gd")
	_assert_not_null(camera_script, "Camera script loads")

	var main_scene = load("res://scenes/main.tscn")
	_assert_not_null(main_scene, "Main scene loads")

	if main_scene:
		var main = main_scene.instantiate()
		var camera = main.get_node_or_null("Camera2D")
		_assert_not_null(camera, "Main scene has Camera2D")
		main.free()

func _test_arena() -> void:
	var arena_script = load("res://scripts/arena.gd")
	_assert_not_null(arena_script, "Arena script loads")

	var main_scene = load("res://scenes/main.tscn")
	if main_scene:
		var main = main_scene.instantiate()
		var arena = main.get_node_or_null("Arena")
		_assert_not_null(arena, "Main scene has Arena")
		if arena:
			_assert_equal(arena.tile_size, 32, "Arena tile_size is 32")
		main.free()

func _test_assets() -> void:
	var characters = ["steve", "zombie", "skeleton", "creeper", "spider", "enderman", "witch"]
	for c in characters:
		_assert_true(ResourceLoader.exists("res://assets/characters/" + c + ".svg"), "Asset: " + c + ".svg")

	var tiles = ["grass", "grass_variant1", "grass_variant2", "dirt"]
	for t in tiles:
		_assert_true(ResourceLoader.exists("res://assets/tiles/" + t + ".svg"), "Asset: " + t + ".svg")

	var weapons = ["diamond_sword", "bow", "arrow", "potion"]
	for w in weapons:
		_assert_true(ResourceLoader.exists("res://assets/weapons/" + w + ".svg"), "Asset: " + w + ".svg")

	var items = ["xp_orb", "heart_full", "heart_half", "heart_empty"]
	for i in items:
		_assert_true(ResourceLoader.exists("res://assets/items/" + i + ".svg"), "Asset: " + i + ".svg")

	var effects = ["hit_effect", "death_poof", "explosion"]
	for e in effects:
		_assert_true(ResourceLoader.exists("res://assets/effects/" + e + ".svg"), "Asset: " + e + ".svg")

	var ui_icons = ["sun", "moon"]
	for u in ui_icons:
		_assert_true(ResourceLoader.exists("res://assets/ui/" + u + ".svg"), "Asset: " + u + ".svg")

# =============================================================================
# PHASE 2: COMBAT BASICS TESTS (TDD - Write First)
# =============================================================================

func _test_health_component() -> void:
	# T2.4.1: Health component script exists
	var health_script = load("res://scripts/components/health.gd")
	_assert_not_null(health_script, "T2.4.1: Health component script loads")

	if health_script:
		var health = Node.new()
		health.set_script(health_script)

		# T2.4.2: Health has max_health property
		_assert_true("max_health" in health, "T2.4.2: Health has max_health property")

		# T2.4.3: Health has current_health property
		_assert_true("current_health" in health, "T2.4.3: Health has current_health property")

		# T2.4.4: Health has take_damage method
		_assert_true(health.has_method("take_damage"), "T2.4.4: Health has take_damage method")

		# T2.4.5: Health has heal method
		_assert_true(health.has_method("heal"), "T2.4.5: Health has heal method")

		# T2.4.6: Health has is_dead method
		_assert_true(health.has_method("is_dead"), "T2.4.6: Health has is_dead method")

		health.free()
	else:
		# Script doesn't exist yet - fail remaining tests
		_assert_true(false, "T2.4.2: Health has max_health property")
		_assert_true(false, "T2.4.3: Health has current_health property")
		_assert_true(false, "T2.4.4: Health has take_damage method")
		_assert_true(false, "T2.4.5: Health has heal method")
		_assert_true(false, "T2.4.6: Health has is_dead method")

func _test_zombie() -> void:
	# T2.2.1: Zombie script exists
	var zombie_script = load("res://scripts/enemies/zombie.gd")
	_assert_not_null(zombie_script, "T2.2.1: Zombie script loads")

	# T2.2.2: Zombie scene exists
	var zombie_scene = load("res://scenes/enemies/zombie.tscn")
	_assert_not_null(zombie_scene, "T2.2.2: Zombie scene loads")

	if zombie_scene:
		var zombie = zombie_scene.instantiate()

		# T2.2.3: Zombie has health
		_assert_true("health" in zombie or zombie.has_node("HealthComponent"), "T2.2.3: Zombie has health")

		# T2.2.4: Zombie has speed
		_assert_true("speed" in zombie, "T2.2.4: Zombie has speed property")

		# T2.2.5: Zombie has damage
		_assert_true("damage" in zombie, "T2.2.5: Zombie has damage property")

		# T2.2.6: Zombie has Sprite2D
		_assert_true(zombie.has_node("Sprite2D"), "T2.2.6: Zombie has Sprite2D")

		# T2.2.7: Zombie has CollisionShape2D
		_assert_true(zombie.has_node("CollisionShape2D"), "T2.2.7: Zombie has CollisionShape2D")

		# T2.2.8: Zombie is CharacterBody2D
		_assert_true(zombie is CharacterBody2D, "T2.2.8: Zombie is CharacterBody2D")

		zombie.free()
	else:
		_assert_true(false, "T2.2.3: Zombie has health")
		_assert_true(false, "T2.2.4: Zombie has speed property")
		_assert_true(false, "T2.2.5: Zombie has damage property")
		_assert_true(false, "T2.2.6: Zombie has Sprite2D")
		_assert_true(false, "T2.2.7: Zombie has CollisionShape2D")
		_assert_true(false, "T2.2.8: Zombie is CharacterBody2D")

func _test_diamond_sword() -> void:
	# T2.1.1: Sword script exists
	var sword_script = load("res://scripts/weapons/diamond_sword.gd")
	_assert_not_null(sword_script, "T2.1.1: Diamond Sword script loads")

	# T2.1.2: Sword scene exists
	var sword_scene = load("res://scenes/weapons/diamond_sword.tscn")
	_assert_not_null(sword_scene, "T2.1.2: Diamond Sword scene loads")

	if sword_scene:
		var sword = sword_scene.instantiate()

		# T2.1.3: Sword has damage property
		_assert_true("damage" in sword, "T2.1.3: Sword has damage property")

		# T2.1.4: Sword has attack_range property
		_assert_true("attack_range" in sword, "T2.1.4: Sword has attack_range property")

		# T2.1.5: Sword has attack_cooldown property
		_assert_true("attack_cooldown" in sword, "T2.1.5: Sword has attack_cooldown property")

		# T2.1.6: Sword is Area2D
		_assert_true(sword is Area2D, "T2.1.6: Sword is Area2D")

		sword.free()
	else:
		_assert_true(false, "T2.1.3: Sword has damage property")
		_assert_true(false, "T2.1.4: Sword has attack_range property")
		_assert_true(false, "T2.1.5: Sword has attack_cooldown property")
		_assert_true(false, "T2.1.6: Sword is Area2D")

func _test_spawner() -> void:
	# T2.3.1: Spawner script exists
	var spawner_script = load("res://scripts/spawner.gd")
	_assert_not_null(spawner_script, "T2.3.1: Spawner script loads")

	if spawner_script:
		var spawner = Node.new()
		spawner.set_script(spawner_script)

		# T2.3.2: Spawner has spawn_interval property
		_assert_true("spawn_interval" in spawner, "T2.3.2: Spawner has spawn_interval property")

		# T2.3.3: Spawner has max_enemies property
		_assert_true("max_enemies" in spawner, "T2.3.3: Spawner has max_enemies property")

		# T2.3.4: Spawner has spawn_radius_min property
		_assert_true("spawn_radius_min" in spawner, "T2.3.4: Spawner has spawn_radius_min property")

		# T2.3.5: Spawner has spawn_radius_max property
		_assert_true("spawn_radius_max" in spawner, "T2.3.5: Spawner has spawn_radius_max property")

		spawner.free()
	else:
		_assert_true(false, "T2.3.2: Spawner has spawn_interval property")
		_assert_true(false, "T2.3.3: Spawner has max_enemies property")
		_assert_true(false, "T2.3.4: Spawner has spawn_radius_min property")
		_assert_true(false, "T2.3.5: Spawner has spawn_radius_max property")

func _test_hud() -> void:
	# T2.4.7: HUD script exists
	var hud_script = load("res://scripts/ui/hud.gd")
	_assert_not_null(hud_script, "T2.4.7: HUD script loads")

	# T2.4.8: HUD scene exists
	var hud_scene = load("res://scenes/ui/hud.tscn")
	_assert_not_null(hud_scene, "T2.4.8: HUD scene loads")

	if hud_scene:
		var hud = hud_scene.instantiate()

		# T2.4.9: HUD has update_health method
		_assert_true(hud.has_method("update_health"), "T2.4.9: HUD has update_health method")

		# T2.4.10: HUD is CanvasLayer
		_assert_true(hud is CanvasLayer, "T2.4.10: HUD is CanvasLayer")

		hud.free()
	else:
		_assert_true(false, "T2.4.9: HUD has update_health method")
		_assert_true(false, "T2.4.10: HUD is CanvasLayer")

# =============================================================================
# PHASE 3: PROGRESSION LOOP TESTS (TDD - Write First)
# =============================================================================

func _test_xp_orb() -> void:
	# T3.1.1: XP orb script exists
	var xp_orb_script = load("res://scripts/pickups/xp_orb.gd")
	_assert_not_null(xp_orb_script, "T3.1.1: XP orb script loads")

	# T3.1.2: XP orb scene exists
	var xp_orb_scene = load("res://scenes/pickups/xp_orb.tscn")
	_assert_not_null(xp_orb_scene, "T3.1.2: XP orb scene loads")

	if xp_orb_scene:
		var xp_orb = xp_orb_scene.instantiate()

		# T3.1.3: XP orb has xp_value property
		_assert_true("xp_value" in xp_orb, "T3.1.3: XP orb has xp_value property")

		# T3.1.4: XP orb has pickup_radius property
		_assert_true("pickup_radius" in xp_orb, "T3.1.4: XP orb has pickup_radius property")

		# T3.1.5: XP orb has attract_radius property
		_assert_true("attract_radius" in xp_orb, "T3.1.5: XP orb has attract_radius property")

		# T3.1.6: XP orb is Area2D
		_assert_true(xp_orb is Area2D, "T3.1.6: XP orb is Area2D")

		# T3.1.7: XP orb has collected signal
		_assert_true(xp_orb.has_signal("collected"), "T3.1.7: XP orb has collected signal")

		xp_orb.free()
	else:
		_assert_true(false, "T3.1.3: XP orb has xp_value property")
		_assert_true(false, "T3.1.4: XP orb has pickup_radius property")
		_assert_true(false, "T3.1.5: XP orb has attract_radius property")
		_assert_true(false, "T3.1.6: XP orb is Area2D")
		_assert_true(false, "T3.1.7: XP orb has collected signal")

func _test_xp_level_system() -> void:
	var player_scene = load("res://scenes/player.tscn")
	if player_scene:
		var player = player_scene.instantiate()

		# T3.2.1: Player has current_xp property
		_assert_true("current_xp" in player, "T3.2.1: Player has current_xp property")

		# T3.2.2: Player has current_level property
		_assert_true("current_level" in player, "T3.2.2: Player has current_level property")

		# T3.2.3: Player has add_xp method
		_assert_true(player.has_method("add_xp"), "T3.2.3: Player has add_xp method")

		# T3.2.4: Player has xp_to_next_level property
		_assert_true("xp_to_next_level" in player, "T3.2.4: Player has xp_to_next_level property")

		# T3.2.5: Player has leveled_up signal
		_assert_true(player.has_signal("leveled_up"), "T3.2.5: Player has leveled_up signal")

		# T3.2.6: Player has xp_changed signal
		_assert_true(player.has_signal("xp_changed"), "T3.2.6: Player has xp_changed signal")

		player.free()
	else:
		_assert_true(false, "T3.2.1: Player has current_xp property")
		_assert_true(false, "T3.2.2: Player has current_level property")
		_assert_true(false, "T3.2.3: Player has add_xp method")
		_assert_true(false, "T3.2.4: Player has xp_to_next_level property")
		_assert_true(false, "T3.2.5: Player has leveled_up signal")
		_assert_true(false, "T3.2.6: Player has xp_changed signal")

func _test_xp_bar() -> void:
	var hud_scene = load("res://scenes/ui/hud.tscn")
	if hud_scene:
		var hud = hud_scene.instantiate()

		# T3.3.1: HUD has update_xp method
		_assert_true(hud.has_method("update_xp"), "T3.3.1: HUD has update_xp method")

		# T3.3.2: HUD has set_level method
		_assert_true(hud.has_method("set_level"), "T3.3.2: HUD has set_level method")

		# T3.3.3: HUD has XPBar node
		_assert_true(hud.has_node("MarginContainer/VBoxContainer/XPBar") or hud.has_node("XPBar"), "T3.3.3: HUD has XPBar node")

		# T3.3.4: HUD has LevelLabel node
		_assert_true(hud.has_node("MarginContainer/VBoxContainer/LevelLabel") or hud.has_node("LevelLabel"), "T3.3.4: HUD has LevelLabel node")

		hud.free()
	else:
		_assert_true(false, "T3.3.1: HUD has update_xp method")
		_assert_true(false, "T3.3.2: HUD has set_level method")
		_assert_true(false, "T3.3.3: HUD has XPBar node")
		_assert_true(false, "T3.3.4: HUD has LevelLabel node")

func _test_upgrade_system() -> void:
	# T3.4.1: Upgrade manager script exists
	var upgrade_manager_script = load("res://scripts/systems/upgrade_manager.gd")
	_assert_not_null(upgrade_manager_script, "T3.4.1: Upgrade manager script loads")

	# T3.4.2: Upgrade script exists
	var upgrade_script = load("res://scripts/systems/upgrade.gd")
	_assert_not_null(upgrade_script, "T3.4.2: Upgrade script loads")

	if upgrade_manager_script:
		var manager = Node.new()
		manager.set_script(upgrade_manager_script)

		# T3.4.3: Manager has available_upgrades property
		_assert_true("available_upgrades" in manager, "T3.4.3: Manager has available_upgrades property")

		# T3.4.4: Manager has get_random_upgrades method
		_assert_true(manager.has_method("get_random_upgrades"), "T3.4.4: Manager has get_random_upgrades method")

		# T3.4.5: Manager has apply_upgrade method
		_assert_true(manager.has_method("apply_upgrade"), "T3.4.5: Manager has apply_upgrade method")

		manager.free()
	else:
		_assert_true(false, "T3.4.3: Manager has available_upgrades property")
		_assert_true(false, "T3.4.4: Manager has get_random_upgrades method")
		_assert_true(false, "T3.4.5: Manager has apply_upgrade method")

	if upgrade_script:
		var upgrade = RefCounted.new()
		upgrade.set_script(upgrade_script)

		# T3.4.6: Upgrade has id property
		_assert_true("id" in upgrade, "T3.4.6: Upgrade has id property")

		# T3.4.7: Upgrade has current_level property
		_assert_true("current_level" in upgrade, "T3.4.7: Upgrade has current_level property")
	else:
		_assert_true(false, "T3.4.6: Upgrade has id property")
		_assert_true(false, "T3.4.7: Upgrade has current_level property")

func _test_upgrade_ui() -> void:
	# T3.5.1: Upgrade UI script exists
	var upgrade_ui_script = load("res://scripts/ui/upgrade_ui.gd")
	_assert_not_null(upgrade_ui_script, "T3.5.1: Upgrade UI script loads")

	# T3.5.2: Upgrade UI scene exists
	var upgrade_ui_scene = load("res://scenes/ui/upgrade_ui.tscn")
	_assert_not_null(upgrade_ui_scene, "T3.5.2: Upgrade UI scene loads")

	if upgrade_ui_scene:
		var ui = upgrade_ui_scene.instantiate()

		# T3.5.3: UI has show_upgrades method
		_assert_true(ui.has_method("show_upgrades"), "T3.5.3: Upgrade UI has show_upgrades method")

		# T3.5.4: UI has hide method
		_assert_true(ui.has_method("hide") or ui.has_method("hide_ui"), "T3.5.4: Upgrade UI has hide method")

		# T3.5.5: UI has upgrade_selected signal
		_assert_true(ui.has_signal("upgrade_selected"), "T3.5.5: Upgrade UI has upgrade_selected signal")

		# T3.5.6: UI is CanvasLayer
		_assert_true(ui is CanvasLayer, "T3.5.6: Upgrade UI is CanvasLayer")

		ui.free()
	else:
		_assert_true(false, "T3.5.3: Upgrade UI has show_upgrades method")
		_assert_true(false, "T3.5.4: Upgrade UI has hide method")
		_assert_true(false, "T3.5.5: Upgrade UI has upgrade_selected signal")
		_assert_true(false, "T3.5.6: Upgrade UI is CanvasLayer")

func _test_skeleton() -> void:
	# T3.6.1: Skeleton script exists
	var skeleton_script = load("res://scripts/enemies/skeleton.gd")
	_assert_not_null(skeleton_script, "T3.6.1: Skeleton script loads")

	# T3.6.2: Skeleton scene exists
	var skeleton_scene = load("res://scenes/enemies/skeleton.tscn")
	_assert_not_null(skeleton_scene, "T3.6.2: Skeleton scene loads")

	if skeleton_scene:
		var skeleton = skeleton_scene.instantiate()

		# T3.6.3: Skeleton has health property
		_assert_true("health" in skeleton, "T3.6.3: Skeleton has health property")

		# T3.6.4: Skeleton has speed property
		_assert_true("speed" in skeleton, "T3.6.4: Skeleton has speed property")

		# T3.6.5: Skeleton has shoot_arrow method
		_assert_true(skeleton.has_method("shoot_arrow"), "T3.6.5: Skeleton has shoot_arrow method")

		# T3.6.6: Skeleton has attack_range property
		_assert_true("attack_range" in skeleton, "T3.6.6: Skeleton has attack_range property")

		# T3.6.7: Skeleton is CharacterBody2D
		_assert_true(skeleton is CharacterBody2D, "T3.6.7: Skeleton is CharacterBody2D")

		skeleton.free()
	else:
		_assert_true(false, "T3.6.3: Skeleton has health property")
		_assert_true(false, "T3.6.4: Skeleton has speed property")
		_assert_true(false, "T3.6.5: Skeleton has shoot_arrow method")
		_assert_true(false, "T3.6.6: Skeleton has attack_range property")
		_assert_true(false, "T3.6.7: Skeleton is CharacterBody2D")

func _test_arrow() -> void:
	# T3.6.8: Arrow script exists
	var arrow_script = load("res://scripts/projectiles/arrow.gd")
	_assert_not_null(arrow_script, "T3.6.8: Arrow script loads")

	# T3.6.9: Arrow scene exists
	var arrow_scene = load("res://scenes/projectiles/arrow.tscn")
	_assert_not_null(arrow_scene, "T3.6.9: Arrow scene loads")

	if arrow_scene:
		var arrow = arrow_scene.instantiate()

		# T3.6.10: Arrow has speed property
		_assert_true("speed" in arrow, "T3.6.10: Arrow has speed property")

		# T3.6.11: Arrow has damage property
		_assert_true("damage" in arrow, "T3.6.11: Arrow has damage property")

		# T3.6.12: Arrow is Area2D
		_assert_true(arrow is Area2D, "T3.6.12: Arrow is Area2D")

		arrow.free()
	else:
		_assert_true(false, "T3.6.10: Arrow has speed property")
		_assert_true(false, "T3.6.11: Arrow has damage property")
		_assert_true(false, "T3.6.12: Arrow is Area2D")

func _test_creeper() -> void:
	# T3.6.13: Creeper script exists
	var creeper_script = load("res://scripts/enemies/creeper.gd")
	_assert_not_null(creeper_script, "T3.6.13: Creeper script loads")

	# T3.6.14: Creeper scene exists
	var creeper_scene = load("res://scenes/enemies/creeper.tscn")
	_assert_not_null(creeper_scene, "T3.6.14: Creeper scene loads")

	if creeper_scene:
		var creeper = creeper_scene.instantiate()

		# T3.6.15: Creeper has health property
		_assert_true("health" in creeper, "T3.6.15: Creeper has health property")

		# T3.6.16: Creeper has explosion_damage property
		_assert_true("explosion_damage" in creeper, "T3.6.16: Creeper has explosion_damage property")

		# T3.6.17: Creeper has fuse_time property
		_assert_true("fuse_time" in creeper, "T3.6.17: Creeper has fuse_time property")

		# T3.6.18: Creeper has start_fuse method
		_assert_true(creeper.has_method("start_fuse"), "T3.6.18: Creeper has start_fuse method")

		# T3.6.19: Creeper has explode method
		_assert_true(creeper.has_method("explode"), "T3.6.19: Creeper has explode method")

		# T3.6.20: Creeper is CharacterBody2D
		_assert_true(creeper is CharacterBody2D, "T3.6.20: Creeper is CharacterBody2D")

		creeper.free()
	else:
		_assert_true(false, "T3.6.15: Creeper has health property")
		_assert_true(false, "T3.6.16: Creeper has explosion_damage property")
		_assert_true(false, "T3.6.17: Creeper has fuse_time property")
		_assert_true(false, "T3.6.18: Creeper has start_fuse method")
		_assert_true(false, "T3.6.19: Creeper has explode method")
		_assert_true(false, "T3.6.20: Creeper is CharacterBody2D")

func _test_spider() -> void:
	# T3.6.21: Spider script exists
	var spider_script = load("res://scripts/enemies/spider.gd")
	_assert_not_null(spider_script, "T3.6.21: Spider script loads")

	# T3.6.22: Spider scene exists
	var spider_scene = load("res://scenes/enemies/spider.tscn")
	_assert_not_null(spider_scene, "T3.6.22: Spider scene loads")

	if spider_scene:
		var spider = spider_scene.instantiate()

		# T3.6.23: Spider has health property
		_assert_true("health" in spider, "T3.6.23: Spider has health property")

		# T3.6.24: Spider has speed property
		_assert_true("speed" in spider, "T3.6.24: Spider has speed property")

		# T3.6.25: Spider has jump method
		_assert_true(spider.has_method("jump"), "T3.6.25: Spider has jump method")

		# T3.6.26: Spider is CharacterBody2D
		_assert_true(spider is CharacterBody2D, "T3.6.26: Spider is CharacterBody2D")

		spider.free()
	else:
		_assert_true(false, "T3.6.23: Spider has health property")
		_assert_true(false, "T3.6.24: Spider has speed property")
		_assert_true(false, "T3.6.25: Spider has jump method")
		_assert_true(false, "T3.6.26: Spider is CharacterBody2D")

# =============================================================================
# PHASE 4: GAME FEEL TESTS (TDD)
# =============================================================================

func _test_game_stats() -> void:
	# T4.4.1: GameStats script loads
	var game_stats_script = load("res://scripts/systems/game_stats.gd")
	_assert_not_null(game_stats_script, "T4.4.1: GameStats script loads")

	if game_stats_script:
		var game_stats = game_stats_script.new()

		# T4.4.2: GameStats has survival_time property
		_assert_true("survival_time" in game_stats, "T4.4.2: GameStats has survival_time property")

		# T4.4.3: GameStats has kills property
		_assert_true("kills" in game_stats, "T4.4.3: GameStats has kills property")

		# T4.4.4: GameStats has add_kill method
		_assert_true(game_stats.has_method("add_kill"), "T4.4.4: GameStats has add_kill method")

		# T4.4.5: GameStats has reset method
		_assert_true(game_stats.has_method("reset"), "T4.4.5: GameStats has reset method")

		# T4.4.6: GameStats has get_stats method
		_assert_true(game_stats.has_method("get_stats"), "T4.4.6: GameStats has get_stats method")

		game_stats.free()
	else:
		_assert_true(false, "T4.4.2: GameStats has survival_time property")
		_assert_true(false, "T4.4.3: GameStats has kills property")
		_assert_true(false, "T4.4.4: GameStats has add_kill method")
		_assert_true(false, "T4.4.5: GameStats has reset method")
		_assert_true(false, "T4.4.6: GameStats has get_stats method")

func _test_day_night_cycle() -> void:
	# T4.1.1: DayNightCycle script loads
	var day_night_script = load("res://scripts/systems/day_night_cycle.gd")
	_assert_not_null(day_night_script, "T4.1.1: DayNightCycle script loads")

	if day_night_script:
		var day_night = day_night_script.new()

		# T4.1.2: DayNightCycle has current_time property
		_assert_true("current_time" in day_night, "T4.1.2: DayNightCycle has current_time property")

		# T4.1.3: DayNightCycle has day_duration property
		_assert_true("day_duration" in day_night, "T4.1.3: DayNightCycle has day_duration property")

		# T4.1.4: DayNightCycle has night_duration property
		_assert_true("night_duration" in day_night, "T4.1.4: DayNightCycle has night_duration property")

		# T4.1.5: DayNightCycle has is_night method
		_assert_true(day_night.has_method("is_night"), "T4.1.5: DayNightCycle has is_night method")

		# T4.1.6: DayNightCycle has get_time_of_day method
		_assert_true(day_night.has_method("get_time_of_day"), "T4.1.6: DayNightCycle has get_time_of_day method")

		# T4.1.7: DayNightCycle has time_changed signal
		_assert_true(day_night.has_signal("time_changed"), "T4.1.7: DayNightCycle has time_changed signal")

		# T4.1.8: DayNightCycle has night_started signal
		_assert_true(day_night.has_signal("night_started"), "T4.1.8: DayNightCycle has night_started signal")

		# T4.1.9: DayNightCycle has day_started signal
		_assert_true(day_night.has_signal("day_started"), "T4.1.9: DayNightCycle has day_started signal")

		day_night.free()
	else:
		_assert_true(false, "T4.1.2: DayNightCycle has current_time property")
		_assert_true(false, "T4.1.3: DayNightCycle has day_duration property")
		_assert_true(false, "T4.1.4: DayNightCycle has night_duration property")
		_assert_true(false, "T4.1.5: DayNightCycle has is_night method")
		_assert_true(false, "T4.1.6: DayNightCycle has get_time_of_day method")
		_assert_true(false, "T4.1.7: DayNightCycle has time_changed signal")
		_assert_true(false, "T4.1.8: DayNightCycle has night_started signal")
		_assert_true(false, "T4.1.9: DayNightCycle has day_started signal")

func _test_wave_manager() -> void:
	# T4.2.1: WaveManager script loads
	var wave_script = load("res://scripts/systems/wave_manager.gd")
	_assert_not_null(wave_script, "T4.2.1: WaveManager script loads")

	if wave_script:
		var wave_manager = wave_script.new()

		# T4.2.2: WaveManager has current_wave property
		_assert_true("current_wave" in wave_manager, "T4.2.2: WaveManager has current_wave property")

		# T4.2.3: WaveManager has wave_interval property
		_assert_true("wave_interval" in wave_manager, "T4.2.3: WaveManager has wave_interval property")

		# T4.2.4: WaveManager has start_wave method
		_assert_true(wave_manager.has_method("start_wave"), "T4.2.4: WaveManager has start_wave method")

		# T4.2.5: WaveManager has get_enemies_for_wave method
		_assert_true(wave_manager.has_method("get_enemies_for_wave"), "T4.2.5: WaveManager has get_enemies_for_wave method")

		# T4.2.6: WaveManager has wave_started signal
		_assert_true(wave_manager.has_signal("wave_started"), "T4.2.6: WaveManager has wave_started signal")

		# T4.2.7: WaveManager has wave_completed signal
		_assert_true(wave_manager.has_signal("wave_completed"), "T4.2.7: WaveManager has wave_completed signal")

		# T4.2.8: WaveManager scales enemies per wave
		var wave1_enemies = wave_manager.get_enemies_for_wave(1)
		var wave5_enemies = wave_manager.get_enemies_for_wave(5)
		_assert_true(wave5_enemies > wave1_enemies, "T4.2.8: WaveManager scales enemies per wave")

		wave_manager.free()
	else:
		_assert_true(false, "T4.2.2: WaveManager has current_wave property")
		_assert_true(false, "T4.2.3: WaveManager has wave_interval property")
		_assert_true(false, "T4.2.4: WaveManager has start_wave method")
		_assert_true(false, "T4.2.5: WaveManager has get_enemies_for_wave method")
		_assert_true(false, "T4.2.6: WaveManager has wave_started signal")
		_assert_true(false, "T4.2.7: WaveManager has wave_completed signal")
		_assert_true(false, "T4.2.8: WaveManager scales enemies per wave")

func _test_game_over_ui() -> void:
	# T4.3.1: GameOverUI script loads
	var game_over_script = load("res://scripts/ui/game_over_ui.gd")
	_assert_not_null(game_over_script, "T4.3.1: GameOverUI script loads")

	# T4.3.2: GameOverUI scene loads
	var game_over_scene = load("res://scenes/ui/game_over_ui.tscn")
	_assert_not_null(game_over_scene, "T4.3.2: GameOverUI scene loads")

	if game_over_scene:
		var game_over = game_over_scene.instantiate()

		# T4.3.3: GameOverUI has show_game_over method
		_assert_true(game_over.has_method("show_game_over"), "T4.3.3: GameOverUI has show_game_over method")

		# T4.3.4: GameOverUI has set_stats method
		_assert_true(game_over.has_method("set_stats"), "T4.3.4: GameOverUI has set_stats method")

		# T4.3.5: GameOverUI has restart_pressed signal
		_assert_true(game_over.has_signal("restart_pressed"), "T4.3.5: GameOverUI has restart_pressed signal")

		# T4.3.6: GameOverUI has quit_pressed signal
		_assert_true(game_over.has_signal("quit_pressed"), "T4.3.6: GameOverUI has quit_pressed signal")

		# T4.3.7: GameOverUI is CanvasLayer
		_assert_true(game_over is CanvasLayer, "T4.3.7: GameOverUI is CanvasLayer")

		game_over.free()
	else:
		_assert_true(false, "T4.3.3: GameOverUI has show_game_over method")
		_assert_true(false, "T4.3.4: GameOverUI has set_stats method")
		_assert_true(false, "T4.3.5: GameOverUI has restart_pressed signal")
		_assert_true(false, "T4.3.6: GameOverUI has quit_pressed signal")
		_assert_true(false, "T4.3.7: GameOverUI is CanvasLayer")

func _test_localization() -> void:
	# T4.7.1: LocalizationManager script loads
	var loc_script = load("res://scripts/systems/localization_manager.gd")
	_assert_not_null(loc_script, "T4.7.1: LocalizationManager script loads")

	if loc_script:
		var loc_manager = loc_script.new()

		# T4.7.2: LocalizationManager has set_language method
		_assert_true(loc_manager.has_method("set_language"), "T4.7.2: LocalizationManager has set_language method")

		# T4.7.3: LocalizationManager has get_current_language method
		_assert_true(loc_manager.has_method("get_current_language"), "T4.7.3: LocalizationManager has get_current_language method")

		# T4.7.4: LocalizationManager has get_available_languages method
		_assert_true(loc_manager.has_method("get_available_languages"), "T4.7.4: LocalizationManager has get_available_languages method")

		# T4.7.5: LocalizationManager has language_changed signal
		_assert_true(loc_manager.has_signal("language_changed"), "T4.7.5: LocalizationManager has language_changed signal")

		# T4.7.6: LocalizationManager supports English
		var langs = loc_manager.get_available_languages()
		_assert_true("en" in langs, "T4.7.6: LocalizationManager supports English")

		# T4.7.7: LocalizationManager supports Japanese
		_assert_true("ja" in langs, "T4.7.7: LocalizationManager supports Japanese")

		# T4.7.8: LocalizationManager supports Chinese
		_assert_true("zh" in langs, "T4.7.8: LocalizationManager supports Chinese")

		loc_manager.free()
	else:
		_assert_true(false, "T4.7.2: LocalizationManager has set_language method")
		_assert_true(false, "T4.7.3: LocalizationManager has get_current_language method")
		_assert_true(false, "T4.7.4: LocalizationManager has get_available_languages method")
		_assert_true(false, "T4.7.5: LocalizationManager has language_changed signal")
		_assert_true(false, "T4.7.6: LocalizationManager supports English")
		_assert_true(false, "T4.7.7: LocalizationManager supports Japanese")
		_assert_true(false, "T4.7.8: LocalizationManager supports Chinese")
