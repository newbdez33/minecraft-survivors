extends Area2D
## Dragon Fireball - Ender Dragon's ranged attack
## Flies towards target with homing and deals damage on impact

@export var speed: float = 300.0
@export var damage: int = 35
@export var lifetime: float = 3.0
## Homing turn rate in radians/sec (gentler than wither skull since faster)
@export var homing_strength: float = 1.8

var direction: Vector2 = Vector2.RIGHT

var _lifetime_timer: SceneTreeTimer = null
var _target: Node2D = null

func _ready() -> void:
	collision_layer = 4  # projectiles
	collision_mask = 1   # player
	body_entered.connect(_on_body_entered)

	# Find player target for homing
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

	# Auto-destroy after lifetime using scene tree timer (auto-cleanup)
	_lifetime_timer = get_tree().create_timer(lifetime)
	_lifetime_timer.timeout.connect(_on_lifetime_expired)


func _on_lifetime_expired() -> void:
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	# Steer toward player
	if is_instance_valid(_target):
		var desired = (_target.global_position - global_position).normalized()
		var current_angle = direction.angle()
		var desired_angle = desired.angle()
		var angle_diff = angle_difference(current_angle, desired_angle)
		var max_turn = homing_strength * delta
		var turn = clampf(angle_diff, -max_turn, max_turn)
		direction = Vector2.from_angle(current_angle + turn)

	position += direction * speed * delta
	# Rotate sprite to face direction
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		_spawn_impact_effect()
		queue_free()

func _spawn_impact_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree():
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(1.0, 0.5, 0.0)  # Orange for dragon fire
		hit.scale = Vector2(2, 2)
		get_tree().current_scene.call_deferred("add_child", hit)
