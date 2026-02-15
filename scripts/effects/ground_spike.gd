extends Area2D
class_name GroundSpike
## Ground Spike (地刺) attack - Shows warning, then damages player

signal hit_player(damage: int)

@export var damage: int = 15
@export var lifetime: float = 0.5
@export var warning_duration: float = 0.5

var _warning_active: bool = true
var _timer: float = 0.0
var _has_damaged: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Setup collision for player detection
	collision_layer = 0
	collision_mask = 1  # Player layer

	body_entered.connect(_on_body_entered)

	# Start in warning state (semi-transparent)
	if sprite:
		sprite.modulate.a = 0.3

	# Disable collision during warning
	if collision:
		collision.disabled = true


func _process(delta: float) -> void:
	_timer += delta

	if _warning_active:
		# Warning phase - pulsing effect
		if sprite:
			var pulse = 0.3 + 0.2 * sin(_timer * 15.0)
			sprite.modulate.a = pulse

		# End warning phase
		if _timer >= warning_duration:
			_warning_active = false
			_timer = 0.0
			_activate_fang()
	else:
		# Active damage phase
		if sprite:
			sprite.modulate.a = 1.0

		# Destroy after lifetime
		if _timer >= lifetime:
			_destroy()


func _activate_fang() -> void:
	# Enable collision
	if collision:
		collision.disabled = false

	# Play activation effect
	_spawn_activation_effect()


func _on_body_entered(body: Node2D) -> void:
	if _warning_active or _has_damaged:
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		hit_player.emit(damage)
		_has_damaged = true


func _spawn_activation_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		var effect = hit_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color(0.6, 0.0, 0.8)  # Purple
		effect.scale = Vector2(0.8, 0.8)
		get_tree().current_scene.add_child(effect)


func _destroy() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
