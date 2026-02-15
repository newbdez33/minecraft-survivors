extends Area2D
## Dark Flame - Sima Yi boss's projectile attack
## Flies towards target with homing and applies poison effect

@export var speed: float = 250.0
@export var damage: int = 25
@export var lifetime: float = 4.0
@export var dot_duration: float = 3.0
## Homing turn rate in radians/sec (higher = tighter tracking)
@export var homing_strength: float = 2.5

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
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Apply dark flame DoT effect
		_apply_dark_flame_effect(body)
		_spawn_impact_effect()
		queue_free()

func _apply_dark_flame_effect(target: Node) -> void:
	var status_manager = target.get_node_or_null("StatusEffectManager")
	if status_manager and status_manager.has_method("apply_effect"):
		var StatusEffect = load("res://scripts/components/status_effect.gd")
		if StatusEffect:
			var effect = StatusEffect.new()
			effect.type = StatusEffect.Type.POISON
			effect.duration = dot_duration
			effect.damage_per_tick = 3
			effect.tick_interval = 0.5
			status_manager.apply_effect(effect)

func _spawn_impact_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree():
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(0.2, 0.2, 0.2)  # Dark gray for dark flame
		hit.scale = Vector2(1.5, 1.5)
		get_tree().current_scene.call_deferred("add_child", hit)
