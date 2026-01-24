extends Node
## Gameplay Test - Captures screenshots during actual gameplay

var screenshot_dir = "res://docs/screenshots/testing/"
var screenshot_count = 0

func _ready() -> void:
	print("=== GAMEPLAY TEST ===")
	print("Press F12 to take screenshot")
	print("Press 1-6 to simulate upgrades")
	print("Press K to kill player (test game over)")
	print("")

	# Take initial screenshot after scene loads
	await get_tree().create_timer(1.0).timeout
	_take_screenshot("gameplay_01_start")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F12:
				screenshot_count += 1
				_take_screenshot("gameplay_manual_%02d" % screenshot_count)
			KEY_1:
				_apply_upgrade("sharpness")
			KEY_2:
				_apply_upgrade("knockback")
			KEY_3:
				_apply_upgrade("looting")
			KEY_4:
				_apply_upgrade("protection")
			KEY_5:
				_apply_upgrade("swiftness")
			KEY_6:
				_apply_upgrade("sweeping")
			KEY_K:
				_kill_player()

func _apply_upgrade(upgrade_id: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Player not found")
		return

	var sword = player.get_node_or_null("DiamondSword")

	match upgrade_id:
		"sharpness":
			if sword:
				sword.damage += 5
				print("Sharpness applied: damage = %d" % sword.damage)
				_take_screenshot("upgrade_sharpness_%d" % sword.damage)
		"knockback":
			if sword:
				sword.knockback += 30.0
				print("Knockback applied: knockback = %.1f" % sword.knockback)
				_take_screenshot("upgrade_knockback_%.0f" % sword.knockback)
		"looting":
			if "xp_multiplier" in player:
				player.xp_multiplier += 0.2
				print("Looting applied: xp_multiplier = %.2f" % player.xp_multiplier)
				_take_screenshot("upgrade_looting_%.0f" % (player.xp_multiplier * 100))
		"protection":
			if "damage_reduction" in player:
				player.damage_reduction += 0.1
				print("Protection applied: damage_reduction = %.2f" % player.damage_reduction)
				_take_screenshot("upgrade_protection_%.0f" % (player.damage_reduction * 100))
		"swiftness":
			player.speed += player.speed * 0.15
			print("Swiftness applied: speed = %.1f" % player.speed)
			_take_screenshot("upgrade_swiftness_%.0f" % player.speed)
		"sweeping":
			if sword:
				sword.attack_range += 20.0
				var shape = sword.get_node_or_null("CollisionShape2D")
				if shape and shape.shape is CircleShape2D:
					shape.shape.radius = sword.attack_range
				sword.queue_redraw()
				print("Sweeping applied: range = %.1f" % sword.attack_range)
				_take_screenshot("upgrade_sweeping_%.0f" % sword.attack_range)

func _kill_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.current_health = 0
		if player.has_method("_on_died"):
			player._on_died()
		print("Player killed - Game Over triggered")
		await get_tree().create_timer(0.5).timeout
		_take_screenshot("game_over_screen")

func _take_screenshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	var path = screenshot_dir + name + ".png"
	var err = img.save_png(path)
	if err == OK:
		print("Screenshot saved: %s" % path)
	else:
		print("Screenshot FAILED: %s" % path)
