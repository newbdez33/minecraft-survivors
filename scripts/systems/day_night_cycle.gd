extends Node
class_name DayNightCycle

## Day/Night Cycle System
## Manages game time, affecting visuals and mob spawning

signal time_changed(current_time: float, is_night: bool)
signal night_started()
signal day_started()

enum TimeOfDay { DAWN, DAY, DUSK, NIGHT }

## Current time in seconds (0 = start of day)
var current_time: float = 0.0

## Duration of daytime in seconds
@export var day_duration: float = 60.0

## Duration of nighttime in seconds
@export var night_duration: float = 60.0

## Transition time between day/night in seconds
@export var transition_time: float = 5.0

## Night visual tint color
@export var night_tint: Color = Color(0.2, 0.2, 0.4, 0.5)

## Current day number
var current_day: int = 1

## Reference to torch manager (optional, for night brightness bonus)
var torch_manager: Node = null

## Is the cycle running
var _is_running: bool = false

## Was it night last frame (for signal detection)
var _was_night: bool = false

## Total cycle duration
var _cycle_duration: float:
	get:
		return day_duration + night_duration


func _ready() -> void:
	_was_night = is_night()


func _process(delta: float) -> void:
	if not _is_running:
		return

	var prev_time = current_time
	current_time += delta

	# Check for day/night transition
	var currently_night = is_night()
	if currently_night != _was_night:
		if currently_night:
			night_started.emit()
		else:
			day_started.emit()
			current_day += 1
		_was_night = currently_night

	# Wrap time and increment day
	if current_time >= _cycle_duration:
		current_time = fmod(current_time, _cycle_duration)

	# Emit time changed signal
	time_changed.emit(current_time, currently_night)


## Start the day/night cycle
func start() -> void:
	_is_running = true


## Stop the day/night cycle
func stop() -> void:
	_is_running = false


## Reset to start of day 1
func reset() -> void:
	current_time = 0.0
	current_day = 1
	_was_night = false
	_is_running = false


## Check if it's currently night
func is_night() -> bool:
	return current_time >= day_duration


## Get current time of day enum
func get_time_of_day() -> TimeOfDay:
	if current_time < transition_time:
		return TimeOfDay.DAWN
	elif current_time < day_duration - transition_time:
		return TimeOfDay.DAY
	elif current_time < day_duration:
		return TimeOfDay.DUSK
	else:
		return TimeOfDay.NIGHT


## Get time of day as string
func get_time_of_day_string() -> String:
	match get_time_of_day():
		TimeOfDay.DAWN:
			return "Dawn"
		TimeOfDay.DAY:
			return "Day"
		TimeOfDay.DUSK:
			return "Dusk"
		TimeOfDay.NIGHT:
			return "Night"
	return "Day"


## Get progress through current period (0.0 - 1.0)
func get_period_progress() -> float:
	if is_night():
		return (current_time - day_duration) / night_duration
	else:
		return current_time / day_duration


## Get the current tint color based on time
func get_current_tint() -> Color:
	var time_of_day = get_time_of_day()
	var base_tint: Color

	match time_of_day:
		TimeOfDay.DAWN:
			# Transition from night to day
			var progress = current_time / transition_time
			base_tint = night_tint.lerp(Color.WHITE, progress)
		TimeOfDay.DAY:
			base_tint = Color.WHITE
		TimeOfDay.DUSK:
			# Transition from day to night
			var dusk_start = day_duration - transition_time
			var progress = (current_time - dusk_start) / transition_time
			base_tint = Color.WHITE.lerp(night_tint, progress)
		TimeOfDay.NIGHT:
			base_tint = night_tint
		_:
			base_tint = Color.WHITE

	# Apply torch brightness bonus during night
	if is_night() and torch_manager and torch_manager.has_method("get_night_brightness_bonus"):
		var brightness_bonus = torch_manager.get_night_brightness_bonus()
		if brightness_bonus > 0:
			base_tint = base_tint.lerp(Color.WHITE, brightness_bonus)

	return base_tint


## Get formatted time string (Day X - HH:MM style)
func get_formatted_time() -> String:
	var period = "Day" if not is_night() else "Night"
	var time_in_period = current_time if not is_night() else current_time - day_duration
	var duration = day_duration if not is_night() else night_duration
	var progress_seconds = int(time_in_period)
	var minutes = progress_seconds / 60
	var seconds = progress_seconds % 60
	return "%s %d - %02d:%02d" % [period, current_day, minutes, seconds]
