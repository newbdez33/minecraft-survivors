extends Area2D
class_name EmeraldPickup
## Emerald pickup - Boss currency drop

signal collected(emerald_value: int)

@export var value: int = 30
@export var pickup_radius: float = 40.0
@export var attract_radius: float = 150.0
@export var attract_speed: float = 280.0
@export var bob_amplitude: float = 4.0
@export var bob_speed: float = 3.5

var _target: Node2D = null
var _attracted: bool = false
var _initial_y: float = 0.0
var _bob_time: float = 0.0

func _ready() -> void:
	_initial_y = position.y
	_bob_time = randf() * TAU

	# Setup collision
	collision_layer = 4  # Pickups layer
	collision_mask = 1   # Player layer

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

	# Sparkle effect
	_update_sparkle(delta)


func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect(body)


func _collect(player: Node2D) -> void:
	collected.emit(value)

	# Add emeralds to player if method exists
	if player.has_method("add_emeralds"):
		player.add_emeralds(value)

	# Play collect effect
	_play_collect_effect()


func _play_collect_effect() -> void:
	# Spawn sparkle effect
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene and get_tree() and get_tree().current_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color(0.2, 1.0, 0.4)  # Green
		effect.scale = Vector2(1.2, 1.2)
		get_tree().current_scene.add_child(effect)

	# Scale up and fade
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)


var _sparkle_timer: float = 0.0

func _update_sparkle(delta: float) -> void:
	_sparkle_timer += delta
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Subtle color pulse
		var pulse = 0.8 + 0.2 * sin(_sparkle_timer * 5.0)
		sprite.modulate = Color(pulse, 1.0, pulse)
