extends CharacterBody2D
class_name Warden
## Warden Boss (Wave 20) - Sonic boom and anger tracking
## HP: 400, Damage: 40, Speed: 35

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 1000
@export var health: int = 1000
@export var speed: float = 35.0
@export var contact_damage: int = 40
@export var xp_value: int = 600
@export var emerald_drop: int = 75

# Attack properties
@export var sonic_boom_cooldown: float = 4.0
@export var sonic_boom_damage: int = 65
@export var sonic_boom_range: float = 400.0
@export var melee_damage: int = 55
@export var melee_cooldown: float = 1.5

# Anger/Detection system
@export var anger_level: int = 0
@export var max_anger: int = 100
@export var anger_per_sound: int = 15

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.30

# AI State
enum State { IDLE, TRACKING, SONIC_BOOM, MELEE_ATTACK }
var _state: State = State.IDLE
var _sonic_timer: float = 0.0
var _melee_timer: float = 0.0

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
		# Warden-specific: heavy, breathing motion
		_animator.walk_bob_height = 5.0
		_animator.walk_bob_speed = 0.5
		_animator.walk_tilt_angle = 3.0
		_animator.walk_squash = 0.04  # Breathing pulse
		_animator.attack_windup_time = 0.3
		_animator.attack_strike_time = 0.15
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

	_sonic_timer += delta
	_melee_timer += delta

	# Track by sound - increase anger when player moves
	_track_by_sound(delta)

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.TRACKING:
			_process_tracking(delta)
		State.SONIC_BOOM:
			pass
		State.MELEE_ATTACK:
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
	var distance = global_position.distance_to(target.global_position)

	# Sonic boom for ranged attack when anger is high (lowered threshold)
	if _sonic_timer >= sonic_boom_cooldown and anger_level >= 30:
		_do_sonic_boom()
		return

	# Melee attack when close (wider range to avoid anti-sticking deadlock)
	if distance <= 80 and _melee_timer >= melee_cooldown:
		_do_melee_attack()
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

func _process_tracking(_delta: float) -> void:
	# More aggressive when angry
	var direction = (target.global_position - global_position).normalized()
	var tracking_speed = speed * (1.0 + (anger_level / 100.0) * 0.5)
	velocity = direction * tracking_speed

func _track_by_sound(_delta: float) -> void:
	# Warden detects player by sound/movement
	if target and is_instance_valid(target):
		if target is CharacterBody2D and target.velocity.length() > 10:
			_update_anger(anger_per_sound)

func _update_anger(amount: int) -> void:
	anger_level = clampi(anger_level + amount, 0, max_anger)

	# Become more aggressive at high anger
	if anger_level >= 80:
		_state = State.TRACKING

func _do_sonic_boom() -> void:
	_state = State.SONIC_BOOM
	_sonic_timer = 0.0
	velocity = Vector2.ZERO

	# Play enhanced sonic boom animation and sync damage to hit frame
	if _animator:
		_animator.stop_walk_animation()
		_animator.play_sonic_boom()

		# Play SFX
		var audio = get_node_or_null("/root/AudioManager")
		if audio and audio.has_method("play_sfx_at"):
			audio.play_sfx_at("boss_attack", global_position)

		# Wait for animation to reach hit frame (syncs damage with visual)
		await _animator.attack_hit_frame
	else:
		# Fallback if no animator
		await get_tree().create_timer(0.7).timeout

	# Ranged sonic attack
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= sonic_boom_range:
			if target.has_method("take_damage"):
				target.take_damage(sonic_boom_damage)
			_spawn_sonic_effect()

	anger_level = max(0, anger_level - 30)  # Reset some anger

	# Wait for recovery animation to finish
	if _animator:
		await _animator.attack_finished
	else:
		await get_tree().create_timer(0.3).timeout
	_state = State.IDLE

func _spawn_sonic_effect() -> void:
	# Visual sonic wave effect - 3 effects in a line from boss to player
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and target and get_tree() and get_tree().current_scene:
		var direction = (target.global_position - global_position).normalized()
		var total_distance = global_position.distance_to(target.global_position)
		for i in range(3):
			var hit = hit_scene.instantiate()
			var t = (i + 1) / 3.0
			hit.global_position = global_position + direction * total_distance * t
			hit.modulate = Color(0, 0.8, 0.8)  # Teal
			hit.scale = Vector2(5, 5)
			get_tree().current_scene.call_deferred("add_child", hit)

func _do_melee_attack() -> void:
	_state = State.MELEE_ATTACK
	_melee_timer = 0.0
	velocity = Vector2.ZERO

	# Play boss melee animation
	if _animator:
		_animator.stop_walk_animation()
		_animator.play_boss_melee()

	# Play SFX
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_sfx_at"):
		audio.play_sfx_at("boss_attack", global_position)

	# Wait for wind-up + strike animation timing
	await get_tree().create_timer(0.43).timeout

	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= 90:
			if target.has_method("take_damage"):
				target.take_damage(melee_damage)

	# Wait for recovery
	await get_tree().create_timer(0.3).timeout
	_state = State.IDLE

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)

func take_damage(amount: int) -> void:
	var reduced_damage = int(amount * (1.0 - damage_reduction))
	reduced_damage = max(1, reduced_damage)

	health -= reduced_damage
	health_changed.emit(health, max_health)

	# Taking damage increases anger
	_update_anger(20)

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
		hit.modulate = Color(0, 0.4, 0.4)
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
		for i in range(5):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
			poof.global_position = global_position + offset
			poof.modulate = Color(0, 0.4, 0.4)
			poof.scale = Vector2(2.0, 2.0)
			get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_drops() -> void:
	_spawn_xp_orbs()
	_spawn_emeralds()

func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree():
		return

	var orbs_to_spawn = 8
	var xp_per_orb = xp_value / orbs_to_spawn

	for i in range(orbs_to_spawn):
		var orb = xp_scene.instantiate()
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		orb.global_position = global_position + offset
		orb.xp_value = xp_per_orb
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_emeralds() -> void:
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if not emerald_scene or not get_tree():
		return

	var emeralds_to_spawn = 6
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)
