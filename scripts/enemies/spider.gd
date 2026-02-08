extends CharacterBody2D
class_name Spider
## Fast enemy that can jump toward the player

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

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

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false
var _attack_cooldown: float = 0.0
const ATTACK_COOLDOWN_TIME: float = 0.5

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

	# Setup animator
	_setup_animator()

	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Spider-specific animation settings: fast, twitchy
		_animator.walk_bob_height = 1.5
		_animator.walk_bob_speed = 0.15
		_animator.walk_tilt_angle = 0.0
		_animator.walk_squash = 0.08
		_animator.attack_windup_time = 0.1
		_animator.attack_strike_time = 0.05
		_animator.attack_recovery_time = 0.15
		add_child(_animator)
		_animator.setup(sprite)

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	# Update attack cooldown
	if _attack_cooldown > 0:
		_attack_cooldown -= delta

	# Apply knockback decay (unless jumping)
	if not is_jumping and knockback_velocity.length() > 1.0:
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

	if is_jumping:
		# Continue jump movement
		move_and_slide()
		return

	# Normal movement
	velocity = direction * speed

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

	# Try to jump if in range and can jump
	if distance <= jump_distance and can_jump:
		jump()


func _update_walk_animation(is_moving: bool) -> void:
	if _animator == null:
		return

	if is_moving and not _was_moving:
		_animator.start_walk_animation()
	elif not is_moving and _was_moving:
		_animator.stop_walk_animation()

	_was_moving = is_moving

func apply_knockback(force: Vector2) -> void:
	if not is_jumping:
		knockback_velocity = force

func jump() -> void:
	if not target or not is_instance_valid(target):
		return

	can_jump = false
	is_jumping = true
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx_at("spider_jump", global_position)

	# Stop walk animation and play jump squash
	if _animator:
		_animator.stop_walk_animation()
		_animator.play_jump_squash()

	# Brief delay for squash animation
	await get_tree().create_timer(0.1).timeout

	# Play jump stretch
	if _animator:
		_animator.play_jump_stretch()

	# Calculate jump velocity toward player's predicted position
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * jump_speed

	# End jump after short duration
	await get_tree().create_timer(0.2).timeout
	is_jumping = false
	velocity = Vector2.ZERO

	# Play landing animation
	if _animator:
		_animator.play_jump_land()

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
		# Play quick attack animation on hit
		if _animator and _attack_cooldown <= 0:
			_animator.play_quick_attack()
			_attack_cooldown = ATTACK_COOLDOWN_TIME

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
