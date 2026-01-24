extends Node
class_name HealthPickupSpawner
## Spawns health pickups periodically around the map

signal pickup_spawned(pickup: Node2D)

@export var spawn_interval: float = 20.0  # Spawn every 20 seconds
@export var spawn_interval_min: float = 15.0  # Minimum after difficulty scaling
@export var max_pickups: int = 3  # Max pickups on map at once
@export var spawn_radius_min: float = 200.0
@export var spawn_radius_max: float = 500.0
@export var initial_delay: float = 30.0  # Don't spawn for first 30 seconds

var health_pickup_scene: PackedScene
var player: Node2D = null
var spawn_timer: Timer
var current_pickup_count: int = 0
var game_time: float = 0.0
var _spawning_enabled: bool = false

func _ready() -> void:
	# Load health pickup scene
	health_pickup_scene = load("res://scenes/pickups/health_pickup.tscn")

	# Create spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Find player
	_find_player()

	# Start initial delay timer
	var delay_timer = get_tree().create_timer(initial_delay)
	delay_timer.timeout.connect(_enable_spawning)

func _process(delta: float) -> void:
	game_time += delta

func _enable_spawning() -> void:
	_spawning_enabled = true
	spawn_timer.start()
	print("[HEALTH SPAWNER] Health pickups enabled after %.0fs delay" % initial_delay)

func _find_player() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _on_spawn_timer_timeout() -> void:
	if not _spawning_enabled:
		return

	if not player or not is_instance_valid(player):
		_find_player()
		return

	# Check player health - spawn more frequently when low health
	var health_ratio: float = 1.0
	if "current_health" in player and "max_health" in player:
		health_ratio = float(player.current_health) / float(player.max_health)

	# Higher chance to spawn when player has low health
	if health_ratio > 0.5 and current_pickup_count >= max_pickups:
		return

	# Always spawn if player is low health (< 30%)
	if health_ratio < 0.3 or current_pickup_count < max_pickups:
		_spawn_pickup()

	# Adjust next spawn time based on player health
	var next_interval = spawn_interval
	if health_ratio < 0.3:
		next_interval = spawn_interval_min  # Faster spawns when low health
	elif health_ratio < 0.5:
		next_interval = lerp(spawn_interval_min, spawn_interval, 0.5)

	spawn_timer.wait_time = next_interval

func _spawn_pickup() -> void:
	if not health_pickup_scene:
		push_error("[HEALTH SPAWNER] Health pickup scene not loaded")
		return

	if not player:
		return

	var pickup = health_pickup_scene.instantiate()
	if not pickup:
		return

	# Calculate spawn position (random point in ring around player)
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	var spawn_pos = player.global_position + spawn_offset

	pickup.global_position = spawn_pos

	# Connect to pickup collected signal
	if pickup.has_signal("collected"):
		pickup.collected.connect(_on_pickup_collected)

	# Track when pickup is freed
	pickup.tree_exited.connect(_on_pickup_removed)

	# Add to scene
	get_parent().add_child(pickup)
	current_pickup_count += 1

	pickup_spawned.emit(pickup)
	print("[HEALTH SPAWNER] Spawned health pickup at %s (total: %d)" % [spawn_pos, current_pickup_count])

func _on_pickup_collected(_heal_amount: int) -> void:
	# Count is decremented in _on_pickup_removed when freed
	pass

func _on_pickup_removed() -> void:
	current_pickup_count = max(0, current_pickup_count - 1)

func set_spawn_rate(interval: float) -> void:
	spawn_interval = max(spawn_interval_min, interval)
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval

func set_wave(wave: int) -> void:
	# Slightly faster spawns at higher waves (players need more healing)
	var new_interval = max(spawn_interval_min, spawn_interval - (wave - 1) * 1.0)
	set_spawn_rate(new_interval)
