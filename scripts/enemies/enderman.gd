extends CharacterBody2D
class_name Enderman
## Teleporting enemy that warps away when hit

signal died(xp_value: int)

@export var speed: float = 70.0
@export var damage: int = 15
@export var health: int = 20
@export var xp_value: int = 15
@export var meat_drop_chance: float = 0.25  # 25% chance (boss-tier)
@export var teleport_cooldown: float = 3.0
@export var teleport_range: float = 200.0
@export var teleport_on_hit: bool = true

## Arrow dodge settings
@export var arrow_dodge_enabled: bool = true
@export var arrow_detection_radius: float = 120.0  # Detection range for incoming arrows
@export var dodge_chance: float = 0.8  # 80% chance to dodge

var target: Node2D = null
var _arrow_detection_area: Area2D = null
var can_teleport: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

func _ready() -> void:
	add_to_group("enemies")

	# Connect hitbox for damaging player
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Setup teleport timer
	var timer = get_node_or_null("TeleportTimer")
	if timer:
		timer.timeout.connect(_on_teleport_timer_timeout)
		timer.wait_time = teleport_cooldown

	# Setup arrow detection area for dodging
	if arrow_dodge_enabled:
		_setup_arrow_detection()

	# Find player as target
	_find_target()

## Create detection area for sensing incoming arrows
func _setup_arrow_detection() -> void:
	_arrow_detection_area = Area2D.new()
	_arrow_detection_area.name = "ArrowDetectionArea"
	_arrow_detection_area.collision_layer = 0  # Don't be detected by others
	_arrow_detection_area.collision_mask = 8   # Detect player projectiles (layer 8)

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = arrow_detection_radius
	shape.shape = circle
	_arrow_detection_area.add_child(shape)

	add_child(_arrow_detection_area)
	_arrow_detection_area.area_entered.connect(_on_arrow_detected)

func _find_target() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	# Apply knockback decay
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		move_and_slide()
		return

	if not target or not is_instance_valid(target):
		return

	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

	# Prevent sticking to player - add separation when too close
	var distance_to_player = global_position.distance_to(target.global_position)
	var min_distance = 30.0
	if distance_to_player < min_distance and distance_to_player > 0:
		var push_direction = (global_position - target.global_position).normalized()
		velocity += push_direction * (min_distance - distance_to_player) * 5.0

	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Damage player on contact
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	_spawn_hit_effect()

	# Teleport when hit if enabled and off cooldown
	if teleport_on_hit and can_teleport:
		teleport()

	if health <= 0:
		_on_died()

func teleport() -> void:
	if not can_teleport:
		return

	can_teleport = false

	# Calculate random teleport position within range
	var random_angle = randf() * TAU
	var random_distance = randf_range(teleport_range * 0.5, teleport_range)
	var teleport_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance

	var new_position = global_position + teleport_offset

	# Spawn teleport effect at old position
	_spawn_teleport_effect(global_position)

	# Move to new position
	global_position = new_position

	# Spawn teleport effect at new position
	_spawn_teleport_effect(global_position)

	# Start cooldown timer
	var timer = get_node_or_null("TeleportTimer")
	if timer:
		timer.start()
	else:
		# Fallback if no timer
		await get_tree().create_timer(teleport_cooldown).timeout
		can_teleport = true

func _on_teleport_timer_timeout() -> void:
	can_teleport = true

## Called when an arrow enters detection range
func _on_arrow_detected(area: Area2D) -> void:
	if not arrow_dodge_enabled or not can_teleport:
		return

	# Check if it's a player projectile
	if not area.is_in_group("player_projectiles"):
		return

	# Random chance to dodge
	if randf() > dodge_chance:
		return

	# Check if arrow is heading towards us
	if _will_arrow_hit(area):
		_dodge_arrow(area)

## Predict if arrow trajectory will hit us
func _will_arrow_hit(arrow: Area2D) -> bool:
	var arrow_pos = arrow.global_position
	var arrow_dir = Vector2.ZERO

	# Get arrow direction from its movement
	if "direction" in arrow:
		arrow_dir = arrow.direction
	elif "_direction" in arrow:
		arrow_dir = arrow._direction
	else:
		# Fallback: assume arrow is moving towards us
		arrow_dir = (global_position - arrow_pos).normalized()

	if arrow_dir == Vector2.ZERO:
		return false

	# Calculate perpendicular distance from arrow trajectory to our position
	var to_me = global_position - arrow_pos
	var perpendicular_dist = abs(to_me.cross(arrow_dir))

	# Hit if trajectory passes within our collision radius (plus arrow size)
	var hit_threshold = 40.0  # Enderman width + arrow size
	return perpendicular_dist < hit_threshold

## Teleport in random direction to dodge arrow
func _dodge_arrow(_arrow: Area2D) -> void:
	# Random direction
	var random_angle = randf() * TAU
	var dodge_direction = Vector2.from_angle(random_angle)

	# Random distance
	var dodge_distance = randf_range(80, 150)

	var new_pos = global_position + dodge_direction * dodge_distance

	# Perform teleport
	can_teleport = false

	# Spawn teleport effect at old position
	_spawn_teleport_effect(global_position)

	# Move to new position
	global_position = new_pos

	# Spawn teleport effect at new position
	_spawn_teleport_effect(global_position)

	# Start cooldown timer
	var timer = get_node_or_null("TeleportTimer")
	if timer:
		timer.start()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func _spawn_hit_effect() -> void:
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene and get_tree() and get_tree().current_scene:
		var hit = hit_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.add_child(hit)

func _spawn_teleport_effect(pos: Vector2) -> void:
	if not get_tree() or not get_tree().current_scene:
		return
	# Use death poof as teleport effect for now
	var effect_scene = load("res://scenes/effects/death_poof.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = pos
		effect.modulate = Color(0.5, 0.0, 0.5, 0.8)  # Purple tint for Enderman
		get_tree().current_scene.add_child(effect)

func _on_died() -> void:
	died.emit(xp_value)
	_spawn_death_effect()
	_spawn_xp_orb()
	_try_spawn_meat()
	queue_free()

func _try_spawn_meat() -> void:
	if randf() <= meat_drop_chance:
		var meat_scene = load("res://scenes/pickups/meat_pickup.tscn")
		if meat_scene and get_tree() and get_tree().current_scene:
			var meat = meat_scene.instantiate()
			meat.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", meat)

func _spawn_death_effect() -> void:
	var death_scene = load("res://scenes/effects/death_poof.tscn")
	if death_scene and get_tree() and get_tree().current_scene:
		var poof = death_scene.instantiate()
		poof.global_position = global_position
		poof.modulate = Color(0.5, 0.0, 0.5)  # Purple tint
		get_tree().current_scene.add_child(poof)

func _spawn_xp_orb() -> void:
	var xp_scene = load("res://scenes/pickups/xp_orb.tscn")
	if xp_scene and get_tree() and get_tree().current_scene:
		var orb = xp_scene.instantiate()
		orb.global_position = global_position
		orb.xp_value = xp_value
		get_tree().current_scene.add_child(orb)
