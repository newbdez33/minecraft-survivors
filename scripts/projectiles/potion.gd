extends Area2D
class_name Potion
## Projectile thrown by Witch, damages player on contact

@export var speed: float = 200.0
@export var damage: int = 12
@export var lifetime: float = 2.0
@export var splash_radius: float = 60.0

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

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	# Slight rotation for visual effect
	rotation += delta * 3.0

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		explode()

func _on_lifetime_timeout() -> void:
	queue_free()

func explode() -> void:
	# Damage player if in splash radius
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if global_position.distance_to(player.global_position) <= splash_radius:
			if player.has_method("take_damage"):
				player.take_damage(damage)

	_spawn_splash_effect()
	queue_free()

func _spawn_splash_effect() -> void:
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color(0.3, 0.8, 0.3)  # Green tint for potion
		get_tree().current_scene.add_child(effect)
