extends PanelContainer
class_name AchievementItem
## Individual achievement display item
## Shows icon, name, description, and progress

@onready var icon: TextureRect = $HBox/Icon
@onready var name_label: Label = $HBox/VBox/NameLabel
@onready var desc_label: Label = $HBox/VBox/DescLabel
@onready var progress_bar: ProgressBar = $HBox/VBox/ProgressBar
@onready var status_label: Label = $HBox/VBox/StatusLabel

var achievement = null
var is_unlocked: bool = false

# Default locked/unlocked colors
const LOCKED_COLOR = Color(0.5, 0.5, 0.5, 0.8)
const UNLOCKED_COLOR = Color(1, 0.843, 0, 1)  # Gold

func _ready() -> void:
	if achievement:
		_update_display()

func set_achievement(ach) -> void:
	achievement = ach
	is_unlocked = ach.is_unlocked
	_update_display()

func _update_display() -> void:
	if not achievement:
		return

	# Build translation keys from achievement id
	var name_key: String = "ACH_%s_NAME" % achievement.id.to_upper()
	var desc_key: String = "ACH_%s_DESC" % achievement.id.to_upper()

	# Update name (use tr() with fallback to raw name)
	if name_label:
		var translated_name: String = tr(name_key)
		name_label.text = translated_name if translated_name != name_key else achievement.name
		name_label.modulate = UNLOCKED_COLOR if is_unlocked else Color.WHITE

	# Update description
	if desc_label:
		var translated_desc: String = tr(desc_key)
		desc_label.text = translated_desc if translated_desc != desc_key else achievement.description

	# Update progress bar
	if progress_bar:
		progress_bar.max_value = achievement.target
		progress_bar.value = achievement.progress if not is_unlocked else achievement.target
		progress_bar.visible = not is_unlocked  # Hide when unlocked

	# Update status
	if status_label:
		if is_unlocked:
			status_label.text = tr("ACH_UNLOCKED")
			status_label.modulate = UNLOCKED_COLOR
		else:
			var percent = (float(achievement.progress) / float(achievement.target)) * 100.0
			status_label.text = "%d / %d (%.0f%%)" % [achievement.progress, achievement.target, percent]
			status_label.modulate = Color.WHITE

	# Load icon texture
	if icon and achievement.icon_path != "":
		if ResourceLoader.exists(achievement.icon_path):
			var texture = load(achievement.icon_path)
			if texture:
				icon.texture = texture

	# Visual state for locked/unlocked
	if is_unlocked:
		modulate = Color.WHITE
	else:
		modulate = LOCKED_COLOR
