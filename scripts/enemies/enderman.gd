extends CharacterBody2D
class_name Enderman
## Teleporting enemy that warps away when hit

signal died(xp_value: int)

@export var speed: float = 70.0
@export var damage: int = 15
@export var health: int = 40
@export var xp_value: int = 15
@export var teleport_cooldown: float = 3.0
@export var teleport_range: float = 200.0
@export var teleport_on_hit: bool = true

var target: Node2D = null
var can_teleport: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

func _ready() -> void:
	add_to_group("enemies")

	# Connect hitbox for damaging player
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup teleport timer
	var timer = get_node_or_null("TeleportTimer")
	if timer:
		timer.timeout.connect(_on_teleport_timer_timeout)
		timer.wait_time = teleport_cooldown

	# Find player as target
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

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Damage player on contact
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	_spawn_hit_effect()

	# Teleport when hit if enabled and off cooldown
	if teleport_on_hit and can_teleport:
		teleport()

	if health <= 0:
		_on_died()

func teleport() -> void:
	if not can_teleport:
		return

	can_teleport = false

	# Calculate random teleport position within range
	var random_angle = randf() * TAU
	var random_distance = randf_range(teleport_range * 0.5, teleport_range)
	var teleport_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance

	var new_position = global_position + teleport_offset

	# Spawn teleport effect at old position
	_spawn_teleport_effect(global_position)

	# Move to new position
	global_position = new_position

	# Spawn teleport effect at new position
	_spawn_teleport_effect(global_position)

	# Start cooldown timer
	var timer = get_node_or_null("TeleportTimer")
	if timer:
		timer.start()
	else:
		# Fallback if no timer
		await get_tree().create_timer(teleport_cooldown).timeout
		can_teleport = true

func _on_teleport_timer_timeout() -> void:
	can_teleport = true

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func _spawn_hit_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.add_child(hit)

func _spawn_teleport_effect(pos: Vector2) -> void:
	# Use death poof as teleport effect for now
	var effect_scene = load("res://scenes/effects/death_poof.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = pos
		effect.modulate = Color(0.5, 0.0, 0.5, 0.8)  # Purple tint for Enderman
		get_tree().current_scene.add_child(effect)

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
		poof.modulate = Color(0.5, 0.0, 0.5)  # Purple tint
		get_tree().current_scene.add_child(poof)

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.add_child(orb)
