class_name EnemyAnimator
extends Node

## Procedural animation component - adds walk and attack animations to enemy sprites
## Uses Tween-based animations for smooth, consistent movement

signal attack_started()
signal attack_hit_frame()  # Attack hit frame - sync damage with this
signal attack_finished()

# Walk animation settings
@export_group("Walk Animation")
@export var walk_bob_height: float = 3.0      # Walk bob height in pixels
@export var walk_bob_speed: float = 0.3       # Bob cycle duration
@export var walk_tilt_angle: float = 5.0      # Slight tilt while walking (degrees)
@export var walk_squash: float = 0.05         # Squash amount during walk

# Attack animation settings
@export_group("Attack Animation")
@export var attack_windup_time: float = 0.15  # Attack windup duration
@export var attack_strike_time: float = 0.1   # Attack strike duration
@export var attack_recovery_time: float = 0.2 # Attack recovery duration
@export var attack_windup_scale: float = 0.85 # Scale during windup
@export var attack_strike_scale: float = 1.15 # Scale during strike
@export var attack_windup_angle: float = -15.0 # Rotation during windup (degrees)
@export var attack_strike_angle: float = 30.0  # Rotation during strike (degrees)

# Hit reaction settings
@export_group("Hit Reaction")
@export var hit_flash_duration: float = 0.1
@export var hit_shake_amount: float = 2.0
@export var hit_shake_duration: float = 0.15

var sprite: Node2D = null
var is_walking: bool = false
var is_attacking: bool = false

var _walk_tween: Tween = null
var _attack_tween: Tween = null
var _hit_tween: Tween = null

var _original_position: Vector2 = Vector2.ZERO
var _original_rotation: float = 0.0
var _original_scale: Vector2 = Vector2.ONE
var _original_modulate: Color = Color.WHITE

var _walk_direction: float = 1.0  # 1 or -1 for bob direction


func _ready() -> void:
	# Try to find sprite automatically if not set
	if sprite == null:
		var parent = get_parent()
		if parent:
			sprite = parent.get_node_or_null("Sprite2D")

	if sprite:
		_original_position = sprite.position
		_original_rotation = sprite.rotation
		_original_scale = sprite.scale
		_original_modulate = sprite.modulate


func _exit_tree() -> void:
	_cleanup_tweens()


func setup(target_sprite: Node2D) -> void:
	"""Initialize the animator with a target sprite"""
	sprite = target_sprite
	if sprite:
		_original_position = sprite.position
		_original_rotation = sprite.rotation
		_original_scale = sprite.scale
		_original_modulate = sprite.modulate


# ============================================================================
# WALK ANIMATION
# ============================================================================

func start_walk_animation() -> void:
	"""Start continuous walking animation loop"""
	if is_walking or sprite == null:
		return

	is_walking = true
	_walk_direction = 1.0
	_play_walk_cycle()


func stop_walk_animation() -> void:
	"""Stop walking animation and reset to original state"""
	if not is_walking:
		return

	is_walking = false

	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()
		_walk_tween = null

	# Reset to original state
	if sprite:
		var reset_tween = create_tween()
		reset_tween.set_parallel(true)
		reset_tween.tween_property(sprite, "position", _original_position, 0.1)
		reset_tween.tween_property(sprite, "rotation", _original_rotation, 0.1)
		reset_tween.tween_property(sprite, "scale", _original_scale, 0.1)


func _play_walk_cycle() -> void:
	"""Play one walk cycle and loop if still walking"""
	if not is_walking or sprite == null:
		return

	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()

	_walk_tween = create_tween()
	_walk_tween.set_loops()  # Infinite loop

	var bob_offset = Vector2(0, walk_bob_height * _walk_direction)
	var tilt_rad = deg_to_rad(walk_tilt_angle * _walk_direction)
	var squash_scale = Vector2(_original_scale.x * (1.0 + walk_squash),
							   _original_scale.y * (1.0 - walk_squash))

	# Down phase
	_walk_tween.tween_property(sprite, "position", _original_position + bob_offset, walk_bob_speed * 0.5)
	_walk_tween.parallel().tween_property(sprite, "rotation", _original_rotation + tilt_rad, walk_bob_speed * 0.5)
	_walk_tween.parallel().tween_property(sprite, "scale", squash_scale, walk_bob_speed * 0.5)

	# Up phase
	_walk_tween.tween_property(sprite, "position", _original_position - bob_offset, walk_bob_speed * 0.5)
	_walk_tween.parallel().tween_property(sprite, "rotation", _original_rotation - tilt_rad, walk_bob_speed * 0.5)
	_walk_tween.parallel().tween_property(sprite, "scale", _original_scale, walk_bob_speed * 0.5)


# ============================================================================
# ATTACK ANIMATION
# ============================================================================

func play_attack_animation() -> void:
	"""Play full attack animation sequence (windup -> strike -> recovery)"""
	if is_attacking or sprite == null:
		return

	is_attacking = true
	attack_started.emit()

	# Stop walk animation during attack
	var was_walking = is_walking
	if is_walking:
		if _walk_tween and _walk_tween.is_valid():
			_walk_tween.kill()
			_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	var windup_scale = _original_scale * attack_windup_scale
	var strike_scale = _original_scale * attack_strike_scale
	var windup_rot = deg_to_rad(attack_windup_angle)
	var strike_rot = deg_to_rad(attack_strike_angle)

	# Windup phase - pull back and shrink
	_attack_tween.tween_property(sprite, "scale", windup_scale, attack_windup_time)
	_attack_tween.parallel().tween_property(sprite, "rotation", windup_rot, attack_windup_time)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, 2), attack_windup_time)

	# Strike phase - lunge forward and grow
	_attack_tween.tween_property(sprite, "scale", strike_scale, attack_strike_time).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", strike_rot, attack_strike_time).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, -3), attack_strike_time)

	# Emit hit frame at peak of strike
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())

	# Recovery phase - return to normal
	_attack_tween.tween_property(sprite, "scale", _original_scale, attack_recovery_time).set_ease(Tween.EASE_IN_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", _original_rotation, attack_recovery_time)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position, attack_recovery_time)

	# Finish callback
	_attack_tween.tween_callback(func():
		is_attacking = false
		attack_finished.emit()
		# Resume walking if was walking
		if was_walking:
			is_walking = true
			_play_walk_cycle()
	)


func play_quick_attack() -> void:
	"""Play a quick attack flash without full animation sequence"""
	if sprite == null:
		return

	attack_started.emit()

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Quick scale pulse
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.1, 0.05)
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.1)
	_attack_tween.tween_callback(func(): attack_finished.emit())


# ============================================================================
# HIT REACTION
# ============================================================================

func play_hit_reaction() -> void:
	"""Play hit reaction (flash white and shake)"""
	if sprite == null:
		return

	if _hit_tween and _hit_tween.is_valid():
		_hit_tween.kill()

	_hit_tween = create_tween()

	# Flash white
	_hit_tween.tween_property(sprite, "modulate", Color.WHITE, hit_flash_duration * 0.5)
	_hit_tween.tween_property(sprite, "modulate", _original_modulate, hit_flash_duration * 0.5)

	# Shake effect (parallel)
	var shake_tween = create_tween()
	var shake_count = int(hit_shake_duration / 0.03)
	for i in range(shake_count):
		var offset = Vector2(randf_range(-hit_shake_amount, hit_shake_amount),
							 randf_range(-hit_shake_amount, hit_shake_amount))
		shake_tween.tween_property(sprite, "position", _original_position + offset, 0.03)
	shake_tween.tween_property(sprite, "position", _original_position, 0.03)


func flash_color(color: Color, duration: float = 0.1) -> void:
	"""Flash the sprite a specific color"""
	if sprite == null:
		return

	if _hit_tween and _hit_tween.is_valid():
		_hit_tween.kill()

	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", color, duration * 0.5)
	_hit_tween.tween_property(sprite, "modulate", _original_modulate, duration * 0.5)


# ============================================================================
# SPECIAL ANIMATIONS
# ============================================================================

func play_jump_squash() -> void:
	"""Play squash animation for charge preparation (Cavalry)"""
	if sprite == null:
		return

	var squash_scale = Vector2(_original_scale.x * 1.2, _original_scale.y * 0.7)

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()
	_attack_tween.tween_property(sprite, "scale", squash_scale, 0.1)


func play_jump_stretch() -> void:
	"""Play stretch animation for charge (Cavalry)"""
	if sprite == null:
		return

	var stretch_scale = Vector2(_original_scale.x * 0.8, _original_scale.y * 1.3)

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()
	_attack_tween.tween_property(sprite, "scale", stretch_scale, 0.05)


func play_jump_land() -> void:
	"""Play landing animation (Cavalry)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Squash on land
	var squash_scale = Vector2(_original_scale.x * 1.15, _original_scale.y * 0.85)
	_attack_tween.tween_property(sprite, "scale", squash_scale, 0.05)
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.15).set_ease(Tween.EASE_OUT)


func play_charge_windup() -> void:
	"""Play charge preparation animation (Ravager)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Lean back and grow
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.1, 0.3)
	_attack_tween.parallel().tween_property(sprite, "rotation", deg_to_rad(-10), 0.3)


func play_charge_rush() -> void:
	"""Play charging animation (Ravager)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Lean forward aggressively
	_attack_tween.tween_property(sprite, "rotation", deg_to_rad(15), 0.1)
	_attack_tween.parallel().tween_property(sprite, "scale", _original_scale * 0.95, 0.1)


func play_teleport_out() -> void:
	"""Play teleport out animation (Assassin)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Stretch vertically and fade
	_attack_tween.tween_property(sprite, "scale", Vector2(_original_scale.x * 0.5, _original_scale.y * 1.5), 0.1)
	_attack_tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.1)


func play_teleport_in() -> void:
	"""Play teleport in animation (Assassin)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	# Start stretched and invisible
	sprite.scale = Vector2(_original_scale.x * 0.5, _original_scale.y * 1.5)
	sprite.modulate.a = 0.0

	_attack_tween = create_tween()

	# Return to normal
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.15)
	_attack_tween.parallel().tween_property(sprite, "modulate:a", _original_modulate.a, 0.15)


func play_explosion_swell(progress: float) -> void:
	"""Play swelling animation for explosion preparation (Fire Soldier)"""
	if sprite == null:
		return

	# Scale increases with progress (0.0 to 1.0)
	var swell_scale = _original_scale * (1.0 + progress * 0.3)
	sprite.scale = swell_scale


func play_breath_attack() -> void:
	"""Play breath attack animation (Dragon)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Rear back then thrust forward
	_attack_tween.tween_property(sprite, "rotation", deg_to_rad(-20), 0.2)
	_attack_tween.tween_property(sprite, "rotation", deg_to_rad(10), 0.1)
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())
	_attack_tween.tween_property(sprite, "rotation", _original_rotation, 0.3)


func play_sonic_boom() -> void:
	"""Play sonic boom animation (Dian Wei) - enhanced with scale pulsing and cyan flash"""
	if sprite == null:
		return

	is_attacking = true
	attack_started.emit()

	var was_walking = is_walking
	if is_walking:
		if _walk_tween and _walk_tween.is_valid():
			_walk_tween.kill()
			_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Charge up with cyan tint
	_attack_tween.tween_property(sprite, "modulate", Color(0.2, 0.9, 0.9), 0.1)
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.15, 0.1)

	# Violent shake with scale pulsing (16 frames)
	for i in range(16):
		var offset = Vector2(randf_range(-10, 10), randf_range(-8, 8))
		var pulse_scale = _original_scale * (1.15 if i % 2 == 0 else 0.9)
		_attack_tween.tween_property(sprite, "position", _original_position + offset, 0.02)
		_attack_tween.parallel().tween_property(sprite, "scale", pulse_scale, 0.02)

	# Hold scaled-up before release
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.2, 0.05)
	_attack_tween.tween_interval(0.15)

	_attack_tween.tween_callback(func(): attack_hit_frame.emit())

	# Flash white on release then recover
	_attack_tween.tween_property(sprite, "modulate", Color.WHITE, 0.03)
	_attack_tween.tween_property(sprite, "modulate", _original_modulate, 0.15)
	_attack_tween.parallel().tween_property(sprite, "scale", _original_scale, 0.2)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position, 0.1)

	_attack_tween.tween_callback(func():
		is_attacking = false
		attack_finished.emit()
		if was_walking:
			is_walking = true
			_play_walk_cycle()
	)


func play_summon_animation() -> void:
	"""Play summoning animation (Xiahou Dun)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Arms up gesture (scale wider)
	_attack_tween.tween_property(sprite, "scale", Vector2(_original_scale.x * 1.2, _original_scale.y * 0.9), 0.2)
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.3)


func play_laser_charge() -> void:
	"""Play laser charging animation (Elder Guardian)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()
	_attack_tween.set_loops(3)

	# Pulsing glow
	_attack_tween.tween_property(sprite, "modulate", Color(0.5, 1.0, 1.0), 0.15)
	_attack_tween.tween_property(sprite, "modulate", _original_modulate, 0.15)


func play_laser_fire() -> void:
	"""Play laser firing animation (Elder Guardian)"""
	if sprite == null:
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Flash and recoil
	_attack_tween.tween_property(sprite, "modulate", Color(0, 1.0, 1.0), 0.05)
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())
	_attack_tween.tween_property(sprite, "scale", _original_scale * 0.9, 0.1)
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.2)
	_attack_tween.tween_property(sprite, "modulate", _original_modulate, 0.2)


# ============================================================================
# BOSS ANIMATIONS
# ============================================================================

func play_boss_stomp() -> void:
	"""Play boss stomp animation (Ravager) - dramatic rise-up and slam-down"""
	if sprite == null:
		return

	is_attacking = true
	attack_started.emit()

	var was_walking = is_walking
	if is_walking:
		if _walk_tween and _walk_tween.is_valid():
			_walk_tween.kill()
			_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Phase 1: Rise up (0.3s) - scale 130%, move Y -15px, tint red
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.3, 0.3).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, -15), 0.3)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color(1.0, 0.4, 0.3), 0.3)

	# Phase 2: Slam down (0.1s) - squash wide, move Y +10px
	var slam_scale = Vector2(_original_scale.x * 0.8, _original_scale.y * 1.2)
	_attack_tween.tween_property(sprite, "scale", slam_scale, 0.1).set_ease(Tween.EASE_IN)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, 10), 0.1)

	# Phase 3: Hit frame
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())

	# Phase 4: Shockwave squash (0.25s) - stretch wide, shrink tall
	var shockwave_scale = Vector2(_original_scale.x * 1.4, _original_scale.y * 0.7)
	_attack_tween.tween_property(sprite, "scale", shockwave_scale, 0.25).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)

	# Phase 5: Recover (0.3s) - return to original
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.3).set_ease(Tween.EASE_IN_OUT)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position, 0.3)
	_attack_tween.parallel().tween_property(sprite, "modulate", _original_modulate, 0.3)

	_attack_tween.tween_callback(func():
		is_attacking = false
		attack_finished.emit()
		if was_walking:
			is_walking = true
			_play_walk_cycle()
	)


func play_boss_charge() -> void:
	"""Play boss charge animation (Ravager) - windup lean-back then rush forward"""
	if sprite == null:
		return

	is_attacking = true
	attack_started.emit()

	var was_walking = is_walking
	if is_walking:
		if _walk_tween and _walk_tween.is_valid():
			_walk_tween.kill()
			_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Phase 1: Windup (0.4s) - scale 125%, rotate -20deg, tint orange-red
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.25, 0.4).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", deg_to_rad(-20), 0.4)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color(1.0, 0.5, 0.2), 0.4)

	# Phase 2: Rush (0.15s) - stretch horizontal, rotate forward, flash white
	var rush_scale = Vector2(_original_scale.x * 1.4, _original_scale.y * 0.8)
	_attack_tween.tween_property(sprite, "scale", rush_scale, 0.15).set_ease(Tween.EASE_IN)
	_attack_tween.parallel().tween_property(sprite, "rotation", deg_to_rad(25), 0.15)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.08)

	_attack_tween.tween_callback(func(): attack_hit_frame.emit())

	# Phase 3: Recovery (0.3s) - return to original
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.3).set_ease(Tween.EASE_IN_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", _original_rotation, 0.3)
	_attack_tween.parallel().tween_property(sprite, "modulate", _original_modulate, 0.3)

	_attack_tween.tween_callback(func():
		is_attacking = false
		attack_finished.emit()
		if was_walking:
			is_walking = true
			_play_walk_cycle()
	)


func play_boss_melee() -> void:
	"""Play boss melee animation (Dian Wei) - dramatic wind-up and heavy slam"""
	if sprite == null:
		return

	is_attacking = true
	attack_started.emit()

	var was_walking = is_walking
	if is_walking:
		if _walk_tween and _walk_tween.is_valid():
			_walk_tween.kill()
			_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_attack_tween = create_tween()

	# Phase 1: Wind up (0.35s) - scale 130%, rotate -25deg, rise up, tint dark cyan
	_attack_tween.tween_property(sprite, "scale", _original_scale * 1.3, 0.35).set_ease(Tween.EASE_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", deg_to_rad(-25), 0.35)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, -10), 0.35)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color(0.2, 0.7, 0.7), 0.35)

	# Phase 2: Strike (0.08s) - squash wide/tall, rotate forward, slam down
	var strike_scale = Vector2(_original_scale.x * 0.85, _original_scale.y * 1.4)
	_attack_tween.tween_property(sprite, "scale", strike_scale, 0.08).set_ease(Tween.EASE_IN)
	_attack_tween.parallel().tween_property(sprite, "rotation", deg_to_rad(35), 0.08)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position + Vector2(0, 8), 0.08)
	_attack_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.05)

	# Phase 3: Hit frame
	_attack_tween.tween_callback(func(): attack_hit_frame.emit())

	# Phase 4: Recover (0.3s) - return to original
	_attack_tween.tween_property(sprite, "scale", _original_scale, 0.3).set_ease(Tween.EASE_IN_OUT)
	_attack_tween.parallel().tween_property(sprite, "rotation", _original_rotation, 0.3)
	_attack_tween.parallel().tween_property(sprite, "position", _original_position, 0.3)
	_attack_tween.parallel().tween_property(sprite, "modulate", _original_modulate, 0.3)

	_attack_tween.tween_callback(func():
		is_attacking = false
		attack_finished.emit()
		if was_walking:
			is_walking = true
			_play_walk_cycle()
	)


# ============================================================================
# UTILITY
# ============================================================================

func reset_to_original() -> void:
	"""Reset sprite to original state immediately"""
	_cleanup_tweens()

	if sprite:
		sprite.position = _original_position
		sprite.rotation = _original_rotation
		sprite.scale = _original_scale
		sprite.modulate = _original_modulate

	is_walking = false
	is_attacking = false


func _cleanup_tweens() -> void:
	"""Clean up all active tweens to prevent memory leaks"""
	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()
		_walk_tween = null

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
		_attack_tween = null

	if _hit_tween and _hit_tween.is_valid():
		_hit_tween.kill()
		_hit_tween = null
