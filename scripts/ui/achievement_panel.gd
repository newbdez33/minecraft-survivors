extends Control
class_name AchievementPanel

signal closed()

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressContainer/ProgressLabel
@onready var overall_progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressContainer/OverallProgressBar
@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer
@onready var category_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/CategoryContainer
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

var achievement_manager: Node = null
var achievement_item_scene: PackedScene = null
var _localization_manager: Node = null

const CATEGORIES = {
	"kill": {"name": "KILL_ACHIEVEMENTS", "ids": ["first_kill", "kills_100", "kills_1000"]},
	"survival": {"name": "SURVIVAL_ACHIEVEMENTS", "ids": ["survive_60", "survive_300", "survive_600", "survive_900"]},
	"level": {"name": "LEVEL_ACHIEVEMENTS", "ids": ["level_5", "level_10", "level_20"]},
	"wave": {"name": "WAVE_ACHIEVEMENTS", "ids": ["wave_3", "wave_5", "wave_10", "idle_master"]},
	"special": {"name": "SPECIAL_ACHIEVEMENTS", "ids": ["poison_survive", "combo_50", "combo_100", "no_damage_60"]},
	"unlock": {"name": "UNLOCK_ACHIEVEMENTS", "ids": ["unlock_zhao_yun", "unlock_bow", "evolve_weapon"]},
}

const CATEGORY_ORDER = ["kill", "survival", "level", "wave", "special", "unlock"]

func _ready() -> void:
	achievement_item_scene = load("res://scenes/ui/achievement_item.tscn")

	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	_localization_manager = get_node_or_null("/root/LocalizationManager")
	if _localization_manager and _localization_manager.has_signal("language_changed"):
		_localization_manager.language_changed.connect(_on_language_changed)

	_update_texts()
	visible = false

func set_achievement_manager(manager: Node) -> void:
	if achievement_manager and achievement_manager.has_signal("achievement_unlocked"):
		if achievement_manager.achievement_unlocked.is_connected(_on_achievement_unlocked):
			achievement_manager.achievement_unlocked.disconnect(_on_achievement_unlocked)
	achievement_manager = manager
	if manager:
		manager.achievement_unlocked.connect(_on_achievement_unlocked)
		populate_achievements()

func populate_achievements() -> void:
	if not achievement_manager or not category_container:
		return

	for child in category_container.get_children():
		child.queue_free()

	var achievements_dict = {}
	for achievement in achievement_manager.get_all_achievements():
		achievements_dict[achievement.id] = achievement

	var unlocked_count = 0
	var total_count = achievement_manager.get_total_count()

	for category_key in CATEGORY_ORDER:
		var category = CATEGORIES[category_key]
		var category_achievements = []
		var category_unlocked = 0

		for id in category.ids:
			if achievements_dict.has(id):
				category_achievements.append(achievements_dict[id])
				if achievements_dict[id].is_unlocked:
					category_unlocked += 1
					unlocked_count += 1

		if category_achievements.size() > 0:
			_create_category_section(
				tr(category.name),
				category_achievements,
				category_unlocked,
				category_achievements.size()
			)

	_update_progress_display(unlocked_count, total_count)

func _create_category_section(category_name: String, achievements: Array, unlocked: int, total: int) -> void:
	var section_vbox = VBoxContainer.new()
	section_vbox.add_theme_constant_override("separation", 6)
	category_container.add_child(section_vbox)

	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	section_vbox.add_child(header_hbox)

	var category_label = Label.new()
	category_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3, 1))
	category_label.add_theme_constant_override("outline_size", 2)
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.text = category_name
	header_hbox.add_child(category_label)

	var category_count = Label.new()
	category_count.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	category_count.add_theme_font_size_override("font_size", 12)
	category_count.text = "(%d/%d)" % [unlocked, total]
	header_hbox.add_child(category_count)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	section_vbox.add_child(grid)

	for achievement in achievements:
		var item = achievement_item_scene.instantiate()
		if item.has_method("set_achievement"):
			item.set_achievement(achievement)
		grid.add_child(item)

func _update_progress_display(unlocked: int, total: int) -> void:
	if progress_label:
		progress_label.text = tr("ACH_PROGRESS") % [unlocked, total]
	if overall_progress_bar:
		overall_progress_bar.max_value = total
		overall_progress_bar.value = unlocked

func _update_texts() -> void:
	if title_label:
		title_label.text = tr("ACHIEVEMENTS")
	if close_button:
		close_button.text = tr("CLOSE")

func _on_language_changed(_locale: String) -> void:
	_update_texts()
	populate_achievements()

func _on_achievement_unlocked(_achievement) -> void:
	populate_achievements()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

func show_panel() -> void:
	_update_texts()
	populate_achievements()
	visible = true

func hide_panel() -> void:
	visible = false
