extends Node2D
class_name DamageNumber
## Floating damage number that rises and fades

@export var rise_speed: float = 50.0
@export var duration: float = 0.8
@export var spread: float = 20.0

var _label: Label
var _elapsed: float = 0.0
var _start_pos: Vector2

enum Type { NORMAL, CRIT, POISON, HEAL, XP }

func _ready() -> void:
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)

	_start_pos = position
	# Random horizontal offset
	position.x += randf_range(-spread, spread)

func setup(amount: int, type: Type = Type.NORMAL) -> void:
	match type:
		Type.NORMAL:
			_label.text = str(amount)
			_label.add_theme_color_override("font_color", Color.WHITE)
			_label.add_theme_font_size_override("font_size", 16)
		Type.CRIT:
			_label.text = str(amount) + "!"
			_label.add_theme_color_override("font_color", Color.YELLOW)
			_label.add_theme_font_size_override("font_size", 24)
		Type.POISON:
			_label.text = str(amount)
			_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.2))
			_label.add_theme_font_size_override("font_size", 14)
		Type.HEAL:
			_label.text = "+" + str(amount)
			_label.add_theme_color_override("font_color", Color.GREEN)
			_label.add_theme_font_size_override("font_size", 18)
		Type.XP:
			_label.text = "+" + str(amount) + " XP"
			_label.add_theme_color_override("font_color", Color.CYAN)
			_label.add_theme_font_size_override("font_size", 14)

func _process(delta: float) -> void:
	_elapsed += delta

	# Rise up
	position.y -= rise_speed * delta

	# Fade out
	var progress = _elapsed / duration
	modulate.a = 1.0 - ease(progress, 2.0)

	# Scale for crit effect
	if _elapsed < 0.1:
		scale = Vector2.ONE * (1.0 + (0.1 - _elapsed) * 5)
	else:
		scale = Vector2.ONE

	if _elapsed >= duration:
		queue_free()
