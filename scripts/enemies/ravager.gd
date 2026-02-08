extends CharacterBody2D
class_name Ravager
## Ravager Boss (Wave 15) - Charge and stomp attacks
## HP: 200, Damage: 25, Speed: 50

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 800
@export var health: int = 800
@export var speed: float = 50.0
@export var contact_damage: int = 30
@export var xp_value: int = 100
@export var emerald_drop: int = 50

# Attack properties
@export var charge_cooldown: float = 5.0
@export var charge_speed: float = 300.0
@export var charge_damage: int = 50
@export var stomp_cooldown: float = 3.0
@export var stomp_damage: int = 40
@export var stomp_radius: float = 120.0

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.25

# AI State
enum State { IDLE, CHARGE_WINDUP, CHARGING, STOMPING }
var _state: State = State.IDLE
var _charge_timer: float = 0.0
var _stomp_timer: float = 0.0
var _charge_direction: Vector2 = Vector2.ZERO
var _charge_time_remaining: float = 0.0
var _charge_hit: bool = false

var target: Node2D = null

# Animation
var _animator = null  # EnemyAnimator instance
var _was_moving: bool = false

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
		# Ravager-specific: heavy stomping walk
		_animator.walk_bob_height = 6.0
		_animator.walk_bob_speed = 0.35
		_animator.walk_tilt_angle = 5.0
		_animator.walk_squash = 0.05
		_animator.attack_windup_time = 0.25
		_animator.attack_strike_time = 0.1
		_animator.attack_recovery_time = 0.3
		add_child(_animator)
		_animator.setup(sprite)

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
		return

	_charge_timer += delta
	_stomp_timer += delta

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.CHARGE_WINDUP:
			velocity = Vector2.ZERO  # Hold still during windup
		State.CHARGING:
			_process_charge(delta)
		State.STOMPING:
			pass

	# Prevent sticking to player - strong separation when too close
	var distance = global_position.distance_to(target.global_position)
	var min_distance = 50.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		var push_strength = (min_distance - distance) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

func _process_idle(_delta: float) -> void:
	# Prioritize charge when ready
	if _charge_timer >= charge_cooldown:
		_start_charge()
		return

	# Stomp when player is close
	var distance = global_position.distance_to(target.global_position)
	if distance <= stomp_radius and _stomp_timer >= stomp_cooldown:
		_do_stomp_attack()
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

	# Update walk animation
	var is_moving = velocity.length() > 10.0
	_update_walk_animation(is_moving)


func _update_walk_animation(is_moving: bool) -> void:
	if _animator == null:
		return

	if is_moving and not _was_moving:
		_animator.start_walk_animation()
	elif not is_moving and _was_moving:
		_animator.stop_walk_animation()

	_was_moving = is_moving

func _start_charge() -> void:
	_state = State.CHARGE_WINDUP
	_charge_timer = 0.0
	_charge_hit = false
	_charge_direction = (target.global_position - global_position).normalized()
	_charge_time_remaining = 0.8  # Charge duration after windup

	# Play boss charge animation
	if _animator:
		_animator.stop_walk_animation()
		_animator.play_boss_charge()

	# Play SFX
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_sfx_at"):
		audio.play_sfx_at("boss_attack", global_position)

	# Hold still during windup (0.4s matches animation phase 1), then begin charge
	await get_tree().create_timer(0.4).timeout
	if _state == State.CHARGE_WINDUP:
		_state = State.CHARGING

func _process_charge(delta: float) -> void:
	_charge_time_remaining -= delta

	velocity = _charge_direction * charge_speed

	# Check for collision with player during charge (wider hit-box, single-hit only)
	if not _charge_hit and target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance < 50:
			_charge_hit = true
			if target.has_method("take_damage"):
				target.take_damage(charge_damage)
			_end_charge()
			return

	if _charge_time_remaining <= 0:
		_end_charge()

func _end_charge() -> void:
	_state = State.IDLE
	if _animator:
		_animator.is_attacking = false

func _do_stomp_attack() -> void:
	_state = State.STOMPING
	_stomp_timer = 0.0
	velocity = Vector2.ZERO

	# Play boss stomp animation
	if _animator:
		_animator.stop_walk_animation()
		_animator.play_boss_stomp()

	# Play SFX
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_sfx_at"):
		audio.play_sfx_at("boss_attack", global_position)

	# Wait for slam to land (matches animation phase 1 + phase 2 timing)
	await get_tree().create_timer(0.4).timeout

	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= stomp_radius:
			if target.has_method("take_damage"):
				target.take_damage(stomp_damage)

	_spawn_stomp_effect()

	# Wait for recovery animation to finish
	await get_tree().create_timer(0.55).timeout
	_state = State.IDLE

func _spawn_stomp_effect() -> void:
	# Visual stomp effect - 3 effects in a ring pattern, larger scale
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		for i in range(3):
			var hit = hit_scene.instantiate()
			var angle = (TAU / 3.0) * i
			var offset = Vector2(cos(angle), sin(angle)) * 40.0
			hit.global_position = global_position + offset
			hit.modulate = Color(0.6, 0.3, 0)  # Brown
			hit.scale = Vector2(4, 4)
			get_tree().current_scene.call_deferred("add_child", hit)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var dmg = charge_damage if _state == State.CHARGING else contact_damage
		body.take_damage(dmg)

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
		hit.modulate = Color(0.5, 0.3, 0.2)
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
		for i in range(4):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-25, 25), randf_range(-25, 25))
			poof.global_position = global_position + offset
			poof.modulate = Color(0.5, 0.3, 0.2)
			poof.scale = Vector2(1.8, 1.8)
			get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_drops() -> void:
	_spawn_xp_orbs()
	_spawn_emeralds()

func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree():
		return

	var orbs_to_spawn = 6
	var xp_per_orb = xp_value / orbs_to_spawn

	for i in range(orbs_to_spawn):
		var orb = xp_scene.instantiate()
		var offset = Vector2(randf_range(-35, 35), randf_range(-35, 35))
		orb.global_position = global_position + offset
		orb.xp_value = xp_per_orb
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_emeralds() -> void:
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if not emerald_scene or not get_tree():
		return

	var emeralds_to_spawn = 5
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-45, 45), randf_range(-45, 45))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)
