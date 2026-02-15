extends CharacterBody2D
class_name Witch
## Ranged enemy that throws potions at the player

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)

@export var speed: float = 35.0
@export var health: int = 10
@export var xp_value: int = 12
@export var meat_drop_chance: float = 0.0  # Witches don't drop meat
@export var potion_damage: int = 12
@export var attack_range: float = 250.0
@export var attack_cooldown: float = 3.0
@export var preferred_distance: float = 180.0

var target: Node2D = null
var can_attack: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0
var is_elite: bool = false

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false

func _ready() -> void:
	add_to_group("enemies")

	# Connect hitbox for contact damage (weak melee)
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup attack timer
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.timeout.connect(_on_attack_timer_timeout)
		timer.wait_time = attack_cooldown

	# Setup animator
	_setup_animator()

	# Find player as target
	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Witch-specific animation settings: graceful, flowing
		_animator.walk_bob_height = 3.0
		_animator.walk_bob_speed = 0.4
		_animator.walk_tilt_angle = 6.0
		_animator.walk_squash = 0.03
		# Attack is throw motion - lean back then forward
		_animator.attack_windup_time = 0.25
		_animator.attack_windup_angle = -25.0
		_animator.attack_strike_time = 0.1
		_animator.attack_strike_angle = 20.0
		_animator.attack_recovery_time = 0.3
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

	# Try to maintain preferred distance (keep away from player)
	if distance > preferred_distance + 30:
		# Move closer
		velocity = direction * speed
	elif distance < preferred_distance - 30:
		# Back away
		velocity = -direction * speed * 0.7
	else:
		# Stay still and attack
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

	# Throw potion if in range and can attack
	if distance <= attack_range and can_attack:
		throw_potion()


func _update_walk_animation(is_moving: bool) -> void:
	if _animator == null:
		return

	if is_moving and not _was_moving:
		_animator.start_walk_animation()
	elif not is_moving and _was_moving:
		_animator.stop_walk_animation()

	_was_moving = is_moving

func make_elite() -> void:
	is_elite = true

func throw_potion() -> void:
	if not target or not is_instance_valid(target):
		return

	can_attack = false

	# Play throw animation
	if _animator:
		_animator.play_attack_animation()

	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx_at("witch_poison_throw", global_position)
	# Load potion scene
	var potion_scene = load("res://scenes/projectiles/potion.tscn")
	if potion_scene:
		# Get spawn position (from marker or default offset)
		var spawn_pos = global_position
		var spawn_point = get_node_or_null("PotionSpawnPoint")
		if spawn_point:
			spawn_pos = spawn_point.global_position

		var base_direction = (target.global_position - spawn_pos).normalized()

		if is_elite:
			# Elite Potion Storm: 3 potions at -20, 0, +20 degrees
			var spread_angles = [deg_to_rad(-20.0), 0.0, deg_to_rad(20.0)]
			for angle_offset in spread_angles:
				var p = potion_scene.instantiate()
				p.global_position = spawn_pos
				var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
				var target_pos = target.global_position + offset
				p.set_target(target_pos)
				var spread_dir = base_direction.rotated(angle_offset)
				p.set_direction(spread_dir)
				p.damage = potion_damage
				if get_tree() and get_tree().current_scene:
					get_tree().current_scene.call_deferred("add_child", p)
		else:
			var potion = potion_scene.instantiate()
			potion.global_position = spawn_pos
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
			var target_pos = target.global_position + offset
			potion.set_target(target_pos)
			var direction = (target_pos - potion.global_position).normalized()
			potion.set_direction(direction)
			potion.damage = potion_damage
			if get_tree() and get_tree().current_scene:
				get_tree().current_scene.call_deferred("add_child", potion)

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
	# Weak contact damage
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(5)  # Low contact damage

func take_damage(amount: int) -> void:
	health -= amount

	# Play hit reaction animation
	if _animator:
		_animator.play_hit_reaction()

	_spawn_hit_effect()

	if health <= 0:
		_on_died()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

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
		poof.modulate = Color(0.3, 0.6, 0.3)  # Green tint for Witch
		get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene and get_tree() and get_tree().current_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.call_deferred("add_child", orb)
