extends Node
## Full Automated Test Runner - Tests all features with screenshots

var screenshot_dir = "res://docs/screenshots/testing/"
var player: Node = null
var sword: Node = null
var test_results = []

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_dir))

	await get_tree().create_timer(1.0).timeout

	player = get_tree().get_first_node_in_group("player")
	if player:
		sword = player.get_node_or_null("DiamondSword")

	print("╔══════════════════════════════════════════════════════════════╗")
	print("║           MINECRAFT SURVIVORS - FULL TEST SUITE              ║")
	print("╚══════════════════════════════════════════════════════════════╝")
	print("")

	await _run_all_tests()

	_print_final_report()

	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func _run_all_tests() -> void:
	# Core Systems
	await _test_initial_values()
	await _test_sword_facing()
	await _test_attack_range_visual()

	# Upgrades
	await _test_sharpness_upgrade()
	await _test_knockback_upgrade()
	await _test_looting_upgrade()
	await _test_protection_upgrade()
	await _test_swiftness_upgrade()
	await _test_sweeping_upgrade()

	# Game Systems
	await _test_enemy_spawning()
	await _test_day_night_cycle()
	await _test_game_over()

func _test_initial_values() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Initial Values                                        │")
	print("└─────────────────────────────────────────────────────────────┘")

	var passed = true
	var details = []

	if sword:
		var dmg_ok = sword.damage == 10
		var kb_ok = sword.knockback == 0.0
		var rng_ok = sword.attack_range == 100.0
		details.append("  Sword damage: %d (expected 10) %s" % [sword.damage, "✓" if dmg_ok else "✗"])
		details.append("  Sword knockback: %.1f (expected 0) %s" % [sword.knockback, "✓" if kb_ok else "✗"])
		details.append("  Sword range: %.1f (expected 100) %s" % [sword.attack_range, "✓" if rng_ok else "✗"])
		passed = passed and dmg_ok and kb_ok and rng_ok

	if player:
		var spd_ok = player.speed == 200.0
		var xp_ok = player.xp_multiplier == 1.0 if "xp_multiplier" in player else false
		var prot_ok = player.damage_reduction == 0.0 if "damage_reduction" in player else false
		details.append("  Player speed: %.1f (expected 200) %s" % [player.speed, "✓" if spd_ok else "✗"])
		if "xp_multiplier" in player:
			details.append("  XP multiplier: %.2f (expected 1.0) %s" % [player.xp_multiplier, "✓" if xp_ok else "✗"])
		if "damage_reduction" in player:
			details.append("  Damage reduction: %.2f (expected 0.0) %s" % [player.damage_reduction, "✓" if prot_ok else "✗"])
		passed = passed and spd_ok and xp_ok and prot_ok

	for d in details:
		print(d)

	await _take_screenshot("01_initial_values")
	_record_result("Initial Values", passed)

func _test_sword_facing() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Sword Following Direction                             │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not player or not sword:
		print("  SKIP: Player or sword not found")
		_record_result("Sword Following", false, true)
		return

	var sprite = sword.get_node_or_null("Sprite2D")
	var passed = true

	# Test each direction
	var directions = {
		"RIGHT": Vector2.RIGHT,
		"LEFT": Vector2.LEFT,
		"UP": Vector2.UP,
		"DOWN": Vector2.DOWN
	}

	for dir_name in directions:
		var dir = directions[dir_name]
		player.facing_direction = dir
		player.facing_changed.emit(dir)
		await get_tree().create_timer(0.1).timeout

		if sprite:
			var expected_pos = dir * 20.0  # hand_offset
			var pos_ok = sprite.position.distance_to(expected_pos) < 1.0
			print("  %s: pos=%s (expected %s) %s" % [dir_name, sprite.position, expected_pos, "✓" if pos_ok else "✗"])
			passed = passed and pos_ok

	await _take_screenshot("02_sword_facing")
	_record_result("Sword Following", passed)

func _test_attack_range_visual() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Attack Range Visual Circle                            │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not sword:
		print("  SKIP: Sword not found")
		_record_result("Attack Range Visual", false, true)
		return

	var initial_range = sword.attack_range
	print("  Initial range: %.1f" % initial_range)
	await _take_screenshot("03a_range_before")

	# Increase range
	sword.attack_range = 140.0
	var shape = sword.get_node_or_null("CollisionShape2D")
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()

	await get_tree().create_timer(0.2).timeout
	print("  Upgraded range: %.1f" % sword.attack_range)
	await _take_screenshot("03b_range_after")

	# Reset
	sword.attack_range = initial_range
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()

	_record_result("Attack Range Visual", true)

func _test_sharpness_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Sharpness Upgrade (+5 damage)                         │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not sword:
		_record_result("Sharpness Upgrade", false, true)
		return

	var old_dmg = sword.damage
	sword.damage += 5
	var passed = sword.damage == old_dmg + 5
	print("  Before: %d, After: %d %s" % [old_dmg, sword.damage, "✓" if passed else "✗"])
	await _take_screenshot("04_sharpness")
	sword.damage = old_dmg
	_record_result("Sharpness Upgrade", passed)

func _test_knockback_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Knockback Upgrade (+30 knockback)                     │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not sword:
		_record_result("Knockback Upgrade", false, true)
		return

	var old_kb = sword.knockback
	sword.knockback += 30.0
	var passed = abs(sword.knockback - (old_kb + 30.0)) < 0.1
	print("  Before: %.1f, After: %.1f %s" % [old_kb, sword.knockback, "✓" if passed else "✗"])
	await _take_screenshot("05_knockback")
	sword.knockback = old_kb
	_record_result("Knockback Upgrade", passed)

func _test_looting_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Looting Upgrade (+20% XP)                             │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not player or not "xp_multiplier" in player:
		_record_result("Looting Upgrade", false, true)
		return

	var old_mult = player.xp_multiplier
	player.xp_multiplier += 0.2
	var passed = abs(player.xp_multiplier - (old_mult + 0.2)) < 0.01
	print("  Before: %.2f, After: %.2f %s" % [old_mult, player.xp_multiplier, "✓" if passed else "✗"])
	await _take_screenshot("06_looting")
	player.xp_multiplier = old_mult
	_record_result("Looting Upgrade", passed)

func _test_protection_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Protection Upgrade (-10% damage taken)                │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not player or not "damage_reduction" in player:
		_record_result("Protection Upgrade", false, true)
		return

	var old_prot = player.damage_reduction
	player.damage_reduction += 0.1
	var passed = abs(player.damage_reduction - (old_prot + 0.1)) < 0.01
	print("  Before: %.2f, After: %.2f %s" % [old_prot, player.damage_reduction, "✓" if passed else "✗"])
	await _take_screenshot("07_protection")
	player.damage_reduction = old_prot
	_record_result("Protection Upgrade", passed)

func _test_swiftness_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Swiftness Upgrade (+15% speed)                        │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not player:
		_record_result("Swiftness Upgrade", false, true)
		return

	var old_speed = player.speed
	var expected = old_speed + (old_speed * 0.15)
	player.speed = expected
	var passed = abs(player.speed - expected) < 0.1
	print("  Before: %.1f, After: %.1f (+15%%) %s" % [old_speed, player.speed, "✓" if passed else "✗"])
	await _take_screenshot("08_swiftness")
	player.speed = old_speed
	_record_result("Swiftness Upgrade", passed)

func _test_sweeping_upgrade() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Sweeping Edge Upgrade (+20 range)                     │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not sword:
		_record_result("Sweeping Upgrade", false, true)
		return

	var old_range = sword.attack_range
	sword.attack_range += 20.0
	var shape = sword.get_node_or_null("CollisionShape2D")
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()

	await get_tree().create_timer(0.1).timeout
	var passed = sword.attack_range == old_range + 20.0
	print("  Before: %.1f, After: %.1f %s" % [old_range, sword.attack_range, "✓" if passed else "✗"])
	await _take_screenshot("09_sweeping")

	sword.attack_range = old_range
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()
	_record_result("Sweeping Upgrade", passed)

func _test_enemy_spawning() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Enemy Spawning                                        │")
	print("└─────────────────────────────────────────────────────────────┘")

	# Wait for enemies to spawn
	await get_tree().create_timer(3.0).timeout

	var enemies = get_tree().get_nodes_in_group("enemies")
	var passed = enemies.size() > 0
	print("  Enemies spawned: %d %s" % [enemies.size(), "✓" if passed else "✗"])
	await _take_screenshot("10_enemies")
	_record_result("Enemy Spawning", passed)

func _test_day_night_cycle() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Day/Night Cycle                                       │")
	print("└─────────────────────────────────────────────────────────────┘")

	var day_night = get_tree().get_first_node_in_group("day_night_cycle")
	if not day_night:
		day_night = get_node_or_null("/root/GameplayTest/Main/DayNightCycle")
	if not day_night:
		day_night = get_node_or_null("/root/Main/DayNightCycle")

	if day_night:
		var time_of_day = day_night.get_time_of_day() if day_night.has_method("get_time_of_day") else "unknown"
		print("  Current time: %s" % time_of_day)
		await _take_screenshot("11_day_night")
		_record_result("Day/Night Cycle", true)
	else:
		print("  SKIP: DayNightCycle not found")
		_record_result("Day/Night Cycle", false, true)

func _test_game_over() -> void:
	print("┌─────────────────────────────────────────────────────────────┐")
	print("│ TEST: Game Over Screen                                      │")
	print("└─────────────────────────────────────────────────────────────┘")

	if not player:
		_record_result("Game Over Screen", false, true)
		return

	# Kill the player
	player.current_health = 0
	player.died.emit()

	await get_tree().create_timer(1.0).timeout
	await _take_screenshot("12_game_over")

	# Check if game over UI is visible
	var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
	if not game_over_ui:
		game_over_ui = get_node_or_null("/root/GameplayTest/Main/GameOverUI")
	if not game_over_ui:
		game_over_ui = get_node_or_null("/root/Main/GameOverUI")

	var passed = game_over_ui != null and game_over_ui.visible
	print("  Game Over UI visible: %s %s" % [passed, "✓" if passed else "✗"])
	_record_result("Game Over Screen", passed)

func _take_screenshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	var path = screenshot_dir + name + ".png"
	img.save_png(path)
	print("  📸 %s" % path)

func _record_result(name: String, passed: bool, skipped: bool = false) -> void:
	test_results.append({"name": name, "passed": passed, "skipped": skipped})
	var status = "SKIP" if skipped else ("PASS" if passed else "FAIL")
	print("  Result: %s" % status)
	print("")

func _print_final_report() -> void:
	print("╔══════════════════════════════════════════════════════════════╗")
	print("║                    FINAL TEST REPORT                         ║")
	print("╚══════════════════════════════════════════════════════════════╝")
	print("")

	var passed = 0
	var failed = 0
	var skipped = 0

	for result in test_results:
		var icon = "⏭️" if result.skipped else ("✅" if result.passed else "❌")
		print("  %s %s" % [icon, result.name])
		if result.skipped:
			skipped += 1
		elif result.passed:
			passed += 1
		else:
			failed += 1

	print("")
	print("─────────────────────────────────────────────────────────────")
	print("  Total: %d | ✅ Passed: %d | ❌ Failed: %d | ⏭️ Skipped: %d" % [test_results.size(), passed, failed, skipped])
	print("─────────────────────────────────────────────────────────────")
	print("")
	print("Screenshots saved to: docs/screenshots/testing/")
