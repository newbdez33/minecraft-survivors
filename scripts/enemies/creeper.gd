extends CharacterBody2D
class_name Creeper
## Explosive enemy that detonates when near player

signal died(xp_value: int)

@export var speed: float = 50.0
@export var health: int = 25
@export var xp_value: int = 10
@export var explosion_damage: int = 30
@export var explosion_radius: float = 80.0
@export var fuse_time: float = 1.5
@export var trigger_distance: float = 40.0

var target: Node2D = null
var is_fusing: bool = false
var _fuse_elapsed: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
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

	if is_fusing:
		# Flash while fusing
		_fuse_elapsed += delta
		_flash_sprite()

		if _fuse_elapsed >= fuse_time:
			explode()
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Start fuse when close
	if distance <= trigger_distance:
		start_fuse()

func start_fuse() -> void:
	if is_fusing:
		return

	is_fusing = true
	_fuse_elapsed = 0.0

	# Start fuse timer
	var timer = get_node_or_null("FuseTimer")
	if timer:
		timer.wait_time = fuse_time
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
	_spawn_explosion_effect()
	_spawn_xp_orb()

	died.emit(xp_value)
	queue_free()

func _spawn_explosion_effect() -> void:
	var explosion_scene = load("res://scenes/effects/explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
	else:
		# Fallback to death poof
		var death_scene = load("res://scenes/effects/death_poof.tscn")
		if death_scene:
			var poof = death_scene.instantiate()
			poof.global_position = global_position
			poof.scale = Vector2(2, 2)
			get_tree().current_scene.add_child(poof)

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
	# Die without exploding
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
