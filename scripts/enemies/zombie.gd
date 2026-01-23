extends CharacterBody2D
class_name Zombie
## Basic zombie enemy that chases the player

signal died(xp_value: int)

@export var speed: float = 60.0
@export var damage: int = 10
@export var xp_value: int = 5
@export var health: int = 20

var target: Node2D = null
var _health_component: Node = null

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

func _physics_process(_delta: float) -> void:
	if not target:
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
	if hit_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.add_child(hit)

func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_xp_orb()
	queue_free()

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.add_child(orb)

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		get_tree().current_scene.add_child(poof)
