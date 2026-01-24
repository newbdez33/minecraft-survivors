extends Area2D
class_name PlayerArrow
## Projectile shot by player's Bow weapon, damages enemies on contact

@export var speed: float = 400.0
@export var damage: int = 8
@export var lifetime: float = 3.0
@export var piercing: bool = false
@export var max_pierce: int = 1
@export var knockback: float = 50.0

var direction: Vector2 = Vector2.RIGHT
var _pierce_count: int = 0
var _hit_enemies: Array = []

func _ready() -> void:
	# Setup collision - targets enemies
	collision_layer = 8  # Player projectiles
	collision_mask = 2   # Enemies

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Rotate to face direction
	rotation = direction.angle()

	# Lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	_try_damage(body)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent:
		_try_damage(parent)

func _try_damage(target: Node) -> void:
	if target in _hit_enemies:
		return

	if target.is_in_group("enemies"):
		_hit_enemies.append(target)

		if target.has_method("take_damage"):
			target.take_damage(damage)

		# Apply knockback
		if knockback > 0 and target is CharacterBody2D:
			target.velocity += direction * knockback

		_pierce_count += 1

		if not piercing or _pierce_count >= max_pierce:
			_spawn_hit_effect()
			queue_free()

func _spawn_hit_effect() -> void:
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)

func _exit_tree() -> void:
	_hit_enemies.clear()
