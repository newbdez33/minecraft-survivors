extends Area2D
class_name SwordBase
## Base class for all sword tiers with evolution support

signal attacked(enemies_hit: int)
signal evolved(new_tier: int)

enum Tier { WOOD = 1, STONE = 2, IRON = 3, DIAMOND = 4 }

# Tier configurations - Minecraft authentic colors
const TIER_CONFIG = {
	Tier.WOOD: {
		"name": "Wood Sword",
		"damage": 5,
		"attack_range": 60.0,
		"attack_cooldown": 1.2,
		"color": Color(0.53, 0.40, 0.15),  # #866526 Wood brown
		"kills_to_evolve": 50
	},
	Tier.STONE: {
		"name": "Stone Sword",
		"damage": 8,
		"attack_range": 70.0,
		"attack_cooldown": 1.0,
		"color": Color(0.55, 0.55, 0.55),  # #8B8B8B Stone gray
		"kills_to_evolve": 150
	},
	Tier.IRON: {
		"name": "Iron Sword",
		"damage": 12,
		"attack_range": 80.0,
		"attack_cooldown": 0.9,
		"color": Color(0.85, 0.85, 0.85),  # #D8D8D8 Iron silver
		"kills_to_evolve": 400
	},
	Tier.DIAMOND: {
		"name": "Diamond Sword",
		"damage": 15,
		"attack_range": 90.0,
		"attack_cooldown": 0.8,
		"color": Color(0.18, 0.80, 0.69),  # #2DCDB0 Diamond cyan
		"kills_to_evolve": -1  # Max tier
	}
}

@export var current_tier: Tier = Tier.WOOD
@export var show_range_indicator: bool = true
@export var knockback: float = 0.0
@export var hand_offset: float = 24.0
@export var level: int = 1

var damage: int = 5
var attack_range: float = 60.0
var attack_cooldown: float = 1.2

var can_attack: bool = true
var enemies_in_range: Array = []
var current_facing: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var kill_count: int = 0

# Fast evolution mode for testing - if > 0, overrides kills_to_evolve
var fast_evolution_threshold: int = 0

# Level scaling (like bow)
const DAMAGE_PER_LEVEL: int = 2
const RANGE_PER_LEVEL: float = 5.0
const COOLDOWN_REDUCTION_PER_LEVEL: float = 0.05
const LEVELS_PER_TIER: int = 3  # Evolve tier every 3 levels

# Evolution bonus - extra stats when evolving to new tier
const EVOLUTION_BONUS = {
	Tier.STONE: {"damage": 5, "range": 15.0, "cooldown_reduction": 0.1},
	Tier.IRON: {"damage": 8, "range": 20.0, "cooldown_reduction": 0.15},
	Tier.DIAMOND: {"damage": 12, "range": 25.0, "cooldown_reduction": 0.2}
}

# Accumulated evolution bonuses
var evolution_damage_bonus: int = 0
var evolution_range_bonus: float = 0.0
var evolution_cooldown_bonus: float = 0.0

var range_color: Color = Color(0.3, 0.7, 1.0, 0.08)
var range_border_color: Color = Color(0.4, 0.8, 1.0, 0.25)

# Whether position is managed by WeaponSlots
var _managed_by_slots: bool = false

func _ready() -> void:
	# Apply tier stats
	_apply_tier_stats()

	# Setup collision
	collision_layer = 0
	collision_mask = 2

	# Sync collision shape
	_update_collision_shape()

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.timeout.connect(_on_attack_timer_timeout)

	_update_sword_position()
	queue_redraw()

func _apply_tier_stats() -> void:
	var config = TIER_CONFIG[current_tier]
	damage = config.damage
	attack_range = config.attack_range
	attack_cooldown = config.attack_cooldown

	# Update timer
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.wait_time = attack_cooldown

	# Load the correct SVG for this tier (no color tinting)
	_update_sword_sprite()

func _update_collision_shape() -> void:
	var shape = get_node_or_null("CollisionShape2D")
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = attack_range

func _physics_process(_delta: float) -> void:
	# Remove invalid enemies in-place (iterate backwards to avoid index issues)
	for i in range(enemies_in_range.size() - 1, -1, -1):
		if not is_instance_valid(enemies_in_range[i]):
			enemies_in_range.remove_at(i)

	if can_attack and enemies_in_range.size() > 0:
		_perform_attack()

func _perform_attack() -> void:
	can_attack = false

	var hit_count = 0
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			hit_count += 1

			if knockback > 0:
				var direction = (enemy.global_position - global_position).normalized()
				if enemy.has_method("apply_knockback"):
					enemy.apply_knockback(direction * knockback)
				elif enemy is CharacterBody2D:
					enemy.velocity = direction * knockback

	if hit_count > 0:
		attacked.emit(hit_count)
		_play_attack_animation()

	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.start()
	else:
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _play_attack_animation() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite or is_attacking:
		return

	is_attacking = true
	var start_angle = current_facing.angle()
	var sweep_duration = 0.3

	# Sweeping attack - rotate sword around player
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Sweep 360 degrees around the player
	tween.tween_method(_sweep_sword.bind(sprite, start_angle), 0.0, 1.0, sweep_duration)
	tween.tween_callback(_finish_attack)

func _sweep_sword(progress: float, sprite: Sprite2D, start_angle: float) -> void:
	var angle = start_angle + progress * TAU
	sprite.position = Vector2.from_angle(angle) * hand_offset
	sprite.rotation = angle + PI / 4
	sprite.flip_v = cos(angle) < 0
	sprite.z_index = 11 if sin(angle) > 0 else -1

func _finish_attack() -> void:
	is_attacking = false
	_update_sword_position()

func _process(_delta: float) -> void:
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
				current_facing = parent.velocity.normalized()
				_update_sword_position()

func _update_sword_position() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.position = current_facing * hand_offset
		sprite.rotation = current_facing.angle() + PI / 4
		if current_facing.x < 0:
			sprite.flip_v = true
			sprite.z_index = 11
		else:
			sprite.flip_v = false
			sprite.z_index = -1

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)

func _draw() -> void:
	if show_range_indicator:
		draw_circle(Vector2.ZERO, attack_range, range_color)
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, range_border_color, 3.0, true)

## Called when an enemy is killed - track kills only (no auto evolution)
func on_enemy_killed() -> void:
	kill_count += 1

func evolve() -> void:
	if current_tier == Tier.DIAMOND:
		return

	current_tier = (current_tier + 1) as Tier
	kill_count = 0

	# Apply evolution bonus for new tier
	if current_tier in EVOLUTION_BONUS:
		var bonus = EVOLUTION_BONUS[current_tier]
		evolution_damage_bonus += bonus.damage
		evolution_range_bonus += bonus.range
		evolution_cooldown_bonus += bonus.cooldown_reduction
		print("[SWORD] Evolution bonus applied! +%d damage, +%.0f range, -%.0f%% cooldown" % [bonus.damage, bonus.range, bonus.cooldown_reduction * 100])

	_apply_tier_stats()
	_update_collision_shape()
	_update_sword_sprite()
	queue_redraw()

	evolved.emit(current_tier)
	_play_evolution_effect()

func _update_sword_sprite() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		print("[SWORD] ERROR: Sprite2D not found!")
		return

	# Load the correct SVG for each tier
	var texture_path = ""
	match current_tier:
		Tier.WOOD:
			texture_path = "res://assets/weapons/wood_sword.svg"
		Tier.STONE:
			texture_path = "res://assets/weapons/stone_sword.svg"
		Tier.IRON:
			texture_path = "res://assets/weapons/iron_sword.svg"
		Tier.DIAMOND:
			texture_path = "res://assets/weapons/diamond_sword.svg"

	print("[SWORD] Updating sprite to tier %d: %s" % [current_tier, texture_path])
	var texture = load(texture_path)
	if texture:
		sprite.texture = texture
		print("[SWORD] Texture loaded successfully!")
	else:
		print("[SWORD] ERROR: Failed to load texture: %s" % texture_path)
	sprite.modulate = Color.WHITE  # No color tinting

func _play_evolution_effect() -> void:
	# Flash effect
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var original_modulate = sprite.modulate
		var original_scale = sprite.scale
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(sprite, "modulate", original_modulate, 0.2)
		tween.tween_property(sprite, "scale", original_scale * 1.25, 0.1)
		tween.tween_property(sprite, "scale", original_scale, 0.2)

func get_tier_name() -> String:
	return TIER_CONFIG[current_tier].name

func get_kills_to_next_tier() -> int:
	if current_tier == Tier.DIAMOND:
		return -1
	return TIER_CONFIG[current_tier].kills_to_evolve - kill_count

func set_tier(tier: Tier) -> void:
	current_tier = tier
	kill_count = 0
	_apply_tier_stats()
	_update_collision_shape()
	_update_sword_sprite()
	queue_redraw()

## Level-based upgrade (like bow)
func upgrade() -> void:
	level += 1

	# Apply level bonuses
	damage = get_total_damage()
	attack_range = get_total_range()
	attack_cooldown = get_total_cooldown()

	# Update collision shape
	_update_collision_shape()

	# Update timer
	var timer = get_node_or_null("AttackTimer")
	if timer:
		timer.wait_time = attack_cooldown

	queue_redraw()

	# Check for tier evolution at levels 4, 7, 10 (matching upgrade_manager expectations)
	if level in [4, 7, 10] and current_tier < Tier.DIAMOND:
		evolve()

func get_total_damage() -> int:
	var base = TIER_CONFIG[current_tier].damage
	return base + (level - 1) * DAMAGE_PER_LEVEL + evolution_damage_bonus

func get_total_range() -> float:
	var base = TIER_CONFIG[current_tier].attack_range
	return base + (level - 1) * RANGE_PER_LEVEL + evolution_range_bonus

func get_total_cooldown() -> float:
	var base = TIER_CONFIG[current_tier].attack_cooldown
	var reduction = (level - 1) * COOLDOWN_REDUCTION_PER_LEVEL + evolution_cooldown_bonus
	return max(0.2, base * (1.0 - reduction))  # Min 0.2s cooldown

## Get evolution bonus for next tier (for UI display)
func get_next_evolution_bonus() -> Dictionary:
	var next_tier = (current_tier + 1) as Tier
	if next_tier in EVOLUTION_BONUS:
		return EVOLUTION_BONUS[next_tier]
	return {}
