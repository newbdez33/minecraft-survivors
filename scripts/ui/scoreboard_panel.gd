extends PanelContainer
class_name ScoreboardPanel
## Displays high scores

signal closed

const ScoreStorageClass = preload("res://scripts/systems/score_storage.gd")

@onready var _title_label: Label = $MarginContainer/VBox/Title
@onready var _scores_container: VBoxContainer = $MarginContainer/VBox/ScoresContainer
@onready var _close_button: TextureButton = $MarginContainer/VBox/CloseButton
@onready var _close_label: Label = $MarginContainer/VBox/CloseButton/Label

var _score_storage: RefCounted

func _ready() -> void:
	_score_storage = ScoreStorageClass.new()

	if _close_button:
		_close_button.pressed.connect(_on_close)

	_update_labels()
	refresh_scores()

func _update_labels() -> void:
	if _title_label:
		_title_label.text = tr("HIGH_SCORES")
	if _close_label:
		_close_label.text = tr("CLOSE")

func refresh_scores() -> void:
	if not _scores_container:
		return

	# Clear existing
	for child in _scores_container.get_children():
		child.queue_free()

	# Load and display scores
	var scores = _score_storage.load_scores()

	if scores.is_empty():
		var empty_label = Label.new()
		empty_label.text = tr("NO_SCORES")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_scores_container.add_child(empty_label)
		return

	# Header
	var header = _create_score_row("#", tr("SCORE"), tr("DATE"), true)
	_scores_container.add_child(header)

	# Score rows
	for i in range(scores.size()):
		var score_data = scores[i]
		var rank = str(i + 1)
		var score = str(score_data.get("score", 0))
		var date = score_data.get("date", "Unknown")
		# Shorten date
		if date.length() > 10:
			date = date.substr(0, 10)

		var row = _create_score_row(rank, score, date, false)
		_scores_container.add_child(row)

		# Highlight top 3
		if i < 3:
			var colors = [Color.GOLD, Color.SILVER, Color(0.8, 0.5, 0.2)]
			row.modulate = colors[i]

func _create_score_row(rank: String, score: String, date: String, is_header: bool) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)

	var rank_label = Label.new()
	rank_label.text = rank
	rank_label.custom_minimum_size.x = 30
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		rank_label.add_theme_color_override("font_color", Color.GRAY)
	row.add_child(rank_label)

	var score_label = Label.new()
	score_label.text = score
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if is_header:
		score_label.add_theme_color_override("font_color", Color.GRAY)
	row.add_child(score_label)

	var date_label = Label.new()
	date_label.text = date
	date_label.custom_minimum_size.x = 100
	if is_header:
		date_label.add_theme_color_override("font_color", Color.GRAY)
	row.add_child(date_label)

	return row

func _on_close() -> void:
	visible = false
	closed.emit()

func highlight_score(rank: int) -> void:
	# Highlight a specific rank (for when new score is added)
	if _scores_container and rank > 0 and rank <= _scores_container.get_child_count():
		var row = _scores_container.get_child(rank)  # +1 for header
		if row:
			var tween = create_tween().set_loops(3)
			tween.tween_property(row, "modulate", Color.WHITE, 0.2)
			tween.tween_property(row, "modulate", Color.YELLOW, 0.2)
