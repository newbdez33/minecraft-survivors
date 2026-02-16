extends CanvasLayer
class_name AchievementNotification
## Popup notification when an achievement is unlocked
## Shows achievement icon, name and description, then fades out

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/HBox/VBox/TitleHBox/TitleLabel
@onready var name_label: Label = $Panel/MarginContainer/HBox/VBox/NameLabel
@onready var desc_label: Label = $Panel/MarginContainer/HBox/VBox/DescLabel
@onready var achievement_icon: TextureRect = $Panel/MarginContainer/HBox/AchievementIcon
@onready var timer: Timer = $Timer

var _queue: Array = []  # Queue of achievements to show
var _is_showing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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

	# Update title
	if title_label:
		title_label.text = tr("ACH_UNLOCKED_TITLE")

	# Update labels with localization
	var name_key: String = "ACH_%s_NAME" % achievement.id.to_upper()
	var desc_key: String = "ACH_%s_DESC" % achievement.id.to_upper()

	if name_label:
		var translated_name: String = tr(name_key)
		name_label.text = translated_name if translated_name != name_key else achievement.name
	if desc_label:
		var translated_desc: String = tr(desc_key)
		desc_label.text = translated_desc if translated_desc != desc_key else achievement.description

	# Load achievement badge icon
	if achievement_icon and achievement.icon_path != "":
		if ResourceLoader.exists(achievement.icon_path):
			var texture = load(achievement.icon_path)
			if texture:
				achievement_icon.texture = texture
				achievement_icon.visible = true
			else:
				achievement_icon.visible = false
		else:
			achievement_icon.visible = false

	# Show with animation
	panel.visible = true
	panel.modulate.a = 0.0

	# Slide in from right + fade in
	panel.position.x = 30.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position:x", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Start display timer
	timer.start(3.0)

func _on_timer_timeout() -> void:
	# Slide out to right + fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "position:x", 30.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_callback(_on_fade_complete)

func _on_fade_complete() -> void:
	hide_notification()
	# Show next if queued
	_show_next()

func hide_notification() -> void:
	if panel:
		panel.visible = false
