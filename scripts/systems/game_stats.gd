extends Node
class_name GameStats

## Game Statistics Tracker
## Tracks all game statistics for display on Game Over screen
## Designed to be used as Autoload singleton

signal kill_added(total_kills: int)
signal stat_updated(stat_name: String, value: Variant)

## Time survived in seconds
var survival_time: float = 0.0

## Number of enemies killed
var kills: int = 0

## Total damage dealt to enemies
var damage_dealt: int = 0

## Total damage taken by player
var damage_taken: int = 0

## Total XP collected
var xp_collected: int = 0

## Highest wave reached
var highest_wave: int = 1

## Highest level reached
var highest_level: int = 1

## Is timer running
var _is_tracking: bool = false


func _process(delta: float) -> void:
	if _is_tracking:
		survival_time += delta


## Start tracking survival time
func start_tracking() -> void:
	_is_tracking = true


## Stop tracking survival time
func stop_tracking() -> void:
	_is_tracking = false


## Add a kill to the counter
func add_kill() -> void:
	kills += 1
	kill_added.emit(kills)
	stat_updated.emit("kills", kills)


## Add damage dealt
func add_damage_dealt(amount: int) -> void:
	damage_dealt += amount
	stat_updated.emit("damage_dealt", damage_dealt)


## Add damage taken
func add_damage_taken(amount: int) -> void:
	damage_taken += amount
	stat_updated.emit("damage_taken", damage_taken)


## Add XP collected
func add_xp(amount: int) -> void:
	xp_collected += amount
	stat_updated.emit("xp_collected", xp_collected)


## Update highest wave
func set_wave(wave: int) -> void:
	if wave > highest_wave:
		highest_wave = wave
		stat_updated.emit("highest_wave", highest_wave)


## Update highest level
func set_level(level: int) -> void:
	if level > highest_level:
		highest_level = level
		stat_updated.emit("highest_level", highest_level)


## Reset all stats for new game
func reset() -> void:
	survival_time = 0.0
	kills = 0
	damage_dealt = 0
	damage_taken = 0
	xp_collected = 0
	highest_wave = 1
	highest_level = 1
	_is_tracking = false


## Get all stats as dictionary
func get_stats() -> Dictionary:
	return {
		"survival_time": survival_time,
		"kills": kills,
		"damage_dealt": damage_dealt,
		"damage_taken": damage_taken,
		"xp_collected": xp_collected,
		"highest_wave": highest_wave,
		"highest_level": highest_level
	}


## Get formatted survival time string (MM:SS)
func get_survival_time_formatted() -> String:
	var minutes = int(survival_time) / 60
	var seconds = int(survival_time) % 60
	return "%02d:%02d" % [minutes, seconds]
