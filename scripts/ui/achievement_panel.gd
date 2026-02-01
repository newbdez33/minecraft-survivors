extends Control
class_name AchievementPanel
## Panel displaying all achievements with their progress
## Can be shown from main menu or pause menu

signal closed()

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var progress_label: Label = $VBoxContainer/ProgressLabel
@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var grid_container: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var close_button: Button = $VBoxContainer/CloseButton

var achievement_manager: Node = null
var achievement_item_scene: PackedScene = null

func _ready() -> void:
	# Load achievement item scene
	achievement_item_scene = load("res://scenes/ui/achievement_item.tscn")

	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Start hidden
	visible = false

func set_achievement_manager(manager: Node) -> void:
	achievement_manager = manager
	if manager:
		manager.achievement_unlocked.connect(_on_achievement_unlocked)
		populate_achievements()

func populate_achievements() -> void:
	if not achievement_manager or not grid_container:
		return

	# Clear existing items
	for child in grid_container.get_children():
		child.queue_free()

	# Get all achievements
	var achievements = achievement_manager.get_all_achievements()
	var unlocked_count = 0

	for achievement in achievements:
		if achievement.is_unlocked:
			unlocked_count += 1
		_create_achievement_item(achievement)

	# Update progress label
	_update_progress_display(unlocked_count, achievements.size())

func _create_achievement_item(achievement) -> void:
	if not achievement_item_scene or not grid_container:
		return

	var item = achievement_item_scene.instantiate()
	if item.has_method("set_achievement"):
		item.set_achievement(achievement)
	grid_container.add_child(item)

func _update_progress_display(unlocked: int, total: int) -> void:
	if progress_label:
		progress_label.text = "%d / %d Achievements" % [unlocked, total]

func _on_achievement_unlocked(_achievement) -> void:
	# Refresh the display
	populate_achievements()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

func show_panel() -> void:
	populate_achievements()
	visible = true

func hide_panel() -> void:
	visible = false
