extends Node
## Visual Test: Biome Walkthrough + Music
## Teleports player to each biome zone, captures screenshots, verifies music triggers
## Run on main scene: godot --path . scenes/testing/visual_test_biome_walkthrough.tscn

const BiomeManagerClass = preload("res://scripts/systems/biome_manager.gd")

var _player: Node2D = null
var _arena: Node2D = null
var _screenshot_count: int = 0
var _biome_changes: Array = []
var _music_events: Array = []

# Teleport waypoints: [position, expected_biome, label]
const WAYPOINTS: Array = [
	[Vector2(0, 0), 0, "Spawn (Plains center)"],
	[Vector2(500, 0), 0, "Plains (500px east, still inner)"],
	[Vector2(950, 0), -1, "Transition zone (950px east)"],
	[Vector2(1300, 0), 1, "Desert (1300px east)"],
	[Vector2(0, -1300), 2, "Snow (1300px north/up)"],
	[Vector2(-1300, 0), 3, "Swamp (1300px west)"],
	[Vector2(0, 1300), 3, "Swamp (1300px south/down)"],
	[Vector2(0, 0), 0, "Return to Spawn"],
]


func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Biome Walkthrough + Music")
	print("=".repeat(50))

	await get_tree().process_frame

	_player = get_tree().current_scene.get_node_or_null("Player")
	_arena = get_tree().current_scene.get_node_or_null("Arena")

	if not _player:
		print("  ERROR: Player not found!")
		await get_tree().create_timer(1.0).timeout
		get_tree().quit(1)
		return

	if not _arena:
		print("  ERROR: Arena not found!")
		await get_tree().create_timer(1.0).timeout
		get_tree().quit(1)
		return

	# Connect biome_changed signal if available
	if _arena.has_signal("biome_changed"):
		_arena.biome_changed.connect(_on_biome_changed)
		print("  Connected to arena.biome_changed signal")

	# Make player invulnerable for test
	if _player.has_method("set_invulnerable"):
		_player.set_invulnerable(true)

	# Disable spawner to avoid interference
	var spawner = get_tree().current_scene.get_node_or_null("MobSpawner")
	if spawner:
		spawner.set_process(false)
		spawner.set_physics_process(false)
		print("  Spawner disabled for clean test")

	await get_tree().create_timer(0.5).timeout
	await _run_walkthrough()


func _run_walkthrough() -> void:
	print("\n[BIOME WALKTHROUGH]")

	for i in range(WAYPOINTS.size()):
		var wp: Array = WAYPOINTS[i]
		var target_pos: Vector2 = wp[0]
		var expected_biome: int = wp[1]
		var label: String = wp[2]

		print("\n  Step %d: %s" % [i + 1, label])
		print("    Teleporting to %s..." % str(target_pos))

		# Teleport player
		_player.global_position = target_pos

		# Wait for arena to redraw and detect biome
		await get_tree().create_timer(0.5).timeout

		# Check biome at position
		var actual_biome: int = BiomeManagerClass.get_primary_biome(target_pos)
		var biome_name: String = BiomeManagerClass.biome_name(actual_biome)

		if expected_biome >= 0:
			var match_str: String = "PASS" if actual_biome == expected_biome else "FAIL"
			print("    Biome: %s (expected: %s) [%s]" % [
				biome_name,
				BiomeManagerClass.biome_name(expected_biome),
				match_str
			])
		else:
			print("    Biome: %s (transition zone, any valid)" % biome_name)

		# Check arena's current biome tracking
		if _arena.has_method("get_current_biome"):
			var arena_biome: int = _arena.get_current_biome()
			print("    Arena reports biome: %s" % BiomeManagerClass.biome_name(arena_biome))

		# Check music state
		var audio = get_node_or_null("/root/AudioManager")
		if audio and audio.has_method("is_music_playing"):
			print("    Music playing: %s" % str(audio.is_music_playing()))

		# Take screenshot
		_take_screenshot("biome_%s_%s" % [str(i + 1).pad_zeros(2), biome_name.to_lower()])

		await get_tree().create_timer(0.3).timeout

	_finish_test()


func _on_biome_changed(biome: int) -> void:
	var biome_name: String = BiomeManagerClass.biome_name(biome)
	_biome_changes.append(biome_name)
	print("    >>> BIOME CHANGED: %s <<<" % biome_name)


func _take_screenshot(name: String) -> void:
	_screenshot_count += 1
	var filename = "user://visual_test_biome_%02d_%s.png" % [_screenshot_count, name]

	# In headless mode, get_image() returns null (dummy renderer)
	var viewport = get_viewport()
	if not viewport or not viewport.get_texture():
		print("    Screenshot skipped (headless mode)")
		return
	var image = viewport.get_texture().get_image()
	if image:
		var error = image.save_png(filename)
		if error == OK:
			print("    Screenshot: %s" % filename)
	else:
		print("    Screenshot skipped (no image)")


func _finish_test() -> void:
	print("\n" + "-".repeat(40))
	print("  [BIOME CHANGE LOG]")
	if _biome_changes.size() == 0:
		print("    No biome changes detected")
	else:
		for i in range(_biome_changes.size()):
			print("    %d. %s" % [i + 1, _biome_changes[i]])

	# Verify expected biome transitions
	print("\n  [VERIFICATION]")
	var expected_transitions: Array = ["Desert", "Snow", "Swamp", "Plains"]
	var passed: int = 0
	var failed: int = 0

	for expected in expected_transitions:
		if expected in _biome_changes:
			print("    PASS: Transitioned to %s" % expected)
			passed += 1
		else:
			print("    FAIL: Never transitioned to %s" % expected)
			failed += 1

	print("\n" + "=".repeat(50))
	print("  BIOME WALKTHROUGH TEST COMPLETE!")
	print("  Transitions: %d passed, %d failed" % [passed, failed])
	print("  Screenshots: %d saved" % _screenshot_count)
	print("  Biome changes detected: %d" % _biome_changes.size())
	print("=".repeat(50) + "\n")

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0 if failed == 0 else 1)
