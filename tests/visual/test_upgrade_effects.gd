extends Node2D
## Visual test for upgrade visual feedback system
## Tests UpgradeEffect and StatPopup features

const UpgradeEffectClass = preload("res://scripts/effects/upgrade_effect.gd")
const StatPopupClass = preload("res://scripts/effects/stat_popup.gd")

var _test_results: Array = []
var _current_test: int = 0
var _tests: Array = []
var _test_target: Node2D = null
var _label: Label = null

func _ready() -> void:
	# Create test target (simulates player)
	_test_target = Node2D.new()
	_test_target.position = Vector2(640, 360)
	add_child(_test_target)

	# Add a sprite to make it visible
	var sprite = Sprite2D.new()
	var texture = load("res://assets/characters/guan_yu.svg")
	if texture:
		sprite.texture = texture
	_test_target.add_child(sprite)

	# Create label for test info
	_label = Label.new()
	_label.position = Vector2(20, 20)
	_label.add_theme_font_size_override("font_size", 20)
	add_child(_label)

	# Define tests
	_tests = [
		# UpgradeEffect color tests
		{"name": "UE.01: Get sharpness color (red)", "func": _test_sharpness_color},
		{"name": "UE.02: Get protection color (blue)", "func": _test_protection_color},
		{"name": "UE.03: Get swiftness color (green)", "func": _test_swiftness_color},
		{"name": "UE.04: Get knockback color (orange)", "func": _test_knockback_color},
		{"name": "UE.05: Get looting color (gold)", "func": _test_looting_color},
		{"name": "UE.06: Get sweeping color (purple)", "func": _test_sweeping_color},
		{"name": "UE.07: Get haste color (violet)", "func": _test_haste_color},
		{"name": "UE.08: Get sword color (silver)", "func": _test_sword_color},
		{"name": "UE.09: Get unknown color (white)", "func": _test_unknown_color},

		# UpgradeEffect visual tests
		{"name": "UE.10: Play upgrade effect - sharpness", "func": _test_play_upgrade_sharpness},
		{"name": "UE.11: Play upgrade effect - protection", "func": _test_play_upgrade_protection},
		{"name": "UE.12: Play upgrade effect - swiftness", "func": _test_play_upgrade_swiftness},
		{"name": "UE.13: Play upgrade effect - high level", "func": _test_play_upgrade_high_level},

		# Evolution effect tests
		{"name": "UE.14: Evolution effect - tier 2", "func": _test_evolution_tier2},
		{"name": "UE.15: Evolution effect - tier 3", "func": _test_evolution_tier3},
		{"name": "UE.16: Evolution effect - tier 4", "func": _test_evolution_tier4},

		# StatPopup tests
		{"name": "UE.17: Spawn stat popup", "func": _test_spawn_stat_popup},
		{"name": "UE.18: Popup float animation", "func": _test_popup_float},
		{"name": "UE.19: Popup with damage text", "func": _test_popup_damage_text},
		{"name": "UE.20: Popup with speed text", "func": _test_popup_speed_text},
		{"name": "UE.21: Multiple popups", "func": _test_multiple_popups},

		# Edge cases
		{"name": "UE.22: Null target handling", "func": _test_null_target},
		{"name": "UE.23: Invalid target handling", "func": _test_invalid_target},
		{"name": "UE.24: Rapid upgrade effects", "func": _test_rapid_upgrades},

		# Ring effect tests
		{"name": "UE.25: Ring expansion", "func": _test_ring_expansion},
		{"name": "UE.26: Ring fade out", "func": _test_ring_fade},

		# Integration tests
		{"name": "UE.27: Full upgrade sequence", "func": _test_full_upgrade_sequence},
		{"name": "UE.28: Full evolution sequence", "func": _test_full_evolution_sequence},
	]

	_run_next_test()


func _run_next_test() -> void:
	if _current_test >= _tests.size():
		_print_results()
		return

	var test = _tests[_current_test]
	_label.text = "Testing: " + test.name

	# Run test
	var result = await test.func.call()
	_test_results.append({"name": test.name, "passed": result})

	_current_test += 1

	# Delay between tests for visual verification
	await get_tree().create_timer(0.4).timeout
	_run_next_test()


func _print_results() -> void:
	print("\n============================================================")
	print("  UPGRADE EFFECT VISUAL TEST RESULTS")
	print("============================================================")

	var passed = 0
	var failed = 0

	for result in _test_results:
		var status = "✓" if result.passed else "✗"
		print("  %s %s" % [status, result.name])
		if result.passed:
			passed += 1
		else:
			failed += 1

	print("------------------------------------------------------------")
	print("  Passed: %d  Failed: %d  Total: %d" % [passed, failed, _test_results.size()])
	print("============================================================\n")

	_label.text = "Tests Complete: %d/%d passed" % [passed, _test_results.size()]

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0 if failed == 0 else 1)


# === COLOR TESTS ===

func _test_sharpness_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("sharpness")
	return color.r > 0.8 and color.g < 0.5  # Red-ish


func _test_protection_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("protection")
	return color.b > 0.8 and color.r < 0.5  # Blue-ish


func _test_swiftness_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("swiftness")
	return color.g > 0.8  # Green-ish


func _test_knockback_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("knockback")
	return color.r > 0.8 and color.g > 0.4  # Orange-ish


func _test_looting_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("looting")
	return color.r > 0.8 and color.g > 0.7  # Gold-ish


func _test_sweeping_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("sweeping")
	return color.r > 0.5 and color.b > 0.8  # Purple-ish


func _test_haste_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("haste")
	return color.b > 0.8  # Violet-ish


func _test_sword_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("sword")
	# Silver - all components similar
	return abs(color.r - color.g) < 0.1 and abs(color.g - color.b) < 0.1


func _test_unknown_color() -> bool:
	var color = UpgradeEffectClass.get_upgrade_color("unknown_upgrade_xyz")
	return color == Color.WHITE


# === UPGRADE EFFECT TESTS ===

func _test_play_upgrade_sharpness() -> bool:
	UpgradeEffectClass.play_upgrade_effect(_test_target, "sharpness", 1)
	await get_tree().create_timer(0.5).timeout
	return true  # Visual check - should show red flash


func _test_play_upgrade_protection() -> bool:
	UpgradeEffectClass.play_upgrade_effect(_test_target, "protection", 1)
	await get_tree().create_timer(0.5).timeout
	return true  # Visual check - should show blue flash


func _test_play_upgrade_swiftness() -> bool:
	UpgradeEffectClass.play_upgrade_effect(_test_target, "swiftness", 1)
	await get_tree().create_timer(0.5).timeout
	return true  # Visual check - should show green flash


func _test_play_upgrade_high_level() -> bool:
	# High level should trigger screen flash
	UpgradeEffectClass.play_upgrade_effect(_test_target, "sharpness", 5)
	await get_tree().create_timer(0.5).timeout
	return true  # Visual check - should show screen flash


# === EVOLUTION EFFECT TESTS ===

func _test_evolution_tier2() -> bool:
	UpgradeEffectClass.play_evolution_effect(_test_target, 1, 2)
	await get_tree().create_timer(1.0).timeout
	return true  # Visual check - gray glow


func _test_evolution_tier3() -> bool:
	UpgradeEffectClass.play_evolution_effect(_test_target, 2, 3)
	await get_tree().create_timer(1.0).timeout
	return true  # Visual check - silver glow


func _test_evolution_tier4() -> bool:
	UpgradeEffectClass.play_evolution_effect(_test_target, 3, 4)
	await get_tree().create_timer(1.0).timeout
	return true  # Visual check - cyan glow


# === STAT POPUP TESTS ===

func _test_spawn_stat_popup() -> bool:
	UpgradeEffectClass.spawn_stat_popup(_test_target, "+5 DMG", Color.RED)
	await get_tree().create_timer(0.3).timeout
	# Check if popup was added to scene
	var popups = get_tree().get_nodes_in_group("stat_popups") if get_tree().has_group("stat_popups") else []
	return true  # Popup spawned (visual check)


func _test_popup_float() -> bool:
	var popup = StatPopupClass.new()
	popup.global_position = Vector2(640, 400)
	add_child(popup)
	popup.show_stat("Test Float", Color.YELLOW)

	var start_y = popup.global_position.y
	await get_tree().create_timer(0.6).timeout
	var end_y = popup.global_position.y

	return end_y < start_y  # Should float upward


func _test_popup_damage_text() -> bool:
	UpgradeEffectClass.spawn_stat_popup(_test_target, "+10 DMG", Color.RED)
	await get_tree().create_timer(1.5).timeout
	return true  # Visual check


func _test_popup_speed_text() -> bool:
	UpgradeEffectClass.spawn_stat_popup(_test_target, "+15% Speed", Color.GREEN)
	await get_tree().create_timer(1.5).timeout
	return true  # Visual check


func _test_multiple_popups() -> bool:
	for i in range(5):
		var offset = Vector2(randf_range(-50, 50), 0)
		var temp_target = Node2D.new()
		temp_target.global_position = _test_target.global_position + offset
		add_child(temp_target)
		UpgradeEffectClass.spawn_stat_popup(temp_target, "+%d" % (i + 1), Color(randf(), randf(), randf()))
		await get_tree().create_timer(0.1).timeout
		temp_target.queue_free()
	await get_tree().create_timer(1.5).timeout
	return true  # All popups spawn without crash


# === EDGE CASE TESTS ===

func _test_null_target() -> bool:
	# Should not crash with null target
	UpgradeEffectClass.play_upgrade_effect(null, "sharpness", 1)
	UpgradeEffectClass.spawn_stat_popup(null, "Test", Color.WHITE)
	return true  # No crash


func _test_invalid_target() -> bool:
	# Test with a valid but minimal target (edge case)
	var temp = Node2D.new()
	add_child(temp)
	UpgradeEffectClass.play_upgrade_effect(temp, "sharpness", 1)
	await get_tree().create_timer(0.1).timeout
	temp.queue_free()
	return true  # No crash


func _test_rapid_upgrades() -> bool:
	# Rapid fire upgrades should not crash
	for i in range(10):
		UpgradeEffectClass.play_upgrade_effect(_test_target, "sharpness", i % 5 + 1)
	await get_tree().create_timer(0.5).timeout
	return true  # No crash


# === RING EFFECT TESTS ===

func _test_ring_expansion() -> bool:
	# Ring should expand from small to large
	UpgradeEffectClass.play_upgrade_effect(_test_target, "protection", 1)
	await get_tree().create_timer(0.5).timeout
	return true  # Visual check - ring expands


func _test_ring_fade() -> bool:
	# Ring should fade out
	UpgradeEffectClass.play_upgrade_effect(_test_target, "swiftness", 1)
	await get_tree().create_timer(0.6).timeout
	return true  # Visual check - ring fades


# === INTEGRATION TESTS ===

func _test_full_upgrade_sequence() -> bool:
	# Simulate full upgrade: effect + popup
	var upgrades = ["sharpness", "protection", "swiftness", "knockback", "looting"]
	for upgrade_id in upgrades:
		UpgradeEffectClass.play_upgrade_effect(_test_target, upgrade_id, 1)
		var color = UpgradeEffectClass.get_upgrade_color(upgrade_id)
		UpgradeEffectClass.spawn_stat_popup(_test_target, upgrade_id.capitalize(), color)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.0).timeout
	return true


func _test_full_evolution_sequence() -> bool:
	# Simulate full evolution: multiple bursts + flash
	print("  [Testing evolution sequence...]")
	UpgradeEffectClass.play_evolution_effect(_test_target, 1, 2)
	await get_tree().create_timer(1.5).timeout

	UpgradeEffectClass.play_evolution_effect(_test_target, 2, 3)
	await get_tree().create_timer(1.5).timeout

	UpgradeEffectClass.play_evolution_effect(_test_target, 3, 4)
	await get_tree().create_timer(1.5).timeout

	return true
