extends Area2D
class_name Arrow
## Projectile shot by Archer, damages player on contact

@export var speed: float = 250.0
@export var damage: int = 8
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Setup collision
	collision_layer = 4  # Projectiles
	collision_mask = 1   # Player

	body_entered.connect(_on_body_entered)

	# Start lifetime timer
	var timer = get_node_or_null("LifetimeTimer")
	if timer:
		timer.wait_time = lifetime
		timer.timeout.connect(_on_lifetime_timeout)
		timer.start()
	else:
		await get_tree().create_timer(lifetime).timeout
		queue_free()

	# Rotate sprite to match direction
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()
