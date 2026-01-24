extends Area2D
class_name PoisonCloud
## Poison cloud area that damages and poisons players who enter
## Square pixel-art style like Minecraft

@export var duration: float = 5.0
@export var size: float = 80.0  # Square size
@export var poison_duration: float = 3.0
@export var poison_damage_per_tick: int = 2
@export var poison_tick_interval: float = 0.5
@export var cloud_damage: int = 5  # Initial damage when entering

var _time_left: float = 0.0
var _players_in_cloud: Array = []
var _particles: Array = []

func _ready() -> void:
	_time_left = duration

	# Setup collision
	collision_layer = 4  # Effects
	collision_mask = 1   # Player

	# Create square collision shape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(size, size)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Create pixel-art visual
	_create_pixel_visual()

func _process(delta: float) -> void:
	_time_left -= delta

	# Fade out near end
	if _time_left < 1.0:
		modulate.a = _time_left

	# Animate particles
	_animate_particles(delta)

	if _time_left <= 0:
		queue_free()

func _create_pixel_visual() -> void:
	# Create base square with pixel grid pattern
	var base = ColorRect.new()
	base.name = "BaseRect"
	base.size = Vector2(size, size)
	base.position = Vector2(-size / 2, -size / 2)
	base.color = Color(0.2, 0.6, 0.2, 0.4)
	add_child(base)

	# Create pixel grid overlay for Minecraft style
	var pixel_size = 8  # Each "pixel" is 8x8
	var grid_count = int(size / pixel_size)

	for y in range(grid_count):
		for x in range(grid_count):
			# Random variation for each pixel
			if randf() > 0.3:  # 70% of pixels visible
				var pixel = ColorRect.new()
				pixel.size = Vector2(pixel_size - 1, pixel_size - 1)
				pixel.position = Vector2(
					-size / 2 + x * pixel_size,
					-size / 2 + y * pixel_size
				)
				# Vary green shades for depth
				var shade = randf_range(0.4, 0.9)
				var alpha = randf_range(0.3, 0.6)
				pixel.color = Color(0.1, shade, 0.1, alpha)
				add_child(pixel)

	# Add floating poison particle squares
	for i in range(6):
		var particle = ColorRect.new()
		particle.name = "Particle" + str(i)
		particle.size = Vector2(6, 6)
		particle.position = Vector2(
			randf_range(-size / 2 + 8, size / 2 - 8),
			randf_range(-size / 2 + 8, size / 2 - 8)
		)
		particle.color = Color(0.3, 1.0, 0.3, 0.8)
		particle.set_meta("float_offset", randf() * TAU)
		particle.set_meta("float_speed", randf_range(1.5, 3.0))
		particle.set_meta("base_y", particle.position.y)
		add_child(particle)
		_particles.append(particle)

func _animate_particles(delta: float) -> void:
	for particle in _particles:
		if is_instance_valid(particle):
			var offset = particle.get_meta("float_offset")
			var speed = particle.get_meta("float_speed")
			var base_y = particle.get_meta("base_y")

			# Float up and down
			particle.set_meta("float_offset", offset + delta * speed)
			particle.position.y = base_y + sin(offset) * 4

			# Slight horizontal drift
			particle.position.x += sin(offset * 0.7) * delta * 2

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
