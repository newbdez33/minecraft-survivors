extends Node
## Unit tests for Player

class_name TestPlayer

static func get_player_instance():
	var scene = load("res://scenes/player.tscn")
	return scene.instantiate() if scene else null

# Test: Player movement direction calculation
static func test_input_direction_zero_when_no_input() -> bool:
	var player = get_player_instance()
	if not player:
		return false

	# With no input, direction should be zero
	var direction = player.get_input_direction()
	var result = direction == Vector2.ZERO

	player.queue_free()
	return result

# Test: Player has correct collision layers
static func test_player_collision_layers() -> bool:
	var player = get_player_instance()
	if not player:
		return false

	# Player should be on layer 1 (player layer)
	var on_player_layer = player.collision_layer == 1
	# Player should detect layer 2 (enemies)
	var detects_enemies = player.collision_mask == 2

	player.queue_free()
	return on_player_layer and detects_enemies

# Test: Player speed is reasonable
static func test_player_speed_reasonable() -> bool:
	var player = get_player_instance()
	if not player:
		return false

	# Speed should be between 100 and 500 for good gameplay
	var speed_ok = player.speed >= 100 and player.speed <= 500

	player.queue_free()
	return speed_ok

# Test: Player sprite exists and has texture
static func test_player_has_sprite() -> bool:
	var player = get_player_instance()
	if not player:
		return false

	var sprite = player.get_node_or_null("Sprite2D")
	var has_sprite = sprite != null
	var has_texture = sprite and sprite.texture != null

	player.queue_free()
	return has_sprite and has_texture
