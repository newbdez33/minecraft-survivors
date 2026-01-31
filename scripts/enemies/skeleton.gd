extends CharacterBody2D
class_name Skeleton
## Ranged enemy that shoots arrows at the player

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

	_find_target()

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
		return

	if not target or not is_instance_valid(target):
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

	# Prevent sticking to player - add separation when too close
	var min_distance = 30.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		velocity += push_direction * (min_distance - distance) * 5.0

	move_and_slide()

	# Shoot if in range
	if distance <= attack_range and can_attack:
		shoot_arrow()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func shoot_arrow() -> void:
	if not target or not is_instance_valid(target):
		return

	can_attack = false

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
