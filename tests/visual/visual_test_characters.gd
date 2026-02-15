extends Node
## Visual Test Script for Character System
## Tests character loading and stats

var _screenshot_count: int = 0
var _character_manager: Node = null
var _player: Node = null

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Character System")
	print("=".repeat(50))

	await get_tree().process_frame

	# Find character manager
	_character_manager = get_tree().current_scene.get_node_or_null("CharacterManager")
	_player = get_tree().current_scene.get_node_or_null("Player")

	if not _character_manager:
		print("ERROR: CharacterManager not found!")
		await get_tree().create_timer(2.0).timeout
		get_tree().quit(1)
		return

	print("CharacterManager found: %s" % _character_manager)
	print("Player found: %s" % _player)

	# Report character definitions
	_report_characters()

	# Test character stats
	await get_tree().create_timer(1.0).timeout
	_test_character_stats()

	# Test unlock conditions
	await get_tree().create_timer(1.0).timeout
	_test_unlock_conditions()

	_take_screenshot("character_test")

	_finish_tests()

func _report_characters() -> void:
	print("\n[CHARACTER DEFINITIONS]")
	var all_characters = _character_manager.get_all_characters()
	print("  Total characters: %d" % all_characters.size())

	for char in all_characters:
		print("\n  [%s] %s" % [char.id.to_upper(), char.name])
		print("    Description: %s" % char.description)
		print("    Unlocked: %s" % ("YES" if char.is_unlocked else "NO"))
		print("    Stats:")
		print("      - HP: %.0f%%" % (char.health_mult * 100))
		print("      - Speed: %.0f%%" % (char.speed_mult * 100))
		print("      - Damage: %.0f%%" % (char.damage_mult * 100))
		print("      - XP: %.0f%%" % (char.xp_mult * 100))
		print("      - Pickup Range: %.0f%%" % (char.pickup_range_mult * 100))
		if not char.is_unlocked:
			print("    Unlock: %s" % char.unlock_requirement)

func _test_character_stats() -> void:
	print("\n[TESTING CHARACTER STATS]")

	var guan_yu = _character_manager.get_character("guan_yu")
	var zhao_yun = _character_manager.get_character("zhao_yun")

	if guan_yu:
		print("\n  Guan Yu (Default):")
		print("    HP mult: %.2f (expected: 1.0)" % guan_yu.health_mult)
		print("    Speed mult: %.2f (expected: 1.0)" % guan_yu.speed_mult)
		print("    PASS: %s" % ("YES" if guan_yu.health_mult == 1.0 and guan_yu.speed_mult == 1.0 else "NO"))

	if zhao_yun:
		print("\n  Zhao Yun (Unlockable):")
		print("    HP mult: %.2f (expected: 0.9)" % zhao_yun.health_mult)
		print("    Speed mult: %.2f (expected: 1.2)" % zhao_yun.speed_mult)
		print("    Pickup mult: %.2f (expected: 1.5)" % zhao_yun.pickup_range_mult)
		print("    PASS: %s" % ("YES" if zhao_yun.health_mult == 0.9 and zhao_yun.speed_mult == 1.2 else "NO"))

func _test_unlock_conditions() -> void:
	print("\n[TESTING UNLOCK CONDITIONS]")

	var zhao_yun = _character_manager.get_character("zhao_yun")
	if zhao_yun:
		print("  Zhao Yun unlock type: %s" % zhao_yun.unlock_condition_type)
		print("  Zhao Yun unlock value: %d" % zhao_yun.unlock_condition_value)
		print("  Expected: survival_time >= 900 (15 minutes)")

		# Test unlock
		var was_locked = not zhao_yun.is_unlocked
		print("\n  Testing unlock trigger...")
		_character_manager.check_unlock_conditions({"survival_time": 900})

		if was_locked and zhao_yun.is_unlocked:
			print("  >>> ZHAO YUN UNLOCKED SUCCESSFULLY <<<")
		elif zhao_yun.is_unlocked:
			print("  Zhao Yun was already unlocked")
		else:
			print("  ERROR: Zhao Yun should be unlocked but isn't")

func _take_screenshot(name: String) -> void:
	_screenshot_count += 1
	var filename = "user://visual_test_character_%02d_%s.png" % [_screenshot_count, name]

	var image = get_viewport().get_texture().get_image()
	if image:
		var error = image.save_png(filename)
		if error == OK:
			print("\n  Screenshot saved: %s" % filename)

func _finish_tests() -> void:
	print("\n" + "=".repeat(50))
	print("  CHARACTER TEST COMPLETE")
	print("=".repeat(50))

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
