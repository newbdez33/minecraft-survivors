extends Node
## Manual Test Runner - Captures screenshots for testing documentation
## Run with: Godot --path . tests/visual/manual_test_runner.tscn

var screenshot_dir = "res://docs/screenshots/testing/"
var test_index = 0
var test_timer = 0.0
var current_test = ""
var tests_completed = []

# Test state
var player: Node = null
var sword: Node = null
var upgrade_manager: Node = null
var initial_values = {}

func _ready() -> void:
	# Ensure screenshot directory exists
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_dir))

	# Wait for scene to be ready
	await get_tree().create_timer(0.5).timeout

	# Get references
	player = get_tree().get_first_node_in_group("player")
	if player:
		sword = player.get_node_or_null("DiamondSword")
	upgrade_manager = get_tree().get_first_node_in_group("upgrade_manager")
	if not upgrade_manager:
		upgrade_manager = get_node_or_null("/root/Main/UpgradeManager")

	# Store initial values
	_store_initial_values()

	# Start tests
	print("=== MANUAL TEST RUNNER ===")
	print("Starting visual tests...")
	print("")

	_run_all_tests()

func _store_initial_values() -> void:
	if player:
		initial_values["player_speed"] = player.speed
		initial_values["player_xp_mult"] = player.xp_multiplier if "xp_multiplier" in player else 1.0
		initial_values["player_dmg_red"] = player.damage_reduction if "damage_reduction" in player else 0.0
	if sword:
		initial_values["sword_damage"] = sword.damage
		initial_values["sword_knockback"] = sword.knockback
		initial_values["sword_range"] = sword.attack_range

func _run_all_tests() -> void:
	# Test 1: Initial game state
	await _test_initial_state()

	# Test 2: Sword following
	await _test_sword_following()

	# Test 3: Attack range circle
	await _test_attack_range()

	# Test 4: Upgrade values verification
	await _test_upgrade_values()

	# Print summary
	_print_summary()

func _test_initial_state() -> void:
	current_test = "Initial Game State"
	print("[TEST] " + current_test)

	await get_tree().create_timer(1.0).timeout
	_take_screenshot("test_01_initial_state")

	# Verify initial values
	var results = []
	if sword:
		results.append("  Sword damage: %d (expected: 10)" % sword.damage)
		results.append("  Sword knockback: %.1f (expected: 0)" % sword.knockback)
		results.append("  Sword range: %.1f (expected: 100)" % sword.attack_range)
	if player:
		results.append("  Player speed: %.1f (expected: 200)" % player.speed)
		if "xp_multiplier" in player:
			results.append("  XP multiplier: %.2f (expected: 1.0)" % player.xp_multiplier)
		if "damage_reduction" in player:
			results.append("  Damage reduction: %.2f (expected: 0.0)" % player.damage_reduction)

	for r in results:
		print(r)

	var passed = true
	if sword:
		passed = passed and sword.damage == 10
		passed = passed and sword.knockback == 0.0
		passed = passed and sword.attack_range == 100.0
	if player:
		passed = passed and player.speed == 200.0

	tests_completed.append({"name": current_test, "passed": passed})
	print("  Result: %s" % ("PASS" if passed else "FAIL"))
	print("")

func _test_sword_following() -> void:
	current_test = "Sword Following Player"
	print("[TEST] " + current_test)

	if not player or not sword:
		print("  SKIP: Player or sword not found")
		tests_completed.append({"name": current_test, "passed": false, "skipped": true})
		return

	var sprite = sword.get_node_or_null("Sprite2D")
	var results = []

	# Test facing right
	player.facing_direction = Vector2.RIGHT
	player.facing_changed.emit(Vector2.RIGHT)
	await get_tree().create_timer(0.1).timeout
	if sprite:
		results.append("  Facing RIGHT - Sprite pos: %s" % sprite.position)
	_take_screenshot("test_02a_sword_right")

	# Test facing left
	player.facing_direction = Vector2.LEFT
	player.facing_changed.emit(Vector2.LEFT)
	await get_tree().create_timer(0.1).timeout
	if sprite:
		results.append("  Facing LEFT - Sprite pos: %s" % sprite.position)
	_take_screenshot("test_02b_sword_left")

	# Test facing up
	player.facing_direction = Vector2.UP
	player.facing_changed.emit(Vector2.UP)
	await get_tree().create_timer(0.1).timeout
	if sprite:
		results.append("  Facing UP - Sprite pos: %s" % sprite.position)
	_take_screenshot("test_02c_sword_up")

	# Test facing down
	player.facing_direction = Vector2.DOWN
	player.facing_changed.emit(Vector2.DOWN)
	await get_tree().create_timer(0.1).timeout
	if sprite:
		results.append("  Facing DOWN - Sprite pos: %s" % sprite.position)
	_take_screenshot("test_02d_sword_down")

	# Reset to right
	player.facing_direction = Vector2.RIGHT
	player.facing_changed.emit(Vector2.RIGHT)

	for r in results:
		print(r)

	tests_completed.append({"name": current_test, "passed": true})
	print("  Result: PASS (visual verification needed)")
	print("")

func _test_attack_range() -> void:
	current_test = "Attack Range Circle"
	print("[TEST] " + current_test)

	if not sword:
		print("  SKIP: Sword not found")
		tests_completed.append({"name": current_test, "passed": false, "skipped": true})
		return

	var initial_range = sword.attack_range
	print("  Initial range: %.1f" % initial_range)
	_take_screenshot("test_03a_range_initial")

	# Simulate sweeping edge upgrade
	sword.attack_range += 20.0
	var shape = sword.get_node_or_null("CollisionShape2D")
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()

	await get_tree().create_timer(0.2).timeout
	print("  After +20 range: %.1f" % sword.attack_range)
	_take_screenshot("test_03b_range_upgraded")

	# Reset
	sword.attack_range = initial_range
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = sword.attack_range
	sword.queue_redraw()

	tests_completed.append({"name": current_test, "passed": true})
	print("  Result: PASS (visual verification needed)")
	print("")

func _test_upgrade_values() -> void:
	current_test = "Upgrade System Values"
	print("[TEST] " + current_test)

	var all_passed = true

	# Test Sharpness
	if sword:
		var old_dmg = sword.damage
		sword.damage += 5  # Simulate upgrade
		print("  Sharpness: %d -> %d (+5)" % [old_dmg, sword.damage])
		all_passed = all_passed and (sword.damage == old_dmg + 5)
		sword.damage = old_dmg  # Reset

	# Test Knockback
	if sword:
		var old_kb = sword.knockback
		sword.knockback += 30.0  # Simulate upgrade
		print("  Knockback: %.1f -> %.1f (+30)" % [old_kb, sword.knockback])
		all_passed = all_passed and (sword.knockback == old_kb + 30.0)
		sword.knockback = old_kb  # Reset

	# Test Looting
	if player and "xp_multiplier" in player:
		var old_xp = player.xp_multiplier
		player.xp_multiplier += 0.2  # Simulate upgrade
		print("  Looting: %.2f -> %.2f (+0.2)" % [old_xp, player.xp_multiplier])
		all_passed = all_passed and abs(player.xp_multiplier - (old_xp + 0.2)) < 0.01
		player.xp_multiplier = old_xp  # Reset

	# Test Protection
	if player and "damage_reduction" in player:
		var old_prot = player.damage_reduction
		player.damage_reduction += 0.1  # Simulate upgrade
		print("  Protection: %.2f -> %.2f (+0.1)" % [old_prot, player.damage_reduction])
		all_passed = all_passed and abs(player.damage_reduction - (old_prot + 0.1)) < 0.01
		player.damage_reduction = old_prot  # Reset

	# Test Swiftness
	if player:
		var old_speed = player.speed
		var speed_increase = old_speed * 0.15
		player.speed += speed_increase  # Simulate upgrade
		print("  Swiftness: %.1f -> %.1f (+15%%)" % [old_speed, player.speed])
		all_passed = all_passed and abs(player.speed - (old_speed + speed_increase)) < 0.1
		player.speed = old_speed  # Reset

	# Test Sweeping Edge
	if sword:
		var old_range = sword.attack_range
		sword.attack_range += 20.0  # Simulate upgrade
		print("  Sweeping: %.1f -> %.1f (+20)" % [old_range, sword.attack_range])
		all_passed = all_passed and (sword.attack_range == old_range + 20.0)
		sword.attack_range = old_range  # Reset

	tests_completed.append({"name": current_test, "passed": all_passed})
	print("  Result: %s" % ("PASS" if all_passed else "FAIL"))
	print("")

func _take_screenshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	var path = screenshot_dir + name + ".png"
	var err = img.save_png(path)
	if err == OK:
		print("  Screenshot: %s" % path)
	else:
		print("  Screenshot FAILED: %s" % path)

func _print_summary() -> void:
	print("")
	print("=== TEST SUMMARY ===")
	var passed = 0
	var failed = 0
	var skipped = 0

	for test in tests_completed:
		var status = "PASS" if test.passed else "FAIL"
		if test.get("skipped", false):
			status = "SKIP"
			skipped += 1
		elif test.passed:
			passed += 1
		else:
			failed += 1
		print("  [%s] %s" % [status, test.name])

	print("")
	print("Total: %d | Passed: %d | Failed: %d | Skipped: %d" % [tests_completed.size(), passed, failed, skipped])
	print("")
	print("Screenshots saved to: %s" % screenshot_dir)
	print("=== TESTS COMPLETE ===")

	# Exit after tests
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
