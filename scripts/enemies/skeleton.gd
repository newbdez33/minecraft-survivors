extends CharacterBody2D
class_name Skeleton
## Ranged enemy that shoots arrows at the player

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)

@export var speed: float = 40.0
@export var damage: int = 8
@export var health: int = 5
@export var xp_value: int = 8
@export var attack_range: float = 300.0
@export var attack_cooldown: float = 2.0
@export var preferred_distance: float = 200.0
@export var meat_drop_chance: float = 0.12  # 12% chance to drop meat

var target: Node2D = null
var can_attack: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false

func _ready() -> void:
	add_to_group("enemies")

	# Connect hitbox
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup attack timer
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.timeout.connect(_on_attack_timer_timeout)

	# Setup animator
	_setup_animator()

	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Skeleton-specific animation settings: rattling bones
		_animator.walk_bob_height = 2.0
		_animator.walk_bob_speed = 0.25
		_animator.walk_tilt_angle = 3.0
		_animator.walk_squash = 0.03
		# Attack is bow draw - lean back then release
		_animator.attack_windup_time = 0.3
		_animator.attack_windup_angle = -20.0
		_animator.attack_strike_time = 0.08
		_animator.attack_strike_angle = 10.0
		_animator.attack_recovery_time = 0.2
		add_child(_animator)
		_animator.setup(sprite)

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	# Apply knockback decay
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		_update_walk_animation(false)
		return

	if not target or not is_instance_valid(target):
		_update_walk_animation(false)
		return

	var distance = global_position.distance_to(target.global_position)
	var direction = (target.global_position - global_position).normalized()

	# Try to maintain preferred distance
	if distance > preferred_distance + 20:
		velocity = direction * speed
	elif distance < preferred_distance - 20:
		velocity = -direction * speed * 0.5
	else:
		velocity = Vector2.ZERO

	# Prevent sticking to player - strong separation when too close
	var min_distance = 40.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		var push_strength = (min_distance - distance) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

	# Update walk animation based on movement
	var is_moving = velocity.length() > 10.0
	_update_walk_animation(is_moving)

	# Shoot if in range
	if distance <= attack_range and can_attack:
		shoot_arrow()


func _update_walk_animation(is_moving: bool) -> void:
	if _animator == null:
		return

	if is_moving and not _was_moving:
		_animator.start_walk_animation()
	elif not is_moving and _was_moving:
		_animator.stop_walk_animation()

	_was_moving = is_moving

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func shoot_arrow() -> void:
	if not target or not is_instance_valid(target):
		return

	can_attack = false

	# Play bow draw animation
	if _animator:
		_animator.play_attack_animation()

	var arrow_scene = load("res://scenes/projectiles/arrow.tscn")
	if arrow_scene and get_tree() and get_tree().current_scene:
		var arrow = arrow_scene.instantiate()
		arrow.global_position = global_position
		var direction = (target.global_position - global_position).normalized()
		arrow.set_direction(direction)
		arrow.damage = damage
		get_tree().current_scene.add_child(arrow)

	# Start cooldown
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.start()
	else:
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount

	# Play hit reaction animation
	if _animator:
		_animator.play_hit_reaction()

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
	# Clean up animator before death
	if _animator:
		_animator.reset_to_original()

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
