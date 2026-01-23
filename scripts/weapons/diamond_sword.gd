extends Area2D
class_name DiamondSword
## Auto-attacking melee weapon that damages enemies in range

signal attacked(enemies_hit: int)

@export var damage: int = 10
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 0.8
@export var knockback: float = 100.0
@export var show_range_indicator: bool = true
@export var range_color: Color = Color(0.3, 0.7, 1.0, 0.08)
@export var range_border_color: Color = Color(0.4, 0.8, 1.0, 0.25)

var can_attack: bool = true
var enemies_in_range: Array = []

func _ready() -> void:
	# Setup collision
	collision_layer = 0
	collision_mask = 2  # Detect enemies (layer 2)

	# Sync collision shape radius with attack_range
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = attack_range

	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Setup attack timer
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.timeout.connect(_on_attack_timer_timeout)
		timer.wait_time = attack_cooldown

	# Trigger initial draw
	queue_redraw()

func _physics_process(_delta: float) -> void:
	# Clean up invalid enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	# Auto attack when enemies in range
	if can_attack and enemies_in_range.size() > 0:
		_perform_attack()

func _perform_attack() -> void:
	can_attack = false

	var hit_count = 0
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			hit_count += 1

			# Apply knockback
			if knockback > 0 and enemy is CharacterBody2D:
				var direction = (enemy.global_position - global_position).normalized()
				enemy.velocity = direction * knockback

	if hit_count > 0:
		attacked.emit(hit_count)
		_play_attack_animation()

	# Start cooldown
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.start()
	else:
		# Fallback if no timer
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _play_attack_animation() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Bring sword to front during attack
		sprite.z_index = 11
		var tween = create_tween()
		tween.tween_property(sprite, "rotation", TAU, 0.2)
		tween.tween_callback(func():
			sprite.rotation = 0
			sprite.z_index = -1  # Move back behind Steve
		)

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)

func _draw() -> void:
	if show_range_indicator:
		# Draw filled circle for range
		draw_circle(Vector2.ZERO, attack_range, range_color)
		# Draw border circle (thicker line)
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, range_border_color, 3.0, true)

func set_show_range(visible: bool) -> void:
	show_range_indicator = visible
	queue_redraw()
