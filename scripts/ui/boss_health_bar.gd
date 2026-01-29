extends CanvasLayer
class_name BossHealthBar
## Boss health bar UI - Shows at top of screen during boss fights

signal boss_defeated()

@onready var container: Control = $Container
@onready var name_label: Label = $Container/VBoxContainer/NameLabel
@onready var health_bar: ProgressBar = $Container/VBoxContainer/HealthBar
@onready var health_label: Label = $Container/VBoxContainer/HealthBar/HealthLabel

var _current_boss: Node = null
var _target_health: float = 0.0
var _display_health: float = 0.0

func _ready() -> void:
	# Start hidden
	hide_bar()


func _process(delta: float) -> void:
	# Smooth health bar animation
	if _display_health != _target_health:
		_display_health = lerp(_display_health, _target_health, 10.0 * delta)
		if abs(_display_health - _target_health) < 0.5:
			_display_health = _target_health
		if health_bar:
			health_bar.value = _display_health


## Set the boss to track
func set_boss(boss: Node, boss_name: String = "BOSS") -> void:
	_current_boss = boss

	# Set name
	if name_label:
		name_label.text = boss_name

	# Connect to boss health signal if available
	if boss.has_signal("health_changed"):
		boss.health_changed.connect(_on_boss_health_changed)

	if boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

	# Initialize health bar
	if "health" in boss and "_max_health" in boss:
		var max_hp = boss._max_health
		var current_hp = boss.health
		health_bar.max_value = max_hp
		_target_health = current_hp
		_display_health = current_hp
		health_bar.value = current_hp
		_update_health_label(current_hp, max_hp)
	elif "health" in boss:
		var hp = boss.health
		health_bar.max_value = hp
		_target_health = hp
		_display_health = hp
		health_bar.value = hp
		_update_health_label(hp, hp)

	# Show the bar
	show_bar()


## Update health display
func update_health(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		_target_health = current

	_update_health_label(current, maximum)


func _on_boss_health_changed(current: int, maximum: int) -> void:
	update_health(current, maximum)


func _on_boss_died(_xp: int) -> void:
	# Animate health to 0
	_target_health = 0

	# Delay then hide
	await get_tree().create_timer(1.0).timeout
	hide_bar()
	boss_defeated.emit()

	_current_boss = null


func _update_health_label(current: int, maximum: int) -> void:
	if health_label:
		health_label.text = "%d / %d" % [max(0, current), maximum]


## Show the boss health bar
func show_bar() -> void:
	if container:
		container.visible = true
	visible = true


## Hide the boss health bar
func hide_bar() -> void:
	if container:
		container.visible = false
	visible = false
