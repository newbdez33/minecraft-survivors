extends Node
## Quick visual test for Sorcerer poison cloud
## - God mode enabled (player invincible)
## - Spawns sorcerers immediately
## - Auto-exits after duration

@export var test_duration: float = 25.0
@export var sorcerer_count: int = 5  # More witches for stacking test

var _player: Node2D = null
var _time_elapsed: float = 0.0

func _ready() -> void:
	print("[SORCERER TEST] Starting poison cloud visual test...")

	# Wait for scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	# Find player and enable god mode
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_player.god_mode = true
		print("[SORCERER TEST] God mode enabled")

	# Spawn sorcerers around player
	_spawn_sorcerers()

	print("[SORCERER TEST] Test running for %.0f seconds..." % test_duration)

func _process(delta: float) -> void:
	_time_elapsed += delta

	# Show progress
	if int(_time_elapsed) % 5 == 0 and fmod(_time_elapsed, 5.0) < delta:
		print("[SORCERER TEST] %.0f seconds elapsed..." % _time_elapsed)

	# End test
	if _time_elapsed >= test_duration:
		print("[SORCERER TEST] Test complete!")
		get_tree().quit()

func _spawn_sorcerers() -> void:
	var sorcerer_scene = load("res://scenes/enemies/sorcerer.tscn")
	if not sorcerer_scene:
		print("[SORCERER TEST] ERROR: Could not load sorcerer scene")
		return

	if not _player:
		print("[SORCERER TEST] ERROR: No player found")
		return

	# Spawn sorcerers at different positions around player
	var angles = [0, TAU / sorcerer_count, TAU * 2 / sorcerer_count]
	var distance = 200.0

	for i in range(sorcerer_count):
		var sorcerer = sorcerer_scene.instantiate()
		var angle = angles[i] if i < angles.size() else randf() * TAU
		var offset = Vector2.from_angle(angle) * distance
		sorcerer.global_position = _player.global_position + offset
		get_tree().current_scene.add_child(sorcerer)
		print("[SORCERER TEST] Spawned sorcerer %d at %s" % [i + 1, sorcerer.global_position])
