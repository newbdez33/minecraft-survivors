extends Area2D
class_name XPOrb
## Experience orb dropped by enemies, attracted to player

signal collected(xp_value: int)

@export var xp_value: int = 5
@export var pickup_radius: float = 50.0
@export var attract_radius: float = 150.0
@export var attract_speed: float = 300.0
@export var bob_amplitude: float = 3.0
@export var bob_speed: float = 4.0

var _target: Node2D = null
var _attracted: bool = false
var _initial_y: float = 0.0
var _bob_time: float = 0.0

func _ready() -> void:
	_initial_y = position.y
	_bob_time = randf() * TAU  # Random start phase

	# Setup collision
	collision_layer = 4  # Pickups layer
	collision_mask = 1   # Detect player

	# Connect signals
	body_entered.connect(_on_body_entered)

	# Find player
	await get_tree().process_frame
	_find_player()

func _physics_process(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_find_player()
		return

	var distance = global_position.distance_to(_target.global_position)

	# Check if within attract range
	if distance <= attract_radius:
		_attracted = true

	# Move toward player if attracted
	if _attracted:
		var direction = (_target.global_position - global_position).normalized()
		var speed = attract_speed * (1.0 + (attract_radius - distance) / attract_radius)
		position += direction * speed * delta
	else:
		# Bob up and down when idle
		_bob_time += delta * bob_speed
		position.y = _initial_y + sin(_bob_time) * bob_amplitude

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(xp_value)

		# Add XP to player if method exists
		if body.has_method("add_xp"):
			body.add_xp(xp_value)

		# Play collect effect and remove
		_play_collect_effect()
		queue_free()

func _play_collect_effect() -> void:
	# Simple scale tween before free
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)

func set_xp(value: int) -> void:
	xp_value = value
	# Scale size based on XP value
	var scale_factor = 1.0 + (value - 5) * 0.05
	scale = Vector2(scale_factor, scale_factor)
