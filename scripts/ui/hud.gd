extends CanvasLayer
class_name HUD
## Heads-Up Display showing player health, XP, and level

@onready var hearts_container: HBoxContainer = $MarginContainer/VBoxContainer/HeartsContainer
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var wave_label: Label = $TopRightContainer/WaveLabel
@onready var kills_label: Label = $TopRightContainer/KillsLabel
@onready var time_label: Label = $TopCenterContainer/TimeLabel
@onready var day_night_icon: TextureRect = $TopCenterContainer/DayNightIcon
@onready var notification_label: Label = $NotificationContainer/NotificationLabel

var heart_full_texture: Texture2D
var heart_half_texture: Texture2D
var heart_empty_texture: Texture2D
# Day/night cycle textures (8 phases)
var sun_dawn_texture: Texture2D      # 0-5s: Dawn
var sun_morning_texture: Texture2D   # 5-20s: Morning
var sun_texture: Texture2D           # 20-40s: Midday
var sun_afternoon_texture: Texture2D # 40-55s: Afternoon
var sun_dusk_texture: Texture2D      # 55-60s: Dusk
var moon_rise_texture: Texture2D     # 60-75s: Moon rising
var moon_texture: Texture2D          # 75-105s: Night
var moon_late_texture: Texture2D     # 105-115s: Late night
var moon_set_texture: Texture2D      # 115-120s: Moon setting

var max_hearts: int = 10
var heart_nodes: Array[TextureRect] = []
var _current_level: int = 1
var _is_poisoned: bool = false
var _poison_tween: Tween = null
var _heart_pulse_tweens: Array = []  # Track individual heart tweens for cleanup

## Heart color constants
const NORMAL_HEART_COLOR = Color.WHITE
const POISON_HEART_COLOR = Color(0.3, 0.8, 0.3)  # Green tint

func _ready() -> void:
	# Connect to language changes
	var localization_manager = get_node_or_null("/root/LocalizationManager")
	if localization_manager and localization_manager.has_signal("language_changed"):
		localization_manager.language_changed.connect(_on_language_changed)

	# Load heart textures
	heart_full_texture = load("res://assets/items/heart_full.svg")
	heart_half_texture = load("res://assets/items/heart_half.svg")
	heart_empty_texture = load("res://assets/items/heart_empty.svg")

	# Load day/night textures (8 phases)
	sun_dawn_texture = load("res://assets/ui/sun_dawn.svg")
	sun_morning_texture = load("res://assets/ui/sun_morning.svg")
	sun_texture = load("res://assets/ui/sun.svg")
	sun_afternoon_texture = load("res://assets/ui/sun_afternoon.svg")
	sun_dusk_texture = load("res://assets/ui/sun_dusk.svg")
	moon_rise_texture = load("res://assets/ui/moon_rise.svg")
	moon_texture = load("res://assets/ui/moon.svg")
	moon_late_texture = load("res://assets/ui/moon_late.svg")
	moon_set_texture = load("res://assets/ui/moon_set.svg")

	# Initialize day/night icon to dawn
	if day_night_icon and sun_dawn_texture:
		day_night_icon.texture = sun_dawn_texture

	# Create heart display
	_create_hearts()

func _create_hearts() -> void:
	if not hearts_container:
		return

	# Clear existing hearts
	for child in hearts_container.get_children():
		child.queue_free()
	heart_nodes.clear()

	# Create heart icons
	for i in range(max_hearts):
		var heart = TextureRect.new()
		heart.texture = heart_full_texture
		heart.custom_minimum_size = Vector2(16, 16)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)
		heart_nodes.append(heart)

## Refresh all HUD labels with current translations
func refresh_labels() -> void:
	# Refresh with current values using translations
	set_level(_current_level)
	if wave_label:
		# Get current wave text and extract number
		var current_text = wave_label.text
		var wave_num = 1
		if current_text.contains(" "):
			wave_num = int(current_text.split(" ")[-1])
		set_wave(wave_num)
	if kills_label:
		# Get current kills text and extract number
		var current_text = kills_label.text
		var kills_num = 0
		if current_text.contains(":"):
			kills_num = int(current_text.split(":")[-1].strip_edges())
		set_kills(kills_num)

## Called when language changes via LocalizationManager
func _on_language_changed(_locale: String) -> void:
	refresh_labels()

func update_health(current_health: int, maximum_health: int = 100) -> void:
	# Each heart = 10 health points
	var health_per_heart = maximum_health / max_hearts
	var full_hearts = current_health / health_per_heart
	var has_half = (current_health % health_per_heart) >= (health_per_heart / 2)

	for i in range(heart_nodes.size()):
		var heart = heart_nodes[i]
		if i < full_hearts:
			heart.texture = heart_full_texture
		elif i == full_hearts and has_half:
			heart.texture = heart_half_texture
		else:
			heart.texture = heart_empty_texture

	# Update poison colors (only remaining hearts should be green)
	if _is_poisoned:
		_update_heart_colors()

func set_max_hearts(count: int) -> void:
	max_hearts = count
	_create_hearts()

func update_xp(current: int, needed: int) -> void:
	if xp_bar:
		xp_bar.max_value = needed
		xp_bar.value = current

func set_level(level: int) -> void:
	_current_level = level
	if level_label:
		level_label.text = tr("HUD_LEVEL") + " " + str(level)

func set_wave(wave: int) -> void:
	if wave_label:
		wave_label.text = tr("HUD_WAVE") + " " + str(wave)

func set_kills(kills: int) -> void:
	if kills_label:
		kills_label.text = tr("HUD_KILLS") + ": " + str(kills)

func set_time(time_seconds: float) -> void:
	if time_label:
		var minutes = int(time_seconds) / 60
		var seconds = int(time_seconds) % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]

func set_day_night(is_night: bool) -> void:
	if day_night_icon:
		if is_night and moon_texture:
			day_night_icon.texture = moon_texture
		elif sun_texture:
			day_night_icon.texture = sun_texture

## Set time of day icon based on exact time (8 phases over 120s cycle)
## 0-5s: Dawn, 5-20s: Morning, 20-40s: Midday, 40-55s: Afternoon
## 55-60s: Dusk, 60-75s: Moon rise, 75-105s: Night, 105-115s: Late night, 115-120s: Moon set
func set_time_icon(current_time: float, day_duration: float = 60.0, night_duration: float = 60.0) -> void:
	if not day_night_icon:
		return

	var cycle_duration = day_duration + night_duration
	var time = fmod(current_time, cycle_duration)

	# Day phases (0 to day_duration)
	if time < 5.0:  # Dawn (0-5s)
		if sun_dawn_texture:
			day_night_icon.texture = sun_dawn_texture
	elif time < 20.0:  # Morning (5-20s)
		if sun_morning_texture:
			day_night_icon.texture = sun_morning_texture
	elif time < 40.0:  # Midday (20-40s)
		if sun_texture:
			day_night_icon.texture = sun_texture
	elif time < 55.0:  # Afternoon (40-55s)
		if sun_afternoon_texture:
			day_night_icon.texture = sun_afternoon_texture
	elif time < day_duration:  # Dusk (55-60s)
		if sun_dusk_texture:
			day_night_icon.texture = sun_dusk_texture
	# Night phases (day_duration to cycle_duration)
	elif time < day_duration + 15.0:  # Moon rise (60-75s)
		if moon_rise_texture:
			day_night_icon.texture = moon_rise_texture
	elif time < day_duration + 45.0:  # Full night (75-105s)
		if moon_texture:
			day_night_icon.texture = moon_texture
	elif time < day_duration + 55.0:  # Late night (105-115s)
		if moon_late_texture:
			day_night_icon.texture = moon_late_texture
	else:  # Moon set (115-120s)
		if moon_set_texture:
			day_night_icon.texture = moon_set_texture

## Set time of day icon (0=DAWN, 1=DAY, 2=DUSK, 3=NIGHT) - legacy method
func set_time_of_day(time_of_day: int) -> void:
	if not day_night_icon:
		return
	match time_of_day:
		0:  # DAWN
			if sun_dawn_texture:
				day_night_icon.texture = sun_dawn_texture
		1:  # DAY
			if sun_texture:
				day_night_icon.texture = sun_texture
		2:  # DUSK
			if sun_dusk_texture:
				day_night_icon.texture = sun_dusk_texture
		3:  # NIGHT
			if moon_texture:
				day_night_icon.texture = moon_texture

## Show a temporary notification message
func show_notification(message: String, duration: float = 3.0) -> void:
	if not notification_label:
		return

	notification_label.text = message
	notification_label.modulate.a = 1.0

	# Fade out after duration
	var tween = create_tween()
	tween.tween_interval(duration - 0.5)
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): notification_label.text = "")

## Set poisoned state - hearts turn green when poisoned
func set_poisoned(poisoned: bool) -> void:
	if _is_poisoned == poisoned:
		return

	_is_poisoned = poisoned
	_update_heart_colors()

## Update heart colors based on poison state
## Only remaining hearts (full/half) turn green, empty hearts stay normal
func _update_heart_colors() -> void:
	# Kill any existing tweens
	if _poison_tween and _poison_tween.is_valid():
		_poison_tween.kill()

	# Kill all heart pulse tweens
	for tween in _heart_pulse_tweens:
		if tween and tween.is_valid():
			tween.kill()
	_heart_pulse_tweens.clear()

	# Create smooth transition tween
	_poison_tween = create_tween()
	_poison_tween.set_parallel(true)

	for heart in heart_nodes:
		var is_empty = (heart.texture == heart_empty_texture)
		var target_color: Color

		if _is_poisoned and not is_empty:
			# Only non-empty hearts turn green
			target_color = POISON_HEART_COLOR
		else:
			# Empty hearts or not poisoned = normal color
			target_color = NORMAL_HEART_COLOR

		_poison_tween.tween_property(heart, "modulate", target_color, 0.3)

	# Start pulse effect if poisoned
	if _is_poisoned:
		_poison_tween.chain().tween_callback(_start_poison_pulse)

## Start pulsing green effect for poisoned hearts (only non-empty hearts)
func _start_poison_pulse() -> void:
	if not _is_poisoned:
		return

	# Kill existing pulse tweens before creating new ones
	for tween in _heart_pulse_tweens:
		if tween and tween.is_valid():
			tween.kill()
	_heart_pulse_tweens.clear()

	var bright_green = Color(0.4, 1.0, 0.4)
	var dark_green = Color(0.2, 0.6, 0.2)

	for heart in heart_nodes:
		var is_empty = (heart.texture == heart_empty_texture)
		if is_empty:
			# Don't pulse empty hearts, keep them normal
			heart.modulate = NORMAL_HEART_COLOR
			continue

		var heart_tween = create_tween()
		heart_tween.set_loops()
		heart_tween.tween_property(heart, "modulate", bright_green, 0.5)
		heart_tween.tween_property(heart, "modulate", dark_green, 0.5)
		_heart_pulse_tweens.append(heart_tween)  # Track for cleanup
