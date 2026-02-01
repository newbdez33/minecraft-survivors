extends CharacterBody2D
class_name Wither
## Wither Boss (Wave 25) - Skull projectiles and wither effect
## HP: 500, Damage: 30, Speed: 45

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 1200
@export var health: int = 1200
@export var speed: float = 45.0
@export var contact_damage: int = 25
@export var xp_value: int = 200
@export var emerald_drop: int = 100

# Attack properties
@export var skull_cooldown: float = 2.0
@export var skull_damage: int = 30
@export var skull_speed: float = 200.0
@export var wither_effect_damage: int = 3
@export var wither_effect_duration: float = 5.0

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.35
@export var wither_immune: bool = true

# AI State
enum State { IDLE, SHOOTING }
var _state: State = State.IDLE
var _skull_timer: float = 0.0
var _shoot_burst: int = 0

var target: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")

	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	_find_target()

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
		return

	_skull_timer += delta

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.SHOOTING:
			pass

	move_and_slide()

func _process_idle(_delta: float) -> void:
	# Shoot skulls when cooldown is ready
	if _skull_timer >= skull_cooldown:
		_start_skull_attack()
		return

	# Float toward player
	var direction = (target.global_position - global_position).normalized()
	var distance = global_position.distance_to(target.global_position)

	if distance > 200:
		velocity = direction * speed
	else:
		# Maintain distance while circling
		velocity = direction.orthogonal() * speed * 0.6

func _start_skull_attack() -> void:
	_state = State.SHOOTING
	_skull_timer = 0.0
	_shoot_burst = 3  # Shoot 3 skulls

	for i in range(_shoot_burst):
		await get_tree().create_timer(0.3).timeout
		_shoot_skull()

	_state = State.IDLE

func _shoot_skull() -> void:
	if not target or not is_instance_valid(target):
		return

	# Create skull projectile
	var direction = (target.global_position - global_position).normalized()

	# Spawn visual effect as projectile
	var projectile_scene = load("res://scenes/projectiles/wither_skull.tscn")
	if not projectile_scene:
		# Fallback - just deal damage directly
		_apply_wither_effect()
		return

	var skull = projectile_scene.instantiate()
	skull.global_position = global_position
	skull.direction = direction
	skull.damage = skull_damage
	skull.wither_duration = wither_effect_duration

	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.call_deferred("add_child", skull)

func _apply_wither_effect() -> void:
	if not target or not is_instance_valid(target):
		return

	# Apply wither DoT effect
	var status_manager = target.get_node_or_null("StatusEffectManager")
	if status_manager and status_manager.has_method("apply_effect"):
		var StatusEffect = load("res://scripts/components/status_effect.gd")
		if StatusEffect:
			# Wither is similar to poison but darker (uses Type.WITHER if exists, else POISON)
			var effect = StatusEffect.new()
			effect.type = StatusEffect.Type.POISON  # Could add WITHER type
			effect.duration = wither_effect_duration
			effect.damage_per_tick = wither_effect_damage
			effect.tick_interval = 1.0
			status_manager.apply_effect(effect)
	else:
		# Direct damage fallback
		if target.has_method("take_damage"):
			target.take_damage(wither_effect_damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
		_apply_wither_effect()

func take_damage(amount: int) -> void:
	var reduced_damage = int(amount * (1.0 - damage_reduction))
	reduced_damage = max(1, reduced_damage)

	health -= reduced_damage
	health_changed.emit(health, max_health)

	_spawn_hit_effect()

	if health <= 0:
		_on_died()

func apply_knockback(_force: Vector2) -> void:
	if knockback_immune:
		return

func _spawn_hit_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(0.2, 0.2, 0.2)  # Dark
		get_tree().current_scene.call_deferred("add_child", hit)

func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_drops()
	queue_free()

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		for i in range(6):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-35, 35), randf_range(-35, 35))
			poof.global_position = global_position + offset
			poof.modulate = Color(0.3, 0.3, 0.3)
			poof.scale = Vector2(2.2, 2.2)
			get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_drops() -> void:
	_spawn_xp_orbs()
	_spawn_emeralds()
	# Nether Star drop (special item)
	if randf() < 0.2:
		_spawn_special_drop()

func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree():
		return

	var orbs_to_spawn = 10
	var xp_per_orb = xp_value / orbs_to_spawn

	for i in range(orbs_to_spawn):
		var orb = xp_scene.instantiate()
		var offset = Vector2(randf_range(-45, 45), randf_range(-45, 45))
		orb.global_position = global_position + offset
		orb.xp_value = xp_per_orb
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_emeralds() -> void:
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if not emerald_scene or not get_tree():
		return

	var emeralds_to_spawn = 8
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-55, 55), randf_range(-55, 55))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)

func _spawn_special_drop() -> void:
	var totem_scene = load("res://scenes/pickups/totem_pickup.tscn")
	if totem_scene and get_tree():
		var totem = totem_scene.instantiate()
		totem.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", totem)
