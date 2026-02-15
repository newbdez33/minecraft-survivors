extends Node
class_name MobSpawner
## Spawns enemies around the player at regular intervals (Cao Cao's forces)

const EliteModifierClass = preload("res://scripts/components/elite_modifier.gd")
const WaveScalerClass = preload("res://scripts/systems/wave_scaler.gd")

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

## Elite tracking
var _current_wave: int = 1
var _elite_count: int = 0

# Enemy scenes
var infantry_scene: PackedScene
var archer_scene: PackedScene
var fire_soldier_scene: PackedScene
var cavalry_scene: PackedScene
var assassin_scene: PackedScene
var sorcerer_scene: PackedScene

# Spawn weights (increase over time)
var infantry_weight: float = 100.0
var archer_weight: float = 0.0
var fire_soldier_weight: float = 0.0
var cavalry_weight: float = 0.0
var assassin_weight: float = 0.0
var sorcerer_weight: float = 0.0

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
	infantry_scene = load("res://scenes/enemies/infantry.tscn")
	archer_scene = load("res://scenes/enemies/archer.tscn")
	fire_soldier_scene = load("res://scenes/enemies/fire_soldier.tscn")
	cavalry_scene = load("res://scenes/enemies/cavalry.tscn")
	assassin_scene = load("res://scenes/enemies/assassin.tscn")
	sorcerer_scene = load("res://scenes/enemies/sorcerer.tscn")

func _process(delta: float) -> void:
	game_time += delta
	_update_spawn_weights()

func _update_spawn_weights() -> void:
	# Introduce new enemies over time
	# Archers after 30 seconds
	if game_time > 30.0:
		archer_weight = min(50.0, (game_time - 30.0) * 0.5)

	# Cavalry after 60 seconds
	if game_time > 60.0:
		cavalry_weight = min(40.0, (game_time - 60.0) * 0.4)

	# Fire soldiers after 90 seconds
	if game_time > 90.0:
		fire_soldier_weight = min(30.0, (game_time - 90.0) * 0.3)

	# Assassins after 120 seconds (rare, teleporting enemy)
	if game_time > 120.0:
		assassin_weight = min(20.0, (game_time - 120.0) * 0.2)

	# Sorcerers after 150 seconds (rare, ranged enemy)
	if game_time > 150.0:
		sorcerer_weight = min(15.0, (game_time - 150.0) * 0.15)

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
		enemy.died.connect(_on_enemy_died.bind(enemy))

	# Connect rally signal for elite infantry
	if enemy.has_signal("rally_requested"):
		enemy.rally_requested.connect(_on_rally_requested)

	# Add to scene first (needed for AudioManager access in elite apply)
	get_parent().add_child(enemy)
	current_enemy_count += 1

	# Apply post-wave-30 scaling to normal enemies
	WaveScalerClass.apply_scaling(enemy, _current_wave, false)

	# Roll for elite promotion (after adding to tree so SFX works)
	if _elite_count < _get_max_elites() and randf() < _get_elite_chance():
		EliteModifierClass.apply(enemy)
		_elite_count += 1

	enemy_spawned.emit(enemy)

func _select_enemy_type() -> PackedScene:
	var total_weight = infantry_weight + archer_weight + fire_soldier_weight + cavalry_weight + assassin_weight + sorcerer_weight
	var roll = randf() * total_weight

	if roll < infantry_weight:
		return infantry_scene
	roll -= infantry_weight

	if roll < archer_weight:
		return archer_scene
	roll -= archer_weight

	if roll < cavalry_weight:
		return cavalry_scene
	roll -= cavalry_weight

	if roll < fire_soldier_weight:
		return fire_soldier_scene
	roll -= fire_soldier_weight

	if roll < assassin_weight:
		return assassin_scene
	roll -= assassin_weight

	if roll < sorcerer_weight:
		return sorcerer_scene

	return infantry_scene

func _on_enemy_died(xp_value: int, enemy: Node2D = null) -> void:
	current_enemy_count -= 1
	if enemy and is_instance_valid(enemy) and enemy.is_in_group("elite"):
		_elite_count = maxi(_elite_count - 1, 0)
	enemy_killed.emit(xp_value)

func set_spawn_rate(interval: float) -> void:
	spawn_interval = interval
	if spawn_timer:
		spawn_timer.wait_time = interval

func set_wave(wave: int) -> void:
	_current_wave = wave
	# Reconcile elite count from actual scene state to prevent drift
	if get_tree():
		_elite_count = get_tree().get_nodes_in_group("elite").size()

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
		archer_weight = max(archer_weight, 20.0)
	if wave >= 3:
		cavalry_weight = max(cavalry_weight, 15.0)
	if wave >= 4:
		fire_soldier_weight = max(fire_soldier_weight, 10.0)
	if wave >= 5:
		assassin_weight = max(assassin_weight, 8.0)
	if wave >= 6:
		sorcerer_weight = max(sorcerer_weight, 5.0)

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


## Pause spawning (used during boss fights)
var _spawn_paused: bool = false

func pause_spawning() -> void:
	_spawn_paused = true
	if spawn_timer:
		spawn_timer.stop()


## Resume spawning (after boss is defeated)
func resume_spawning() -> void:
	_spawn_paused = false
	if spawn_timer:
		spawn_timer.start()


## Check if spawning is paused
func is_spawning_paused() -> bool:
	return _spawn_paused


## Get elite spawn chance based on current wave and time of day
func _get_elite_chance() -> float:
	# Post-wave-30 scaling overrides base logic
	var scaled = WaveScalerClass.get_elite_chance(_current_wave, _is_night)
	if scaled >= 0.0:
		return scaled

	var chance: float = 0.0
	if _current_wave < 4:
		chance = 0.0
	elif _current_wave <= 6:
		chance = 0.05
	elif _current_wave <= 9:
		chance = 0.10
	elif _current_wave <= 14:
		chance = 0.15
	elif _current_wave <= 19:
		chance = 0.20
	else:
		chance = 0.25

	# Night bonus
	if _is_night:
		chance += 0.10

	return chance


## Get max simultaneous elites based on current wave
func _get_max_elites() -> int:
	# Post-wave-30 scaling overrides base logic
	var scaled = WaveScalerClass.get_max_elites(_current_wave)
	if scaled >= 0:
		return scaled

	if _current_wave < 4:
		return 0
	elif _current_wave <= 9:
		return 2
	elif _current_wave <= 14:
		return 3
	elif _current_wave <= 19:
		return 4
	else:
		return 5


## Handle elite infantry war cry: spawn tracked normal infantry
## Deferred to avoid physics query errors when called from _on_body_entered chain
func _on_rally_requested(pos: Vector2, count: int) -> void:
	call_deferred("_spawn_rally_infantry", pos, count)

func _spawn_rally_infantry(pos: Vector2, count: int) -> void:
	if not infantry_scene:
		return
	for i in range(count):
		var soldier = infantry_scene.instantiate()
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		soldier.global_position = pos + offset
		if soldier.has_signal("died"):
			soldier.died.connect(_on_enemy_died.bind(soldier))
		if soldier.has_signal("rally_requested"):
			soldier.rally_requested.connect(_on_rally_requested)
		get_parent().add_child(soldier)
		current_enemy_count += 1
		enemy_spawned.emit(soldier)
