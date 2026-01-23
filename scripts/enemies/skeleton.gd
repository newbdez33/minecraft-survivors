extends CharacterBody2D
class_name Skeleton
## Ranged enemy that shoots arrows at the player

signal died(xp_value: int)

@export var speed: float = 40.0
@export var damage: int = 8
@export var health: int = 15
@export var xp_value: int = 8
@export var attack_range: float = 300.0
@export var attack_cooldown: float = 2.0
@export var preferred_distance: float = 200.0

var target: Node2D = null
var can_attack: bool = true

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

func _physics_process(_delta: float) -> void:
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

	move_and_slide()

	# Shoot if in range
	if distance <= attack_range and can_attack:
		shoot_arrow()

func shoot_arrow() -> void:
	if not target or not is_instance_valid(target):
		return

	can_attack = false

	var arrow_scene = load("res://scenes/projectiles/arrow.tscn")
	if arrow_scene:
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
	if hit_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.add_child(hit)

func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_xp_orb()
	queue_free()

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		get_tree().current_scene.add_child(poof)

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.add_child(orb)
