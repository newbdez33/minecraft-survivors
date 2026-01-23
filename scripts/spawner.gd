extends Node
class_name MobSpawner
## Spawns enemies around the player at regular intervals

signal enemy_spawned(enemy: Node2D)

@export var spawn_interval: float = 2.0
@export var max_enemies: int = 50
@export var spawn_radius_min: float = 400.0
@export var spawn_radius_max: float = 600.0

# Enemy scenes
var zombie_scene: PackedScene
var skeleton_scene: PackedScene
var creeper_scene: PackedScene
var spider_scene: PackedScene

# Spawn weights (increase over time)
var zombie_weight: float = 100.0
var skeleton_weight: float = 0.0
var creeper_weight: float = 0.0
var spider_weight: float = 0.0

var player: Node2D = null
var spawn_timer: Timer
var current_enemy_count: int = 0
var game_time: float = 0.0

func _ready() -> void:
	# Create spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Find player
	_find_player()

	# Load enemy scenes
	zombie_scene = load("res://scenes/enemies/zombie.tscn")
	skeleton_scene = load("res://scenes/enemies/skeleton.tscn")
	creeper_scene = load("res://scenes/enemies/creeper.tscn")
	spider_scene = load("res://scenes/enemies/spider.tscn")

func _process(delta: float) -> void:
	game_time += delta
	_update_spawn_weights()

func _update_spawn_weights() -> void:
	# Introduce new enemies over time
	# Skeletons after 30 seconds
	if game_time > 30.0:
		skeleton_weight = min(50.0, (game_time - 30.0) * 0.5)

	# Spiders after 60 seconds
	if game_time > 60.0:
		spider_weight = min(40.0, (game_time - 60.0) * 0.4)

	# Creepers after 90 seconds
	if game_time > 90.0:
		creeper_weight = min(30.0, (game_time - 90.0) * 0.3)

func _find_player() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _on_spawn_timer_timeout() -> void:
	if not player:
		_find_player()
		return

	if current_enemy_count >= max_enemies:
		return

	_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy_scene = _select_enemy_type()
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	if not enemy:
		return

	# Calculate spawn position (random point in ring around player)
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	var spawn_pos = player.global_position + spawn_offset

	enemy.global_position = spawn_pos

	# Connect to enemy death signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

	# Add to scene
	get_parent().add_child(enemy)
	current_enemy_count += 1

	enemy_spawned.emit(enemy)

func _select_enemy_type() -> PackedScene:
	var total_weight = zombie_weight + skeleton_weight + creeper_weight + spider_weight
	var roll = randf() * total_weight

	if roll < zombie_weight:
		return zombie_scene
	roll -= zombie_weight

	if roll < skeleton_weight:
		return skeleton_scene
	roll -= skeleton_weight

	if roll < spider_weight:
		return spider_scene
	roll -= spider_weight

	if roll < creeper_weight:
		return creeper_scene

	return zombie_scene

func _on_enemy_died(_xp_value: int) -> void:
	current_enemy_count -= 1

func set_spawn_rate(interval: float) -> void:
	spawn_interval = interval
	if spawn_timer:
		spawn_timer.wait_time = interval
