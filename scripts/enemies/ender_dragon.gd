extends CharacterBody2D
class_name EnderDragon
## Ender Dragon Boss (Wave 30) - Final boss with fireball and dive attacks
## HP: 800, Damage: 50, Speed: 60

const EnemyAnimatorClass = preload("res://scripts/components/enemy_animator.gd")

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var max_health: int = 1500
@export var health: int = 1500
@export var speed: float = 60.0
@export var contact_damage: int = 40
@export var xp_value: int = 300
@export var emerald_drop: int = 150

# Attack properties
@export var fireball_cooldown: float = 3.0
@export var fireball_damage: int = 35
@export var breath_damage: int = 20
@export var breath_radius: float = 100.0
@export var dive_cooldown: float = 8.0
@export var dive_damage: int = 50
@export var dive_speed: float = 400.0

# Flying pattern
@export var fly_radius: float = 300.0
@export var fly_speed: float = 80.0

# Boss immunities
@export var knockback_immune: bool = true
@export var damage_reduction: float = 0.40

# AI State
enum State { FLYING, DIVING, BREATHING_FIRE, FIREBALL_ATTACK }
var _state: State = State.FLYING
var _fireball_timer: float = 0.0
var _dive_timer: float = 0.0
var _fly_angle: float = 0.0
var _dive_target: Vector2 = Vector2.ZERO

var target: Node2D = null
var _center_point: Vector2 = Vector2.ZERO

# Animation
var _animator = null  # EnemyAnimator instance

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	_center_point = global_position

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
		# Dragon-specific animation: majestic flying motion
		_animator.walk_bob_height = 8.0
		_animator.walk_bob_speed = 0.6
		_animator.walk_tilt_angle = 10.0
		_animator.walk_squash = 0.03
		add_child(_animator)
		_animator.setup(sprite)
		# Dragon is always flying - start animation immediately
		_animator.start_walk_animation()

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		_center_point = target.global_position

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
		return

	_fireball_timer += delta
	_dive_timer += delta

	# Update center point to follow player
	_center_point = target.global_position

	match _state:
		State.FLYING:
			_fly_pattern(delta)
			_process_attacks()
		State.DIVING:
			_process_dive(delta)
		State.BREATHING_FIRE:
			pass
		State.FIREBALL_ATTACK:
			pass

	# Prevent sticking to player - strong separation when too close
	var distance = global_position.distance_to(target.global_position)
	var min_distance = 80.0  # Larger for big boss
	if distance < min_distance and distance > 0:
		var push_direction = (global_position - target.global_position).normalized()
		var push_strength = (min_distance - distance) / min_distance
		velocity = push_direction * speed * push_strength * 2.0

	move_and_slide()

func _fly_pattern(delta: float) -> void:
	# Circle around player
	_fly_angle += delta * 1.5  # Rotation speed

	var target_pos = _center_point + Vector2(
		cos(_fly_angle) * fly_radius,
		sin(_fly_angle) * fly_radius
	)

	var direction = (target_pos - global_position).normalized()
	velocity = direction * fly_speed

func _process_attacks() -> void:
	# Prioritize dive attack
	if _dive_timer >= dive_cooldown:
		_start_dive_attack()
		return

	# Fireball attack
	if _fireball_timer >= fireball_cooldown:
		_do_fireball_attack()

func _start_dive_attack() -> void:
	_state = State.DIVING
	_dive_timer = 0.0
	_dive_target = target.global_position if target else global_position

	# Stop flying animation and play dive stretch
	if _animator:
		_animator.stop_walk_animation()
		# Stretch effect for diving
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2(0.8, 1.3), 0.2)

func _process_dive(_delta: float) -> void:
	var direction = (_dive_target - global_position).normalized()
	velocity = direction * dive_speed

	var distance = global_position.distance_to(_dive_target)
	if distance < 50:
		# Deal damage at impact
		if target and is_instance_valid(target):
			var player_dist = global_position.distance_to(target.global_position)
			if player_dist < 80:
				if target.has_method("take_damage"):
					target.take_damage(dive_damage)
		_spawn_dive_impact()
		_state = State.FLYING
		# Resume flying animation after dive
		if _animator:
			_animator.start_walk_animation()

func _spawn_dive_impact() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree():
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(0.8, 0, 0.8)  # Purple
		hit.scale = Vector2(4, 4)
		get_tree().current_scene.call_deferred("add_child", hit)

func _do_fireball_attack() -> void:
	_state = State.FIREBALL_ATTACK
	_fireball_timer = 0.0

	# Play breath attack animation
	if _animator:
		_animator.play_breath_attack()

	await get_tree().create_timer(0.3).timeout

	if target and is_instance_valid(target):
		# Spawn fireball or breath fire directly
		var direction = (target.global_position - global_position).normalized()
		_spawn_fireball(direction)

	_state = State.FLYING

func _spawn_fireball(direction: Vector2) -> void:
	# Try to spawn fireball projectile
	var fireball_scene = load("res://scenes/projectiles/dragon_fireball.tscn")
	if fireball_scene:
		var fireball = fireball_scene.instantiate()
		fireball.global_position = global_position + direction * 30
		fireball.direction = direction
		fireball.damage = fireball_damage
		if get_tree() and get_tree().current_scene:
			get_tree().current_scene.call_deferred("add_child", fireball)
	else:
		# Direct breath damage fallback
		if target and target.has_method("take_damage"):
			var distance = global_position.distance_to(target.global_position)
			if distance <= 250:
				target.take_damage(breath_damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var dmg = dive_damage if _state == State.DIVING else contact_damage
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
		hit.modulate = Color(0.6, 0, 0.6)
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
		# Dramatic death for final boss
		for i in range(8):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			poof.global_position = global_position + offset
			poof.modulate = Color(0.6, 0, 0.6)
			poof.scale = Vector2(2.5, 2.5)
			get_tree().current_scene.call_deferred("add_child", poof)

func _spawn_drops() -> void:
	_spawn_xp_orbs()
	_spawn_emeralds()
	# Dragon Egg drop (guaranteed special item)
	_spawn_special_drop()

func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree():
		return

	var orbs_to_spawn = 15
	var xp_per_orb = xp_value / orbs_to_spawn

	for i in range(orbs_to_spawn):
		var orb = xp_scene.instantiate()
		var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
		orb.global_position = global_position + offset
		orb.xp_value = xp_per_orb
		get_tree().current_scene.call_deferred("add_child", orb)

func _spawn_emeralds() -> void:
	var emerald_scene = load("res://scenes/pickups/emerald_pickup.tscn")
	if not emerald_scene or not get_tree():
		return

	var emeralds_to_spawn = 10
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-70, 70), randf_range(-70, 70))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)

func _spawn_special_drop() -> void:
	# Guaranteed totem for defeating final boss
	var totem_scene = load("res://scenes/pickups/totem_pickup.tscn")
	if totem_scene and get_tree():
		var totem = totem_scene.instantiate()
		totem.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", totem)
