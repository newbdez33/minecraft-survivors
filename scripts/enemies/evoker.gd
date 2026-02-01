extends CharacterBody2D
class_name Evoker
## Evoker Boss - Summons Vexes and casts fang attacks

signal died(xp_value: int)
signal health_changed(current: int, maximum: int)

# Boss stats
@export var health: int = 400
@export var speed: float = 40.0
@export var contact_damage: int = 5
@export var xp_value: int = 50
@export var emerald_drop: int = 30

# Attack properties
@export var fang_cooldown: float = 3.0
@export var summon_cooldown: float = 8.0
@export var fang_damage: int = 15
@export var fang_count: int = 5
@export var preferred_distance: float = 225.0  # Stay 200-250px from player

# Boss immunities and resistances
@export var knockback_immune: bool = true
@export var poison_immune: bool = true
@export var damage_reduction: float = 0.2  # Takes 20% less damage

# AI State
enum State { IDLE, CASTING_FANG, SUMMONING }
var _state: State = State.IDLE
var _fang_timer: float = 0.0
var _summon_timer: float = 0.0
var _vex_count: int = 0
const MAX_VEX: int = 3
var _active_vexes: Array = []  # Track spawned vexes for cleanup

var target: Node2D = null
var _max_health: int = 400

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	_max_health = health

	# Connect hitbox for contact damage
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Find player as target
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

	# Update timers
	_fang_timer += delta
	_summon_timer += delta

	# State machine
	match _state:
		State.IDLE:
			_process_idle(delta)
		State.CASTING_FANG:
			pass  # Wait for cast animation
		State.SUMMONING:
			pass  # Wait for summon animation

	# Movement (maintain preferred distance)
	_process_movement(delta)


func _process_idle(_delta: float) -> void:
	# Check summon cooldown (priority over fang attack)
	if _vex_count < MAX_VEX and _summon_timer >= summon_cooldown:
		_start_summon()
		return

	# Check fang cooldown
	if _fang_timer >= fang_cooldown:
		_start_fang_attack()


func _process_movement(_delta: float) -> void:
	if _state != State.IDLE:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not target or not is_instance_valid(target):
		return

	var distance = global_position.distance_to(target.global_position)
	var direction = (target.global_position - global_position).normalized()

	# Maintain preferred distance (200-250px)
	if distance > preferred_distance + 25:
		# Move closer
		velocity = direction * speed
	elif distance < preferred_distance - 25:
		# Back away
		velocity = -direction * speed * 0.8
	else:
		# Strafe sideways
		velocity = direction.orthogonal() * speed * 0.5
		# Occasionally change strafe direction
		if randf() < 0.02:
			velocity = -velocity

	move_and_slide()


func _start_fang_attack() -> void:
	_state = State.CASTING_FANG
	_fang_timer = 0.0

	# Cast fang attack after brief delay
	await get_tree().create_timer(0.3).timeout
	cast_fang_attack()

	_state = State.IDLE


func _start_summon() -> void:
	_state = State.SUMMONING
	_summon_timer = 0.0

	# Summon animation delay
	await get_tree().create_timer(0.5).timeout
	summon_vex()
	summon_vex()
	summon_vex()

	_state = State.IDLE


func cast_fang_attack() -> void:
	if not target or not is_instance_valid(target):
		return

	var fang_scene = load("res://scenes/effects/evoker_fang.tscn")
	if not fang_scene:
		return

	# Get direction to player
	var direction = (target.global_position - global_position).normalized()
	var start_pos = global_position + direction * 50  # Start 50px from evoker

	# Spawn fangs in a line toward player
	for i in range(fang_count):
		var fang = fang_scene.instantiate()
		var offset = direction * (i * 40)  # 40px spacing
		fang.global_position = start_pos + offset
		fang.damage = fang_damage

		if get_tree() and get_tree().current_scene:
			get_tree().current_scene.call_deferred("add_child", fang)

		# Stagger spawn timing
		await get_tree().create_timer(0.1).timeout


func summon_vex() -> void:
	if _vex_count >= MAX_VEX:
		return

	var vex_scene = load("res://scenes/enemies/vex.tscn")
	if not vex_scene:
		return

	var vex = vex_scene.instantiate()

	# Spawn near evoker with random offset
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	vex.global_position = global_position + offset

	# Connect to vex death to track count
	if vex.has_signal("died"):
		vex.died.connect(_on_vex_died.bind(vex))

	# Track active vexes for cleanup
	_active_vexes.append(vex)

	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.call_deferred("add_child", vex)
		_vex_count += 1


func _on_vex_died(_xp: int, vex: Node = null) -> void:
	_vex_count = max(0, _vex_count - 1)
	# Remove from tracking array
	if vex:
		_active_vexes.erase(vex)


func _exit_tree() -> void:
	# Disconnect signals from any remaining vexes to prevent memory leaks
	for vex in _active_vexes:
		if is_instance_valid(vex) and vex.has_signal("died"):
			var callable = _on_vex_died.bind(vex)
			if vex.died.is_connected(callable):
				vex.died.disconnect(callable)
	_active_vexes.clear()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)


func take_damage(amount: int) -> void:
	# Apply damage reduction
	var reduced_damage = int(amount * (1.0 - damage_reduction))
	reduced_damage = max(1, reduced_damage)  # At least 1 damage

	health -= reduced_damage
	health_changed.emit(health, _max_health)

	_spawn_hit_effect()

	if health <= 0:
		_on_died()


func apply_knockback(_force: Vector2) -> void:
	# Boss is immune to knockback
	if knockback_immune:
		return


func _spawn_hit_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		hit.modulate = Color(0.5, 0.0, 0.5)  # Purple tint
		get_tree().current_scene.call_deferred("add_child", hit)


func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_drops()
	queue_free()


func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		# Spawn multiple death effects for boss
		for i in range(3):
			var poof = death_scene.instantiate()
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			poof.global_position = global_position + offset
			poof.modulate = Color(0.4, 0.0, 0.6)  # Purple tint
			poof.scale = Vector2(1.5, 1.5)
			get_tree().current_scene.call_deferred("add_child", poof)


func _spawn_drops() -> void:
	# Spawn XP orbs
	_spawn_xp_orbs()

	# Spawn emeralds
	_spawn_emeralds()

	# 10% chance for Totem of Undying
	if randf() < 0.1:
		_spawn_totem()


func _spawn_xp_orbs() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if not xp_scene or not get_tree() or not get_tree().current_scene:
		return

	# Spawn multiple XP orbs for boss (total = xp_value)
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
	if not emerald_scene or not get_tree() or not get_tree().current_scene:
		return

	# Spawn emeralds
	var emeralds_to_spawn = 3
	var value_per_emerald = emerald_drop / emeralds_to_spawn

	for i in range(emeralds_to_spawn):
		var emerald = emerald_scene.instantiate()
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		emerald.global_position = global_position + offset
		emerald.value = value_per_emerald
		get_tree().current_scene.call_deferred("add_child", emerald)


func _spawn_totem() -> void:
	var totem_scene = load("res://scenes/pickups/totem_pickup.tscn")
	if not totem_scene or not get_tree() or not get_tree().current_scene:
		return

	var totem = totem_scene.instantiate()
	totem.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", totem)
