extends Area2D
class_name PoisonCloud
## Poison cloud area that damages and poisons players who enter
## Circular pixel-art style

@export var duration: float = 5.0
@export var size: float = 80.0  # Diameter of cloud
@export var poison_duration: float = 3.0
@export var poison_damage_per_tick: int = 2
@export var poison_tick_interval: float = 0.5
@export var cloud_damage: int = 5  # Initial damage when entering

var _time_left: float = 0.0
var _players_in_cloud: Array = []
var _particles: Array = []
var _radius: float = 40.0
var _pixel_data: Array = []  # Pre-generated pixel positions and colors

func _ready() -> void:
	_time_left = duration
	_radius = size / 2.0

	# Setup collision
	collision_layer = 4  # Effects
	collision_mask = 1   # Player

	# Create circular collision shape
	var shape = CircleShape2D.new()
	shape.radius = _radius
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Pre-generate pixel pattern
	_generate_pixel_pattern()

	# Create pixel-art visual
	_create_pixel_visual()

	# Enable custom drawing
	queue_redraw()

func _generate_pixel_pattern() -> void:
	var pixel_size = 8
	var grid_radius = int(_radius / pixel_size)

	# First pass: create base circle pixels (darker green)
	for y in range(-grid_radius, grid_radius + 1):
		for x in range(-grid_radius, grid_radius + 1):
			var pixel_pos = Vector2(x * pixel_size, y * pixel_size)
			# Only add pixels within the circle
			if pixel_pos.length() <= _radius - pixel_size / 2:
				# Base layer - all pixels filled for solid circle shape
				var base_alpha = randf_range(0.4, 0.6)
				_pixel_data.append({
					"pos": pixel_pos - Vector2(pixel_size / 2, pixel_size / 2),
					"size": Vector2(pixel_size, pixel_size),
					"color": Color(0.15, 0.4, 0.15, base_alpha),
					"layer": 0
				})

	# Second pass: add variation pixels on top (brighter green, sparse)
	for y in range(-grid_radius, grid_radius + 1):
		for x in range(-grid_radius, grid_radius + 1):
			var pixel_pos = Vector2(x * pixel_size, y * pixel_size)
			if pixel_pos.length() <= _radius - pixel_size / 2:
				if randf() > 0.4:  # 60% chance for variation
					var shade = randf_range(0.5, 0.9)
					var alpha = randf_range(0.3, 0.5)
					_pixel_data.append({
						"pos": pixel_pos - Vector2(pixel_size / 2, pixel_size / 2),
						"size": Vector2(pixel_size, pixel_size),
						"color": Color(0.1, shade, 0.1, alpha),
						"layer": 1
					})

func _process(delta: float) -> void:
	_time_left -= delta

	# Fade out near end
	if _time_left < 1.0:
		modulate.a = _time_left

	# Animate particles
	_animate_particles(delta)

	if _time_left <= 0:
		queue_free()

func _draw() -> void:
	# Draw pixel-art circle (no smooth circle, only chunky pixels)
	for pixel in _pixel_data:
		draw_rect(Rect2(pixel.pos, pixel.size), pixel.color)

func _create_pixel_visual() -> void:
	# Add floating poison particle squares within circle
	for i in range(6):
		var particle = ColorRect.new()
		particle.name = "Particle" + str(i)
		particle.size = Vector2(6, 6)
		# Random position within circle
		var angle = randf() * TAU
		var dist = randf_range(8, _radius - 8)
		particle.position = Vector2(cos(angle) * dist, sin(angle) * dist) - Vector2(3, 3)
		particle.color = Color(0.3, 1.0, 0.3, 0.8)
		particle.set_meta("float_offset", randf() * TAU)
		particle.set_meta("float_speed", randf_range(1.5, 3.0))
		particle.set_meta("base_pos", particle.position)
		add_child(particle)
		_particles.append(particle)

func _animate_particles(delta: float) -> void:
	for particle in _particles:
		if is_instance_valid(particle):
			var offset = particle.get_meta("float_offset")
			var speed = particle.get_meta("float_speed")
			var base_pos = particle.get_meta("base_pos")

			# Float up and down
			particle.set_meta("float_offset", offset + delta * speed)
			particle.position.y = base_pos.y + sin(offset) * 4

			# Slight horizontal drift
			particle.position.x = base_pos.x + sin(offset * 0.7) * 3

			# Keep particles within circle bounds
			var center_offset = particle.position + Vector2(3, 3)  # Offset for particle center
			if center_offset.length() > _radius - 6:
				particle.position = center_offset.normalized() * (_radius - 6) - Vector2(3, 3)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body not in _players_in_cloud:
		_players_in_cloud.append(body)
		_apply_poison_to_player(body)

		# Deal initial cloud damage
		if body.has_method("take_damage"):
			body.take_damage(cloud_damage)

func _on_body_exited(body: Node2D) -> void:
	_players_in_cloud.erase(body)

func _apply_poison_to_player(player: Node) -> void:
	var status_manager = player.get_node_or_null("StatusEffectManager")
	if status_manager:
		var StatusEffectClass = load("res://scripts/components/status_effect.gd")
		var poison = StatusEffectClass.new(
			StatusEffectClass.Type.POISON,
			poison_duration,
			poison_tick_interval,
			poison_damage_per_tick
		)
		status_manager.apply_effect(poison)

func _exit_tree() -> void:
	# Clean up arrays to prevent memory leaks
	_pixel_data.clear()
	_particles.clear()
	_players_in_cloud.clear()
