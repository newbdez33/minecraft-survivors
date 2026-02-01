extends CanvasLayer
class_name AchievementNotification
## Popup notification when an achievement is unlocked
## Shows achievement name and description, then fades out

@onready var panel: PanelContainer = $Panel
@onready var name_label: Label = $Panel/VBox/NameLabel
@onready var desc_label: Label = $Panel/VBox/DescLabel
@onready var timer: Timer = $Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _queue: Array = []  # Queue of achievements to show
var _is_showing: bool = false

func _ready() -> void:
	hide_notification()
	timer.timeout.connect(_on_timer_timeout)

func show_achievement(achievement) -> void:
	# Add to queue
	_queue.append(achievement)

	# If not currently showing, start showing
	if not _is_showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_is_showing = false
		return

	_is_showing = true
	var achievement = _queue.pop_front()

	# Update labels
	if name_label:
		name_label.text = achievement.name
	if desc_label:
		desc_label.text = achievement.description

	# Show with animation
	panel.visible = true
	panel.modulate.a = 0.0

	# Fade in
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

	# Start display timer
	timer.start(3.0)

func _on_timer_timeout() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_on_fade_complete)

func _on_fade_complete() -> void:
	hide_notification()
	# Show next if queued
	_show_next()

func hide_notification() -> void:
	if panel:
		panel.visible = false
