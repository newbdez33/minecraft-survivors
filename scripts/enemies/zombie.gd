extends CharacterBody2D
class_name Zombie
## Basic zombie enemy that chases the player

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)

@export var speed: float = 60.0
@export var damage: int = 10
@export var xp_value: int = 5
@export var health: int = 10
@export var meat_drop_chance: float = 0.15  # 15% chance to drop meat

var target: Node2D = null
var _health_component: Node = null
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0  # How fast knockback fades

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false
var _attack_cooldown: float = 0.0
const ATTACK_COOLDOWN_TIME: float = 1.0  # Time between attack animations

func _ready() -> void:
	add_to_group("enemies")

	# Get health component if exists
	_health_component = get_node_or_null("HealthComponent")
	if _health_component:
		_health_component.max_health = health
		_health_component.current_health = health
		_health_component.died.connect(_on_died)

	# Connect hitbox for damaging player
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup animator
	_setup_animator()

	# Find player as target
	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Zombie-specific animation settings: slow, stiff movement
		_animator.walk_bob_height = 3.0
		_animator.walk_bob_speed = 0.4
		_animator.walk_tilt_angle = 5.0
		_animator.attack_windup_time = 0.2
		_animator.attack_strike_time = 0.1
		_animator.attack_recovery_time = 0.25
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

	# Apply knockback decay
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		_update_walk_animation(false)
		return

	if not target:
		_update_walk_animation(false)
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

	# Prevent sticking to player - strong separation when too close
	var distance_to_player = global_position.distance_to(target.global_position)
	var min_distance = 40.0  # Minimum distance to maintain from player
	if distance_to_player < min_distance and distance_to_player > 0:
		var push_direction = (global_position - target.global_position).normalized()
		# Strong push force that overrides movement when very close
		var push_strength = (min_distance - distance_to_player) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

	# Update walk animation based on movement
	var is_moving = velocity.length() > 10.0
	_update_walk_animation(is_moving)


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

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Damage player on contact
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		# Play attack animation if cooldown ready
		if _animator and _attack_cooldown <= 0:
			_animator.play_attack_animation()
			_attack_cooldown = ATTACK_COOLDOWN_TIME

func take_damage(amount: int) -> void:
	if _health_component:
		_health_component.take_damage(amount)
		health = _health_component.current_health
	else:
		health -= amount
		if health <= 0:
			_on_died()

	# Play hit reaction animation
	if _animator:
		_animator.play_hit_reaction()

	# Spawn hit effect
	_spawn_hit_effect()

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

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene and get_tree() and get_tree().current_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", poof)
