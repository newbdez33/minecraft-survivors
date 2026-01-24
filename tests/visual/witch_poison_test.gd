extends Node
## Quick visual test for Witch poison cloud
## - God mode enabled (player invincible)
## - Spawns witches immediately
## - Auto-exits after duration

@export var test_duration: float = 25.0
@export var witch_count: int = 5  # More witches for stacking test

var _player: Node2D = null
var _time_elapsed: float = 0.0

func _ready() -> void:
	print("[WITCH TEST] Starting poison cloud visual test...")

	# Wait for scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	# Find player and enable god mode
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_player.god_mode = true
		print("[WITCH TEST] God mode enabled")

	# Spawn witches around player
	_spawn_witches()

	print("[WITCH TEST] Test running for %.0f seconds..." % test_duration)

func _process(delta: float) -> void:
	_time_elapsed += delta

	# Show progress
	if int(_time_elapsed) % 5 == 0 and fmod(_time_elapsed, 5.0) < delta:
		print("[WITCH TEST] %.0f seconds elapsed..." % _time_elapsed)

	# End test
	if _time_elapsed >= test_duration:
		print("[WITCH TEST] Test complete!")
		get_tree().quit()

func _spawn_witches() -> void:
	var witch_scene = load("res://scenes/enemies/witch.tscn")
	if not witch_scene:
		print("[WITCH TEST] ERROR: Could not load witch scene")
		return

	if not _player:
		print("[WITCH TEST] ERROR: No player found")
		return

	# Spawn witches at different positions around player
	var angles = [0, TAU / witch_count, TAU * 2 / witch_count]
	var distance = 200.0

	for i in range(witch_count):
		var witch = witch_scene.instantiate()
		var angle = angles[i] if i < angles.size() else randf() * TAU
		var offset = Vector2.from_angle(angle) * distance
		witch.global_position = _player.global_position + offset
		get_tree().current_scene.add_child(witch)
		print("[WITCH TEST] Spawned witch %d at %s" % [i + 1, witch.global_position])
