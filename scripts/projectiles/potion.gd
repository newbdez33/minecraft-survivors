extends Area2D
class_name Potion
## Projectile thrown by Witch, lands near player and creates poison cloud

@export var speed: float = 200.0
@export var damage: int = 5
@export var lifetime: float = 2.0

# Poison cloud properties
@export var cloud_duration: float = 5.0
@export var cloud_size: float = 80.0  # Circle diameter
@export var poison_duration: float = 3.0
@export var poison_damage_per_tick: int = 2
@export var poison_tick_interval: float = 0.5

var direction: Vector2 = Vector2.RIGHT
var _target_position: Vector2 = Vector2.ZERO
var _has_landed: bool = false

func _ready() -> void:
	# Setup collision - no direct player collision, lands at target
	collision_layer = 4  # Projectiles
	collision_mask = 0   # No collision, lands at target position

	# Start lifetime timer (time to reach target)
	var timer = get_node_or_null("LifetimeTimer")
	if timer:
		timer.wait_time = lifetime
		timer.timeout.connect(_on_lifetime_timeout)
		timer.start()
	else:
		await get_tree().create_timer(lifetime).timeout
		_land()

func _physics_process(delta: float) -> void:
	if _has_landed:
		return

	position += direction * speed * delta

	# Slight rotation for visual effect
	rotation += delta * 3.0

	# Check if reached target position
	if _target_position != Vector2.ZERO:
		if global_position.distance_to(_target_position) < 20:
			_land()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func set_target(target_pos: Vector2) -> void:
	_target_position = target_pos

func _on_lifetime_timeout() -> void:
	if not _has_landed:
		_land()

func _land() -> void:
	if _has_landed:
		return
	_has_landed = true

	# Spawn poison cloud at landing position
	_spawn_poison_cloud()
	queue_free()

func _spawn_poison_cloud() -> void:
	var cloud_scene = load("res://scenes/effects/poison_cloud.tscn")
	if cloud_scene:
		var cloud = cloud_scene.instantiate()
		cloud.global_position = global_position
		cloud.duration = cloud_duration
		cloud.size = cloud_size
		cloud.poison_duration = poison_duration
		cloud.poison_damage_per_tick = poison_damage_per_tick
		cloud.poison_tick_interval = poison_tick_interval
		cloud.cloud_damage = damage
		get_tree().current_scene.add_child(cloud)
