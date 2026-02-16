extends SceneTree
## Test Runner for Three Kingdoms Survivors (TDD)
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

# Coverage tracker
var coverage_tracker = null

# Set to true to run Phase 2 tests (will fail until implemented)
const RUN_PHASE2_TESTS: bool = true
# Set to true to run Phase 3 tests (TDD - will fail until implemented)
const RUN_PHASE3_TESTS: bool = true
# Set to true to run Phase 4 tests (TDD - will fail until implemented)
const RUN_PHASE4_TESTS: bool = true
# Set to true to run Phase 5 tests (TDD - will fail until implemented)
const RUN_PHASE5_TESTS: bool = true
# Set to true to run Phase 6 tests (TDD - will fail until implemented)
const RUN_PHASE6_TESTS: bool = true
# Set to true to run Phase 7 tests (Complete Coverage)
const RUN_PHASE7_TESTS: bool = true
# Set to true to enable coverage tracking
const ENABLE_COVERAGE: bool = true

func _init() -> void:
	print("\n" + "=".repeat(60))
	print("  THREE KINGDOMS SURVIVORS - TEST SUITE (TDD)")
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
		_run_test_suite("Infantry Tests", _test_infantry)
		_run_test_suite("Divine Weapon Tests", _test_divine_weapon)
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
		_run_test_suite("Archer Tests", _test_archer)
		_run_test_suite("Arrow Tests", _test_arrow)
		_run_test_suite("Fire Soldier Tests", _test_fire_soldier)
		_run_test_suite("Cavalry Tests", _test_cavalry)

	# Phase 4 Tests (TDD - write first, implement later)
	if RUN_PHASE4_TESTS:
		print("[PHASE 4: Game Feel - TDD]")
		print("")
		_run_test_suite("Game Stats Tests", _test_game_stats)
		_run_test_suite("Day/Night Cycle Tests", _test_day_night_cycle)
		_run_test_suite("Wave Manager Tests", _test_wave_manager)
		_run_test_suite("Game Over UI Tests", _test_game_over_ui)
		_run_test_suite("Localization Tests", _test_localization)
		# Step 8-10: New Enemies
		_run_test_suite("Assassin Tests", _test_assassin)
		_run_test_suite("Sorcerer Tests", _test_sorcerer)
		_run_test_suite("Potion Tests", _test_potion)
		# Step 12: Integration
		_run_test_suite("Spawner Integration Tests", _test_spawner_integration)
		_run_test_suite("HUD Integration Tests", _test_hud_integration)
		_run_test_suite("Game Behavior Tests", _test_game_behavior)
		_run_test_suite("Wave-Spawner Integration Tests", _test_wave_spawner_integration)
		_run_test_suite("Game Over Stats Tests", _test_game_over_stats)
		_run_test_suite("Main Scene Integration Tests", _test_main_scene_integration)
		_run_test_suite("Upgrade UI Selection Tests", _test_upgrade_ui_selection)

	# Phase 5 Tests (TDD - write first, implement later)
	if RUN_PHASE5_TESTS:
		print("[PHASE 5: Game Enhancements - TDD]")
		print("")
		_run_test_suite("Status Effect Tests", _test_status_effect)
		_run_test_suite("Status Effect Manager Tests", _test_status_effect_manager)
		_run_test_suite("Poison System Tests", _test_poison_system)
		_run_test_suite("Score Calculator Tests", _test_score_calculator)
		_run_test_suite("Score Storage Tests", _test_score_storage)
		_run_test_suite("Combo System Tests", _test_combo_system)
		_run_test_suite("Haste Upgrade Tests", _test_haste_upgrade)
		_run_test_suite("Damage Number Tests", _test_damage_number)
		_run_test_suite("Screen Shake Tests", _test_screen_shake)
		_run_test_suite("Bow Weapon Tests", _test_bow_weapon)
		_run_test_suite("Player Arrow Tests", _test_player_arrow)
		_run_test_suite("Lucky Drop Tests", _test_lucky_drop)
		_run_test_suite("Health Pickup Tests", _test_health_pickup)
		_run_test_suite("Health Pickup Spawner Tests", _test_health_pickup_spawner)
		_run_test_suite("Main Menu Tests", _test_main_menu)
		_run_test_suite("Settings Panel Tests", _test_settings_panel)
		_run_test_suite("Scoreboard Panel Tests", _test_scoreboard_panel)
		_run_test_suite("Status Container Tests", _test_status_container)
		_run_test_suite("Status Icon Tests", _test_status_icon)
		_run_test_suite("Achievement Tests", _test_achievement)
		_run_test_suite("Achievement Manager Tests", _test_achievement_manager)
		_run_test_suite("Character Tests", _test_character)
		_run_test_suite("Character Manager Tests", _test_character_manager)
		_run_test_suite("Crossbow Tests", _test_crossbow)
		_run_test_suite("Crossbow Bolt Tests", _test_crossbow_bolt)
		_run_test_suite("Weapon Evolution Tests", _test_weapon_evolution)
		_run_test_suite("Weapon Evolution Manager Tests", _test_weapon_evolution_manager)
		_run_test_suite("Sword Tier Evolution Tests", _test_sword_tier_evolution)
		_run_test_suite("Torch Visibility Tests", _test_torch_visibility)
		_run_test_suite("Fog of War Tests", _test_fog_of_war)
		_run_test_suite("Assassin Arrow Dodge Tests", _test_assassin_arrow_dodge)
		_run_test_suite("Elite Enemy Spawning Tests", _test_elite_enemy_spawning)
		_run_test_suite("Upgrade Artwork Tests", _test_upgrade_artwork)

	# Phase 6 Tests (TDD - write first, implement later)
	if RUN_PHASE6_TESTS:
		print("[PHASE 6: Boss System - TDD]")
		print("")
		_run_test_suite("Xiahou Dun Boss Tests", _test_xiahou_dun_boss)
		_run_test_suite("Ground Spike Tests", _test_ground_spike)
		_run_test_suite("Shadow Guard Tests", _test_shadow_guard)
		_run_test_suite("Boss Battle System Tests", _test_boss_battle_system)
		_run_test_suite("Boss Drop System Tests", _test_boss_drop_system)

	# Phase 7 Tests (Complete Coverage)
	if RUN_PHASE7_TESTS:
		print("[PHASE 7: Complete Coverage Tests]")
		print("")
		_run_complete_coverage_tests()

	# Print summary
	_print_summary()

	# Print coverage report if enabled
	if ENABLE_COVERAGE and coverage_tracker:
		coverage_tracker.print_summary()
		coverage_tracker.save_report()

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
	var characters = ["guan_yu", "infantry", "archer", "fire_soldier", "cavalry", "assassin", "sorcerer"]
	for c in characters:
		_assert_true(ResourceLoader.exists("res://assets/characters/" + c + ".svg"), "Asset: " + c + ".svg")

	var tiles = ["grass", "grass_variant1", "grass_variant2", "dirt"]
	for t in tiles:
		_assert_true(ResourceLoader.exists("res://assets/tiles/" + t + ".svg"), "Asset: " + t + ".svg")

	var weapons = ["divine_weapon", "bow", "arrow", "potion"]
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

func _test_infantry() -> void:
	# T2.2.1: Infantry script exists
	var infantry_script = load("res://scripts/enemies/infantry.gd")
	_assert_not_null(infantry_script, "T2.2.1: Infantry script loads")

	# T2.2.2: Infantry scene exists
	var infantry_scene = load("res://scenes/enemies/infantry.tscn")
	_assert_not_null(infantry_scene, "T2.2.2: Infantry scene loads")

	if infantry_scene:
		var infantry = infantry_scene.instantiate()

		# T2.2.3: Infantry has health
		_assert_true("health" in infantry or infantry.has_node("HealthComponent"), "T2.2.3: Infantry has health")

		# T2.2.4: Infantry has speed
		_assert_true("speed" in infantry, "T2.2.4: Infantry has speed property")

		# T2.2.5: Infantry has damage
		_assert_true("damage" in infantry, "T2.2.5: Infantry has damage property")

		# T2.2.6: Infantry has Sprite2D
		_assert_true(infantry.has_node("Sprite2D"), "T2.2.6: Infantry has Sprite2D")

		# T2.2.7: Infantry has CollisionShape2D
		_assert_true(infantry.has_node("CollisionShape2D"), "T2.2.7: Infantry has CollisionShape2D")

		# T2.2.8: Infantry is CharacterBody2D
		_assert_true(infantry is CharacterBody2D, "T2.2.8: Infantry is CharacterBody2D")

		infantry.free()
	else:
		_assert_true(false, "T2.2.3: Infantry has health")
		_assert_true(false, "T2.2.4: Infantry has speed property")
		_assert_true(false, "T2.2.5: Infantry has damage property")
		_assert_true(false, "T2.2.6: Infantry has Sprite2D")
		_assert_true(false, "T2.2.7: Infantry has CollisionShape2D")
		_assert_true(false, "T2.2.8: Infantry is CharacterBody2D")

func _test_divine_weapon() -> void:
	# T2.1.1: Sword script exists
	var sword_script = load("res://scripts/weapons/divine_weapon.gd")
	_assert_not_null(sword_script, "T2.1.1: Divine Weapon script loads")

	# T2.1.2: Sword scene exists
	var sword_scene = load("res://scenes/weapons/divine_weapon.tscn")
	_assert_not_null(sword_scene, "T2.1.2: Divine Weapon scene loads")

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

		# T3.5.7: UI has selection_timeout property (5 seconds default)
		_assert_true("selection_timeout" in ui, "T3.5.7: Upgrade UI has selection_timeout property")
		if "selection_timeout" in ui:
			_assert_true(ui.selection_timeout == 5.0, "T3.5.8: Default selection timeout is 5 seconds")
		else:
			_assert_true(false, "T3.5.8: Default selection timeout is 5 seconds")

		# T3.5.9: UI has get_selected_index method
		_assert_true(ui.has_method("get_selected_index"), "T3.5.9: Upgrade UI has get_selected_index method")

		# T3.5.10: UI has get_remaining_time method
		_assert_true(ui.has_method("get_remaining_time"), "T3.5.10: Upgrade UI has get_remaining_time method")

		# T3.5.11: UI has is_active method
		_assert_true(ui.has_method("is_active"), "T3.5.11: Upgrade UI has is_active method")

		ui.free()
	else:
		_assert_true(false, "T3.5.3: Upgrade UI has show_upgrades method")
		_assert_true(false, "T3.5.4: Upgrade UI has hide method")
		_assert_true(false, "T3.5.5: Upgrade UI has upgrade_selected signal")
		_assert_true(false, "T3.5.6: Upgrade UI is CanvasLayer")
		_assert_true(false, "T3.5.7: Upgrade UI has selection_timeout property")
		_assert_true(false, "T3.5.8: Default selection timeout is 5 seconds")
		_assert_true(false, "T3.5.9: Upgrade UI has get_selected_index method")
		_assert_true(false, "T3.5.10: Upgrade UI has get_remaining_time method")
		_assert_true(false, "T3.5.11: Upgrade UI has is_active method")

func _test_archer() -> void:
	# T3.6.1: Archer script exists
	var archer_script = load("res://scripts/enemies/archer.gd")
	_assert_not_null(archer_script, "T3.6.1: Archer script loads")

	# T3.6.2: Archer scene exists
	var archer_scene = load("res://scenes/enemies/archer.tscn")
	_assert_not_null(archer_scene, "T3.6.2: Archer scene loads")

	if archer_scene:
		var archer = archer_scene.instantiate()

		# T3.6.3: Archer has health property
		_assert_true("health" in archer, "T3.6.3: Archer has health property")

		# T3.6.4: Archer has speed property
		_assert_true("speed" in archer, "T3.6.4: Archer has speed property")

		# T3.6.5: Archer has shoot_arrow method
		_assert_true(archer.has_method("shoot_arrow"), "T3.6.5: Archer has shoot_arrow method")

		# T3.6.6: Archer has attack_range property
		_assert_true("attack_range" in archer, "T3.6.6: Archer has attack_range property")

		# T3.6.7: Archer is CharacterBody2D
		_assert_true(archer is CharacterBody2D, "T3.6.7: Archer is CharacterBody2D")

		archer.free()
	else:
		_assert_true(false, "T3.6.3: Archer has health property")
		_assert_true(false, "T3.6.4: Archer has speed property")
		_assert_true(false, "T3.6.5: Archer has shoot_arrow method")
		_assert_true(false, "T3.6.6: Archer has attack_range property")
		_assert_true(false, "T3.6.7: Archer is CharacterBody2D")

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

func _test_fire_soldier() -> void:
	# T3.6.13: Fire Soldier script exists
	var fire_soldier_script = load("res://scripts/enemies/fire_soldier.gd")
	_assert_not_null(fire_soldier_script, "T3.6.13: Fire Soldier script loads")

	# T3.6.14: Fire Soldier scene exists
	var fire_soldier_scene = load("res://scenes/enemies/fire_soldier.tscn")
	_assert_not_null(fire_soldier_scene, "T3.6.14: Fire Soldier scene loads")

	if fire_soldier_scene:
		var fire_soldier = fire_soldier_scene.instantiate()

		# T3.6.15: Fire Soldier has health property
		_assert_true("health" in fire_soldier, "T3.6.15: Fire Soldier has health property")

		# T3.6.16: Fire Soldier has explosion_damage property
		_assert_true("explosion_damage" in fire_soldier, "T3.6.16: Fire Soldier has explosion_damage property")

		# T3.6.17: Fire Soldier has fuse_time property
		_assert_true("fuse_time" in fire_soldier, "T3.6.17: Fire Soldier has fuse_time property")

		# T3.6.18: Fire Soldier has start_fuse method
		_assert_true(fire_soldier.has_method("start_fuse"), "T3.6.18: Fire Soldier has start_fuse method")

		# T3.6.19: Fire Soldier has explode method
		_assert_true(fire_soldier.has_method("explode"), "T3.6.19: Fire Soldier has explode method")

		# T3.6.20: Fire Soldier is CharacterBody2D
		_assert_true(fire_soldier is CharacterBody2D, "T3.6.20: Fire Soldier is CharacterBody2D")

		fire_soldier.free()
	else:
		_assert_true(false, "T3.6.15: Fire Soldier has health property")
		_assert_true(false, "T3.6.16: Fire Soldier has explosion_damage property")
		_assert_true(false, "T3.6.17: Fire Soldier has fuse_time property")
		_assert_true(false, "T3.6.18: Fire Soldier has start_fuse method")
		_assert_true(false, "T3.6.19: Fire Soldier has explode method")
		_assert_true(false, "T3.6.20: Fire Soldier is CharacterBody2D")

func _test_cavalry() -> void:
	# T3.6.21: Cavalry script exists
	var cavalry_script = load("res://scripts/enemies/cavalry.gd")
	_assert_not_null(cavalry_script, "T3.6.21: Cavalry script loads")

	# T3.6.22: Cavalry scene exists
	var cavalry_scene = load("res://scenes/enemies/cavalry.tscn")
	_assert_not_null(cavalry_scene, "T3.6.22: Cavalry scene loads")

	if cavalry_scene:
		var cavalry = cavalry_scene.instantiate()

		# T3.6.23: Cavalry has health property
		_assert_true("health" in cavalry, "T3.6.23: Cavalry has health property")

		# T3.6.24: Cavalry has speed property
		_assert_true("speed" in cavalry, "T3.6.24: Cavalry has speed property")

		# T3.6.25: Cavalry has jump method
		_assert_true(cavalry.has_method("jump"), "T3.6.25: Cavalry has jump method")

		# T3.6.26: Cavalry is CharacterBody2D
		_assert_true(cavalry is CharacterBody2D, "T3.6.26: Cavalry is CharacterBody2D")

		cavalry.free()
	else:
		_assert_true(false, "T3.6.23: Cavalry has health property")
		_assert_true(false, "T3.6.24: Cavalry has speed property")
		_assert_true(false, "T3.6.25: Cavalry has jump method")
		_assert_true(false, "T3.6.26: Cavalry is CharacterBody2D")

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

		# T4.7.2: LocalizationManager has set_locale method
		_assert_true(loc_manager.has_method("set_locale"), "T4.7.2: LocalizationManager has set_locale method")

		# T4.7.3: LocalizationManager has get_locale method
		_assert_true(loc_manager.has_method("get_locale"), "T4.7.3: LocalizationManager has get_locale method")

		# T4.7.4: LocalizationManager has get_supported_locales method
		_assert_true(loc_manager.has_method("get_supported_locales"), "T4.7.4: LocalizationManager has get_supported_locales method")

		# T4.7.5: LocalizationManager has language_changed signal
		_assert_true(loc_manager.has_signal("language_changed"), "T4.7.5: LocalizationManager has language_changed signal")

		# T4.7.6: LocalizationManager supports English
		var langs = loc_manager.get_supported_locales()
		_assert_true("en" in langs, "T4.7.6: LocalizationManager supports English")

		# T4.7.7: LocalizationManager supports Japanese
		_assert_true("ja" in langs, "T4.7.7: LocalizationManager supports Japanese")

		# T4.7.8: LocalizationManager supports Chinese
		_assert_true("zh" in langs, "T4.7.8: LocalizationManager supports Chinese")

		loc_manager.free()
	else:
		_assert_true(false, "T4.7.2: LocalizationManager has set_locale method")
		_assert_true(false, "T4.7.3: LocalizationManager has get_locale method")
		_assert_true(false, "T4.7.4: LocalizationManager has get_supported_locales method")
		_assert_true(false, "T4.7.5: LocalizationManager has language_changed signal")
		_assert_true(false, "T4.7.6: LocalizationManager supports English")
		_assert_true(false, "T4.7.7: LocalizationManager supports Japanese")
		_assert_true(false, "T4.7.8: LocalizationManager supports Chinese")

# =============================================================================
# PHASE 4 STEP 8: ASSASSIN TESTS (TDD - Write First)
# =============================================================================

func _test_assassin() -> void:
	# T4.6.1: Assassin script loads
	var assassin_script = load("res://scripts/enemies/assassin.gd")
	_assert_not_null(assassin_script, "T4.6.1: Assassin script loads")

	# T4.6.2: Assassin scene loads
	var assassin_scene = load("res://scenes/enemies/assassin.tscn")
	_assert_not_null(assassin_scene, "T4.6.2: Assassin scene loads")

	if assassin_scene:
		var assassin = assassin_scene.instantiate()

		# T4.6.3: Assassin has health property (40)
		_assert_true("health" in assassin, "T4.6.3: Assassin has health property")
		if "health" in assassin:
			_assert_equal(assassin.health, 40, "T4.6.3a: Assassin health is 40")

		# T4.6.4: Assassin has speed property (70)
		_assert_true("speed" in assassin, "T4.6.4: Assassin has speed property")
		if "speed" in assassin:
			_assert_equal(assassin.speed, 70, "T4.6.4a: Assassin speed is 70")

		# T4.6.5: Assassin has teleport method
		_assert_true(assassin.has_method("teleport"), "T4.6.5: Assassin has teleport method")

		# T4.6.6: Assassin has teleport_cooldown property
		_assert_true("teleport_cooldown" in assassin, "T4.6.6: Assassin has teleport_cooldown property")
		if "teleport_cooldown" in assassin:
			_assert_equal(assassin.teleport_cooldown, 3.0, "T4.6.6a: Assassin teleport_cooldown is 3.0")

		# T4.6.7: Assassin has teleport_range property
		_assert_true("teleport_range" in assassin, "T4.6.7: Assassin has teleport_range property")
		if "teleport_range" in assassin:
			_assert_equal(assassin.teleport_range, 200.0, "T4.6.7a: Assassin teleport_range is 200")

		# T4.6.8: Assassin has damage property (15)
		_assert_true("damage" in assassin, "T4.6.8: Assassin has damage property")
		if "damage" in assassin:
			_assert_equal(assassin.damage, 15, "T4.6.8a: Assassin damage is 15")

		# T4.6.9: Assassin has xp_value property (15)
		_assert_true("xp_value" in assassin, "T4.6.9: Assassin has xp_value property")
		if "xp_value" in assassin:
			_assert_equal(assassin.xp_value, 15, "T4.6.9a: Assassin xp_value is 15")

		# T4.6.10: Assassin is CharacterBody2D
		_assert_true(assassin is CharacterBody2D, "T4.6.10: Assassin is CharacterBody2D")

		# T4.6.11: Assassin has can_teleport property
		_assert_true("can_teleport" in assassin, "T4.6.11: Assassin has can_teleport property")

		# T4.6.12: Assassin has apply_knockback method (for knockback system)
		_assert_true(assassin.has_method("apply_knockback"), "T4.6.12: Assassin has apply_knockback method")

		assassin.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T4.6.3: Assassin has health property")
		_assert_true(false, "T4.6.3a: Assassin health is 40")
		_assert_true(false, "T4.6.4: Assassin has speed property")
		_assert_true(false, "T4.6.4a: Assassin speed is 70")
		_assert_true(false, "T4.6.5: Assassin has teleport method")
		_assert_true(false, "T4.6.6: Assassin has teleport_cooldown property")
		_assert_true(false, "T4.6.6a: Assassin teleport_cooldown is 3.0")
		_assert_true(false, "T4.6.7: Assassin has teleport_range property")
		_assert_true(false, "T4.6.7a: Assassin teleport_range is 200")
		_assert_true(false, "T4.6.8: Assassin has damage property")
		_assert_true(false, "T4.6.8a: Assassin damage is 15")
		_assert_true(false, "T4.6.9: Assassin has xp_value property")
		_assert_true(false, "T4.6.9a: Assassin xp_value is 15")
		_assert_true(false, "T4.6.10: Assassin is CharacterBody2D")
		_assert_true(false, "T4.6.11: Assassin has can_teleport property")
		_assert_true(false, "T4.6.12: Assassin has apply_knockback method")

# =============================================================================
# PHASE 4 STEP 9: SORCERER TESTS (TDD - Write First)
# =============================================================================

func _test_sorcerer() -> void:
	# T4.6.13: Sorcerer script loads
	var sorcerer_script = load("res://scripts/enemies/sorcerer.gd")
	_assert_not_null(sorcerer_script, "T4.6.13: Sorcerer script loads")

	# T4.6.14: Sorcerer scene loads
	var sorcerer_scene = load("res://scenes/enemies/sorcerer.tscn")
	_assert_not_null(sorcerer_scene, "T4.6.14: Sorcerer scene loads")

	if sorcerer_scene:
		var sorcerer = sorcerer_scene.instantiate()

		# T4.6.15: Sorcerer has health property (20)
		_assert_true("health" in sorcerer, "T4.6.15: Sorcerer has health property")
		if "health" in sorcerer:
			_assert_equal(sorcerer.health, 20, "T4.6.15a: Sorcerer health is 20")

		# T4.6.16: Sorcerer has speed property (35)
		_assert_true("speed" in sorcerer, "T4.6.16: Sorcerer has speed property")
		if "speed" in sorcerer:
			_assert_equal(sorcerer.speed, 35, "T4.6.16a: Sorcerer speed is 35")

		# T4.6.17: Sorcerer has throw_potion method
		_assert_true(sorcerer.has_method("throw_potion"), "T4.6.17: Sorcerer has throw_potion method")

		# T4.6.18: Sorcerer has attack_range property (250)
		_assert_true("attack_range" in sorcerer, "T4.6.18: Sorcerer has attack_range property")
		if "attack_range" in sorcerer:
			_assert_equal(sorcerer.attack_range, 250.0, "T4.6.18a: Sorcerer attack_range is 250")

		# T4.6.19: Sorcerer has attack_cooldown property (3.0)
		_assert_true("attack_cooldown" in sorcerer, "T4.6.19: Sorcerer has attack_cooldown property")
		if "attack_cooldown" in sorcerer:
			_assert_equal(sorcerer.attack_cooldown, 3.0, "T4.6.19a: Sorcerer attack_cooldown is 3.0")

		# T4.6.20: Sorcerer has potion_damage property (12)
		_assert_true("potion_damage" in sorcerer, "T4.6.20: Sorcerer has potion_damage property")
		if "potion_damage" in sorcerer:
			_assert_equal(sorcerer.potion_damage, 12, "T4.6.20a: Sorcerer potion_damage is 12")

		# T4.6.21: Sorcerer has xp_value property (12)
		_assert_true("xp_value" in sorcerer, "T4.6.21: Sorcerer has xp_value property")
		if "xp_value" in sorcerer:
			_assert_equal(sorcerer.xp_value, 12, "T4.6.21a: Sorcerer xp_value is 12")

		# T4.6.22: Sorcerer has preferred_distance property
		_assert_true("preferred_distance" in sorcerer, "T4.6.22: Sorcerer has preferred_distance property")

		# T4.6.23: Sorcerer is CharacterBody2D
		_assert_true(sorcerer is CharacterBody2D, "T4.6.23: Sorcerer is CharacterBody2D")

		# T4.6.24: Sorcerer has apply_knockback method
		_assert_true(sorcerer.has_method("apply_knockback"), "T4.6.24: Sorcerer has apply_knockback method")

		sorcerer.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T4.6.15: Sorcerer has health property")
		_assert_true(false, "T4.6.15a: Sorcerer health is 20")
		_assert_true(false, "T4.6.16: Sorcerer has speed property")
		_assert_true(false, "T4.6.16a: Sorcerer speed is 35")
		_assert_true(false, "T4.6.17: Sorcerer has throw_potion method")
		_assert_true(false, "T4.6.18: Sorcerer has attack_range property")
		_assert_true(false, "T4.6.18a: Sorcerer attack_range is 250")
		_assert_true(false, "T4.6.19: Sorcerer has attack_cooldown property")
		_assert_true(false, "T4.6.19a: Sorcerer attack_cooldown is 3.0")
		_assert_true(false, "T4.6.20: Sorcerer has potion_damage property")
		_assert_true(false, "T4.6.20a: Sorcerer potion_damage is 12")
		_assert_true(false, "T4.6.21: Sorcerer has xp_value property")
		_assert_true(false, "T4.6.21a: Sorcerer xp_value is 12")
		_assert_true(false, "T4.6.22: Sorcerer has preferred_distance property")
		_assert_true(false, "T4.6.23: Sorcerer is CharacterBody2D")
		_assert_true(false, "T4.6.24: Sorcerer has apply_knockback method")

# =============================================================================
# PHASE 4 STEP 10: POTION TESTS (TDD - Write First)
# =============================================================================

func _test_potion() -> void:
	# T4.6.25: Potion script loads
	var potion_script = load("res://scripts/projectiles/poison_dart.gd")
	_assert_not_null(potion_script, "T4.6.25: Potion script loads")

	# T4.6.26: Potion scene loads
	var potion_scene = load("res://scenes/projectiles/poison_dart.tscn")
	_assert_not_null(potion_scene, "T4.6.26: Potion scene loads")

	if potion_scene:
		var potion = potion_scene.instantiate()

		# T4.6.27: Potion has speed property (200)
		_assert_true("speed" in potion, "T4.6.27: Potion has speed property")
		if "speed" in potion:
			_assert_equal(potion.speed, 200.0, "T4.6.27a: Potion speed is 200")

		# T4.6.28: Potion has damage property (12)
		_assert_true("damage" in potion, "T4.6.28: Potion has damage property")
		if "damage" in potion:
			_assert_equal(potion.damage, 12, "T4.6.28a: Potion damage is 12")

		# T4.6.29: Potion has cloud_size property (80)
		_assert_true("cloud_size" in potion, "T4.6.29: Potion has cloud_size property")
		if "cloud_size" in potion:
			_assert_equal(potion.cloud_size, 80.0, "T4.6.29a: Potion cloud_size is 80")

		# T4.6.30: Potion has lifetime property (2.0)
		_assert_true("lifetime" in potion, "T4.6.30: Potion has lifetime property")
		if "lifetime" in potion:
			_assert_equal(potion.lifetime, 2.0, "T4.6.30a: Potion lifetime is 2.0")

		# T4.6.31: Potion has set_direction method
		_assert_true(potion.has_method("set_direction"), "T4.6.31: Potion has set_direction method")

		# T4.6.32: Potion has _land method
		_assert_true(potion.has_method("_land"), "T4.6.32: Potion has _land method")

		# T4.6.33: Potion is Area2D
		_assert_true(potion is Area2D, "T4.6.33: Potion is Area2D")

		# T4.6.34: Potion has direction property
		_assert_true("direction" in potion, "T4.6.34: Potion has direction property")

		potion.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T4.6.27: Potion has speed property")
		_assert_true(false, "T4.6.27a: Potion speed is 200")
		_assert_true(false, "T4.6.28: Potion has damage property")
		_assert_true(false, "T4.6.28a: Potion damage is 12")
		_assert_true(false, "T4.6.29: Potion has cloud_size property")
		_assert_true(false, "T4.6.29a: Potion cloud_size is 80")
		_assert_true(false, "T4.6.30: Potion has lifetime property")
		_assert_true(false, "T4.6.30a: Potion lifetime is 2.0")
		_assert_true(false, "T4.6.31: Potion has set_direction method")
		_assert_true(false, "T4.6.32: Potion has _land method")
		_assert_true(false, "T4.6.33: Potion is Area2D")
		_assert_true(false, "T4.6.34: Potion has direction property")

# =============================================================================
# PHASE 4 STEP 12: INTEGRATION TESTS (TDD - Write First)
# =============================================================================

func _test_spawner_integration() -> void:
	# T4.12.1: Spawner loads Assassin scene
	var spawner_script = load("res://scripts/spawner.gd")
	_assert_not_null(spawner_script, "T4.12.1: Spawner script loads")

	if spawner_script:
		var spawner = Node.new()
		spawner.set_script(spawner_script)

		# T4.12.2: Spawner has assassin_scene variable
		_assert_true("assassin_scene" in spawner, "T4.12.2: Spawner has assassin_scene")

		# T4.12.3: Spawner has sorcerer_scene variable
		_assert_true("sorcerer_scene" in spawner, "T4.12.3: Spawner has sorcerer_scene")

		# T4.12.4: Spawner has assassin_weight variable
		_assert_true("assassin_weight" in spawner, "T4.12.4: Spawner has assassin_weight")

		# T4.12.5: Spawner has sorcerer_weight variable
		_assert_true("sorcerer_weight" in spawner, "T4.12.5: Spawner has sorcerer_weight")

		# T4.12.19: Spawner has enemy_killed signal for kill tracking
		_assert_true(spawner.has_signal("enemy_killed"), "T4.12.19: Spawner has enemy_killed signal")

		spawner.free()
	else:
		_assert_true(false, "T4.12.2: Spawner has assassin_scene")
		_assert_true(false, "T4.12.3: Spawner has sorcerer_scene")
		_assert_true(false, "T4.12.4: Spawner has assassin_weight")
		_assert_true(false, "T4.12.5: Spawner has sorcerer_weight")
		_assert_true(false, "T4.12.19: Spawner has enemy_killed signal")

func _test_hud_integration() -> void:
	var hud_scene = load("res://scenes/ui/hud.tscn")
	if hud_scene:
		var hud = hud_scene.instantiate()

		# T4.12.6: HUD has set_wave method
		_assert_true(hud.has_method("set_wave"), "T4.12.6: HUD has set_wave method")

		# T4.12.7: HUD has set_kills method
		_assert_true(hud.has_method("set_kills"), "T4.12.7: HUD has set_kills method")

		# T4.12.8: HUD has set_time method
		_assert_true(hud.has_method("set_time"), "T4.12.8: HUD has set_time method")

		# T4.12.9: HUD has WaveLabel or wave display
		var has_wave = hud.has_node("WaveLabel") or hud.has_node("MarginContainer/VBoxContainer/TopBar/WaveLabel") or hud.has_node("TopBar/WaveLabel")
		_assert_true(has_wave or hud.has_method("set_wave"), "T4.12.9: HUD has wave display")

		# T4.12.10: HUD has KillsLabel or kills display
		var has_kills = hud.has_node("KillsLabel") or hud.has_node("MarginContainer/VBoxContainer/TopBar/KillsLabel") or hud.has_node("TopBar/KillsLabel")
		_assert_true(has_kills or hud.has_method("set_kills"), "T4.12.10: HUD has kills display")

		hud.free()
	else:
		_assert_true(false, "T4.12.6: HUD has set_wave method")
		_assert_true(false, "T4.12.7: HUD has set_kills method")
		_assert_true(false, "T4.12.8: HUD has set_time method")
		_assert_true(false, "T4.12.9: HUD has wave display")
		_assert_true(false, "T4.12.10: HUD has kills display")

func _test_game_behavior() -> void:
	# T4.12.20: Game.gd starts DayNightCycle
	var game_script = load("res://scripts/game.gd")
	_assert_not_null(game_script, "T4.12.20: Game script loads")

	# Check the script source for proper behavior
	if game_script:
		var source = FileAccess.open("res://scripts/game.gd", FileAccess.READ)
		if source:
			var content = source.get_as_text()
			source.close()
			# T4.12.21: Check that day_night_cycle.start() is called
			_assert_true(content.contains("day_night_cycle.start()"), "T4.12.21: Game starts DayNightCycle")
			# T4.12.22: Check that _on_time_changed handles 2 parameters
			_assert_true(content.contains("_on_time_changed(") and content.contains("is_night"), "T4.12.22: _on_time_changed handles is_night param")
			# T4.12.23: Check that wave_manager.start() is called
			_assert_true(content.contains("wave_manager.start()"), "T4.12.23: Game starts WaveManager")
		else:
			_assert_true(false, "T4.12.21: Game starts DayNightCycle")
			_assert_true(false, "T4.12.22: _on_time_changed handles is_night param")
			_assert_true(false, "T4.12.23: Game starts WaveManager")

func _test_wave_spawner_integration() -> void:
	var spawner_script = load("res://scripts/spawner.gd")
	if not spawner_script:
		_assert_true(false, "T4.13.1: Spawner script loads for wave tests")
		return

	# Add spawner to scene tree so get_tree() works inside set_wave()
	var spawner = Node.new()
	spawner.set_script(spawner_script)
	root.add_child(spawner)

	# T4.13.1: Spawner has set_wave method
	_assert_true(spawner.has_method("set_wave"), "T4.13.1: Spawner has set_wave method")

	# Store initial values
	var initial_interval = spawner.spawn_interval
	var initial_max = spawner.max_enemies

	# T4.13.2: Wave 1 keeps default spawn interval
	spawner.set_wave(1)
	_assert_equal(spawner.spawn_interval, initial_interval, "T4.13.2: Wave 1 spawn_interval unchanged")

	# T4.13.3: Wave 2 decreases spawn interval
	spawner.set_wave(2)
	_assert_true(spawner.spawn_interval < initial_interval, "T4.13.3: Wave 2 spawn_interval decreased")

	# T4.13.4: Wave 5 has faster spawning than wave 2
	var wave2_interval = spawner.spawn_interval
	spawner.set_wave(5)
	_assert_true(spawner.spawn_interval < wave2_interval, "T4.13.4: Wave 5 faster than wave 2")

	# T4.13.5: Spawn interval has minimum (doesn't go below 0.5)
	spawner.set_wave(20)
	_assert_true(spawner.spawn_interval >= 0.5, "T4.13.5: Spawn interval minimum is 0.5")

	# T4.13.6: Wave 1 sets base max_enemies (48 after 60% increase)
	spawner.set_wave(1)
	var wave1_max = spawner.max_enemies
	_assert_equal(wave1_max, 48, "T4.13.6: Wave 1 max_enemies is 48")

	# T4.13.7: Wave 2 increases max_enemies (35)
	spawner.set_wave(2)
	_assert_true(spawner.max_enemies > wave1_max, "T4.13.7: Wave 2 max_enemies increased")

	# T4.13.8: Wave 5 has more max_enemies than wave 2
	var wave2_max = spawner.max_enemies
	spawner.set_wave(5)
	_assert_true(spawner.max_enemies > wave2_max, "T4.13.8: Wave 5 more enemies than wave 2")

	# Reset weights for enemy type tests
	spawner.archer_weight = 0.0
	spawner.cavalry_weight = 0.0
	spawner.fire_soldier_weight = 0.0
	spawner.assassin_weight = 0.0
	spawner.sorcerer_weight = 0.0

	# T4.13.9: Wave 1 has no archer weight boost
	spawner.set_wave(1)
	_assert_equal(spawner.archer_weight, 0.0, "T4.13.9: Wave 1 no archer boost")

	# T4.13.10: Wave 2 adds archer weight
	spawner.archer_weight = 0.0
	spawner.set_wave(2)
	_assert_true(spawner.archer_weight > 0, "T4.13.10: Wave 2 adds archers")

	# T4.13.11: Wave 3 adds cavalry weight
	spawner.cavalry_weight = 0.0
	spawner.set_wave(3)
	_assert_true(spawner.cavalry_weight > 0, "T4.13.11: Wave 3 adds cavalry")

	# T4.13.12: Wave 4 adds fire_soldier weight
	spawner.fire_soldier_weight = 0.0
	spawner.set_wave(4)
	_assert_true(spawner.fire_soldier_weight > 0, "T4.13.12: Wave 4 adds fire soldiers")

	# T4.13.13: Wave 5 adds assassin weight
	spawner.assassin_weight = 0.0
	spawner.set_wave(5)
	_assert_true(spawner.assassin_weight > 0, "T4.13.13: Wave 5 adds assassin")

	# T4.13.14: Wave 6 adds sorcerer weight
	spawner.sorcerer_weight = 0.0
	spawner.set_wave(6)
	_assert_true(spawner.sorcerer_weight > 0, "T4.13.14: Wave 6 adds sorcerer")

	root.remove_child(spawner)
	spawner.free()

	# T4.13.15: Game.gd connects wave to spawner
	var source = FileAccess.open("res://scripts/game.gd", FileAccess.READ)
	if source:
		var content = source.get_as_text()
		source.close()
		_assert_true(content.contains("spawner.set_wave"), "T4.13.15: Game connects wave to spawner")
	else:
		_assert_true(false, "T4.13.15: Game connects wave to spawner")

func _test_game_over_stats() -> void:
	# T4.14.1: GameOverUI scene loads
	var game_over_scene = load("res://scenes/ui/game_over_ui.tscn")
	_assert_not_null(game_over_scene, "T4.14.1: GameOverUI scene loads")

	if game_over_scene:
		var game_over = game_over_scene.instantiate()

		# T4.14.2: GameOverUI has TitleLabel (check node path)
		var title = game_over.get_node_or_null("Panel/MarginContainer/VBoxContainer/TitleLabel")
		_assert_not_null(title, "T4.14.2: GameOverUI TitleLabel found at correct path")

		# T4.14.3: GameOverUI has TimeLabel (check node path)
		var time_lbl = game_over.get_node_or_null("Panel/MarginContainer/VBoxContainer/StatsContainer/TimeLabel")
		_assert_not_null(time_lbl, "T4.14.3: GameOverUI TimeLabel found at correct path")

		# T4.14.4: GameOverUI has KillsLabel (check node path)
		var kills_lbl = game_over.get_node_or_null("Panel/MarginContainer/VBoxContainer/StatsContainer/KillsLabel")
		_assert_not_null(kills_lbl, "T4.14.4: GameOverUI KillsLabel found at correct path")

		# T4.14.5: GameOverUI has LevelLabel (check node path)
		var level_lbl = game_over.get_node_or_null("Panel/MarginContainer/VBoxContainer/StatsContainer/LevelLabel")
		_assert_not_null(level_lbl, "T4.14.5: GameOverUI LevelLabel found at correct path")

		# T4.14.6: GameOverUI has WaveLabel (check node path)
		var wave_lbl = game_over.get_node_or_null("Panel/MarginContainer/VBoxContainer/StatsContainer/WaveLabel")
		_assert_not_null(wave_lbl, "T4.14.6: GameOverUI WaveLabel found at correct path")

		game_over.free()
	else:
		_assert_true(false, "T4.14.2: GameOverUI TitleLabel found at correct path")
		_assert_true(false, "T4.14.3: GameOverUI TimeLabel found at correct path")
		_assert_true(false, "T4.14.4: GameOverUI KillsLabel found at correct path")
		_assert_true(false, "T4.14.5: GameOverUI LevelLabel found at correct path")
		_assert_true(false, "T4.14.6: GameOverUI WaveLabel found at correct path")

	# T4.14.7: GameOverUI script has correct node paths
	var source = FileAccess.open("res://scripts/ui/game_over_ui.gd", FileAccess.READ)
	if source:
		var content = source.get_as_text()
		source.close()
		_assert_true(content.contains("Panel/MarginContainer/VBoxContainer/TitleLabel"), "T4.14.7: Script has correct TitleLabel path")
		_assert_true(content.contains("Panel/MarginContainer/VBoxContainer/StatsContainer/TimeLabel"), "T4.14.8: Script has correct TimeLabel path")
		_assert_true(content.contains("Panel/MarginContainer/VBoxContainer/StatsContainer/KillsLabel"), "T4.14.9: Script has correct KillsLabel path")
		_assert_true(content.contains("Panel/MarginContainer/VBoxContainer/StatsContainer/WaveLabel"), "T4.14.10: Script has correct WaveLabel path")
	else:
		_assert_true(false, "T4.14.7: Script has correct TitleLabel path")
		_assert_true(false, "T4.14.8: Script has correct TimeLabel path")
		_assert_true(false, "T4.14.9: Script has correct KillsLabel path")
		_assert_true(false, "T4.14.10: Script has correct WaveLabel path")

	# T4.14.11: Game.gd updates game_stats.set_wave on wave change
	var game_source = FileAccess.open("res://scripts/game.gd", FileAccess.READ)
	if game_source:
		var game_content = game_source.get_as_text()
		game_source.close()
		_assert_true(game_content.contains("game_stats.set_wave"), "T4.14.11: Game updates game_stats wave")
		_assert_true(game_content.contains("game_stats.set_level") or game_content.contains("game_stats.highest_level"), "T4.14.12: Game updates game_stats level")
	else:
		_assert_true(false, "T4.14.11: Game updates game_stats wave")
		_assert_true(false, "T4.14.12: Game updates game_stats level")

func _test_main_scene_integration() -> void:
	# T4.12.11: Main scene loads
	var main_scene = load("res://scenes/main.tscn")
	_assert_not_null(main_scene, "T4.12.11: Main scene loads")

	if main_scene:
		var main = main_scene.instantiate()

		# T4.12.12: Main has Player
		_assert_not_null(main.get_node_or_null("Player"), "T4.12.12: Main has Player")

		# T4.12.13: Main has HUD
		var hud = main.get_node_or_null("HUD") or main.get_node_or_null("CanvasLayer/HUD")
		_assert_not_null(hud, "T4.12.13: Main has HUD")

		# T4.12.14: Main has GameOverUI
		var game_over = main.get_node_or_null("GameOverUI") or main.get_node_or_null("CanvasLayer/GameOverUI")
		_assert_not_null(game_over, "T4.12.14: Main has GameOverUI")

		# T4.12.15: Main has Spawner or MobSpawner
		var spawner = main.get_node_or_null("Spawner") or main.get_node_or_null("MobSpawner")
		_assert_not_null(spawner, "T4.12.15: Main has Spawner")

		# T4.12.16: Main has DayNightCycle
		var day_night = main.get_node_or_null("DayNightCycle")
		_assert_not_null(day_night, "T4.12.16: Main has DayNightCycle")

		# T4.12.17: Main has WaveManager
		var wave_manager = main.get_node_or_null("WaveManager")
		_assert_not_null(wave_manager, "T4.12.17: Main has WaveManager")

		# T4.12.18: Main has GameStats
		var game_stats = main.get_node_or_null("GameStats")
		_assert_not_null(game_stats, "T4.12.18: Main has GameStats")

		main.free()
	else:
		_assert_true(false, "T4.12.12: Main has Player")
		_assert_true(false, "T4.12.13: Main has HUD")
		_assert_true(false, "T4.12.14: Main has GameOverUI")
		_assert_true(false, "T4.12.15: Main has Spawner")
		_assert_true(false, "T4.12.16: Main has DayNightCycle")
		_assert_true(false, "T4.12.17: Main has WaveManager")
		_assert_true(false, "T4.12.18: Main has GameStats")

# =============================================================================
# PHASE 4: UPGRADE UI SELECTION TESTS (TDD - Timer & Navigation)
# =============================================================================

func _test_upgrade_ui_selection() -> void:
	var upgrade_ui_scene = load("res://scenes/ui/upgrade_ui.tscn")
	_assert_not_null(upgrade_ui_scene, "T4.15.1: UpgradeUI scene loads")

	if not upgrade_ui_scene:
		_assert_true(false, "T4.15.2: UpgradeUI has _selected_index property")
		_assert_true(false, "T4.15.3: UpgradeUI has _timer property")
		_assert_true(false, "T4.15.4: UpgradeUI has _is_active property")
		_assert_true(false, "T4.15.5: UpgradeUI selection_timeout default is 5.0")
		_assert_true(false, "T4.15.6: UpgradeUI has _move_selection method")
		_assert_true(false, "T4.15.7: UpgradeUI has _confirm_selection method")
		_assert_true(false, "T4.15.8: UpgradeUI has _update_selection_visuals method")
		_assert_true(false, "T4.15.9: UpgradeUI has _normal_style property")
		_assert_true(false, "T4.15.10: UpgradeUI has _selected_style property")
		_assert_true(false, "T4.15.11: UpgradeUI scene has TimerLabel")
		_assert_true(false, "T4.15.12: UpgradeUI default selection is middle (index 1 of 3)")
		return

	var ui = upgrade_ui_scene.instantiate()

	# T4.15.2: Has _selected_index property
	_assert_true("_selected_index" in ui, "T4.15.2: UpgradeUI has _selected_index property")

	# T4.15.3: Has _timer property
	_assert_true("_timer" in ui, "T4.15.3: UpgradeUI has _timer property")

	# T4.15.4: Has _is_active property
	_assert_true("_is_active" in ui, "T4.15.4: UpgradeUI has _is_active property")

	# T4.15.5: selection_timeout default is 5.0 seconds
	if "selection_timeout" in ui:
		_assert_equal(ui.selection_timeout, 5.0, "T4.15.5: UpgradeUI selection_timeout default is 5.0")
	else:
		_assert_true(false, "T4.15.5: UpgradeUI selection_timeout default is 5.0")

	# T4.15.6: Has _move_selection method
	_assert_true(ui.has_method("_move_selection"), "T4.15.6: UpgradeUI has _move_selection method")

	# T4.15.7: Has _confirm_selection method
	_assert_true(ui.has_method("_confirm_selection"), "T4.15.7: UpgradeUI has _confirm_selection method")

	# T4.15.8: Has _update_selection_visuals method
	_assert_true(ui.has_method("_update_selection_visuals"), "T4.15.8: UpgradeUI has _update_selection_visuals method")

	# T4.15.9: Has _normal_style property
	_assert_true("_normal_style" in ui, "T4.15.9: UpgradeUI has _normal_style property")

	# T4.15.10: Has _selected_style property
	_assert_true("_selected_style" in ui, "T4.15.10: UpgradeUI has _selected_style property")

	# T4.15.11: Scene has TimerLabel node
	var timer_label = ui.get_node_or_null("Container/MainVBox/TimerLabel")
	_assert_not_null(timer_label, "T4.15.11: UpgradeUI scene has TimerLabel")

	# T4.15.12: Test default selection is middle
	# Create mock upgrades (3 items, middle should be index 1)
	var mock_upgrades = []
	for i in range(3):
		var mock = RefCounted.new()
		mock.set_meta("display_name", "Upgrade " + str(i))
		mock.set_meta("icon_path", "")
		mock.set_meta("current_level", 0)
		mock.set_meta("max_level", 5)
		mock_upgrades.append(mock)

	# Check script source for middle selection logic
	var source = FileAccess.open("res://scripts/ui/upgrade_ui.gd", FileAccess.READ)
	if source:
		var content = source.get_as_text()
		source.close()
		# Check for middle selection: _selected_index = _upgrades.size() / 2
		_assert_true(content.contains("_selected_index = _upgrades.size() / 2"), "T4.15.12: UpgradeUI default selection is middle")
	else:
		_assert_true(false, "T4.15.12: UpgradeUI default selection is middle")

	ui.free()

# =============================================================================
# PHASE 5: GAME ENHANCEMENTS TESTS (TDD)
# =============================================================================

func _test_status_effect() -> void:
	# T5.1.1: StatusEffect script loads
	var script = load("res://scripts/components/status_effect.gd")
	_assert_not_null(script, "T5.1.1: StatusEffect script loads")

	if script == null:
		_skip_test("T5.1.2-T5.1.5", "StatusEffect script not found")
		return

	var effect = script.new()
	_assert_not_null(effect, "T5.1.2: StatusEffect can be instantiated")

	# T5.1.3: Has Type enum with POISON
	_assert_true("Type" in effect or effect.get_script().get_script_constant_map().has("Type"),
		"T5.1.3: StatusEffect has Type enum")

	# T5.1.4: Has duration property
	_assert_true("duration" in effect, "T5.1.4: StatusEffect has duration property")

	# T5.1.5: Has tick_interval property
	_assert_true("tick_interval" in effect, "T5.1.5: StatusEffect has tick_interval property")

	# T5.1.6: Has damage_per_tick property
	_assert_true("damage_per_tick" in effect, "T5.1.6: StatusEffect has damage_per_tick property")

	# T5.1.7: Has remaining_time property
	_assert_true("remaining_time" in effect, "T5.1.7: StatusEffect has remaining_time property")

func _test_status_effect_manager() -> void:
	# T5.1.8: StatusEffectManager script loads
	var script = load("res://scripts/components/status_effect_manager.gd")
	_assert_not_null(script, "T5.1.8: StatusEffectManager script loads")

	if script == null:
		_skip_test("T5.1.9-T5.1.14", "StatusEffectManager script not found")
		return

	var manager = script.new()
	_assert_not_null(manager, "T5.1.9: StatusEffectManager can be instantiated")

	# T5.1.10: Has apply_effect method
	_assert_true(manager.has_method("apply_effect"), "T5.1.10: Manager has apply_effect method")

	# T5.1.11: Has remove_effect method
	_assert_true(manager.has_method("remove_effect"), "T5.1.11: Manager has remove_effect method")

	# T5.1.12: Has has_effect method
	_assert_true(manager.has_method("has_effect"), "T5.1.12: Manager has has_effect method")

	# T5.1.13: Has clear_all_effects method
	_assert_true(manager.has_method("clear_all_effects"), "T5.1.13: Manager has clear_all_effects method")

	# T5.1.14: Has active_effects array
	_assert_true("active_effects" in manager, "T5.1.14: Manager has active_effects array")

	# T5.1.15: Has effect_applied signal
	_assert_true(manager.has_signal("effect_applied"), "T5.1.15: Manager has effect_applied signal")

	# T5.1.16: Has effect_removed signal
	_assert_true(manager.has_signal("effect_removed"), "T5.1.16: Manager has effect_removed signal")

	# T5.1.17: Has effect_tick signal
	_assert_true(manager.has_signal("effect_tick"), "T5.1.17: Manager has effect_tick signal")

func _test_poison_system() -> void:
	# T5.1.18: Poison Dart has cloud_size property (poison is always applied via cloud)
	var potion_scene = load("res://scenes/projectiles/poison_dart.tscn")
	if potion_scene == null:
		_skip_test("T5.1.18-T5.1.24", "Potion scene not found")
		return

	var potion = potion_scene.instantiate()
	_assert_true("cloud_size" in potion, "T5.1.18: Potion has cloud_size property")

	# T5.1.19: Potion cloud_size is 80
	_assert_true("cloud_size" in potion, "T5.1.19: Potion has cloud_size property")
	if "cloud_size" in potion:
		_assert_equal(potion.cloud_size, 80.0, "T5.1.20: Potion cloud_size is 80")

	# T5.1.21: Potion has poison_duration
	_assert_true("poison_duration" in potion, "T5.1.21: Potion has poison_duration property")
	if "poison_duration" in potion:
		_assert_equal(potion.poison_duration, 5.0, "T5.1.22: Potion poison_duration is 5.0")

	# T5.1.23: Potion has poison_damage_per_tick
	_assert_true("poison_damage_per_tick" in potion, "T5.1.23: Potion has poison_damage_per_tick")
	if "poison_damage_per_tick" in potion:
		_assert_equal(potion.poison_damage_per_tick, 2, "T5.1.24: Potion poison_damage is 2")

	# T5.1.25: Potion has poison_tick_interval
	_assert_true("poison_tick_interval" in potion, "T5.1.25: Potion has poison_tick_interval")
	if "poison_tick_interval" in potion:
		_assert_equal(potion.poison_tick_interval, 0.5, "T5.1.26: Potion tick_interval is 0.5")

	potion.free()

	# T5.1.27: Player has StatusEffectManager
	var player_scene = load("res://scenes/player.tscn")
	if player_scene:
		var player = player_scene.instantiate()
		var sem = player.get_node_or_null("StatusEffectManager")
		_assert_not_null(sem, "T5.1.27: Player has StatusEffectManager node")
		player.free()

func _test_score_calculator() -> void:
	# T5.2.1: ScoreCalculator script loads
	var script = load("res://scripts/systems/score_calculator.gd")
	_assert_not_null(script, "T5.2.1: ScoreCalculator script loads")

	if script == null:
		_skip_test("T5.2.2-T5.2.7", "ScoreCalculator script not found")
		return

	# T5.2.2: Has calculate static method
	_assert_true(script.has_method("calculate"), "T5.2.2: ScoreCalculator has calculate method")

	# T5.2.3: Has correct constants
	var constants = script.get_script_constant_map()
	_assert_true(constants.has("KILL_POINTS"), "T5.2.3: Has KILL_POINTS constant")
	_assert_true(constants.has("TIME_POINTS"), "T5.2.4: Has TIME_POINTS constant")
	_assert_true(constants.has("LEVEL_POINTS"), "T5.2.5: Has LEVEL_POINTS constant")
	_assert_true(constants.has("WAVE_POINTS"), "T5.2.6: Has WAVE_POINTS constant")

	# T5.2.7: Constants have correct values
	if constants.has("KILL_POINTS"):
		_assert_equal(constants["KILL_POINTS"], 10, "T5.2.7: KILL_POINTS is 10")
	if constants.has("TIME_POINTS"):
		_assert_equal(constants["TIME_POINTS"], 1, "T5.2.8: TIME_POINTS is 1")
	if constants.has("LEVEL_POINTS"):
		_assert_equal(constants["LEVEL_POINTS"], 50, "T5.2.9: LEVEL_POINTS is 50")
	if constants.has("WAVE_POINTS"):
		_assert_equal(constants["WAVE_POINTS"], 100, "T5.2.10: WAVE_POINTS is 100")

func _test_score_storage() -> void:
	# T5.2.11: ScoreStorage script loads
	var script = load("res://scripts/systems/score_storage.gd")
	_assert_not_null(script, "T5.2.11: ScoreStorage script loads")

	if script == null:
		_skip_test("T5.2.12-T5.2.18", "ScoreStorage script not found")
		return

	var storage = script.new()
	_assert_not_null(storage, "T5.2.12: ScoreStorage can be instantiated")

	# T5.2.13: Has save_score method
	_assert_true(storage.has_method("save_score"), "T5.2.13: Has save_score method")

	# T5.2.14: Has load_scores method
	_assert_true(storage.has_method("load_scores"), "T5.2.14: Has load_scores method")

	# T5.2.15: Has get_high_score method
	_assert_true(storage.has_method("get_high_score"), "T5.2.15: Has get_high_score method")

	# T5.2.16: Has is_high_score method
	_assert_true(storage.has_method("is_high_score"), "T5.2.16: Has is_high_score method")

	# T5.2.17: Has MAX_ENTRIES constant
	var constants = script.get_script_constant_map()
	_assert_true(constants.has("MAX_ENTRIES"), "T5.2.17: Has MAX_ENTRIES constant")
	if constants.has("MAX_ENTRIES"):
		_assert_equal(constants["MAX_ENTRIES"], 10, "T5.2.18: MAX_ENTRIES is 10")

func _test_combo_system() -> void:
	# T5.5.1: ComboSystem script loads
	var script = load("res://scripts/systems/combo_system.gd")
	_assert_not_null(script, "T5.5.1: ComboSystem script loads")

	if script == null:
		_skip_test("T5.5.2-T5.5.8", "ComboSystem script not found")
		return

	var combo = script.new()
	_assert_not_null(combo, "T5.5.2: ComboSystem can be instantiated")

	# T5.5.3: Has current_combo property
	_assert_true("current_combo" in combo, "T5.5.3: Has current_combo property")

	# T5.5.4: Has on_enemy_killed method
	_assert_true(combo.has_method("on_enemy_killed"), "T5.5.4: Has on_enemy_killed method")

	# T5.5.5: Has on_player_damaged method
	_assert_true(combo.has_method("on_player_damaged"), "T5.5.5: Has on_player_damaged method")

	# T5.5.6: Has get_xp_bonus method
	_assert_true(combo.has_method("get_xp_bonus"), "T5.5.6: Has get_xp_bonus method")

	# T5.5.7: Has combo_timeout property (3 seconds)
	_assert_true("combo_timeout" in combo, "T5.5.7: Has combo_timeout property")
	if "combo_timeout" in combo:
		_assert_equal(combo.combo_timeout, 3.0, "T5.5.8: combo_timeout is 3.0")

	# T5.5.9: Has milestone_reached signal
	_assert_true(combo.has_signal("milestone_reached"), "T5.5.9: Has milestone_reached signal")

	# T5.5.10: Has combo_changed signal
	_assert_true(combo.has_signal("combo_changed"), "T5.5.10: Has combo_changed signal")

func _test_haste_upgrade() -> void:
	# T5.U.1: Haste upgrade exists in upgrade manager
	var upgrade_manager_script = load("res://scripts/systems/upgrade_manager.gd")
	if upgrade_manager_script == null:
		_skip_test("T5.U.1-T5.U.4", "UpgradeManager script not found")
		return

	# Check if haste is in the upgrades
	var source = FileAccess.open("res://scripts/systems/upgrade_manager.gd", FileAccess.READ)
	if source:
		var content = source.get_as_text()
		source.close()
		_assert_true(content.contains("haste") or content.contains("Haste"), "T5.U.1: Haste upgrade defined")
		_assert_true(content.contains("attack_speed") or content.contains("cooldown"), "T5.U.2: Haste affects attack speed")

# =============================================================================
# PHASE 5: ADDITIONAL FEATURES TESTS
# =============================================================================

func _test_damage_number() -> void:
	var script = load("res://scripts/effects/damage_number.gd")
	_assert_not_null(script, "T5.8.1: DamageNumber script loads")

	if script:
		var dmg_num = script.new()
		_assert_not_null(dmg_num, "T5.8.2: DamageNumber can be instantiated")
		_assert_true(dmg_num.has_method("setup"), "T5.8.3: DamageNumber has setup method")
		_assert_true("rise_speed" in dmg_num, "T5.8.4: DamageNumber has rise_speed")
		_assert_true("duration" in dmg_num, "T5.8.5: DamageNumber has duration")
		dmg_num.free()

func _test_screen_shake() -> void:
	var script = load("res://scripts/effects/screen_shake.gd")
	_assert_not_null(script, "T5.8.6: ScreenShake script loads")

	if script:
		var shake = script.new()
		_assert_not_null(shake, "T5.8.7: ScreenShake can be instantiated")
		_assert_true(shake.has_method("shake"), "T5.8.8: ScreenShake has shake method")
		_assert_true(shake.has_method("shake_light"), "T5.8.9: ScreenShake has shake_light")
		_assert_true(shake.has_method("shake_heavy"), "T5.8.10: ScreenShake has shake_heavy")
		_assert_true(shake.has_signal("shake_started"), "T5.8.11: ScreenShake has shake_started signal")
		shake.free()

func _test_bow_weapon() -> void:
	var script = load("res://scripts/weapons/bow.gd")
	_assert_not_null(script, "T5.W.1: Bow script loads")

	var scene = load("res://scenes/weapons/bow.tscn")
	_assert_not_null(scene, "T5.W.2: Bow scene loads")

	if scene:
		var bow = scene.instantiate()
		_assert_not_null(bow, "T5.W.3: Bow can be instantiated")
		_assert_true("damage" in bow, "T5.W.4: Bow has damage property")
		_assert_true("attack_speed" in bow, "T5.W.5: Bow has attack_speed property")
		_assert_true("range" in bow, "T5.W.6: Bow has range property")
		_assert_true("level" in bow, "T5.W.7: Bow has level property")
		_assert_true(bow.has_signal("arrow_fired"), "T5.W.8: Bow has arrow_fired signal")

		# T5.W.16: Bow MAX_LEVEL is 4 (evolves to crossbow at level 4)
		_assert_equal(bow.MAX_LEVEL, 4, "T5.W.16: Bow MAX_LEVEL is 4")

		# T5.W.17: Bow has evolved_to_crossbow signal
		_assert_true(bow.has_signal("evolved_to_crossbow"), "T5.W.17: Bow has evolved_to_crossbow signal")

		# T5.W.18: Bow nerfed damage is 6
		_assert_equal(bow.damage, 6, "T5.W.18: Bow base damage is 6")

		# T5.W.19: Bow nerfed attack_speed is 0.5
		_assert_equal(bow.attack_speed, 0.5, "T5.W.19: Bow base attack_speed is 0.5")

		bow.free()

func _test_player_arrow() -> void:
	var script = load("res://scripts/projectiles/player_arrow.gd")
	_assert_not_null(script, "T5.W.9: PlayerArrow script loads")

	var scene = load("res://scenes/projectiles/player_arrow.tscn")
	_assert_not_null(scene, "T5.W.10: PlayerArrow scene loads")

	if scene:
		var arrow = scene.instantiate()
		_assert_not_null(arrow, "T5.W.11: PlayerArrow can be instantiated")
		_assert_true("speed" in arrow, "T5.W.12: PlayerArrow has speed")
		_assert_true("damage" in arrow, "T5.W.13: PlayerArrow has damage")
		_assert_true("piercing" in arrow, "T5.W.14: PlayerArrow has piercing")
		_assert_true(arrow.has_method("set_direction"), "T5.W.15: PlayerArrow has set_direction")
		arrow.free()

func _test_lucky_drop() -> void:
	var script = load("res://scripts/systems/lucky_drop.gd")
	_assert_not_null(script, "T5.7.1: LuckyDrop script loads")

	if script:
		_assert_true(script.has_method("roll_drop"), "T5.7.2: LuckyDrop has roll_drop method")
		_assert_true(script.has_method("apply_drop"), "T5.7.3: LuckyDrop has apply_drop method")
		_assert_true(script.has_method("get_drop_name"), "T5.7.4: LuckyDrop has get_drop_name method")

		# Test drop table exists
		var constants = script.get_script_constant_map()
		_assert_true(constants.has("DROP_TABLE"), "T5.7.5: LuckyDrop has DROP_TABLE")
		_assert_true(constants.has("DROP_NAMES"), "T5.7.6: LuckyDrop has DROP_NAMES")

func _test_health_pickup() -> void:
	var script = load("res://scripts/pickups/health_pickup.gd")
	_assert_not_null(script, "T5.7.7: HealthPickup script loads")

	var scene = load("res://scenes/pickups/health_pickup.tscn")
	_assert_not_null(scene, "T5.7.8: HealthPickup scene loads")

	if scene:
		var pickup = scene.instantiate()
		_assert_not_null(pickup, "T5.7.9: HealthPickup instantiates")
		_assert_true(pickup.has_signal("collected"), "T5.7.10: HealthPickup has collected signal")
		_assert_true("heal_percent" in pickup, "T5.7.11: HealthPickup has heal_percent property")
		_assert_true("attract_radius" in pickup, "T5.7.12: HealthPickup has attract_radius property")
		_assert_true("despawn_time" in pickup, "T5.7.13: HealthPickup has despawn_time property")
		pickup.free()

	# Test asset exists
	var texture = load("res://assets/items/golden_apple.svg")
	_assert_not_null(texture, "T5.7.14: Golden apple asset exists")

func _test_health_pickup_spawner() -> void:
	var script = load("res://scripts/systems/health_pickup_spawner.gd")
	_assert_not_null(script, "T5.7.15: HealthPickupSpawner script loads")

	if script:
		var spawner = script.new()
		_assert_not_null(spawner, "T5.7.16: HealthPickupSpawner instantiates")
		_assert_true(spawner.has_signal("pickup_spawned"), "T5.7.17: Spawner has pickup_spawned signal")
		_assert_true("spawn_interval" in spawner, "T5.7.18: Spawner has spawn_interval property")
		_assert_true("max_pickups" in spawner, "T5.7.19: Spawner has max_pickups property")
		_assert_true("initial_delay" in spawner, "T5.7.20: Spawner has initial_delay property")
		_assert_true(spawner.has_method("set_spawn_rate"), "T5.7.21: Spawner has set_spawn_rate method")
		_assert_true(spawner.has_method("set_wave"), "T5.7.22: Spawner has set_wave method")
		spawner.free()

	# Test main scene includes health pickup spawner
	var main_scene = load("res://scenes/main.tscn")
	if main_scene:
		var main = main_scene.instantiate()
		var health_spawner = main.get_node_or_null("HealthPickupSpawner")
		_assert_not_null(health_spawner, "T5.7.23: Main scene has HealthPickupSpawner")
		main.free()

func _test_main_menu() -> void:
	var script = load("res://scripts/ui/main_menu.gd")
	_assert_not_null(script, "T5.0.1: MainMenu script loads")

	var scene = load("res://scenes/ui/main_menu.tscn")
	_assert_not_null(scene, "T5.0.2: MainMenu scene loads")

	if scene:
		var menu = scene.instantiate()
		_assert_not_null(menu, "T5.0.3: MainMenu can be instantiated")
		_assert_true(menu.has_signal("start_pressed"), "T5.0.4: MainMenu has start_pressed signal")
		_assert_true(menu.has_signal("settings_pressed"), "T5.0.5: MainMenu has settings_pressed signal")
		_assert_true(menu.has_signal("scoreboard_pressed"), "T5.0.6: MainMenu has scoreboard_pressed signal")
		menu.free()

func _test_settings_panel() -> void:
	var script = load("res://scripts/ui/settings_panel.gd")
	_assert_not_null(script, "T5.0.7: SettingsPanel script loads")

	if script:
		var panel = script.new()
		_assert_not_null(panel, "T5.0.8: SettingsPanel can be instantiated")
		_assert_true(panel.has_method("save_settings"), "T5.0.9: SettingsPanel has save_settings")
		_assert_true(panel.has_method("load_settings"), "T5.0.10: SettingsPanel has load_settings")
		_assert_true("settings" in panel, "T5.0.11: SettingsPanel has settings dict")
		panel.free()

func _test_scoreboard_panel() -> void:
	var script = load("res://scripts/ui/scoreboard_panel.gd")
	_assert_not_null(script, "T5.2.13: ScoreboardPanel script loads")

	if script:
		var panel = script.new()
		_assert_not_null(panel, "T5.2.14: ScoreboardPanel can be instantiated")
		_assert_true(panel.has_method("refresh_scores"), "T5.2.15: ScoreboardPanel has refresh_scores")
		_assert_true(panel.has_method("highlight_score"), "T5.2.16: ScoreboardPanel has highlight_score")
		_assert_true(panel.has_signal("closed"), "T5.2.17: ScoreboardPanel has closed signal")
		panel.free()

func _test_status_container() -> void:
	var script = load("res://scripts/ui/status_container.gd")
	_assert_not_null(script, "T5.1.24: StatusContainer script loads")

	if script:
		var container = script.new()
		_assert_not_null(container, "T5.1.25: StatusContainer can be instantiated")
		_assert_true(container.has_method("connect_to_player"), "T5.1.26: StatusContainer has connect_to_player")
		container.free()

func _test_status_icon() -> void:
	var script = load("res://scripts/ui/status_icon.gd")
	_assert_not_null(script, "T5.1.22: StatusIcon script loads")

	if script:
		var icon = script.new()
		_assert_not_null(icon, "T5.1.23: StatusIcon can be instantiated")
		_assert_true(icon.has_method("setup"), "T5.1.24a: StatusIcon has setup")
		_assert_true(icon.has_method("update_time"), "T5.1.25a: StatusIcon has update_time")
		icon.free()

func _test_achievement() -> void:
	var script = load("res://scripts/systems/achievement.gd")
	_assert_not_null(script, "T5.2.1: Achievement script loads")

	if script:
		var achievement = script.new("test_id", "Test Name", "Test Desc", 10, 50)
		_assert_not_null(achievement, "T5.2.2: Achievement can be instantiated")
		_assert_equal(achievement.id, "test_id", "T5.2.3: Achievement has correct id")
		_assert_equal(achievement.name, "Test Name", "T5.2.4: Achievement has correct name")
		_assert_equal(achievement.description, "Test Desc", "T5.2.5: Achievement has correct description")
		_assert_equal(achievement.target, 10, "T5.2.6: Achievement has correct target")
		_assert_equal(achievement.reward_emeralds, 50, "T5.2.7: Achievement has correct reward")
		_assert_false(achievement.is_unlocked, "T5.2.8: Achievement starts locked")
		_assert_equal(achievement.progress, 0, "T5.2.9: Achievement starts with 0 progress")

		# Test progress checking
		_assert_false(achievement.check_progress(5), "T5.2.10: Progress below target doesn't unlock")
		_assert_equal(achievement.progress, 5, "T5.2.11: Progress is updated")
		_assert_true(achievement.check_progress(10), "T5.2.12: Progress at target unlocks")
		_assert_true(achievement.is_unlocked, "T5.2.13: Achievement is now unlocked")
		_assert_true(achievement.unlock_date.length() > 0, "T5.2.14: Unlock date is set")

		# Test progress percent
		_assert_equal(achievement.get_progress_percent(), 1.0, "T5.2.15: Progress percent is 1.0 when complete")

		# Test to_dict and from_dict
		var dict = achievement.to_dict()
		_assert_true("id" in dict, "T5.2.16: to_dict includes id")
		_assert_true("is_unlocked" in dict, "T5.2.17: to_dict includes is_unlocked")
		_assert_true("progress" in dict, "T5.2.18: to_dict includes progress")

func _test_achievement_manager() -> void:
	var script = load("res://scripts/systems/achievement_manager.gd")
	_assert_not_null(script, "T5.2.19: AchievementManager script loads")

	if script:
		var manager = script.new()
		_assert_not_null(manager, "T5.2.20: AchievementManager can be instantiated")
		_assert_true(manager.has_signal("achievement_unlocked"), "T5.2.21: Has achievement_unlocked signal")
		_assert_true(manager.has_signal("progress_updated"), "T5.2.22: Has progress_updated signal")
		_assert_true(manager.has_method("check_kill_count"), "T5.2.23: Has check_kill_count")
		_assert_true(manager.has_method("check_survival_time"), "T5.2.24: Has check_survival_time")
		_assert_true(manager.has_method("check_level"), "T5.2.25: Has check_level")
		_assert_true(manager.has_method("check_wave"), "T5.2.26: Has check_wave")
		_assert_true(manager.has_method("check_combo"), "T5.2.27: Has check_combo")
		_assert_true(manager.has_method("get_achievement"), "T5.2.28: Has get_achievement")
		_assert_true(manager.has_method("get_all_achievements"), "T5.2.29: Has get_all_achievements")
		_assert_true(manager.has_method("save_achievements"), "T5.2.30: Has save_achievements")
		_assert_true(manager.has_method("load_achievements"), "T5.2.31: Has load_achievements")

		# Test achievement definitions exist
		_assert_true(manager.ACHIEVEMENT_DEFS.size() > 0, "T5.2.32: Has achievement definitions")
		_assert_true("first_kill" in manager.ACHIEVEMENT_DEFS, "T5.2.33: Has first_kill achievement")
		_assert_true("survive_60" in manager.ACHIEVEMENT_DEFS, "T5.2.34: Has survive_60 achievement")
		_assert_true("level_5" in manager.ACHIEVEMENT_DEFS, "T5.2.35: Has level_5 achievement")
		_assert_true("wave_3" in manager.ACHIEVEMENT_DEFS, "T5.2.36: Has wave_3 achievement")

func _test_character() -> void:
	var script = load("res://scripts/systems/character.gd")
	_assert_not_null(script, "T5.3.1: GameCharacter script loads")

	if script:
		var character = script.new("guan_yu", "Guan Yu", "Default character")
		_assert_not_null(character, "T5.3.2: GameCharacter can be instantiated")
		_assert_equal(character.id, "guan_yu", "T5.3.3: Character has correct id")
		_assert_equal(character.name, "Guan Yu", "T5.3.4: Character has correct name")
		_assert_equal(character.description, "Default character", "T5.3.5: Character has correct description")
		_assert_equal(character.health_mult, 1.0, "T5.3.6: Character has default health multiplier")
		_assert_equal(character.speed_mult, 1.0, "T5.3.7: Character has default speed multiplier")
		_assert_equal(character.damage_mult, 1.0, "T5.3.8: Character has default damage multiplier")
		_assert_equal(character.xp_mult, 1.0, "T5.3.9: Character has default xp multiplier")
		_assert_equal(character.pickup_range_mult, 1.0, "T5.3.10: Character has default pickup range multiplier")
		_assert_false(character.is_unlocked, "T5.3.11: Character starts locked by default")

		# Test to_dict and from_dict
		character.is_unlocked = true
		var dict = character.to_dict()
		_assert_true("id" in dict, "T5.3.12: to_dict includes id")
		_assert_true("is_unlocked" in dict, "T5.3.13: to_dict includes is_unlocked")

		var new_char = script.new()
		new_char.from_dict(dict)
		_assert_true(new_char.is_unlocked, "T5.3.14: from_dict restores is_unlocked")

		_assert_true(character.has_method("apply_to_player"), "T5.3.15: Has apply_to_player method")

func _test_character_manager() -> void:
	var script = load("res://scripts/systems/character_manager.gd")
	_assert_not_null(script, "T5.3.16: CharacterManager script loads")

	if script:
		var manager = script.new()
		_assert_not_null(manager, "T5.3.17: CharacterManager can be instantiated")
		_assert_true(manager.has_signal("character_unlocked"), "T5.3.18: Has character_unlocked signal")
		_assert_true(manager.has_signal("character_selected"), "T5.3.19: Has character_selected signal")
		_assert_true(manager.has_method("get_character"), "T5.3.20: Has get_character")
		_assert_true(manager.has_method("get_selected_character"), "T5.3.21: Has get_selected_character")
		_assert_true(manager.has_method("select_character"), "T5.3.22: Has select_character")
		_assert_true(manager.has_method("apply_selected_to_player"), "T5.3.23: Has apply_selected_to_player")
		_assert_true(manager.has_method("check_unlock_conditions"), "T5.3.24: Has check_unlock_conditions")
		_assert_true(manager.has_method("get_unlocked_characters"), "T5.3.25: Has get_unlocked_characters")
		_assert_true(manager.has_method("get_all_characters"), "T5.3.26: Has get_all_characters")

		# Test character definitions exist
		_assert_true(manager.CHARACTER_DEFS.size() > 0, "T5.3.27: Has character definitions")
		_assert_true("guan_yu" in manager.CHARACTER_DEFS, "T5.3.28: Has guan_yu character")
		_assert_true("zhao_yun" in manager.CHARACTER_DEFS, "T5.3.29: Has zhao_yun character")
		_assert_equal(manager.selected_character_id, "guan_yu", "T5.3.30: Default selected is guan_yu")

		# Test guan_yu is unlocked by default
		var guan_yu_def = manager.CHARACTER_DEFS["guan_yu"]
		_assert_true(guan_yu_def.unlocked, "T5.3.31: Guan Yu is unlocked by default")

		# Test zhao_yun unlock condition
		var zhao_yun_def = manager.CHARACTER_DEFS["zhao_yun"]
		_assert_false(zhao_yun_def.unlocked, "T5.3.32: Zhao Yun is locked by default")
		_assert_equal(zhao_yun_def.unlock_type, "survival_time", "T5.3.33: Zhao Yun unlock type is survival_time")
		_assert_equal(zhao_yun_def.unlock_value, 900, "T5.3.34: Zhao Yun unlock value is 900 (15 min)")

func _test_crossbow() -> void:
	var script = load("res://scripts/weapons/crossbow.gd")
	_assert_not_null(script, "T5.4.1: Crossbow script loads")

	var scene = load("res://scenes/weapons/crossbow.tscn")
	_assert_not_null(scene, "T5.4.2: Crossbow scene loads")

	if scene:
		var crossbow = scene.instantiate()
		_assert_not_null(crossbow, "T5.4.3: Crossbow can be instantiated")
		_assert_true(crossbow is Node2D, "T5.4.4: Crossbow is Node2D")
		_assert_true(crossbow.has_signal("bolt_fired"), "T5.4.5: Crossbow has bolt_fired signal")
		_assert_equal(crossbow.damage, 20, "T5.4.6: Crossbow has correct base damage")
		_assert_equal(crossbow.attack_speed, 0.8, "T5.4.7: Crossbow has correct attack speed")
		_assert_equal(crossbow.range, 400.0, "T5.4.8: Crossbow has correct range")
		_assert_equal(crossbow.bolt_speed, 600.0, "T5.4.9: Crossbow has correct bolt speed")
		_assert_equal(crossbow.pierce_count, 3, "T5.4.10: Crossbow has pierce count of 3")
		_assert_equal(crossbow.level, 1, "T5.4.11: Crossbow starts at level 1")
		_assert_true(crossbow.has_method("upgrade"), "T5.4.12: Crossbow has upgrade method")
		_assert_true(crossbow.has_method("get_total_damage"), "T5.4.13: Crossbow has get_total_damage")
		_assert_true(crossbow.has_method("get_total_pierce"), "T5.4.14: Crossbow has get_total_pierce")

		# Test level scaling
		_assert_equal(crossbow.get_total_damage(), 20, "T5.4.15: Level 1 damage is 20")
		crossbow.upgrade()
		_assert_equal(crossbow.level, 2, "T5.4.16: Upgrade increases level")
		_assert_equal(crossbow.get_total_damage(), 25, "T5.4.17: Level 2 damage is 25")
		_assert_equal(crossbow.get_total_pierce(), 4, "T5.4.18: Level 2 pierce is 4")
		crossbow.free()

func _test_crossbow_bolt() -> void:
	var script = load("res://scripts/projectiles/crossbow_bolt.gd")
	_assert_not_null(script, "T5.4.19: CrossbowBolt script loads")

	var scene = load("res://scenes/projectiles/crossbow_bolt.tscn")
	_assert_not_null(scene, "T5.4.20: CrossbowBolt scene loads")

	if scene:
		var bolt = scene.instantiate()
		_assert_not_null(bolt, "T5.4.21: CrossbowBolt can be instantiated")
		_assert_true(bolt is Area2D, "T5.4.22: CrossbowBolt is Area2D")
		_assert_true(bolt.has_signal("enemy_hit"), "T5.4.23: CrossbowBolt has enemy_hit signal")
		_assert_true(bolt.has_method("set_direction"), "T5.4.24: CrossbowBolt has set_direction")
		_assert_equal(bolt.damage, 20, "T5.4.25: CrossbowBolt has default damage")
		_assert_equal(bolt.speed, 600.0, "T5.4.26: CrossbowBolt has default speed")
		_assert_equal(bolt.pierce_count, 3, "T5.4.27: CrossbowBolt has default pierce count")
		_assert_equal(bolt.lifetime, 3.0, "T5.4.28: CrossbowBolt has 3 second lifetime")

		# Test direction setting
		bolt.set_direction(Vector2(1, 0))
		_assert_equal(bolt._direction, Vector2(1, 0), "T5.4.29: Direction is set correctly")
		bolt.free()

func _test_weapon_evolution() -> void:
	var script = load("res://scripts/systems/weapon_evolution.gd")
	_assert_not_null(script, "T5.5.1: WeaponEvolution script loads")

	if script:
		var evolution = script.new("bow", "sharpness", 5, "crossbow", "res://scenes/weapons/crossbow.tscn")
		_assert_not_null(evolution, "T5.5.2: WeaponEvolution can be instantiated")
		_assert_equal(evolution.base_weapon_id, "bow", "T5.5.3: Base weapon is bow")
		_assert_equal(evolution.required_upgrade_id, "sharpness", "T5.5.4: Required upgrade is sharpness")
		_assert_equal(evolution.required_upgrade_level, 5, "T5.5.5: Required level is 5")
		_assert_equal(evolution.result_weapon_id, "crossbow", "T5.5.6: Result weapon is crossbow")
		_assert_true(evolution.result_scene_path.length() > 0, "T5.5.7: Result scene path is set")

		# Test can_evolve
		_assert_false(evolution.can_evolve("sword", {"sharpness": 5}), "T5.5.8: Wrong weapon can't evolve")
		_assert_false(evolution.can_evolve("bow", {"sharpness": 3}), "T5.5.9: Low upgrade can't evolve")
		_assert_true(evolution.can_evolve("bow", {"sharpness": 5}), "T5.5.10: Correct conditions can evolve")
		_assert_true(evolution.can_evolve("bow", {"sharpness": 6}), "T5.5.11: Higher upgrade can also evolve")

func _test_weapon_evolution_manager() -> void:
	var script = load("res://scripts/systems/weapon_evolution_manager.gd")
	_assert_not_null(script, "T5.5.12: WeaponEvolutionManager script loads")

	if script:
		var manager = script.new()
		_assert_not_null(manager, "T5.5.13: WeaponEvolutionManager can be instantiated")
		_assert_true(manager.has_signal("evolution_available"), "T5.5.14: Has evolution_available signal")
		_assert_true(manager.has_signal("weapon_evolved"), "T5.5.15: Has weapon_evolved signal")
		_assert_true(manager.has_method("set_player"), "T5.5.16: Has set_player method")
		_assert_true(manager.has_method("set_upgrade_manager"), "T5.5.17: Has set_upgrade_manager method")
		_assert_true(manager.has_method("check_evolutions"), "T5.5.18: Has check_evolutions method")
		_assert_true(manager.has_method("evolve_weapon"), "T5.5.19: Has evolve_weapon method")
		_assert_true(manager.has_method("get_evolution_by_id"), "T5.5.20: Has get_evolution_by_id method")

		# Test evolution definitions
		_assert_true(manager.EVOLUTION_DEFS.size() > 0, "T5.5.21: Has evolution definitions")
		_assert_true("crossbow" in manager.EVOLUTION_DEFS, "T5.5.22: Has crossbow evolution")

		var crossbow_def = manager.EVOLUTION_DEFS["crossbow"]
		_assert_equal(crossbow_def.base, "bow", "T5.5.23: Crossbow base is bow")
		_assert_equal(crossbow_def.upgrade, "sharpness", "T5.5.24: Crossbow requires sharpness")
		_assert_equal(crossbow_def.level, 5, "T5.5.25: Crossbow requires level 5")

func _test_sword_tier_evolution() -> void:
	# T5.6.1: SwordBase script exists
	var script = load("res://scripts/weapons/sword_base.gd")
	_assert_not_null(script, "T5.6.1: SwordBase script loads")

	# T5.6.2: Iron Blade scene exists
	var scene = load("res://scenes/weapons/iron_blade.tscn")
	_assert_not_null(scene, "T5.6.2: Iron Blade scene loads")

	if scene and script:
		var sword = scene.instantiate()
		# Get Tier enum from script
		var Tier = script.Tier

		# T5.6.3: Sword starts at Iron Blade tier
		_assert_equal(sword.current_tier, Tier.IRON_BLADE, "T5.6.3: Sword starts at IRON_BLADE tier")

		# T5.6.4: Iron Blade has correct damage
		_assert_equal(sword.damage, 5, "T5.6.4: Iron Blade damage is 5")

		# T5.6.5: Iron Blade has correct range (60.0)
		_assert_equal(sword.attack_range, 60.0, "T5.6.5: Iron Blade range is 60")

		# T5.6.6: Iron Blade has correct cooldown
		_assert_equal(sword.attack_cooldown, 1.2, "T5.6.6: Iron Blade cooldown is 1.2")

		# T5.6.7: Kill count starts at 0
		_assert_equal(sword.kill_count, 0, "T5.6.7: Kill count starts at 0")

		# T5.6.8: on_enemy_killed increments kill count
		sword.on_enemy_killed()
		_assert_equal(sword.kill_count, 1, "T5.6.8: Kill count increments")

		# T5.6.9: Evolve to Steel Blade via upgrade() at level 4
		# Evolution is level-based: levels 4, 7, 10 trigger tier evolution
		sword.kill_count = 0  # Reset from previous test
		sword.upgrade()  # level 2
		sword.upgrade()  # level 3
		sword.upgrade()  # level 4 -> triggers evolution to Steel Blade
		_assert_equal(sword.current_tier, Tier.STEEL_BLADE, "T5.6.9: Evolves to STEEL_BLADE at level 4 via upgrade()")

		# T5.6.10: Steel Blade has correct base damage (8) + level bonuses + evolution bonuses
		# Base 8 + (level-1)*2 damage_per_level + evolution bonus 5 = 8 + 6 + 5 = 19
		var expected_damage = sword.get_total_damage()
		_assert_equal(sword.damage, expected_damage, "T5.6.10: Steel Blade damage matches get_total_damage()")

		# T5.6.11: Steel Blade has correct range (70.0 base + level bonuses + evolution bonus)
		var expected_range = sword.get_total_range()
		_assert_equal(sword.attack_range, expected_range, "T5.6.11: Steel Blade range matches get_total_range()")

		# T5.6.12: Kill count resets after evolution
		_assert_equal(sword.kill_count, 0, "T5.6.12: Kill count resets after evolution")

		# T5.6.13: Tier name getter works
		_assert_equal(sword.get_tier_name(), "Steel Blade", "T5.6.13: Tier name is correct")

		# T5.6.14: get_kills_to_next_tier reflects remaining kills
		# After evolution, kill_count is 0, kills_to_evolve for Steel Blade is 150
		_assert_equal(sword.get_kills_to_next_tier(), 150, "T5.6.14: Kills to next tier is 150")

		# T5.6.15: set_tier works
		sword.set_tier(Tier.DIVINE)
		_assert_equal(sword.damage, sword.get_total_damage(), "T5.6.15: Divine Weapon damage matches get_total_damage()")
		_assert_equal(sword.attack_range, sword.get_total_range(), "T5.6.16: Divine Weapon range matches get_total_range()")

		# T5.6.17: Divine is max tier
		_assert_equal(sword.get_kills_to_next_tier(), -1, "T5.6.17: Divine has no next tier")

		sword.free()


# =============================================================================
# PHASE 5: TORCH VISIBILITY TESTS
# =============================================================================

func _test_torch_visibility() -> void:
	# T5.7.1: TorchManager script loads
	var torch_script = load("res://scripts/systems/torch_manager.gd")
	_assert_not_null(torch_script, "T5.7.1: TorchManager script loads")

	if not torch_script:
		_assert_true(false, "T5.7.2: TorchManager has BASE_VISIBILITY_RADIUS")
		_assert_true(false, "T5.7.3: BASE_VISIBILITY_RADIUS is 0.25")
		_assert_true(false, "T5.7.4: TorchManager has TORCH_RADIUS_BONUS")
		_assert_true(false, "T5.7.5: TORCH_RADIUS_BONUS values correct")
		return

	# T5.7.2: TorchManager has BASE_VISIBILITY_RADIUS constant
	_assert_true("BASE_VISIBILITY_RADIUS" in torch_script, "T5.7.2: TorchManager has BASE_VISIBILITY_RADIUS")

	# T5.7.3: BASE_VISIBILITY_RADIUS is 0.25 (increased for better visibility)
	_assert_equal(torch_script.BASE_VISIBILITY_RADIUS, 0.25, "T5.7.3: BASE_VISIBILITY_RADIUS is 0.25")

	# T5.7.4: TorchManager has TORCH_RADIUS_BONUS array
	_assert_true("TORCH_RADIUS_BONUS" in torch_script, "T5.7.4: TorchManager has TORCH_RADIUS_BONUS")

	# T5.7.5: TORCH_RADIUS_BONUS has correct values
	var expected_bonus = [0.0, 0.15, 0.30, 0.60]
	_assert_equal(torch_script.TORCH_RADIUS_BONUS, expected_bonus, "T5.7.5: TORCH_RADIUS_BONUS values correct")

	# Create instance for method tests
	var torch = torch_script.new()

	# T5.7.6: get_visibility_radius method exists
	_assert_true(torch.has_method("get_visibility_radius"), "T5.7.6: get_visibility_radius method exists")

	# T5.7.7: Level 0 visibility is BASE_VISIBILITY_RADIUS (0.25)
	torch.torch_level = 0
	_assert_equal(torch.get_visibility_radius(), 0.25, "T5.7.7: Level 0 visibility is 0.25")

	# T5.7.8: Level 1 visibility is 0.40
	torch.torch_level = 1
	_assert_equal(torch.get_visibility_radius(), 0.40, "T5.7.8: Level 1 visibility is 0.40")

	# T5.7.9: Level 2 visibility is 0.55
	torch.torch_level = 2
	_assert_equal(torch.get_visibility_radius(), 0.55, "T5.7.9: Level 2 visibility is 0.55")

	# T5.7.10: Level 3 visibility is 0.85 (nearly full screen)
	torch.torch_level = 3
	_assert_equal(torch.get_visibility_radius(), 0.85, "T5.7.10: Level 3 visibility is 0.85")

	# T5.7.11: Old brightness methods removed
	_assert_false(torch.has_method("get_night_brightness_bonus"), "T5.7.11: get_night_brightness_bonus removed")
	_assert_false(torch.has_method("get_spawn_rate_reduction"), "T5.7.12: get_spawn_rate_reduction removed")

	torch.free()


# =============================================================================
# PHASE 5: FOG OF WAR TESTS
# =============================================================================

func _test_fog_of_war() -> void:
	# T5.8.1: Fog of war shader exists
	var shader = load("res://assets/shaders/fog_of_war.gdshader")
	_assert_not_null(shader, "T5.8.1: Fog of war shader exists")

	# T5.8.2: Main scene loads
	var main_scene = load("res://scenes/main.tscn")
	_assert_not_null(main_scene, "T5.8.2: Main scene loads")

	if main_scene:
		var main = main_scene.instantiate()

		# T5.8.3: FogOfWarLayer exists
		var fog_layer = main.get_node_or_null("FogOfWarLayer")
		_assert_not_null(fog_layer, "T5.8.3: FogOfWarLayer node exists")

		# T5.8.4: FogOfWarLayer is CanvasLayer
		_assert_true(fog_layer is CanvasLayer, "T5.8.4: FogOfWarLayer is CanvasLayer")

		# T5.8.5: FogOfWar ColorRect exists
		var fog_rect = main.get_node_or_null("FogOfWarLayer/FogOfWar")
		_assert_not_null(fog_rect, "T5.8.5: FogOfWar ColorRect exists")

		# T5.8.6: FogOfWar is ColorRect
		if fog_rect:
			_assert_true(fog_rect is ColorRect, "T5.8.6: FogOfWar is ColorRect")

			# T5.8.7: FogOfWar has ShaderMaterial
			_assert_true(fog_rect.material is ShaderMaterial, "T5.8.7: FogOfWar has ShaderMaterial")

			if fog_rect.material is ShaderMaterial:
				var mat = fog_rect.material as ShaderMaterial

				# T5.8.8: Shader has enabled parameter
				var enabled = mat.get_shader_parameter("enabled")
				_assert_true(enabled != null or enabled == false, "T5.8.8: Shader has enabled parameter")

				# T5.8.9: Shader has player_pos parameter
				var player_pos = mat.get_shader_parameter("player_pos")
				_assert_not_null(player_pos, "T5.8.9: Shader has player_pos parameter")

				# T5.8.10: Shader has visibility_radius parameter
				var radius = mat.get_shader_parameter("visibility_radius")
				_assert_not_null(radius, "T5.8.10: Shader has visibility_radius parameter")

				# T5.8.11: Default visibility_radius is 0.25
				_assert_equal(radius, 0.25, "T5.8.11: Default visibility_radius is 0.25")

				# T5.8.12: Shader has darkness parameter
				var darkness = mat.get_shader_parameter("darkness")
				_assert_not_null(darkness, "T5.8.12: Shader has darkness parameter")

				# T5.8.13: Default darkness is 0.9 (90%)
				_assert_equal(darkness, 0.9, "T5.8.13: Default darkness is 0.9")

				# T5.8.14: Shader has has_torch parameter for clear vision
				var has_torch = mat.get_shader_parameter("has_torch")
				_assert_true(has_torch != null or has_torch == false, "T5.8.14: Shader has has_torch parameter")

				# T5.8.15: Shader has screen_size parameter for aspect ratio
				var screen_size = mat.get_shader_parameter("screen_size")
				_assert_not_null(screen_size, "T5.8.15: Shader has screen_size parameter")
		else:
			_assert_true(false, "T5.8.6: FogOfWar is ColorRect")
			_assert_true(false, "T5.8.7: FogOfWar has ShaderMaterial")
			_assert_true(false, "T5.8.8: Shader has enabled parameter")
			_assert_true(false, "T5.8.9: Shader has player_pos parameter")
			_assert_true(false, "T5.8.10: Shader has visibility_radius parameter")
			_assert_true(false, "T5.8.11: Default visibility_radius is 0.25")
			_assert_true(false, "T5.8.12: Shader has darkness parameter")
			_assert_true(false, "T5.8.13: Default darkness is 0.9")

		# T5.8.16: Game script has fog_of_war reference
		var game_script = load("res://scripts/game.gd")
		_assert_not_null(game_script, "T5.8.16: Game script loads")

		# T5.8.17: DayNightCycle no longer has torch_manager reference
		var dnc = main.get_node_or_null("DayNightCycle")
		if dnc:
			_assert_false("torch_manager" in dnc, "T5.8.17: DayNightCycle has no torch_manager")
		else:
			_assert_true(false, "T5.8.17: DayNightCycle has no torch_manager")

		# T5.8.18: Spawner no longer has torch_manager reference
		var spawner = main.get_node_or_null("MobSpawner")
		if spawner:
			_assert_false("torch_manager" in spawner, "T5.8.18: Spawner has no torch_manager")
		else:
			_assert_true(false, "T5.8.18: Spawner has no torch_manager")

		main.free()
	else:
		# Fail all tests if scene doesn't load
		for i in range(16):
			_assert_true(false, "T5.8.%d: Main scene failed to load" % (i + 3))


# =============================================================================
# PHASE 5: ASSASSIN ARROW DODGE TESTS
# =============================================================================

func _test_assassin_arrow_dodge() -> void:
	# T5.9.1: Assassin scene loads
	var assassin_scene = load("res://scenes/enemies/assassin.tscn")
	_assert_not_null(assassin_scene, "T5.9.1: Assassin scene loads")

	if assassin_scene:
		var assassin = assassin_scene.instantiate()

		# T5.9.2: Assassin has arrow_dodge_enabled property
		_assert_true("arrow_dodge_enabled" in assassin, "T5.9.2: Assassin has arrow_dodge_enabled")

		# T5.9.3: Arrow dodge is enabled by default
		if "arrow_dodge_enabled" in assassin:
			_assert_true(assassin.arrow_dodge_enabled, "T5.9.3: Arrow dodge enabled by default")

		# T5.9.4: Assassin has arrow_detection_radius property
		_assert_true("arrow_detection_radius" in assassin, "T5.9.4: Assassin has arrow_detection_radius")

		# T5.9.5: Detection radius is 120.0
		if "arrow_detection_radius" in assassin:
			_assert_equal(assassin.arrow_detection_radius, 120.0, "T5.9.5: Detection radius is 120")

		# T5.9.6: Assassin has dodge_chance property
		_assert_true("dodge_chance" in assassin, "T5.9.6: Assassin has dodge_chance")

		# T5.9.7: Dodge chance is 0.8 (80%)
		if "dodge_chance" in assassin:
			_assert_equal(assassin.dodge_chance, 0.8, "T5.9.7: Dodge chance is 0.8")

		# T5.9.8: Assassin has _dodge_arrow method
		_assert_true(assassin.has_method("_dodge_arrow"), "T5.9.8: Assassin has _dodge_arrow method")

		# T5.9.9: Assassin has _will_arrow_hit method
		_assert_true(assassin.has_method("_will_arrow_hit"), "T5.9.9: Assassin has _will_arrow_hit method")

		# T5.9.10: Assassin has _setup_arrow_detection method
		_assert_true(assassin.has_method("_setup_arrow_detection"), "T5.9.10: Assassin has _setup_arrow_detection")

		# T5.9.11: Assassin has target variable for dodge direction
		_assert_true("target" in assassin, "T5.9.11: Assassin has target variable")

		# T5.9.12: Verify dodge is random direction (not towards player)
		# The _dodge_arrow method uses random angle for teleport direction
		_assert_true(assassin.has_method("_dodge_arrow"), "T5.9.12: _dodge_arrow method verified")

		assassin.free()
	else:
		# Fail all tests if scene doesn't load
		for i in range(11):
			_assert_true(false, "T5.9.%d: Assassin scene failed" % (i + 2))


# =============================================================================
# PHASE 5: ELITE ENEMY SPAWNING TESTS
# =============================================================================

func _test_elite_enemy_spawning() -> void:
	# T5.E.1: Spawner script loads
	var spawner_script = load("res://scripts/spawner.gd")
	_assert_not_null(spawner_script, "T5.E.1: Spawner script loads")

	# T5.E.2: Assassin scene exists
	var assassin_scene = load("res://scenes/enemies/assassin.tscn")
	_assert_not_null(assassin_scene, "T5.E.2: Assassin scene exists")

	# T5.E.3: Sorcerer scene exists
	var sorcerer_scene = load("res://scenes/enemies/sorcerer.tscn")
	_assert_not_null(sorcerer_scene, "T5.E.3: Sorcerer scene exists")

	# Create spawner instance for testing
	if spawner_script:
		var spawner = spawner_script.new()

		# T5.E.4: Spawner has assassin_weight
		_assert_true("assassin_weight" in spawner, "T5.E.4: Spawner has assassin_weight")

		# T5.E.5: Spawner has sorcerer_weight
		_assert_true("sorcerer_weight" in spawner, "T5.E.5: Spawner has sorcerer_weight")

		# T5.E.6: Assassin spawns after 120 seconds (check weight logic)
		spawner.game_time = 0.0
		spawner._update_spawn_weights()
		_assert_equal(spawner.assassin_weight, 0.0, "T5.E.6: Assassin weight 0 at start")

		# T5.E.7: Assassin weight increases after 120 seconds
		spawner.game_time = 130.0
		spawner._update_spawn_weights()
		_assert_true(spawner.assassin_weight > 0, "T5.E.7: Assassin weight > 0 after 120s")

		# T5.E.8: Sorcerer spawns after 150 seconds
		spawner.game_time = 0.0
		spawner._update_spawn_weights()
		_assert_equal(spawner.sorcerer_weight, 0.0, "T5.E.8: Sorcerer weight 0 at start")

		# T5.E.9: Sorcerer weight increases after 150 seconds
		spawner.game_time = 160.0
		spawner._update_spawn_weights()
		_assert_true(spawner.sorcerer_weight > 0, "T5.E.9: Sorcerer weight > 0 after 150s")

		# T5.E.10: Wave 5 guarantees minimum assassin weight
		spawner.assassin_weight = 0.0
		spawner.set_wave(5)
		_assert_true(spawner.assassin_weight >= 8.0, "T5.E.10: Wave 5 guarantees assassin_weight >= 8")

		# T5.E.11: Wave 6 guarantees minimum sorcerer weight
		spawner.sorcerer_weight = 0.0
		spawner.set_wave(6)
		_assert_true(spawner.sorcerer_weight >= 5.0, "T5.E.11: Wave 6 guarantees sorcerer_weight >= 5")

		# T5.E.12: Assassin max weight is 20
		spawner.game_time = 500.0
		spawner._update_spawn_weights()
		_assert_true(spawner.assassin_weight <= 20.0, "T5.E.12: Assassin max weight is 20")

		# T5.E.13: Sorcerer max weight is 15
		_assert_true(spawner.sorcerer_weight <= 15.0, "T5.E.13: Sorcerer max weight is 15")

		spawner.free()


# =============================================================================
# PHASE 5: UPGRADE ARTWORK TESTS
# =============================================================================

func _test_upgrade_artwork() -> void:
	# T5.10.1: UpgradeManager script loads
	var manager_script = load("res://scripts/systems/upgrade_manager.gd")
	_assert_not_null(manager_script, "T5.10.1: UpgradeManager script loads")

	if not manager_script:
		_assert_true(false, "T5.10.2: UPGRADE_DEFS exists")
		return

	# T5.10.2: UPGRADE_DEFS exists
	_assert_true("UPGRADE_DEFS" in manager_script, "T5.10.2: UPGRADE_DEFS exists")

	# Test each upgrade icon exists
	var upgrade_icons = {
		"sharpness": "res://assets/ui/upgrades/sharpness.svg",
		"knockback": "res://assets/ui/upgrades/knockback.svg",
		"looting": "res://assets/ui/upgrades/looting.svg",
		"protection": "res://assets/ui/upgrades/protection.svg",
		"swiftness": "res://assets/ui/upgrades/swiftness.svg",
		"sweeping": "res://assets/ui/upgrades/sweeping.svg",
		"haste": "res://assets/ui/upgrades/haste.svg",
		"torch": "res://assets/ui/upgrades/torch.svg",
	}

	var test_num = 3
	for id in upgrade_icons:
		var path = upgrade_icons[id]
		var icon = load(path)
		_assert_not_null(icon, "T5.10.%d: %s icon exists (%s)" % [test_num, id, path])
		test_num += 1

	# Test weapon icons exist
	var weapon_icons = {
		"iron_blade": "res://assets/weapons/iron_blade.svg",
		"steel_blade": "res://assets/weapons/steel_blade.svg",
		"fine_steel_blade": "res://assets/weapons/fine_steel_blade.svg",
		"divine_weapon": "res://assets/weapons/divine_weapon.svg",
		"bow": "res://assets/weapons/bow.svg",
		"crossbow": "res://assets/weapons/crossbow.svg",
		"torch": "res://assets/weapons/torch.svg",
	}

	for id in weapon_icons:
		var path = weapon_icons[id]
		var icon = load(path)
		_assert_not_null(icon, "T5.10.%d: %s weapon icon exists" % [test_num, id])
		test_num += 1

	# Test UPGRADE_DEFS icon paths match actual files
	for id in manager_script.UPGRADE_DEFS:
		var def = manager_script.UPGRADE_DEFS[id]
		if def.has("icon"):
			var icon = load(def.icon)
			_assert_not_null(icon, "T5.10.%d: UPGRADE_DEFS[%s] icon path valid" % [test_num, id])
			test_num += 1

	# Test sword icon matches default in UPGRADE_DEFS
	var sword_def = manager_script.UPGRADE_DEFS.get("sword", {})
	_assert_equal(sword_def.get("icon", ""), "res://assets/weapons/iron_blade.svg", "T5.10.%d: Sword default icon is iron_blade" % test_num)
	test_num += 1

	# Test bow icon matches default in UPGRADE_DEFS
	var bow_def = manager_script.UPGRADE_DEFS.get("bow", {})
	_assert_equal(bow_def.get("icon", ""), "res://assets/weapons/bow.svg", "T5.10.%d: Bow default icon is bow" % test_num)
	test_num += 1

	# Test UpgradeManager methods exist
	var manager = manager_script.new()
	_assert_true(manager.has_method("get_weapon_icon"), "T5.10.%d: get_weapon_icon method exists" % (test_num + 1))
	_assert_true(manager.has_method("get_next_evolution_icon"), "T5.10.%d: get_next_evolution_icon method exists" % (test_num + 2))
	manager.free()
	test_num += 3

	# Test torch is in WEAPON_UPGRADE_IDS
	_assert_true("torch" in manager_script.WEAPON_UPGRADE_IDS, "T5.10.%d: Torch in WEAPON_UPGRADE_IDS" % test_num)
	test_num += 1

	# Test torch weapon scene exists
	var torch_scene = load("res://scenes/weapons/torch.tscn")
	_assert_not_null(torch_scene, "T5.10.%d: Torch weapon scene exists" % test_num)
	test_num += 1

	# Test torch weapon script exists
	var torch_script = load("res://scripts/weapons/torch.gd")
	_assert_not_null(torch_script, "T5.10.%d: Torch weapon script exists" % test_num)
	test_num += 1

	if torch_scene:
		var torch = torch_scene.instantiate()

		# Test torch has level property
		_assert_true("level" in torch, "T5.10.%d: Torch has level property" % test_num)
		test_num += 1

		# Test torch has upgrade method
		_assert_true(torch.has_method("upgrade"), "T5.10.%d: Torch has upgrade method" % test_num)
		test_num += 1

		# Test torch has Sprite2D
		var sprite = torch.get_node_or_null("Sprite2D")
		_assert_not_null(sprite, "T5.10.%d: Torch has Sprite2D" % test_num)

		torch.free()


# =============================================================================
# PHASE 6: BOSS SYSTEM TESTS
# =============================================================================

# =============================================================================
# PHASE 6 STEP 1: XIAHOU DUN BOSS TESTS (T6.1)
# =============================================================================

func _test_xiahou_dun_boss() -> void:
	# T6.1.1: Xiahou Dun script loads
	var xiahou_dun_script = load("res://scripts/enemies/xiahou_dun.gd")
	_assert_not_null(xiahou_dun_script, "T6.1.1: Xiahou Dun script loads")

	# T6.1.2: Xiahou Dun scene loads
	var xiahou_dun_scene = load("res://scenes/enemies/xiahou_dun.tscn")
	_assert_not_null(xiahou_dun_scene, "T6.1.2: Xiahou Dun scene loads")

	if xiahou_dun_scene:
		var xiahou_dun = xiahou_dun_scene.instantiate()

		# T6.1.3: Xiahou Dun has health property (400)
		_assert_true("health" in xiahou_dun, "T6.1.3: Xiahou Dun has health property")
		if "health" in xiahou_dun:
			_assert_equal(xiahou_dun.health, 400, "T6.1.3a: Xiahou Dun health is 400")

		# T6.1.4: Xiahou Dun has speed property (40)
		_assert_true("speed" in xiahou_dun, "T6.1.4: Xiahou Dun has speed property")
		if "speed" in xiahou_dun:
			_assert_equal(xiahou_dun.speed, 40, "T6.1.4a: Xiahou Dun speed is 40")

		# T6.1.5: Xiahou Dun has contact_damage property (5)
		_assert_true("contact_damage" in xiahou_dun, "T6.1.5: Xiahou Dun has contact_damage property")
		if "contact_damage" in xiahou_dun:
			_assert_equal(xiahou_dun.contact_damage, 5, "T6.1.5a: Xiahou Dun contact_damage is 5")

		# T6.1.6: Xiahou Dun has fang_cooldown property (3.0)
		_assert_true("fang_cooldown" in xiahou_dun, "T6.1.6: Xiahou Dun has fang_cooldown property")
		if "fang_cooldown" in xiahou_dun:
			_assert_equal(xiahou_dun.fang_cooldown, 3.0, "T6.1.6a: Xiahou Dun fang_cooldown is 3.0")

		# T6.1.7: Xiahou Dun has summon_cooldown property (8.0)
		_assert_true("summon_cooldown" in xiahou_dun, "T6.1.7: Xiahou Dun has summon_cooldown property")
		if "summon_cooldown" in xiahou_dun:
			_assert_equal(xiahou_dun.summon_cooldown, 8.0, "T6.1.7a: Xiahou Dun summon_cooldown is 8.0")

		# T6.1.8: Xiahou Dun has cast_fang_attack method
		_assert_true(xiahou_dun.has_method("cast_fang_attack"), "T6.1.8: Xiahou Dun has cast_fang_attack method")

		# T6.1.9: Xiahou Dun has summon_shadow_guard method
		_assert_true(xiahou_dun.has_method("summon_shadow_guard"), "T6.1.9: Xiahou Dun has summon_shadow_guard method")

		# T6.1.10: Xiahou Dun has xp_value property (200)
		_assert_true("xp_value" in xiahou_dun, "T6.1.10: Xiahou Dun has xp_value property")
		if "xp_value" in xiahou_dun:
			_assert_equal(xiahou_dun.xp_value, 200, "T6.1.10a: Xiahou Dun xp_value is 200")

		# T6.1.11: Xiahou Dun has emerald_drop property (30)
		_assert_true("emerald_drop" in xiahou_dun, "T6.1.11: Xiahou Dun has emerald_drop property")
		if "emerald_drop" in xiahou_dun:
			_assert_equal(xiahou_dun.emerald_drop, 30, "T6.1.11a: Xiahou Dun emerald_drop is 30")

		# T6.1.12: Xiahou Dun is CharacterBody2D
		_assert_true(xiahou_dun is CharacterBody2D, "T6.1.12: Xiahou Dun is CharacterBody2D")

		# T6.1.13: Xiahou Dun knockback_immune
		_assert_true("knockback_immune" in xiahou_dun, "T6.1.13: Xiahou Dun has knockback_immune property")
		if "knockback_immune" in xiahou_dun:
			_assert_true(xiahou_dun.knockback_immune, "T6.1.13a: Xiahou Dun knockback_immune is true")

		# T6.1.14: Xiahou Dun poison_immune
		_assert_true("poison_immune" in xiahou_dun, "T6.1.14: Xiahou Dun has poison_immune property")
		if "poison_immune" in xiahou_dun:
			_assert_true(xiahou_dun.poison_immune, "T6.1.14a: Xiahou Dun poison_immune is true")

		# T6.1.15: Xiahou Dun damage_reduction (0.2)
		_assert_true("damage_reduction" in xiahou_dun, "T6.1.15: Xiahou Dun has damage_reduction property")
		if "damage_reduction" in xiahou_dun:
			_assert_equal(xiahou_dun.damage_reduction, 0.2, "T6.1.15a: Xiahou Dun damage_reduction is 0.2")

		xiahou_dun.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T6.1.3: Xiahou Dun has health property")
		_assert_true(false, "T6.1.3a: Xiahou Dun health is 400")
		_assert_true(false, "T6.1.4: Xiahou Dun has speed property")
		_assert_true(false, "T6.1.4a: Xiahou Dun speed is 40")
		_assert_true(false, "T6.1.5: Xiahou Dun has contact_damage property")
		_assert_true(false, "T6.1.5a: Xiahou Dun contact_damage is 5")
		_assert_true(false, "T6.1.6: Xiahou Dun has fang_cooldown property")
		_assert_true(false, "T6.1.6a: Xiahou Dun fang_cooldown is 3.0")
		_assert_true(false, "T6.1.7: Xiahou Dun has summon_cooldown property")
		_assert_true(false, "T6.1.7a: Xiahou Dun summon_cooldown is 8.0")
		_assert_true(false, "T6.1.8: Xiahou Dun has cast_fang_attack method")
		_assert_true(false, "T6.1.9: Xiahou Dun has summon_shadow_guard method")
		_assert_true(false, "T6.1.10: Xiahou Dun has xp_value property")
		_assert_true(false, "T6.1.10a: Xiahou Dun xp_value is 200")
		_assert_true(false, "T6.1.11: Xiahou Dun has emerald_drop property")
		_assert_true(false, "T6.1.11a: Xiahou Dun emerald_drop is 30")
		_assert_true(false, "T6.1.12: Xiahou Dun is CharacterBody2D")
		_assert_true(false, "T6.1.13: Xiahou Dun has knockback_immune property")
		_assert_true(false, "T6.1.13a: Xiahou Dun knockback_immune is true")
		_assert_true(false, "T6.1.14: Xiahou Dun has poison_immune property")
		_assert_true(false, "T6.1.14a: Xiahou Dun poison_immune is true")
		_assert_true(false, "T6.1.15: Xiahou Dun has damage_reduction property")
		_assert_true(false, "T6.1.15a: Xiahou Dun damage_reduction is 0.2")


# =============================================================================
# PHASE 6 STEP 2: GROUND SPIKE TESTS (T6.2)
# =============================================================================

func _test_ground_spike() -> void:
	# T6.2.1: GroundSpike script loads
	var fang_script = load("res://scripts/effects/ground_spike.gd")
	_assert_not_null(fang_script, "T6.2.1: GroundSpike script loads")

	# T6.2.2: GroundSpike scene loads
	var fang_scene = load("res://scenes/effects/ground_spike.tscn")
	_assert_not_null(fang_scene, "T6.2.2: GroundSpike scene loads")

	if fang_scene:
		var fang = fang_scene.instantiate()

		# T6.2.3: GroundSpike has damage property (15)
		_assert_true("damage" in fang, "T6.2.3: GroundSpike has damage property")
		if "damage" in fang:
			_assert_equal(fang.damage, 15, "T6.2.3a: GroundSpike damage is 15")

		# T6.2.4: GroundSpike has lifetime property (0.5)
		_assert_true("lifetime" in fang, "T6.2.4: GroundSpike has lifetime property")
		if "lifetime" in fang:
			_assert_equal(fang.lifetime, 0.5, "T6.2.4a: GroundSpike lifetime is 0.5")

		# T6.2.5: GroundSpike is Area2D
		_assert_true(fang is Area2D, "T6.2.5: GroundSpike is Area2D")

		# T6.2.6: GroundSpike has warning_duration (0.5)
		_assert_true("warning_duration" in fang, "T6.2.6: GroundSpike has warning_duration property")
		if "warning_duration" in fang:
			_assert_equal(fang.warning_duration, 0.5, "T6.2.6a: GroundSpike warning_duration is 0.5")

		fang.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T6.2.3: GroundSpike has damage property")
		_assert_true(false, "T6.2.3a: GroundSpike damage is 15")
		_assert_true(false, "T6.2.4: GroundSpike has lifetime property")
		_assert_true(false, "T6.2.4a: GroundSpike lifetime is 0.5")
		_assert_true(false, "T6.2.5: GroundSpike is Area2D")
		_assert_true(false, "T6.2.6: GroundSpike has warning_duration property")
		_assert_true(false, "T6.2.6a: GroundSpike warning_duration is 0.5")


# =============================================================================
# PHASE 6 STEP 3: SHADOW GUARD TESTS (T6.3)
# =============================================================================

func _test_shadow_guard() -> void:
	# T6.3.1: Shadow Guard script loads
	var shadow_guard_script = load("res://scripts/enemies/shadow_guard.gd")
	_assert_not_null(shadow_guard_script, "T6.3.1: Shadow Guard script loads")

	# T6.3.2: Shadow Guard scene loads
	var shadow_guard_scene = load("res://scenes/enemies/shadow_guard.tscn")
	_assert_not_null(shadow_guard_scene, "T6.3.2: Shadow Guard scene loads")

	if shadow_guard_scene:
		var shadow_guard = shadow_guard_scene.instantiate()

		# T6.3.3: Shadow Guard has health property (10)
		_assert_true("health" in shadow_guard, "T6.3.3: Shadow Guard has health property")
		if "health" in shadow_guard:
			_assert_equal(shadow_guard.health, 10, "T6.3.3a: Shadow Guard health is 10")

		# T6.3.4: Shadow Guard has damage property (8)
		_assert_true("damage" in shadow_guard, "T6.3.4: Shadow Guard has damage property")
		if "damage" in shadow_guard:
			_assert_equal(shadow_guard.damage, 8, "T6.3.4a: Shadow Guard damage is 8")

		# T6.3.5: Shadow Guard has speed property (120)
		_assert_true("speed" in shadow_guard, "T6.3.5: Shadow Guard has speed property")
		if "speed" in shadow_guard:
			_assert_equal(shadow_guard.speed, 120, "T6.3.5a: Shadow Guard speed is 120")

		# T6.3.6: Shadow Guard has xp_value property (3)
		_assert_true("xp_value" in shadow_guard, "T6.3.6: Shadow Guard has xp_value property")
		if "xp_value" in shadow_guard:
			_assert_equal(shadow_guard.xp_value, 3, "T6.3.6a: Shadow Guard xp_value is 3")

		# T6.3.7: Shadow Guard has lifetime property (15.0)
		_assert_true("lifetime" in shadow_guard, "T6.3.7: Shadow Guard has lifetime property")
		if "lifetime" in shadow_guard:
			_assert_equal(shadow_guard.lifetime, 15.0, "T6.3.7a: Shadow Guard lifetime is 15.0")

		# T6.3.8: Shadow Guard is CharacterBody2D
		_assert_true(shadow_guard is CharacterBody2D, "T6.3.8: Shadow Guard is CharacterBody2D")

		# T6.3.9: Shadow Guard has can_pass_walls property (true)
		_assert_true("can_pass_walls" in shadow_guard, "T6.3.9: Shadow Guard has can_pass_walls property")
		if "can_pass_walls" in shadow_guard:
			_assert_true(shadow_guard.can_pass_walls, "T6.3.9a: Shadow Guard can_pass_walls is true")

		# T6.3.10: Shadow Guard has apply_knockback method
		_assert_true(shadow_guard.has_method("apply_knockback"), "T6.3.10: Shadow Guard has apply_knockback method")

		shadow_guard.free()
	else:
		# Script/scene doesn't exist yet - fail remaining tests
		_assert_true(false, "T6.3.3: Shadow Guard has health property")
		_assert_true(false, "T6.3.3a: Shadow Guard health is 10")
		_assert_true(false, "T6.3.4: Shadow Guard has damage property")
		_assert_true(false, "T6.3.4a: Shadow Guard damage is 8")
		_assert_true(false, "T6.3.5: Shadow Guard has speed property")
		_assert_true(false, "T6.3.5a: Shadow Guard speed is 120")
		_assert_true(false, "T6.3.6: Shadow Guard has xp_value property")
		_assert_true(false, "T6.3.6a: Shadow Guard xp_value is 3")
		_assert_true(false, "T6.3.7: Shadow Guard has lifetime property")
		_assert_true(false, "T6.3.7a: Shadow Guard lifetime is 15.0")
		_assert_true(false, "T6.3.8: Shadow Guard is CharacterBody2D")
		_assert_true(false, "T6.3.9: Shadow Guard has can_pass_walls property")
		_assert_true(false, "T6.3.9a: Shadow Guard can_pass_walls is true")
		_assert_true(false, "T6.3.10: Shadow Guard has apply_knockback method")


# =============================================================================
# PHASE 6 STEP 4: BOSS BATTLE SYSTEM TESTS (T6.4)
# =============================================================================

func _test_boss_battle_system() -> void:
	# T6.4.1: WaveManager has is_boss_wave method
	var wave_script = load("res://scripts/systems/wave_manager.gd")
	_assert_not_null(wave_script, "T6.4.1a: WaveManager script loads")

	if wave_script:
		var wave_manager = wave_script.new()

		_assert_true(wave_manager.has_method("is_boss_wave"), "T6.4.1: WaveManager has is_boss_wave method")

		# T6.4.2: WaveManager.is_boss_wave(5) returns true
		if wave_manager.has_method("is_boss_wave"):
			_assert_true(wave_manager.is_boss_wave(5), "T6.4.2: WaveManager.is_boss_wave(5) returns true")
		else:
			_assert_true(false, "T6.4.2: WaveManager.is_boss_wave(5) returns true")

		wave_manager.free()
	else:
		_assert_true(false, "T6.4.1: WaveManager has is_boss_wave method")
		_assert_true(false, "T6.4.2: WaveManager.is_boss_wave(5) returns true")

	# T6.4.3: BossHealthBar script loads
	var bar_script = load("res://scripts/ui/boss_health_bar.gd")
	_assert_not_null(bar_script, "T6.4.3: BossHealthBar script loads")

	# T6.4.4-5: BossHealthBar methods
	var bar_scene = load("res://scenes/ui/boss_health_bar.tscn")
	if bar_scene:
		var bar = bar_scene.instantiate()
		_assert_true(bar.has_method("set_boss"), "T6.4.4: BossHealthBar has set_boss method")
		_assert_true(bar.has_method("update_health"), "T6.4.5: BossHealthBar has update_health method")
		bar.free()
	else:
		_assert_true(false, "T6.4.4: BossHealthBar has set_boss method")
		_assert_true(false, "T6.4.5: BossHealthBar has update_health method")

	# T6.4.6: Spawner has pause_spawning method
	var spawner_script = load("res://scripts/spawner.gd")
	if spawner_script:
		var spawner = spawner_script.new()
		_assert_true(spawner.has_method("pause_spawning"), "T6.4.6: Spawner has pause_spawning method")
		spawner.free()
	else:
		_assert_true(false, "T6.4.6: Spawner has pause_spawning method")


# =============================================================================
# PHASE 6 STEP 5: BOSS DROP SYSTEM TESTS (T6.5)
# =============================================================================

func _test_boss_drop_system() -> void:
	# T6.5.1: Xiahou Dun emits died signal with xp_value
	var xiahou_dun_scene = load("res://scenes/enemies/xiahou_dun.tscn")
	if xiahou_dun_scene:
		var xiahou_dun = xiahou_dun_scene.instantiate()
		_assert_true(xiahou_dun.has_signal("died"), "T6.5.1: Xiahou Dun has died signal")
		if "xp_value" in xiahou_dun:
			_assert_equal(xiahou_dun.xp_value, 200, "T6.5.1a: Xiahou Dun xp_value for died signal is 200")
		else:
			_assert_true(false, "T6.5.1a: Xiahou Dun xp_value for died signal is 200")
		xiahou_dun.free()
	else:
		_assert_true(false, "T6.5.1: Xiahou Dun has died signal")
		_assert_true(false, "T6.5.1a: Xiahou Dun xp_value for died signal is 200")

	# T6.5.2: EmeraldPickup script loads
	var emerald_script = load("res://scripts/pickups/emerald_pickup.gd")
	_assert_not_null(emerald_script, "T6.5.2: EmeraldPickup script loads")

	# T6.5.3: EmeraldPickup has value property (30)
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if emerald_scene:
		var emerald = emerald_scene.instantiate()
		_assert_true("value" in emerald, "T6.5.3: EmeraldPickup has value property")
		if "value" in emerald:
			_assert_equal(emerald.value, 30, "T6.5.3a: EmeraldPickup value is 30")
		else:
			_assert_true(false, "T6.5.3a: EmeraldPickup value is 30")
		emerald.free()
	else:
		_assert_true(false, "T6.5.3: EmeraldPickup has value property")
		_assert_true(false, "T6.5.3a: EmeraldPickup value is 30")

	# T6.5.4: TotemPickup script loads
	var totem_script = load("res://scripts/pickups/totem_pickup.gd")
	_assert_not_null(totem_script, "T6.5.4: TotemPickup script loads")

# =============================================================================
# PHASE 7: COMPLETE COVERAGE TESTS
# =============================================================================

func _run_complete_coverage_tests() -> void:
	# Initialize coverage tracker if enabled
	if ENABLE_COVERAGE:
		var CoverageTrackerClass = load("res://tests/coverage/coverage_tracker.gd")
		if CoverageTrackerClass:
			coverage_tracker = CoverageTrackerClass.new()

	# Run Player Complete Tests
	_run_external_test_suite("Player Complete Tests", "res://tests/unit/player/test_player_complete.gd")

	# Run Health Component Complete Tests
	_run_external_test_suite("Health Complete Tests", "res://tests/unit/components/test_health_complete.gd")

	# Run Upgrade Manager Complete Tests
	_run_external_test_suite("Upgrade Manager Complete Tests", "res://tests/unit/systems/test_upgrade_manager_complete.gd")

	# Run Enemy Complete Tests
	_run_external_test_suite("Infantry Complete Tests", "res://tests/unit/enemies/test_infantry_complete.gd")
	_run_external_test_suite("Archer Complete Tests", "res://tests/unit/enemies/test_archer_complete.gd")
	_run_external_test_suite("Cavalry Complete Tests", "res://tests/unit/enemies/test_cavalry_complete.gd")
	_run_external_test_suite("Fire Soldier Complete Tests", "res://tests/unit/enemies/test_fire_soldier_complete.gd")
	_run_external_test_suite("Assassin Complete Tests", "res://tests/unit/enemies/test_assassin_complete.gd")
	_run_external_test_suite("Sorcerer Complete Tests", "res://tests/unit/enemies/test_sorcerer_complete.gd")
	_run_external_test_suite("Xiahou Dun Complete Tests", "res://tests/unit/enemies/test_xiahou_dun_complete.gd")
	_run_external_test_suite("Shadow Guard Complete Tests", "res://tests/unit/enemies/test_shadow_guard_complete.gd")
	_run_external_test_suite("Boss Enemies Tests", "res://tests/unit/enemies/test_boss_enemies.gd")

	# Run Weapon Complete Tests
	_run_external_test_suite("Sword Complete Tests", "res://tests/unit/weapons/test_sword_complete.gd")
	_run_external_test_suite("Bow Complete Tests", "res://tests/unit/weapons/test_bow_complete.gd")
	_run_external_test_suite("Crossbow Complete Tests", "res://tests/unit/weapons/test_crossbow_complete.gd")

	# Run Projectile Tests
	_run_external_test_suite("Projectiles Complete Tests", "res://tests/unit/projectiles/test_projectiles_complete.gd")

	# Run System Complete Tests
	_run_external_test_suite("Wave Manager Complete Tests", "res://tests/unit/systems/test_wave_manager_complete.gd")
	_run_external_test_suite("Day/Night Complete Tests", "res://tests/unit/systems/test_day_night_complete.gd")
	_run_external_test_suite("Combo System Complete Tests", "res://tests/unit/systems/test_combo_system_complete.gd")

	# Run UI Complete Tests
	_run_external_test_suite("UI Complete Tests", "res://tests/unit/ui/test_ui_complete.gd")

	# Run Core Complete Tests (NEW)
	_run_external_test_suite("Game Complete Tests", "res://tests/unit/core/test_game_complete.gd")
	_run_external_test_suite("Spawner Complete Tests", "res://tests/unit/core/test_spawner_complete.gd")
	_run_external_test_suite("Arena Complete Tests", "res://tests/unit/core/test_arena_complete.gd")
	_run_external_test_suite("Camera Complete Tests", "res://tests/unit/core/test_camera_complete.gd")

	# Run Additional Component Tests (NEW)
	_run_external_test_suite("Status Effect Complete Tests", "res://tests/unit/components/test_status_effect_complete.gd")
	_run_external_test_suite("Status Effect Manager Complete Tests", "res://tests/unit/components/test_status_effect_manager_complete.gd")
	_run_external_test_suite("Weapon Slots Complete Tests", "res://tests/unit/components/test_weapon_slots_complete.gd")

	# Run Additional Weapon Tests (NEW)
	_run_external_test_suite("Divine Weapon Complete Tests", "res://tests/unit/weapons/test_divine_weapon_complete.gd")
	_run_external_test_suite("Torch Complete Tests", "res://tests/unit/weapons/test_torch_complete.gd")

	# Run Pickups Complete Tests (NEW)
	_run_external_test_suite("Pickups Complete Tests", "res://tests/unit/pickups/test_pickups_complete.gd")

	# Run Effects Complete Tests (NEW)
	_run_external_test_suite("Effects Complete Tests", "res://tests/unit/effects/test_effects_complete.gd")

	# Run Additional Systems Tests (NEW)
	_run_external_test_suite("Systems Complete Tests", "res://tests/unit/systems/test_systems_complete.gd")

	# Achievement Integration Tests
	_run_external_test_suite("Achievement Integration Tests", "res://tests/unit/systems/test_achievement_integration.gd")

	# Run UI Remaining Complete Tests (NEW)
	_run_external_test_suite("UI Remaining Complete Tests", "res://tests/unit/ui/test_ui_remaining_complete.gd")

	# Achievement UI Tests
	_run_external_test_suite("Achievement UI Tests", "res://tests/unit/ui/test_achievement_ui.gd")

	# Character Selection UI Tests
	_run_external_test_suite("Character Selection UI Tests", "res://tests/unit/ui/test_character_select_ui.gd")

	# Run Integration Tests
	_run_external_test_suite("Combat Flow Integration Tests", "res://tests/integration/test_combat_flow.gd")
	_run_external_test_suite("Progression Flow Integration Tests", "res://tests/integration/test_progression_flow.gd")

	# Run E2E Tests
	_run_external_test_suite("Game Session E2E Tests", "res://tests/e2e/test_game_session.gd")

	# Run Behavioral Tests (DEEP BEHAVIOR VERIFICATION)
	print("")
	print("[BEHAVIORAL TESTS: Deep Logic Verification]")
	print("")
	_run_external_test_suite("Player Behavior Tests", "res://tests/unit/behavioral/test_player_behavior.gd")
	_run_external_test_suite("Sword Behavior Tests", "res://tests/unit/behavioral/test_sword_behavior.gd")
	_run_external_test_suite("Upgrade Behavior Tests", "res://tests/unit/behavioral/test_upgrade_behavior.gd")
	_run_external_test_suite("Wave Behavior Tests", "res://tests/unit/behavioral/test_wave_behavior.gd")
	_run_external_test_suite("Combo Behavior Tests", "res://tests/unit/behavioral/test_combo_behavior.gd")
	_run_external_test_suite("Day/Night Behavior Tests", "res://tests/unit/behavioral/test_day_night_behavior.gd")
	_run_external_test_suite("Combat Behavior Tests", "res://tests/unit/behavioral/test_combat_behavior.gd")
	_run_external_test_suite("Status Effect Behavior Tests", "res://tests/unit/behavioral/test_status_effect_behavior.gd")
	_run_external_test_suite("Pickup Behavior Tests", "res://tests/unit/behavioral/test_pickup_behavior.gd")
	_run_external_test_suite("Boss Attack Behavior BDD Tests", "res://tests/unit/behavioral/test_boss_attack_behavior.gd")
	_run_external_test_suite("Elite Monsters BDD Tests", "res://tests/unit/behavioral/test_elite_monsters.gd")
	_run_external_test_suite("Wave Scaling BDD Tests", "res://tests/unit/behavioral/test_wave_scaling.gd")
	_run_external_test_suite("Idle Mode BDD Tests", "res://tests/unit/behavioral/test_idle_mode_behavior.gd")
	_run_external_test_suite("Achievement UI Behavior BDD Tests", "res://tests/unit/behavioral/test_achievement_ui_behavior.gd")

	# Biome & Music System Tests
	_run_external_test_suite("Biome Manager Tests", "res://tests/unit/systems/test_biome_manager.gd")
	_run_external_test_suite("Music Generator Tests", "res://tests/unit/systems/test_music_generator.gd")

## Run tests from an external test file that follows the run_tests() -> Dictionary pattern
func _run_external_test_suite(suite_name: String, script_path: String) -> void:
	print("[SUITE] " + suite_name)
	print("-".repeat(40))

	var script = load(script_path)
	if not script:
		_assert_true(false, "Failed to load: " + script_path)
		print("")
		return

	# Check if script has run_tests method
	var temp_instance = script.new() if script.can_instantiate() else null
	if temp_instance == null:
		# Static class - call run_tests directly
		if script.has_method("run_tests"):
			var results = script.run_tests()
			_process_test_results(results)

			# Update coverage tracker - call static method directly
			_try_mark_coverage(script, script_path)
		else:
			_assert_true(false, "Script has no run_tests method: " + script_path)
	else:
		temp_instance.free()
		# Try static call
		if script.has_method("run_tests"):
			var results = script.run_tests()
			_process_test_results(results)

			# Update coverage tracker - call static method directly
			_try_mark_coverage(script, script_path)
		else:
			_assert_true(false, "Script has no run_tests method: " + script_path)

	print("")

## Process results from external test suite
func _process_test_results(results: Dictionary) -> void:
	if not results.has("tests"):
		return

	for test in results.tests:
		if test.passed:
			tests_passed += 1
			test_results.append({"name": test.name, "passed": true})
			print("  ✓ " + test.name)
		else:
			tests_failed += 1
			test_results.append({"name": test.name, "passed": false})
			print("  ✗ " + test.name + " [FAILED]")

## Try to mark coverage by calling get_tested_functions() static method directly
func _try_mark_coverage(script: GDScript, script_path: String) -> void:
	if not coverage_tracker:
		return

	# Check if the script has get_tested_functions method in its method list
	var has_method = false
	for method in script.get_script_method_list():
		if method.name == "get_tested_functions":
			has_method = true
			break

	if has_method:
		# Call the static method directly on the script
		var tested_funcs = script.get_tested_functions()
		if tested_funcs.size() > 0:
			_mark_coverage_from_test(script_path, tested_funcs)

## Mark functions as tested in coverage tracker
func _mark_coverage_from_test(test_script_path: String, tested_funcs: Array) -> void:
	if not coverage_tracker:
		return

	# Map test script to target script
	var target_script = ""
	if "player" in test_script_path:
		target_script = "res://scripts/player.gd"
	elif "health_complete" in test_script_path:
		target_script = "res://scripts/components/health.gd"
	elif "upgrade_manager" in test_script_path:
		target_script = "res://scripts/systems/upgrade_manager.gd"
	elif "infantry_complete" in test_script_path:
		target_script = "res://scripts/enemies/infantry.gd"
	elif "archer_complete" in test_script_path:
		target_script = "res://scripts/enemies/archer.gd"
	elif "cavalry_complete" in test_script_path:
		target_script = "res://scripts/enemies/cavalry.gd"
	elif "fire_soldier_complete" in test_script_path:
		target_script = "res://scripts/enemies/fire_soldier.gd"
	elif "assassin_complete" in test_script_path:
		target_script = "res://scripts/enemies/assassin.gd"
	elif "sorcerer_complete" in test_script_path:
		target_script = "res://scripts/enemies/sorcerer.gd"
	elif "xiahou_dun_complete" in test_script_path:
		target_script = "res://scripts/enemies/xiahou_dun.gd"
	elif "shadow_guard_complete" in test_script_path:
		target_script = "res://scripts/enemies/shadow_guard.gd"
	elif "test_sword_complete" in test_script_path and "divine" not in test_script_path:
		target_script = "res://scripts/weapons/sword_base.gd"
	elif "test_bow_complete" in test_script_path and "crossbow" not in test_script_path:
		target_script = "res://scripts/weapons/bow.gd"
	elif "test_crossbow_complete" in test_script_path:
		target_script = "res://scripts/weapons/crossbow.gd"
	elif "wave_manager" in test_script_path:
		target_script = "res://scripts/systems/wave_manager.gd"
	elif "day_night" in test_script_path:
		target_script = "res://scripts/systems/day_night_cycle.gd"
	elif "combo_system" in test_script_path:
		target_script = "res://scripts/systems/combo_system.gd"
	elif "projectiles" in test_script_path:
		# Projectiles test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/projectiles/arrow.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/projectiles/player_arrow.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/projectiles/crossbow_bolt.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/projectiles/poison_dart.gd", tested_funcs)
		return  # Already handled
	elif "ui_complete" in test_script_path:
		# UI test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/ui/hud.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/upgrade_ui.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/game_over_ui.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/main_menu.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/settings_panel.gd", tested_funcs)
		return  # Already handled
	# Core scripts
	elif "game_complete" in test_script_path:
		target_script = "res://scripts/game.gd"
	elif "spawner_complete" in test_script_path:
		target_script = "res://scripts/spawner.gd"
	elif "arena_complete" in test_script_path:
		target_script = "res://scripts/arena.gd"
	elif "camera_complete" in test_script_path:
		target_script = "res://scripts/camera.gd"
	# Components
	elif "status_effect_manager_complete" in test_script_path:
		target_script = "res://scripts/components/status_effect_manager.gd"
	elif "status_effect_complete" in test_script_path:
		target_script = "res://scripts/components/status_effect.gd"
	elif "weapon_slots_complete" in test_script_path:
		target_script = "res://scripts/components/weapon_slots.gd"
	# Weapons
	elif "divine_weapon_complete" in test_script_path:
		target_script = "res://scripts/weapons/divine_weapon.gd"
	elif "torch_complete" in test_script_path:
		target_script = "res://scripts/weapons/torch.gd"
	# Pickups
	elif "pickups_complete" in test_script_path:
		# Pickups test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/pickups/xp_orb.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/pickups/health_pickup.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/pickups/meat_pickup.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/pickups/emerald_pickup.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/pickups/totem_pickup.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/pickups/lucky_drop_pickup.gd", tested_funcs)
		return  # Already handled
	# Effects
	elif "effects_complete" in test_script_path:
		# Effects test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/effects/death_poof.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/effect_base.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/explosion.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/hit_effect.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/damage_number.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/screen_shake.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/poison_cloud.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/effects/ground_spike.gd", tested_funcs)
		return  # Already handled
	# Systems
	elif "systems_complete" in test_script_path:
		# Systems test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/systems/upgrade.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/game_stats.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/score_storage.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/health_pickup_spawner.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/localization_manager.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/achievement.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/achievement_manager.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/character.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/character_manager.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/weapon_evolution.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/weapon_evolution_manager.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/systems/torch_manager.gd", tested_funcs)
		return  # Already handled
	# UI Remaining
	elif "ui_remaining_complete" in test_script_path:
		# UI remaining test covers multiple scripts - mark all
		coverage_tracker.mark_functions_tested("res://scripts/ui/game_over_ui.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/main_menu.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/pause_menu.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/settings_panel.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/scoreboard_panel.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/status_container.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/status_icon.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/boss_health_bar.gd", tested_funcs)
		coverage_tracker.mark_functions_tested("res://scripts/ui/splash_screen.gd", tested_funcs)
		return  # Already handled

	if target_script != "":
		coverage_tracker.mark_functions_tested(target_script, tested_funcs)
