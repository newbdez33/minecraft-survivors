extends Area2D
class_name MeatPickup
## Meat pickup dropped by enemies - restores 1 heart (10 HP)

signal collected(heal_amount: int)

const HEAL_AMOUNT: int = 10  # 1 heart = 10 HP

@export var pickup_radius: float = 25.0
@export var attract_radius: float = 100.0
@export var attract_speed: float = 300.0
@export var bob_amplitude: float = 3.0
@export var bob_speed: float = 4.0
@export var despawn_time: float = 15.0  # Shorter despawn than golden apple

var _target: Node2D = null
var _attracted: bool = false
var _initial_y: float = 0.0
var _bob_time: float = 0.0
var _despawn_timer: float = 0.0
var _is_collecting: bool = false

func _ready() -> void:
	_initial_y = position.y
	_bob_time = randf() * TAU

	collision_layer = 4  # Pickups layer
	collision_mask = 1   # Detect player

	body_entered.connect(_on_body_entered)

	await get_tree().process_frame
	_find_player()

func _physics_process(delta: float) -> void:
	_despawn_timer += delta
	if _despawn_timer >= despawn_time:
		_fade_out()
		return

	# Blink when close to despawn (last 3 seconds)
	if _despawn_timer >= despawn_time - 3.0:
		var blink_alpha = 0.5 + 0.5 * sin(_despawn_timer * 12.0)
		modulate.a = blink_alpha

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

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _is_collecting:
		_heal_player(body)

func _heal_player(player: Node2D) -> void:
	_is_collecting = true
	set_deferred("monitoring", false)
	if player.has_method("heal"):
		player.heal(HEAL_AMOUNT)
	elif "current_health" in player and "max_health" in player:
		player.current_health = min(player.current_health + HEAL_AMOUNT, player.max_health)

	collected.emit(HEAL_AMOUNT)
	_play_collect_effect()

func _play_collect_effect() -> void:
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color(1.0, 0.4, 0.4)  # Red tint for meat
		get_tree().current_scene.add_child(effect)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)

func _fade_out() -> void:
	if _is_collecting:
		return  # Already being collected
	_is_collecting = true
	set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
