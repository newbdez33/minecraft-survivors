extends Node2D
class_name Crossbow
## Evolved Bow - piercing shots that hit multiple enemies

signal bolt_fired(bolt: Node2D)

@export var damage: int = 20
@export var attack_speed: float = 3.33  # ~0.3s cooldown (1.0 / 3.33)
@export var range: float = 400.0
@export var bolt_speed: float = 600.0
@export var pierce_count: int = 3  # How many enemies one bolt can hit
@export var level: int = 1
@export var hand_offset: float = 24.0  # Distance from player center

var _cooldown_timer: float = 0.0
var _can_attack: bool = true
var _bolt_scene: PackedScene
var _current_facing: Vector2 = Vector2.RIGHT
var _managed_by_slots: bool = false

# Enemy caching to avoid expensive group queries every frame
var _cached_enemies: Array = []
var _enemy_cache_timer: float = 0.0
const ENEMY_CACHE_INTERVAL: float = 0.1  # Refresh every 100ms

# Level scaling
const DAMAGE_PER_LEVEL: int = 5
const PIERCE_PER_LEVEL: int = 1
const RANGE_PER_LEVEL: float = 30.0

func _ready() -> void:
	_bolt_scene = load("res://scenes/projectiles/crossbow_bolt.tscn")
	_update_weapon_position()

func _process(delta: float) -> void:
	if not _can_attack:
		_cooldown_timer += delta
		if _cooldown_timer >= 1.0 / attack_speed:
			_can_attack = true
			_cooldown_timer = 0.0

	# Update enemy cache periodically instead of every frame
	_enemy_cache_timer += delta
	if _enemy_cache_timer >= ENEMY_CACHE_INTERVAL:
		_enemy_cache_timer = 0.0
		_cached_enemies = get_tree().get_nodes_in_group("enemies")

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
	var nearest: Node2D = null
	var min_dist: float = range

	for enemy in _cached_enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	return nearest

func _fire_at(target: Node2D) -> void:
	if not _bolt_scene:
		return

	_can_attack = false

	var bolt = _bolt_scene.instantiate()

	# Spawn bolt from sprite position (where crossbow visually is)
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		bolt.global_position = global_position + sprite.position
	else:
		bolt.global_position = global_position

	bolt.damage = get_total_damage()
	bolt.speed = bolt_speed
	bolt.pierce_count = get_total_pierce()

	var direction = (target.global_position - bolt.global_position).normalized()
	bolt.set_direction(direction)

	get_tree().current_scene.add_child(bolt)
	bolt_fired.emit(bolt)

func get_total_damage() -> int:
	return damage + (level - 1) * DAMAGE_PER_LEVEL

func get_total_pierce() -> int:
	return pierce_count + (level - 1) * PIERCE_PER_LEVEL

func get_total_range() -> float:
	return range + (level - 1) * RANGE_PER_LEVEL

func upgrade() -> void:
	level += 1
	range = get_total_range()

func _update_weapon_position() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.position = _current_facing * hand_offset
		# Z-index: in front when facing down, behind when facing up
		sprite.z_index = 1 if _current_facing.y > 0 else -1
