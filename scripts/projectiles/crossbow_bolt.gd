extends Area2D
class_name CrossbowBolt
## Piercing projectile that can hit multiple enemies

signal enemy_hit(enemy: Node2D, damage: int)

@export var damage: int = 20
@export var speed: float = 600.0
@export var lifetime: float = 3.0
@export var pierce_count: int = 3

var _direction: Vector2 = Vector2.RIGHT
var _lifetime_timer: float = 0.0
var _hit_enemies: Array = []  # Track which enemies we've already hit

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position += _direction * speed * delta
	rotation = _direction.angle()

	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		queue_free()

func set_direction(dir: Vector2) -> void:
	_direction = dir.normalized()
	rotation = _direction.angle()

func _on_body_entered(body: Node2D) -> void:
	_try_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent():
		_try_hit(area.get_parent())

func _try_hit(target: Node) -> void:
	if not target.is_in_group("enemies"):
		return

	# Skip if already hit this enemy
	if target in _hit_enemies:
		return

	_hit_enemies.append(target)
	enemy_hit.emit(target, damage)

	if target.has_method("take_damage"):
		target.take_damage(damage)

	# Check if we've hit max enemies
	if _hit_enemies.size() >= pierce_count:
		queue_free()
