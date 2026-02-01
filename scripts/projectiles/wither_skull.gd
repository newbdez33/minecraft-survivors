extends Area2D
## Wither Skull - Wither boss's projectile attack
## Flies towards target and applies wither/poison effect

@export var speed: float = 250.0
@export var damage: int = 25
@export var lifetime: float = 4.0
@export var wither_duration: float = 3.0

var direction: Vector2 = Vector2.RIGHT

var _lifetime_timer: SceneTreeTimer = null

func _ready() -> void:
	collision_layer = 4  # projectiles
	collision_mask = 1   # player
	body_entered.connect(_on_body_entered)

	# Auto-destroy after lifetime using scene tree timer (auto-cleanup)
	_lifetime_timer = get_tree().create_timer(lifetime)
	_lifetime_timer.timeout.connect(_on_lifetime_expired)


func _on_lifetime_expired() -> void:
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	# Rotate sprite to face direction
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Apply wither/poison effect
		_apply_wither_effect(body)
		_spawn_impact_effect()
		queue_free()

func _apply_wither_effect(target: Node) -> void:
	var status_manager = target.get_node_or_null("StatusEffectManager")
	if status_manager and status_manager.has_method("apply_effect"):
		var StatusEffect = load("res://scripts/components/status_effect.gd")
		if StatusEffect:
			var effect = StatusEffect.new()
			effect.type = StatusEffect.Type.POISON
			effect.duration = wither_duration
			effect.damage_per_tick = 3
			effect.tick_interval = 0.5
			status_manager.apply_effect(effect)

func _spawn_impact_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree():
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(0.2, 0.2, 0.2)  # Dark gray for wither
		hit.scale = Vector2(1.5, 1.5)
		get_tree().current_scene.call_deferred("add_child", hit)
