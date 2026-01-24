extends CharacterBody2D
## Player character controller (Steve)
## Handles movement, health, and combat interactions

signal health_changed(current: int, maximum: int)
signal died
signal xp_changed(current: int, needed: int)
signal leveled_up(new_level: int)
signal facing_changed(direction: Vector2)

@export var speed: float = 200.0
@export var max_health: int = 100
@export var invincibility_time: float = 1.0
@export var base_xp_requirement: int = 10
@export var xp_scaling: float = 1.5

var current_health: int
var is_invincible: bool = false
var god_mode: bool = false  # Testing flag - prevents all damage
var _health_component: Node = null
var _status_effect_manager: Node = null
var _weapon_slots: Node = null

# XP/Level system
var current_xp: int = 0
var current_level: int = 1
var xp_to_next_level: int = 10

# Upgrade bonuses
var xp_multiplier: float = 1.0  # Looting upgrade
var damage_reduction: float = 0.0  # Protection upgrade (0.0 = 0%, 0.1 = 10%)

# Facing direction for weapon positioning
var facing_direction: Vector2 = Vector2.RIGHT

# Mouse click-to-move target
var _mouse_target: Vector2 = Vector2.ZERO
var _has_mouse_target: bool = false
const MOUSE_TARGET_THRESHOLD: float = 10.0  # Stop when this close to target

func _ready() -> void:
	current_health = max_health
	xp_to_next_level = base_xp_requirement
	add_to_group("player")

	# Ensure sprite is fully visible
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)

	# Get health component if exists
	_health_component = get_node_or_null("HealthComponent")
	if _health_component:
		_health_component.max_health = max_health
		_health_component.health_changed.connect(_on_health_changed)
		_health_component.died.connect(_on_died)

	# Connect to status effect manager for poison damage
	_status_effect_manager = get_node_or_null("StatusEffectManager")
	if _status_effect_manager:
		_status_effect_manager.effect_tick.connect(_on_status_effect_tick)
		_status_effect_manager.effect_applied.connect(_on_status_effect_applied)
		_status_effect_manager.effect_removed.connect(_on_status_effect_removed)

	# Register initial sword with weapon slots
	_weapon_slots = get_node_or_null("WeaponSlots")
	if _weapon_slots:
		var sword = get_node_or_null("Sword")
		if sword:
			_weapon_slots.register_weapon(sword, 0)  # Slot 0 = right side

func _physics_process(_delta: float) -> void:
	var input_direction = get_input_direction()

	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * speed
		# Update facing direction when moving
		var new_facing = input_direction.normalized()
		if new_facing != facing_direction:
			facing_direction = new_facing
			facing_changed.emit(facing_direction)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _input(event: InputEvent) -> void:
	# Handle mouse click for click-to-move
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_mouse_target = get_global_mouse_position()
			_has_mouse_target = true

func get_input_direction() -> Vector2:
	# Check keyboard input first
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# Keyboard input cancels mouse target
	if direction != Vector2.ZERO:
		_has_mouse_target = false
		return direction

	# Move towards mouse click target
	if _has_mouse_target:
		var to_target = _mouse_target - global_position
		if to_target.length() > MOUSE_TARGET_THRESHOLD:
			direction = to_target.normalized()
		else:
			# Reached target
			_has_mouse_target = false

	return direction

func take_damage(amount: int) -> void:
	if is_invincible or god_mode:
		return

	# Apply protection damage reduction
	var actual_damage = int(amount * (1.0 - damage_reduction))
	actual_damage = max(1, actual_damage)  # Always take at least 1 damage

	if _health_component:
		_health_component.take_damage(actual_damage)
	else:
		current_health = max(0, current_health - actual_damage)
		health_changed.emit(current_health, max_health)
		if current_health <= 0:
			_on_died()

	# Start invincibility
	_start_invincibility()

func _start_invincibility() -> void:
	is_invincible = true
	# Flash effect
	_flash_sprite()
	# End invincibility after timer
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
	# Reset sprite
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate.a = 1.0

func _flash_sprite() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Flash animation during invincibility
	for i in range(int(invincibility_time / 0.1)):
		sprite.modulate.a = 0.3 if i % 2 == 0 else 1.0
		await get_tree().create_timer(0.1).timeout

func heal(amount: int) -> void:
	if _health_component:
		_health_component.heal(amount)
	else:
		current_health = min(max_health, current_health + amount)
		health_changed.emit(current_health, max_health)

func _on_health_changed(current: int, maximum: int) -> void:
	current_health = current
	health_changed.emit(current, maximum)

func _on_died() -> void:
	died.emit()
	# TODO: Game over screen
	print("Player died!")

# XP/Level System
func add_xp(amount: int) -> void:
	# Apply looting multiplier
	var actual_xp = int(amount * xp_multiplier)
	current_xp += actual_xp

	# Check for level up
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		_level_up()

	xp_changed.emit(current_xp, xp_to_next_level)

func _level_up() -> void:
	current_level += 1
	xp_to_next_level = int(base_xp_requirement * pow(xp_scaling, current_level - 1))
	leveled_up.emit(current_level)
	print("Level up! Now level ", current_level)

func get_xp_progress() -> float:
	return float(current_xp) / float(xp_to_next_level)

# Status Effect Handling
func _on_status_effect_tick(effect, damage: int) -> void:
	# God mode prevents all damage including poison
	if god_mode:
		return

	# Poison damage ignores invincibility but respects protection
	var actual_damage = int(damage * (1.0 - damage_reduction))
	actual_damage = max(1, actual_damage)

	if _health_component:
		_health_component.take_damage(actual_damage)
	else:
		current_health = max(0, current_health - actual_damage)
		health_changed.emit(current_health, max_health)
		if current_health <= 0:
			_on_died()

func _on_status_effect_applied(effect) -> void:
	# Visual feedback - green tint for poison
	var StatusEffectClass = load("res://scripts/components/status_effect.gd")
	if effect.type == StatusEffectClass.Type.POISON:
		_start_poison_visual()

func _on_status_effect_removed(effect) -> void:
	# Remove visual effect
	var StatusEffectClass = load("res://scripts/components/status_effect.gd")
	if effect.type == StatusEffectClass.Type.POISON:
		_stop_poison_visual()

var _poison_tween: Tween = null
var _poison_particles: Array = []

func _start_poison_visual() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Stop existing tween
	if _poison_tween and _poison_tween.is_valid():
		_poison_tween.kill()

	# Start pulsing green tint
	_poison_tween = create_tween()
	_poison_tween.set_loops()
	_poison_tween.tween_property(sprite, "modulate", Color(0.4, 1.0, 0.4), 0.3)
	_poison_tween.tween_property(sprite, "modulate", Color(0.7, 1.0, 0.7), 0.3)

	# Add pixel poison particles
	_spawn_poison_particles()

func _stop_poison_visual() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite and not is_invincible:
		sprite.modulate = Color(1, 1, 1, 1)

	# Stop tween
	if _poison_tween and _poison_tween.is_valid():
		_poison_tween.kill()
		_poison_tween = null

	# Remove particles
	for particle in _poison_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	_poison_particles.clear()

func _spawn_poison_particles() -> void:
	# Create small pixel particles that float up
	for i in range(4):
		var particle = ColorRect.new()
		particle.name = "PoisonParticle" + str(i)
		particle.size = Vector2(4, 4)
		particle.color = Color(0.3, 0.9, 0.3, 0.8)
		particle.z_index = 20
		add_child(particle)
		_poison_particles.append(particle)

		# Animate particle floating up
		_animate_poison_particle(particle, i)

func _animate_poison_particle(particle: ColorRect, index: int) -> void:
	var start_x = randf_range(-12, 12)
	var start_y = randf_range(-8, 8)
	particle.position = Vector2(start_x, start_y)

	var tween = create_tween()
	tween.set_loops()

	# Float up and fade, then reset
	var end_y = start_y - 20
	tween.tween_property(particle, "position:y", end_y, 0.8 + index * 0.2)
	tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.8 + index * 0.2)
	tween.tween_callback(func():
		particle.position = Vector2(randf_range(-12, 12), randf_range(-8, 8))
		particle.modulate.a = 0.8
	)
