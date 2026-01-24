extends Node2D
class_name Bow
## Ranged weapon that shoots arrows at enemies

signal arrow_fired(arrow: Node2D)
signal evolved_to_crossbow

@export var damage: int = 8
@export var attack_speed: float = 1.0  # Arrows per second
@export var range: float = 300.0
@export var arrow_speed: float = 400.0
@export var level: int = 1
@export var hand_offset: float = 24.0  # Distance from player center

const MAX_LEVEL: int = 4  # Level 4 = evolve to Crossbow

var _cooldown_timer: float = 0.0
var _can_attack: bool = true
var _arrow_scene: PackedScene
var _current_facing: Vector2 = Vector2.RIGHT
var _managed_by_slots: bool = false

# Level scaling
const DAMAGE_PER_LEVEL: int = 3
const SPEED_PER_LEVEL: float = 0.15
const RANGE_PER_LEVEL: float = 25.0

func _ready() -> void:
	_arrow_scene = load("res://scenes/projectiles/player_arrow.tscn")
	_update_weapon_position()

func _process(delta: float) -> void:
	if not _can_attack:
		_cooldown_timer += delta
		if _cooldown_timer >= 1.0 / attack_speed:
			_can_attack = true
			_cooldown_timer = 0.0

	# Check if managed by weapon slots
	if not _managed_by_slots:
		var parent = get_parent()
		if parent:
			var weapon_slots = parent.get_node_or_null("WeaponSlots")
			if weapon_slots:
				_managed_by_slots = true

	# Only update position if not managed by WeaponSlots
	if not _managed_by_slots:
		var parent = get_parent()
		if parent and parent is CharacterBody2D:
			if parent.velocity.length() > 10:
				_current_facing = parent.velocity.normalized()
				_update_weapon_position()

	# Auto-attack nearest enemy in range
	var target = _find_nearest_enemy()
	if target:
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			# Calculate direction from sprite's visual position
			var sprite_global_pos = global_position + sprite.position
			var direction = (target.global_position - sprite_global_pos).normalized()
			sprite.rotation = direction.angle() + PI  # Rotate 180 degrees
			# Flip sprite when facing left
			sprite.flip_v = direction.x < 0

		if _can_attack:
			_fire_at(target)

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var min_dist: float = range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	return nearest

func _fire_at(target: Node2D) -> void:
	if not _arrow_scene:
		return

	_can_attack = false

	var arrow = _arrow_scene.instantiate()

	# Spawn arrow from sprite position (where bow visually is)
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		arrow.global_position = global_position + sprite.position
	else:
		arrow.global_position = global_position

	arrow.damage = get_total_damage()
	arrow.speed = arrow_speed

	var direction = (target.global_position - arrow.global_position).normalized()
	arrow.set_direction(direction)

	get_tree().current_scene.add_child(arrow)
	arrow_fired.emit(arrow)

func get_total_damage() -> int:
	return damage + (level - 1) * DAMAGE_PER_LEVEL

func get_total_attack_speed() -> float:
	return attack_speed + (level - 1) * SPEED_PER_LEVEL

func get_total_range() -> float:
	return range + (level - 1) * RANGE_PER_LEVEL

func upgrade() -> void:
	level += 1
	range = get_total_range()
	attack_speed = get_total_attack_speed()

	# Evolution at level 4 -> Crossbow
	if level >= MAX_LEVEL:
		evolved_to_crossbow.emit()

func can_evolve() -> bool:
	return level >= MAX_LEVEL - 1  # At level 3, next upgrade will evolve

func _update_weapon_position() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.position = _current_facing * hand_offset
		# Z-index: in front when facing down, behind when facing up
		sprite.z_index = 1 if _current_facing.y > 0 else -1
