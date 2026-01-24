extends Control
class_name StatusIcon
## Single status effect icon with timer

@export var icon_size: Vector2 = Vector2(24, 24)

var _texture_rect: TextureRect
var _timer_label: Label
var _bg_panel: Panel

var effect_type: int = 0  # StatusEffect.Type
var remaining_time: float = 0.0

func _ready() -> void:
	custom_minimum_size = icon_size + Vector2(4, 16)

	# Background
	_bg_panel = Panel.new()
	_bg_panel.custom_minimum_size = icon_size + Vector2(4, 4)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.set_corner_radius_all(3)
	_bg_panel.add_theme_stylebox_override("panel", style)
	add_child(_bg_panel)

	# Icon
	_texture_rect = TextureRect.new()
	_texture_rect.custom_minimum_size = icon_size
	_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_texture_rect.position = Vector2(2, 2)
	add_child(_texture_rect)

	# Timer
	_timer_label = Label.new()
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 10)
	_timer_label.position = Vector2(0, icon_size.y + 4)
	_timer_label.custom_minimum_size.x = icon_size.x + 4
	add_child(_timer_label)

func setup(type: int, texture: Texture2D = null) -> void:
	effect_type = type
	if texture:
		_texture_rect.texture = texture
	else:
		# Default colored rect based on type
		match type:
			0:  # POISON
				_bg_panel.get_theme_stylebox("panel").bg_color = Color(0.2, 0.5, 0.2, 0.8)
			1:  # BURN
				_bg_panel.get_theme_stylebox("panel").bg_color = Color(0.5, 0.2, 0.1, 0.8)
			2:  # SLOW
				_bg_panel.get_theme_stylebox("panel").bg_color = Color(0.2, 0.3, 0.5, 0.8)
			3:  # STUN
				_bg_panel.get_theme_stylebox("panel").bg_color = Color(0.5, 0.5, 0.1, 0.8)

func update_time(time: float) -> void:
	remaining_time = time
	_timer_label.text = "%.1f" % time
