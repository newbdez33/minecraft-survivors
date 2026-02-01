extends Area2D
class_name TotemPickup
## Totem of Undying - Rare boss drop that gives extra life

signal collected()

@export var pickup_radius: float = 50.0
@export var attract_radius: float = 180.0
@export var attract_speed: float = 200.0
@export var bob_amplitude: float = 5.0
@export var bob_speed: float = 2.5

var _target: Node2D = null
var _attracted: bool = false
var _initial_y: float = 0.0
var _bob_time: float = 0.0
var _glow_time: float = 0.0
var _is_collecting: bool = false

func _ready() -> void:
	_initial_y = position.y
	_bob_time = randf() * TAU

	# Setup collision
	collision_layer = 4  # Pickups layer
	collision_mask = 1   # Player layer

	body_entered.connect(_on_body_entered)

	# Find player
	await get_tree().process_frame
	_find_player()


func _physics_process(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_find_player()
		return

	var distance = global_position.distance_to(_target.global_position)

	if distance <= attract_radius:
		_attracted = true

	if _attracted:
		var direction = (_target.global_position - global_position).normalized()
		var speed = attract_speed * (1.0 + (attract_radius - distance) / attract_radius)
		position += direction * speed * delta
	else:
		_bob_time += delta * bob_speed
		position.y = _initial_y + sin(_bob_time) * bob_amplitude

	# Golden glow effect
	_update_glow(delta)


func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _is_collecting:
		_collect(body)


func _collect(player: Node2D) -> void:
	_is_collecting = true
	set_deferred("monitoring", false)
	collected.emit()

	# Give player totem effect
	if player.has_method("add_totem"):
		player.add_totem()
	elif "has_totem" in player:
		player.has_totem = true

	_play_collect_effect()


func _play_collect_effect() -> void:
	# Spawn golden burst effect
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene and get_tree() and get_tree().current_scene:
		for i in range(3):
			var effect = effect_scene.instantiate()
			var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
			effect.global_position = global_position + offset
			effect.modulate = Color(1.0, 0.85, 0.0)  # Gold
			effect.scale = Vector2(1.5, 1.5)
			get_tree().current_scene.add_child(effect)

	# Scale up and fade with golden flash
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1.0, 1.0, 0.5, 0.0), 0.2)
	tween.tween_callback(queue_free)


func _update_glow(delta: float) -> void:
	_glow_time += delta
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Golden pulsing glow
		var pulse = 0.8 + 0.2 * sin(_glow_time * 4.0)
		sprite.modulate = Color(1.0, pulse, 0.6)
