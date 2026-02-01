class_name StatPopup
extends Node2D

## Floating stat text that rises and fades - shows upgrade values

@export var float_distance: float = 40.0
@export var duration: float = 1.2
@export var font_size: int = 16

var _label: Label = null
var _tween: Tween = null
var _start_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Will be started when show_stat is called
	pass


func show_stat(text: String, color: Color) -> void:
	"""Display the stat text with animation"""
	_start_position = global_position

	# Create label
	_label = Label.new()
	_label.text = text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Style the label
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 2)

	# Center the label
	_label.position = Vector2(-100, -20)
	_label.size = Vector2(200, 40)

	add_child(_label)

	# Animate
	_animate_popup()


func _animate_popup() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)

	# Float upward
	_tween.tween_property(self, "global_position", _start_position + Vector2(0, -float_distance), duration)

	# Scale pulse at start
	if _label:
		var scale_tween = create_tween()
		scale_tween.tween_property(_label, "scale", Vector2(1.3, 1.3), 0.1)
		scale_tween.tween_property(_label, "scale", Vector2(1.0, 1.0), 0.2)

	# Fade out in second half
	var fade_tween = create_tween()
	fade_tween.tween_interval(duration * 0.5)
	fade_tween.tween_property(self, "modulate:a", 0.0, duration * 0.5)

	# Clean up when done
	_tween.tween_callback(queue_free)
