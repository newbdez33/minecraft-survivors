extends CharacterBody2D
class_name Zombie
## Basic zombie enemy that chases the player

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

	if not target:
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

	# Prevent sticking to player - add separation when too close
	var distance_to_player = global_position.distance_to(target.global_position)
	var min_distance = 30.0  # Minimum distance to maintain from player
	if distance_to_player < min_distance and distance_to_player > 0:
		# Push away from player slightly to prevent sticking
		var push_direction = (global_position - target.global_position).normalized()
		velocity += push_direction * (min_distance - distance_to_player) * 5.0

	move_and_slide()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Damage player on contact
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	if _health_component:
		_health_component.take_damage(amount)
		health = _health_component.current_health
	else:
		health -= amount
		if health <= 0:
			_on_died()

	# Spawn hit effect
	_spawn_hit_effect()

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
