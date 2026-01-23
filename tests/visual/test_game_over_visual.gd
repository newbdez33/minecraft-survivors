extends SceneTree

## Visual test for Game Over UI
## Run with: godot --headless --script tests/visual/test_game_over_visual.gd

func _init() -> void:
	# Load the game over scene
	var game_over_scene = load("res://scenes/ui/game_over_ui.tscn")
	if not game_over_scene:
		print("ERROR: Could not load game_over_ui.tscn")
		quit(1)
		return

	var game_over = game_over_scene.instantiate()
	root.add_child(game_over)

	# Set test stats
	var test_stats = {
		"survival_time": 125.5,  # 2:05
		"kills": 42,
		"highest_level": 5,
		"highest_wave": 3,
		"damage_dealt": 1250,
		"damage_taken": 80
	}

	game_over.set_stats(test_stats)
	game_over.visible = true

	print("Game Over UI test ready")
	print("Stats: %s" % test_stats)

	# Keep running to allow screenshot
	await create_timer(5.0).timeout
	quit(0)
