extends Node
class_name WaveManager

## Wave Manager System
## Manages enemy waves with scaling difficulty

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemies_spawned(enemy_list: Array)

## Current wave number
var current_wave: int = 0

## Time between waves in seconds
@export var wave_interval: float = 30.0

## Base number of enemies per wave (increased 60% from original 5)
@export var base_enemies_per_wave: int = 8

## Enemy count multiplier per wave (exponential scaling)
@export var wave_scaling: float = 1.2

## Multiplier for enemy count during night
@export var night_multiplier: float = 2.0

## Is wave system active
var _is_active: bool = false

## Timer for wave intervals
var _wave_timer: float = 0.0

## Reference to day/night cycle (optional)
var day_night_cycle: Node = null

## Enemy type weights by wave range
## Format: { "enemy_type": weight }
var _wave_enemy_weights: Dictionary = {
	# Waves 1-3: Only Infantry
	1: { "infantry": 1.0 },
	# Waves 4-6: Infantry, Archers, Cavalry
	4: { "infantry": 0.6, "archer": 0.3, "cavalry": 0.1 },
	# Waves 7-9: Add Fire Soldiers
	7: { "infantry": 0.4, "archer": 0.3, "fire_soldier": 0.15, "cavalry": 0.15 },
	# Waves 10+: Full mix
	10: { "infantry": 0.3, "archer": 0.25, "fire_soldier": 0.2, "cavalry": 0.25 }
}


func _process(delta: float) -> void:
	if not _is_active:
		return

	_wave_timer += delta

	if _wave_timer >= wave_interval:
		_wave_timer = 0.0
		start_wave()


## Start the wave system
func start() -> void:
	_is_active = true
	_wave_timer = 0.0
	# Start first wave immediately
	start_wave()


## Stop the wave system
func stop() -> void:
	_is_active = false


## Reset wave system
func reset() -> void:
	current_wave = 0
	_wave_timer = 0.0
	_is_active = false


## Start a new wave
func start_wave() -> void:
	current_wave += 1
	wave_started.emit(current_wave)

	var enemy_count = get_enemies_for_wave(current_wave)
	var enemy_types = get_enemy_types_for_wave(current_wave)

	enemies_spawned.emit(_generate_enemy_list(enemy_count, enemy_types))


## Complete current wave (called externally when all enemies dead)
func complete_wave() -> void:
	wave_completed.emit(current_wave)


## Calculate number of enemies for a given wave
func get_enemies_for_wave(wave: int) -> int:
	var base_count = base_enemies_per_wave * pow(wave_scaling, wave - 1)

	# Apply night multiplier if it's night
	if day_night_cycle and day_night_cycle.is_night():
		base_count *= night_multiplier

	return int(ceil(base_count))


## Get enemy type weights for a given wave
func get_enemy_types_for_wave(wave: int) -> Dictionary:
	var weights = { "infantry": 1.0 }

	# Find the highest wave threshold that applies
	for threshold in _wave_enemy_weights.keys():
		if wave >= threshold:
			weights = _wave_enemy_weights[threshold]

	return weights


## Generate a list of enemy types to spawn based on weights
func _generate_enemy_list(count: int, weights: Dictionary) -> Array:
	var enemies = []
	var total_weight = 0.0

	for weight in weights.values():
		total_weight += weight

	for i in range(count):
		var roll = randf() * total_weight
		var cumulative = 0.0

		for enemy_type in weights.keys():
			cumulative += weights[enemy_type]
			if roll <= cumulative:
				enemies.append(enemy_type)
				break

	return enemies


## Get current wave info as dictionary
func get_wave_info() -> Dictionary:
	return {
		"current_wave": current_wave,
		"enemies_count": get_enemies_for_wave(current_wave),
		"enemy_types": get_enemy_types_for_wave(current_wave),
		"is_night": day_night_cycle.is_night() if day_night_cycle else false,
		"is_boss_wave": is_boss_wave(current_wave)
	}


## Check if a wave is a boss wave
## Boss waves occur every 5 waves (5, 10, 15, etc.)
func is_boss_wave(wave: int) -> bool:
	return wave > 0 and wave % 5 == 0


## Boss wave mapping - specific bosses at specific waves
const BOSS_WAVES = {
	5: "xiahou_dun",
	10: "xu_chu",
	15: "zhang_liao",
	20: "dian_wei",
	25: "sima_yi",
	30: "lv_bu"
}

## Get the boss type for a specific wave
func get_boss_for_wave(wave: int) -> String:
	if not is_boss_wave(wave):
		return ""

	# Check for specific boss at this wave
	if wave in BOSS_WAVES:
		return BOSS_WAVES[wave]

	# For waves beyond 30, cycle through bosses with increasing difficulty
	var boss_cycle = ["xiahou_dun", "xu_chu", "zhang_liao", "dian_wei", "sima_yi", "lv_bu"]
	var cycle_index = ((wave / 5) - 1) % boss_cycle.size()
	return boss_cycle[cycle_index]
