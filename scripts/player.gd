extends CharacterBody2D
## Player character controller (Steve)
## Handles movement, health, and combat interactions

signal health_changed(current: int, maximum: int)
signal died
signal xp_changed(current: int, needed: int)
signal leveled_up(new_level: int)

@export var speed: float = 200.0
@export var max_health: int = 100
@export var invincibility_time: float = 1.0
@export var base_xp_requirement: int = 10
@export var xp_scaling: float = 1.5

var current_health: int
var is_invincible: bool = false
var _health_component: Node = null

# XP/Level system
var current_xp: int = 0
var current_level: int = 1
var xp_to_next_level: int = 10

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

func _physics_process(_delta: float) -> void:
	var input_direction = get_input_direction()

	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return direction

func take_damage(amount: int) -> void:
	if is_invincible:
		return

	if _health_component:
		_health_component.take_damage(amount)
	else:
		current_health = max(0, current_health - amount)
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
	current_xp += amount

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
