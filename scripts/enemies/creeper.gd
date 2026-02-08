extends CharacterBody2D
class_name Creeper
## Explosive enemy that detonates when near player

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)

@export var speed: float = 50.0
@export var health: int = 12
@export var xp_value: int = 10
@export var explosion_damage: int = 30
@export var explosion_radius: float = 80.0
@export var fuse_time: float = 1.5
@export var trigger_distance: float = 40.0
@export var meat_drop_chance: float = 0.18  # 18% chance (harder enemy)

var target: Node2D = null
var is_fusing: bool = false
var _fuse_elapsed: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false

func _ready() -> void:
	add_to_group("enemies")

	# Setup animator
	_setup_animator()

	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Creeper-specific animation settings: slow swaying
		_animator.walk_bob_height = 2.5
		_animator.walk_bob_speed = 0.35
		_animator.walk_tilt_angle = 4.0
		_animator.walk_squash = 0.04
		add_child(_animator)
		_animator.setup(sprite)

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	# Apply knockback decay (unless fusing)
	if not is_fusing and knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		_update_walk_animation(false)
		return

	if not target or not is_instance_valid(target):
		_update_walk_animation(false)
		return

	var distance = global_position.distance_to(target.global_position)

	if is_fusing:
		# Flash while fusing and swell up
		_fuse_elapsed += delta
		_flash_sprite()

		# Animator swell effect during fuse
		if _animator:
			var progress = _fuse_elapsed / fuse_time
			_animator.play_explosion_swell(progress)

		if _fuse_elapsed >= fuse_time:
			explode()
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
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

	# Start fuse when close
	if distance <= trigger_distance:
		start_fuse()


func _update_walk_animation(is_moving: bool) -> void:
	if _animator == null:
		return

	if is_moving and not _was_moving:
		_animator.start_walk_animation()
	elif not is_moving and _was_moving:
		_animator.stop_walk_animation()

	_was_moving = is_moving

func apply_knockback(force: Vector2) -> void:
	if not is_fusing:
		knockback_velocity = force

func start_fuse() -> void:
	if is_fusing:
		return

	is_fusing = true
	_fuse_elapsed = 0.0

	# Stop walk animation when starting fuse
	if _animator:
		_animator.stop_walk_animation()

	# Start fuse timer
	var timer = get_node_or_null("FuseTimer")
	if timer:
		timer.wait_time = fuse_time
		# Only connect if not already connected
		if not timer.timeout.is_connected(explode):
			timer.timeout.connect(explode)
		timer.start()

func _flash_sprite() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var flash_rate = 10.0 + (_fuse_elapsed / fuse_time) * 20.0
		sprite.modulate = Color.WHITE if int(_fuse_elapsed * flash_rate) % 2 == 0 else Color.RED

func explode() -> void:
	# Damage player if in radius
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= explosion_radius:
			if target.has_method("take_damage"):
				target.take_damage(explosion_damage)

	# Spawn explosion effect
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx_at("creeper_explosion", global_position)
	_spawn_explosion_effect()
	_spawn_xp_orb()

	died.emit(xp_value)
	queue_free()

func _spawn_explosion_effect() -> void:
	if not get_tree() or not get_tree().current_scene:
		return
	var explosion_scene = load("res://scenes/effects/explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", explosion)
	else:
		# Fallback to death poof
		var death_scene = load("res://scenes/effects/death_poof.tscn")
		if death_scene:
			var poof = death_scene.instantiate()
			poof.global_position = global_position
			poof.scale = Vector2(2, 2)
			get_tree().current_scene.call_deferred("add_child", poof)

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

	# Die without exploding
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
