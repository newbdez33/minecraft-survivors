extends CanvasLayer
class_name GameOverUI

## Game Over Screen
## Displays when the player dies, shows stats and restart options

signal restart_pressed
signal quit_pressed

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/StatsContainer
@onready var time_label: Label = $Panel/MarginContainer/VBoxContainer/StatsContainer/TimeLabel
@onready var kills_label: Label = $Panel/MarginContainer/VBoxContainer/StatsContainer/KillsLabel
@onready var level_label: Label = $Panel/MarginContainer/VBoxContainer/StatsContainer/LevelLabel
@onready var wave_label: Label = $Panel/MarginContainer/VBoxContainer/StatsContainer/WaveLabel
@onready var restart_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/RestartButton
@onready var quit_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/QuitButton

## Stats to display
var _stats: Dictionary = {}


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process input even when paused

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Enter or Space to restart
	if event.is_action_pressed("ui_accept"):
		_on_restart_pressed()
		get_viewport().set_input_as_handled()

	# Escape to quit
	elif event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
		get_viewport().set_input_as_handled()

	# Tab to switch between buttons
	elif event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if restart_button and quit_button:
			if restart_button.has_focus():
				quit_button.grab_focus()
			else:
				restart_button.grab_focus()
			get_viewport().set_input_as_handled()


## Show the game over screen
func show_game_over() -> void:
	visible = true
	get_tree().paused = true
	_update_display()

	# Focus restart button for keyboard navigation
	if restart_button:
		restart_button.grab_focus()


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
		quit_button.text = _tr("MAIN_MENU", "Main Menu")


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
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
