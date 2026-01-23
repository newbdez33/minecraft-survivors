extends CharacterBody2D
class_name Spider
## Fast enemy that can jump toward the player

signal died(xp_value: int)

@export var speed: float = 100.0
@export var damage: int = 8
@export var health: int = 12
@export var xp_value: int = 6
@export var jump_distance: float = 150.0
@export var jump_cooldown: float = 3.0
@export var jump_speed: float = 400.0

var target: Node2D = null
var can_jump: bool = true
var is_jumping: bool = false

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
	move_and_slide()

	# Try to jump if in range and can jump
	if distance <= jump_distance and can_jump:
		jump()

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
