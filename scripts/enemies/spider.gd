extends CharacterBody2D
class_name Spider
## Fast enemy that can jump toward the player

signal died(xp_value: int)

@export var speed: float = 100.0
@export var damage: int = 8
@export var health: int = 6
@export var xp_value: int = 6
@export var jump_distance: float = 150.0
@export var jump_cooldown: float = 3.0
@export var jump_speed: float = 400.0
@export var meat_drop_chance: float = 0.10  # 10% chance to drop meat

var target: Node2D = null
var can_jump: bool = true
var is_jumping: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

func _ready() -> void:
	add_to_group("enemies")

	# Connect hitbox
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup jump timer
	var timer = get_node_or_null("JumpTimer")
	if timer:
		timer.timeout.connect(_on_jump_timer_timeout)

	_find_target()

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	# Apply knockback decay (unless jumping)
	if not is_jumping and knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		return

	if not target or not is_instance_valid(target):
		return

	var distance = global_position.distance_to(target.global_position)
	var direction = (target.global_position - global_position).normalized()

	if is_jumping:
		# Continue jump movement
		move_and_slide()
		return

	# Normal movement
	velocity = direction * speed

	# Prevent sticking to player - add separation when too close
	var min_distance = 30.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		velocity += push_direction * (min_distance - distance) * 5.0

	move_and_slide()

	# Try to jump if in range and can jump
	if distance <= jump_distance and can_jump:
		jump()

func apply_knockback(force: Vector2) -> void:
	if not is_jumping:
		knockback_velocity = force

func jump() -> void:
	if not target or not is_instance_valid(target):
		return

	can_jump = false
	is_jumping = true

	# Calculate jump velocity toward player's predicted position
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * jump_speed

	# End jump after short duration
	await get_tree().create_timer(0.2).timeout
	is_jumping = false
	velocity = Vector2.ZERO

	# Start cooldown
	var timer = get_node_or_null("JumpTimer")
	if timer:
		timer.start()
	else:
		await get_tree().create_timer(jump_cooldown).timeout
		can_jump = true

func _on_jump_timer_timeout() -> void:
	can_jump = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	_spawn_hit_effect()

	if health <= 0:
		_on_died()

func _spawn_hit_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", hit)

func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_xp_orb()
	_try_spawn_meat()
	queue_free()

func _try_spawn_meat() -> void:
	if randf() <= meat_drop_chance:
		var meat_scene = load("res://scenes/pickups/meat_pickup.tscn")
		if meat_scene and get_tree() and get_tree().current_scene:
			var meat = meat_scene.instantiate()
			meat.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", meat)

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene and get_tree() and get_tree().current_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.call_deferred("add_child", orb)
