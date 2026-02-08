extends CharacterBody2D
class_name ElderGuardian
## Elder Guardian Boss (Wave 10) - Laser attack and spike aura
## HP: 150, Damage: 20, Speed: 30

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 600
@export var health: int = 600
@export var speed: float = 30.0
@export var contact_damage: int = 15
@export var xp_value: int = 150
@export var emerald_drop: int = 40

# Attack properties
@export var laser_cooldown: float = 4.0
@export var laser_damage: int = 20
@export var laser_range: float = 300.0
@export var spike_aura_damage: int = 5
@export var spike_aura_radius: float = 80.0
@export var spike_cooldown: float = 1.0

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.15

# AI State
enum State { IDLE, CHARGING_LASER, FIRING_LASER }
var _state: State = State.IDLE
var _laser_timer: float = 0.0
var _spike_timer: float = 0.0
var _laser_target_pos: Vector2 = Vector2.ZERO

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
		# Elder Guardian-specific: pulsing, breathing motion
		_animator.walk_bob_height = 4.0
		_animator.walk_bob_speed = 0.7
		_animator.walk_tilt_angle = 0.0  # No tilt - floats upright
		_animator.walk_squash = 0.06  # Breathing pulse
		add_child(_animator)
		_animator.setup(sprite)
		# Always floating - start animation
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

	_laser_timer += delta
	_spike_timer += delta

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.CHARGING_LASER:
			pass
		State.FIRING_LASER:
			pass

	# Spike aura - thorns damage to nearby player
	if _spike_timer >= spike_cooldown:
		_activate_spike_aura()

	_process_movement(delta)

func _process_idle(_delta: float) -> void:
	if _laser_timer >= laser_cooldown:
		_start_laser_attack()

func _process_movement(_delta: float) -> void:
	if _state != State.IDLE or not target:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (target.global_position - global_position).normalized()
	var distance = global_position.distance_to(target.global_position)

	# Maintain medium distance for laser attacks
	if distance > laser_range * 0.8:
		velocity = direction * speed
	elif distance < 100:
		velocity = -direction * speed * 0.5
	else:
		# Circle around player
		velocity = direction.orthogonal() * speed * 0.4

	# Prevent sticking to player - strong separation when too close
	var min_distance = 60.0
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		var push_strength = (min_distance - distance) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

func _start_laser_attack() -> void:
	_state = State.CHARGING_LASER
	_laser_timer = 0.0
	_laser_target_pos = target.global_position if target else global_position

	# Play laser charging animation
	if _animator:
		_animator.play_laser_charge()

	# Charging beam (warning indicator)
	_spawn_laser_warning()

	await get_tree().create_timer(1.0).timeout

	# Play laser fire animation
	if _animator:
		_animator.play_laser_fire()

	_do_laser_attack()
	_state = State.IDLE

func _spawn_laser_warning() -> void:
	# Visual warning before laser fires - draw a line to target
	if not target or not is_instance_valid(target):
		return

	# Create warning line using multiple small indicators
	var start_pos = global_position
	var end_pos = target.global_position
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	var segments = int(distance / 30)

	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		for i in range(segments):
			var pos = start_pos + direction * (i * 30)
			var warning = hit_scene.instantiate()
			warning.global_position = pos
			warning.modulate = Color(1.0, 0.3, 0.3, 0.5)  # Red warning
			warning.scale = Vector2(0.5, 0.5)
			get_tree().current_scene.call_deferred("add_child", warning)

func _do_laser_attack() -> void:
	if not target or not is_instance_valid(target):
		return

	# Check if player is in range
	var distance = global_position.distance_to(target.global_position)
	if distance <= laser_range:
		# Deal damage to player
		if target.has_method("take_damage"):
			target.take_damage(laser_damage)

		# Spawn laser beam visual effect
		_spawn_laser_effect()

func _spawn_laser_effect() -> void:
	# Spawn visual laser beam effect - draw beam from guardian to target
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if not hit_scene or not target or not get_tree() or not get_tree().current_scene:
		return

	var start_pos = global_position
	var end_pos = target.global_position
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	var segments = int(distance / 20)

	# Draw laser beam with cyan effects
	for i in range(segments + 1):
		var pos = start_pos + direction * (i * 20)
		var beam = hit_scene.instantiate()
		beam.global_position = pos
		beam.modulate = Color(0, 0.9, 1.0)  # Bright cyan
		beam.scale = Vector2(1.2, 1.2)
		get_tree().current_scene.call_deferred("add_child", beam)

	# Big impact at target
	var impact = hit_scene.instantiate()
	impact.global_position = end_pos
	impact.modulate = Color(0, 1.0, 1.0)  # Bright cyan
	impact.scale = Vector2(3, 3)
	get_tree().current_scene.call_deferred("add_child", impact)

func _activate_spike_aura() -> void:
	_spike_timer = 0.0

	if not target or not is_instance_valid(target):
		return

	# Thorns - damage player if they're too close
	var distance = global_position.distance_to(target.global_position)
	if distance <= spike_aura_radius:
		if target.has_method("take_damage"):
			target.take_damage(spike_aura_damage)
			_spawn_spike_effect()

func _spawn_spike_effect() -> void:
	# Spawn spike visual effects around the guardian
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if not hit_scene or not get_tree() or not get_tree().current_scene:
		return

	# Spawn spikes in a ring
	for i in range(6):
		var angle = i * (TAU / 6)
		var offset = Vector2(cos(angle), sin(angle)) * 40
		var spike = hit_scene.instantiate()
		spike.global_position = global_position + offset
		spike.modulate = Color(0.3, 0.8, 0.6)  # Teal/aqua
		spike.scale = Vector2(0.8, 0.8)
		get_tree().current_scene.call_deferred("add_child", spike)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)

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
		hit.modulate = Color(0, 0.6, 0.8)  # Cyan-blue tint
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
		for i in range(3):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			poof.global_position = global_position + offset
			poof.modulate = Color(0, 0.6, 0.8)
			poof.scale = Vector2(1.5, 1.5)
			get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_drops() -> void:
	_spawn_xp_orbs()
	_spawn_emeralds()

func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree():
		return

	var orbs_to_spawn = 5
	var xp_per_orb = xp_value / orbs_to_spawn

	for i in range(orbs_to_spawn):
		var orb = xp_scene.instantiate()
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		orb.global_position = global_position + offset
		orb.xp_value = xp_per_orb
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_emeralds() -> void:
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if not emerald_scene or not get_tree():
		return

	var emeralds_to_spawn = 4
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)
