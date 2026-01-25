extends Node
class_name MobSpawner
## Spawns enemies around the player at regular intervals

signal enemy_spawned(enemy: Node2D)
signal enemy_killed(xp_value: int)

## Base spawn interval (reduced from 2.0 for 60% more spawns)
@export var spawn_interval: float = 1.25
## Base max enemies (increased from 30 for 60% more capacity)
@export var max_enemies: int = 48
@export var spawn_radius_min: float = 400.0
@export var spawn_radius_max: float = 600.0

## Night modifiers
@export var night_spawn_multiplier: float = 0.5  # Halve interval = double frequency
@export var night_max_enemy_multiplier: float = 2.0  # Double max enemies at night

## Day/night cycle reference
var day_night_cycle: Node = null
var _base_spawn_interval: float = 1.25
var _base_max_enemies: int = 48
var _is_night: bool = false

# Enemy scenes
var zombie_scene: PackedScene
var skeleton_scene: PackedScene
var creeper_scene: PackedScene
var spider_scene: PackedScene
var enderman_scene: PackedScene
var witch_scene: PackedScene

# Spawn weights (increase over time)
var zombie_weight: float = 100.0
var skeleton_weight: float = 0.0
var creeper_weight: float = 0.0
var spider_weight: float = 0.0
var enderman_weight: float = 0.0
var witch_weight: float = 0.0

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
	enderman_scene = load("res://scenes/enemies/enderman.tscn")
	witch_scene = load("res://scenes/enemies/witch.tscn")

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

	# Enderman after 120 seconds (rare, teleporting enemy)
	if game_time > 120.0:
		enderman_weight = min(20.0, (game_time - 120.0) * 0.2)

	# Witch after 150 seconds (rare, ranged enemy)
	if game_time > 150.0:
		witch_weight = min(15.0, (game_time - 150.0) * 0.15)

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
	var total_weight = zombie_weight + skeleton_weight + creeper_weight + spider_weight + enderman_weight + witch_weight
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
	roll -= creeper_weight

	if roll < enderman_weight:
		return enderman_scene
	roll -= enderman_weight

	if roll < witch_weight:
		return witch_scene

	return zombie_scene

func _on_enemy_died(xp_value: int) -> void:
	current_enemy_count -= 1
	enemy_killed.emit(xp_value)

func set_spawn_rate(interval: float) -> void:
	spawn_interval = interval
	if spawn_timer:
		spawn_timer.wait_time = interval

func set_wave(wave: int) -> void:
	# Increase difficulty based on wave (adjusted for 60% base increase)
	# Faster spawns: 1.25s → 1.0s → 0.75s → 0.5s
	var new_interval = max(0.5, 1.25 - (wave - 1) * 0.1)
	_base_spawn_interval = new_interval

	# More max enemies: 48 → 56 → 64 → 72... (increased from 30 + 5 per wave)
	var new_max = 48 + (wave - 1) * 8
	_base_max_enemies = new_max

	# Apply values (with night modifier if applicable)
	if _is_night:
		_apply_night_modifier()
	else:
		set_spawn_rate(_base_spawn_interval)
		max_enemies = _base_max_enemies

	# Boost weights based on wave (in addition to time-based)
	if wave >= 2:
		skeleton_weight = max(skeleton_weight, 20.0)
	if wave >= 3:
		spider_weight = max(spider_weight, 15.0)
	if wave >= 4:
		creeper_weight = max(creeper_weight, 10.0)
	if wave >= 5:
		enderman_weight = max(enderman_weight, 8.0)
	if wave >= 6:
		witch_weight = max(witch_weight, 5.0)

## Called when night starts
func _on_night_started() -> void:
	_is_night = true
	_apply_night_modifier()

## Called when day starts
func _on_day_started() -> void:
	_is_night = false
	_remove_night_modifier()

## Apply night spawn modifiers (double frequency and max enemies)
func _apply_night_modifier() -> void:
	var night_interval = _base_spawn_interval * night_spawn_multiplier
	set_spawn_rate(night_interval)
	max_enemies = int(_base_max_enemies * night_max_enemy_multiplier)

## Remove night modifiers (restore daytime values)
func _remove_night_modifier() -> void:
	set_spawn_rate(_base_spawn_interval)
	max_enemies = _base_max_enemies
