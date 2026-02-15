extends CharacterBody2D
class_name SimaYi
## Sima Yi (司马懿) Boss (Wave 25) - Dark flame projectiles and DoT effect
## HP: 500, Damage: 30, Speed: 45

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 3600
@export var health: int = 3600
@export var speed: float = 45.0
@export var contact_damage: int = 25
@export var xp_value: int = 800
@export var emerald_drop: int = 100

# Attack properties
@export var skull_cooldown: float = 2.0
@export var skull_damage: int = 30
@export var skull_speed: float = 200.0
@export var dark_flame_damage: int = 3
@export var dark_flame_duration: float = 5.0

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.35
@export var dark_flame_immune: bool = true

# AI State
enum State { IDLE, SHOOTING }
var _state: State = State.IDLE
var _skull_timer: float = 0.0
var _shoot_burst: int = 0

var target: Node2D = null

# Animation
var _animator = null  # EnemyAnimator instance

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")

	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup animator
	_setup_animator()

	_find_target()


func _setup_animator() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		_animator = EnemyAnimatorClass.new()
		_animator.name = "EnemyAnimator"
		# Sima Yi-specific: floating, ominous motion
		_animator.walk_bob_height = 5.0
		_animator.walk_bob_speed = 0.55
		_animator.walk_tilt_angle = 3.0
		_animator.walk_squash = 0.04
		add_child(_animator)
		_animator.setup(sprite)
		# Sima Yi floats - start animation
		_animator.start_walk_animation()

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

	# Prevent sticking to player - strong separation when too close
	var distance = global_position.distance_to(target.global_position)
	var min_distance = 60.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		var push_strength = (min_distance - distance) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

func _process_idle(_delta: float) -> void:
	# Shoot dark flames when cooldown is ready
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
	_shoot_burst = 3  # Shoot 3 dark flames

	for i in range(_shoot_burst):
		# Play attack animation for each skull
		if _animator:
			_animator.play_attack_animation()
		await get_tree().create_timer(0.3).timeout
		_shoot_skull()

	_state = State.IDLE

func _shoot_skull() -> void:
	if not target or not is_instance_valid(target):
		return

	# Create dark flame projectile
	var direction = (target.global_position - global_position).normalized()

	# Spawn dark flame projectile
	var projectile_scene = load("res://scenes/projectiles/dark_flame.tscn")
	if not projectile_scene:
		# Fallback - just deal damage directly
		_apply_dark_flame_effect()
		return

	var skull = projectile_scene.instantiate()
	skull.global_position = global_position
	skull.direction = direction
	skull.damage = skull_damage
	skull.dot_duration = dark_flame_duration

	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.call_deferred("add_child", skull)

func _apply_dark_flame_effect() -> void:
	if not target or not is_instance_valid(target):
		return

	# Apply dark flame DoT effect
	var status_manager = target.get_node_or_null("StatusEffectManager")
	if status_manager and status_manager.has_method("apply_effect"):
		var StatusEffect = load("res://scripts/components/status_effect.gd")
		if StatusEffect:
			# Dark flame applies poison DoT
			var effect = StatusEffect.new()
			effect.type = StatusEffect.Type.POISON  # Dark flame DoT
			effect.duration = dark_flame_duration
			effect.damage_per_tick = dark_flame_damage
			effect.tick_interval = 1.0
			status_manager.apply_effect(effect)
	else:
		# Direct damage fallback
		if target.has_method("take_damage"):
			target.take_damage(dark_flame_damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
		_apply_dark_flame_effect()

func take_damage(amount: int) -> void:
	var reduced_damage = int(amount * (1.0 - damage_reduction))
	reduced_damage = max(1, reduced_damage)

	health -= reduced_damage
	health_changed.emit(health, max_health)

	# Play hit reaction
	if _animator:
		_animator.play_hit_reaction()

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
	# Clean up animator
	if _animator:
		_animator.reset_to_original()

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
	# Special item drop
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
