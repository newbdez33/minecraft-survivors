extends CharacterBody2D
class_name Vex
## Vex - Flying minion summoned by Evoker
## Can pass through walls, has limited lifetime

signal died(xp_value: int)

@export var health: int = 10
@export var damage: int = 8
@export var speed: float = 120.0
@export var xp_value: int = 3
@export var lifetime: float = 15.0
@export var can_pass_walls: bool = true

var target: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0
var _lifetime_timer: float = 0.0
var _flicker_timer: float = 0.0
var _is_fading: bool = false

func _ready() -> void:
	add_to_group("enemies")

	# Vex can pass through walls - disable collision with environment
	if can_pass_walls:
		collision_mask = 1  # Only collide with player

	# Connect hitbox
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Find player
	_find_target()


func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]


func _physics_process(delta: float) -> void:
	# Update lifetime
	_lifetime_timer += delta

	# Start flickering when close to expiring (last 3 seconds)
	if _lifetime_timer >= lifetime - 3.0 and not _is_fading:
		_is_fading = true

	if _is_fading:
		_flicker_timer += delta
		# Flicker effect
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate.a = 0.4 + 0.4 * sin(_flicker_timer * 15.0)

	# Expire after lifetime
	if _lifetime_timer >= lifetime:
		_on_died()
		return

	# Apply knockback decay
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		return

	if not target or not is_instance_valid(target):
		_find_target()
		return

	# Chase player directly (can fly through obstacles)
	var direction = (target.global_position - global_position).normalized()

	# Add slight wobble for flying effect
	var wobble = Vector2(sin(_lifetime_timer * 8.0), cos(_lifetime_timer * 6.0)) * 20.0
	velocity = direction * speed + wobble

	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)


func take_damage(amount: int) -> void:
	health -= amount
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
		hit.modulate = Color(0.5, 0.7, 0.9)  # Light blue tint
		hit.scale = Vector2(0.6, 0.6)
		get_tree().current_scene.call_deferred("add_child", hit)


func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_xp_orb()
	queue_free()


func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		poof.modulate = Color(0.6, 0.7, 0.9)  # Light blue tint
		poof.scale = Vector2(0.7, 0.7)
		get_tree().current_scene.call_deferred("add_child", poof)


func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene and get_tree() and get_tree().current_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.call_deferred("add_child", orb)
