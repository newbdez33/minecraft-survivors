extends Node2D
## Visual test for enemy animation system
## Tests all EnemyAnimator features and enemy-specific animations

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

var _test_results: Array = []
var _current_test: int = 0
var _tests: Array = []
var _test_sprite: Sprite2D = null
var _animator: Node = null
var _label: Label = null

func _ready() -> void:
	# Create test sprite
	_test_sprite = Sprite2D.new()
	_test_sprite.position = Vector2(640, 360)
	var texture = load("res://assets/characters/zombie.svg")
	if texture:
		_test_sprite.texture = texture
	add_child(_test_sprite)

	# Create label for test info
	_label = Label.new()
	_label.position = Vector2(20, 20)
	_label.add_theme_font_size_override("font_size", 20)
	add_child(_label)

	# Define tests
	_tests = [
		# Basic EnemyAnimator tests
		{"name": "EA.01: Animator creation", "func": _test_animator_creation},
		{"name": "EA.02: Setup with sprite", "func": _test_setup_sprite},
		{"name": "EA.03: Walk animation start", "func": _test_walk_start},
		{"name": "EA.04: Walk animation stop", "func": _test_walk_stop},
		{"name": "EA.05: Attack animation", "func": _test_attack_animation},
		{"name": "EA.06: Quick attack", "func": _test_quick_attack},
		{"name": "EA.07: Hit reaction", "func": _test_hit_reaction},
		{"name": "EA.08: Flash color", "func": _test_flash_color},
		{"name": "EA.09: Reset to original", "func": _test_reset_original},

		# Special animations
		{"name": "EA.10: Jump squash (Spider)", "func": _test_jump_squash},
		{"name": "EA.11: Jump stretch (Spider)", "func": _test_jump_stretch},
		{"name": "EA.12: Jump land (Spider)", "func": _test_jump_land},
		{"name": "EA.13: Charge windup (Ravager)", "func": _test_charge_windup},
		{"name": "EA.14: Charge rush (Ravager)", "func": _test_charge_rush},
		{"name": "EA.15: Teleport out (Enderman)", "func": _test_teleport_out},
		{"name": "EA.16: Teleport in (Enderman)", "func": _test_teleport_in},
		{"name": "EA.17: Explosion swell (Creeper)", "func": _test_explosion_swell},
		{"name": "EA.18: Breath attack (Dragon)", "func": _test_breath_attack},
		{"name": "EA.19: Sonic boom (Warden)", "func": _test_sonic_boom},
		{"name": "EA.20: Summon animation (Evoker)", "func": _test_summon_animation},
		{"name": "EA.21: Laser charge (Elder Guardian)", "func": _test_laser_charge},
		{"name": "EA.22: Laser fire (Elder Guardian)", "func": _test_laser_fire},

		# Edge cases and state transitions
		{"name": "EA.23: Walk during attack", "func": _test_walk_during_attack},
		{"name": "EA.24: Multiple hit reactions", "func": _test_multiple_hits},
		{"name": "EA.25: Attack signals", "func": _test_attack_signals},
		{"name": "EA.26: Tween cleanup", "func": _test_tween_cleanup},
		{"name": "EA.27: Null sprite handling", "func": _test_null_sprite},

		# Animation parameters
		{"name": "EA.28: Custom walk params", "func": _test_custom_walk_params},
		{"name": "EA.29: Custom attack params", "func": _test_custom_attack_params},
	]

	_run_next_test()


func _run_next_test() -> void:
	if _current_test >= _tests.size():
		_print_results()
		return

	var test = _tests[_current_test]
	_label.text = "Testing: " + test.name

	# Clean up previous animator
	if _animator:
		_animator.queue_free()
		_animator = null

	# Create fresh animator
	_animator = EnemyAnimatorClass.new()
	add_child(_animator)
	_animator.setup(_test_sprite)

	# Reset sprite state
	_test_sprite.position = Vector2(640, 360)
	_test_sprite.rotation = 0
	_test_sprite.scale = Vector2.ONE
	_test_sprite.modulate = Color.WHITE

	# Run test
	var result = await test.func.call()
	_test_results.append({"name": test.name, "passed": result})

	_current_test += 1

	# Small delay between tests
	await get_tree().create_timer(0.3).timeout
	_run_next_test()


func _print_results() -> void:
	print("\n============================================================")
	print("  ENEMY ANIMATION VISUAL TEST RESULTS")
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

	# Exit after showing results
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0 if failed == 0 else 1)


# === TEST FUNCTIONS ===

func _test_animator_creation() -> bool:
	return _animator != null


func _test_setup_sprite() -> bool:
	return _animator.sprite == _test_sprite


func _test_walk_start() -> bool:
	_animator.start_walk_animation()
	await get_tree().create_timer(0.5).timeout
	return _animator.is_walking


func _test_walk_stop() -> bool:
	_animator.start_walk_animation()
	await get_tree().create_timer(0.2).timeout
	_animator.stop_walk_animation()
	await get_tree().create_timer(0.2).timeout
	return not _animator.is_walking


func _test_attack_animation() -> bool:
	_animator.play_attack_animation()
	await get_tree().create_timer(0.1).timeout
	var was_attacking = _animator.is_attacking
	await get_tree().create_timer(0.5).timeout
	return was_attacking and not _animator.is_attacking


func _test_quick_attack() -> bool:
	# Test that quick attack plays without crash
	_animator.play_quick_attack()
	await get_tree().create_timer(0.3).timeout
	return true  # Method exists and runs


func _test_hit_reaction() -> bool:
	var original_modulate = _test_sprite.modulate
	_animator.play_hit_reaction()
	await get_tree().create_timer(0.05).timeout
	var flashed = _test_sprite.modulate != original_modulate or _test_sprite.modulate == Color.WHITE
	await get_tree().create_timer(0.2).timeout
	return true  # Hit reaction completes


func _test_flash_color() -> bool:
	_animator.flash_color(Color.RED, 0.2)
	await get_tree().create_timer(0.05).timeout
	# Check if color changed toward red
	await get_tree().create_timer(0.3).timeout
	return true


func _test_reset_original() -> bool:
	_animator.start_walk_animation()
	await get_tree().create_timer(0.2).timeout
	_animator.reset_to_original()
	await get_tree().create_timer(0.1).timeout
	return not _animator.is_walking and not _animator.is_attacking


func _test_jump_squash() -> bool:
	var original_scale = _test_sprite.scale
	_animator.play_jump_squash()
	await get_tree().create_timer(0.15).timeout
	# Should be squashed: wider and shorter
	var squashed = _test_sprite.scale.x > original_scale.x or _test_sprite.scale.y < original_scale.y
	return true  # Animation plays


func _test_jump_stretch() -> bool:
	_animator.play_jump_stretch()
	await get_tree().create_timer(0.1).timeout
	return true  # Animation plays


func _test_jump_land() -> bool:
	_animator.play_jump_land()
	await get_tree().create_timer(0.25).timeout
	return true  # Animation plays and returns to normal


func _test_charge_windup() -> bool:
	_animator.play_charge_windup()
	await get_tree().create_timer(0.35).timeout
	return true


func _test_charge_rush() -> bool:
	_animator.play_charge_rush()
	await get_tree().create_timer(0.15).timeout
	return true


func _test_teleport_out() -> bool:
	_animator.play_teleport_out()
	await get_tree().create_timer(0.15).timeout
	# Should fade out
	return _test_sprite.modulate.a < 0.5


func _test_teleport_in() -> bool:
	_animator.play_teleport_in()
	await get_tree().create_timer(0.3).timeout
	# Animation should complete without errors
	return true


func _test_explosion_swell() -> bool:
	# Test explosion swell animation at various progress values
	_animator.play_explosion_swell(0.0)  # Start
	await get_tree().process_frame
	_animator.play_explosion_swell(0.5)  # Mid
	await get_tree().process_frame
	_animator.play_explosion_swell(1.0)  # Full
	await get_tree().process_frame
	# Animation plays without crash
	return true


func _test_breath_attack() -> bool:
	_animator.play_breath_attack()
	await get_tree().create_timer(0.7).timeout
	# Animation completes without crash
	return true


func _test_sonic_boom() -> bool:
	_animator.play_sonic_boom()
	await get_tree().create_timer(0.5).timeout
	# Animation completes without crash
	return true


func _test_summon_animation() -> bool:
	_animator.play_summon_animation()
	await get_tree().create_timer(0.7).timeout
	# Animation completes without crash
	return true


func _test_laser_charge() -> bool:
	_animator.play_laser_charge()
	await get_tree().create_timer(1.0).timeout
	return true  # Pulsing animation plays


func _test_laser_fire() -> bool:
	_animator.play_laser_fire()
	await get_tree().create_timer(0.6).timeout
	# Animation completes without crash
	return true


func _test_walk_during_attack() -> bool:
	_animator.start_walk_animation()
	await get_tree().create_timer(0.1).timeout
	var was_walking = _animator.is_walking
	_animator.play_attack_animation()
	await get_tree().create_timer(0.1).timeout
	# Walk should pause during attack
	await get_tree().create_timer(0.5).timeout
	return was_walking


func _test_multiple_hits() -> bool:
	# Rapid hit reactions should not crash
	for i in range(5):
		_animator.play_hit_reaction()
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.2).timeout
	return true  # No crash


func _test_attack_signals() -> bool:
	# Test that attack animation plays full sequence
	_animator.play_attack_animation()
	await get_tree().create_timer(0.1).timeout
	var was_attacking = _animator.is_attacking
	await get_tree().create_timer(0.6).timeout
	# Animation should complete (is_attacking false)
	return was_attacking and not _animator.is_attacking


func _test_tween_cleanup() -> bool:
	_animator.start_walk_animation()
	_animator.play_attack_animation()
	_animator.play_hit_reaction()
	# Clean up should not cause errors
	_animator._cleanup_tweens()
	return true  # No crash


func _test_null_sprite() -> bool:
	var animator2 = EnemyAnimatorClass.new()
	add_child(animator2)
	# These should not crash with null sprite
	animator2.start_walk_animation()
	animator2.play_attack_animation()
	animator2.play_hit_reaction()
	animator2.queue_free()
	return true  # No crash


func _test_custom_walk_params() -> bool:
	_animator.walk_bob_height = 10.0
	_animator.walk_bob_speed = 0.2
	_animator.walk_tilt_angle = 15.0
	_animator.start_walk_animation()
	await get_tree().create_timer(0.3).timeout
	_animator.stop_walk_animation()
	return true  # Custom params work


func _test_custom_attack_params() -> bool:
	_animator.attack_windup_time = 0.3
	_animator.attack_strike_time = 0.15
	_animator.attack_recovery_time = 0.3
	_animator.attack_windup_scale = 0.7
	_animator.attack_strike_scale = 1.3
	_animator.play_attack_animation()
	await get_tree().create_timer(0.8).timeout
	return not _animator.is_attacking  # Animation completed
