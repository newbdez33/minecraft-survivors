extends Area2D
class_name HealthPickup
## Health pickup (golden apple) that heals the player

signal collected(heal_amount: int)

@export var heal_percent: float = 0.5  # Heal 50% of max HP
@export var pickup_radius: float = 30.0
@export var attract_radius: float = 120.0
@export var attract_speed: float = 250.0
@export var bob_amplitude: float = 4.0
@export var bob_speed: float = 3.0
@export var despawn_time: float = 30.0  # Despawn after 30 seconds

var _target: Node2D = null
var _attracted: bool = false
var _initial_y: float = 0.0
var _bob_time: float = 0.0
var _despawn_timer: float = 0.0
var _is_collecting: bool = false

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
	# Despawn timer
	_despawn_timer += delta
	if _despawn_timer >= despawn_time:
		_fade_out()
		return

	# Start blinking when close to despawn (last 5 seconds)
	if _despawn_timer >= despawn_time - 5.0:
		var blink_alpha = 0.5 + 0.5 * sin(_despawn_timer * 10.0)
		modulate.a = blink_alpha

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
	if body.is_in_group("player") and not _is_collecting:
		_heal_player(body)

func _heal_player(player: Node2D) -> void:
	_is_collecting = true
	set_deferred("monitoring", false)
	var heal_amount: int = 0

	# Calculate heal amount based on player's max health
	if "max_health" in player:
		heal_amount = int(player.max_health * heal_percent)
	elif player.has_method("get_max_health"):
		heal_amount = int(player.get_max_health() * heal_percent)
	else:
		heal_amount = 50  # Fallback

	# Apply healing
	if player.has_method("heal"):
		player.heal(heal_amount)
	elif "current_health" in player and "max_health" in player:
		player.current_health = min(player.current_health + heal_amount, player.max_health)

	collected.emit(heal_amount)

	# Play collect effect and remove
	_play_collect_effect()

func _play_collect_effect() -> void:
	# Spawn particle effect
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color.GOLD
		effect.scale = Vector2(2.0, 2.0)
		get_tree().current_scene.add_child(effect)

	# Scale up and fade
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)

func _fade_out() -> void:
	if _is_collecting:
		return  # Already being collected
	_is_collecting = true
	set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
