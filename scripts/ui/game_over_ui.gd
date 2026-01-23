extends CanvasLayer
class_name GameOverUI

## Game Over Screen
## Displays when the player dies, shows stats and restart options

signal restart_pressed
signal quit_pressed

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/VBoxContainer/StatsContainer
@onready var time_label: Label = $Panel/VBoxContainer/StatsContainer/TimeLabel
@onready var kills_label: Label = $Panel/VBoxContainer/StatsContainer/KillsLabel
@onready var level_label: Label = $Panel/VBoxContainer/StatsContainer/LevelLabel
@onready var wave_label: Label = $Panel/VBoxContainer/StatsContainer/WaveLabel
@onready var restart_button: Button = $Panel/VBoxContainer/ButtonContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/ButtonContainer/QuitButton

## Stats to display
var _stats: Dictionary = {}


func _ready() -> void:
	visible = false

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)


## Show the game over screen
func show_game_over() -> void:
	visible = true
	get_tree().paused = true
	_update_display()


## Hide the game over screen
func hide_game_over() -> void:
	visible = false
	get_tree().paused = false


## Set stats to display
func set_stats(stats: Dictionary) -> void:
	_stats = stats
	_update_display()


## Update the display with current stats
func _update_display() -> void:
	if title_label:
		title_label.text = _tr("YOU_DIED", "You Died!")

	if time_label and _stats.has("survival_time"):
		var time = _stats.survival_time
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		time_label.text = _tr("SURVIVAL_TIME", "Survival Time") + ": %02d:%02d" % [minutes, seconds]

	if kills_label and _stats.has("kills"):
		kills_label.text = _tr("KILLS", "Kills") + ": %d" % _stats.kills

	if level_label and _stats.has("highest_level"):
		level_label.text = _tr("LEVEL", "Level") + ": %d" % _stats.highest_level

	if wave_label and _stats.has("highest_wave"):
		wave_label.text = _tr("WAVE", "Wave") + ": %d" % _stats.highest_wave

	if restart_button:
		restart_button.text = _tr("RESPAWN", "Respawn")

	if quit_button:
		quit_button.text = _tr("QUIT", "Quit")


## Translation helper with fallback
func _tr(key: String, fallback: String) -> String:
	var translated = tr(key)
	if translated == key:
		return fallback
	return translated


func _on_restart_pressed() -> void:
	restart_pressed.emit()
	hide_game_over()


func _on_quit_pressed() -> void:
	quit_pressed.emit()
	get_tree().quit()
