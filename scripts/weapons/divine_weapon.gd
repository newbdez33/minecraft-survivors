extends Area2D
class_name DivineWeapon
## Auto-attacking melee weapon that damages enemies in range

signal attacked(enemies_hit: int)

@export var damage: int = 10
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 0.8
@export var knockback: float = 0.0
@export var show_range_indicator: bool = true
@export var range_color: Color = Color(0.3, 0.7, 1.0, 0.08)
@export var range_border_color: Color = Color(0.4, 0.8, 1.0, 0.25)
@export var hand_offset: float = 20.0  # Distance from player center to hand

var can_attack: bool = true
var enemies_in_range: Array = []
var current_facing: Vector2 = Vector2.RIGHT
var is_attacking: bool = false

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

	# Connect to player's facing direction
	var player = get_parent()
	if player and player.has_signal("facing_changed"):
		player.facing_changed.connect(_on_player_facing_changed)
		# Get initial facing direction
		if "facing_direction" in player:
			current_facing = player.facing_direction

	# Set initial sword position
	_update_sword_position()

	# Trigger initial draw
	queue_redraw()

func _physics_process(_delta: float) -> void:
	# Remove invalid enemies in-place (iterate backwards to avoid index issues)
	for i in range(enemies_in_range.size() - 1, -1, -1):
		if not is_instance_valid(enemies_in_range[i]):
			enemies_in_range.remove_at(i)

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
			if knockback > 0:
				var direction = (enemy.global_position - global_position).normalized()
				if enemy.has_method("apply_knockback"):
					enemy.apply_knockback(direction * knockback)
				elif enemy is CharacterBody2D:
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
	if sprite and not is_attacking:
		is_attacking = true
		# Bring sword to front during attack
		sprite.z_index = 11

		# Swing animation: -45 degrees to +45 degrees relative to current facing
		var base_angle = current_facing.angle()
		var start_angle = base_angle - PI / 4  # -45 degrees
		var end_angle = base_angle + PI / 4    # +45 degrees

		sprite.rotation = start_angle
		var tween = create_tween()
		tween.tween_property(sprite, "rotation", end_angle, 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "rotation", base_angle, 0.1).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
			is_attacking = false
			_update_sword_position()
		)

func _on_player_facing_changed(direction: Vector2) -> void:
	current_facing = direction
	if not is_attacking:
		_update_sword_position()

func _update_sword_position() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Position sword at hand offset in facing direction
		sprite.position = current_facing * hand_offset
		# Rotate sword to point in facing direction (add 45 degrees for diagonal sword)
		sprite.rotation = current_facing.angle() + PI / 4
		# Flip sprite based on direction to keep sword looking correct
		if current_facing.x < 0:
			sprite.flip_v = true
			sprite.z_index = 11  # In front when facing left
		else:
			sprite.flip_v = false
			sprite.z_index = -1  # Behind when facing right

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
