extends PanelContainer
class_name CharacterCard
## Individual character card for selection
## Shows sprite, name, stats, and unlock status
## Click anywhere on the card to select (if unlocked)

signal selected()

@onready var sprite: TextureRect = $VBox/Sprite
@onready var name_label: Label = $VBox/NameLabel
@onready var stats_container: VBoxContainer = $VBox/StatsContainer
@onready var desc_label: Label = $VBox/DescLabel
@onready var lock_overlay: ColorRect = $LockOverlay
@onready var lock_label: Label = $LockOverlay/LockLabel

var border_rect: ColorRect = null

var character = null
var is_unlocked: bool = false
var is_selected: bool = false

const SELECTED_COLOR = Color(0.2, 0.8, 0.4, 1.0)   # Green for selected
const NORMAL_COLOR = Color(0.3, 0.3, 0.3, 1.0)    # Gray for normal
const HOVER_COLOR = Color(0.5, 0.7, 0.9, 1.0)     # Light blue for hover
const BORDER_WIDTH = 4

func _ready() -> void:
	# Make card clickable
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Create border overlay for selection effect
	_create_border()

	if character:
		_update_display()

func _create_border() -> void:
	# Create a border ColorRect that sits behind content
	border_rect = ColorRect.new()
	border_rect.name = "SelectionBorder"
	border_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	border_rect.color = Color.TRANSPARENT
	# Add as first child so it's behind everything
	add_child(border_rect)
	move_child(border_rect, 0)

func set_character(char_data, selected: bool = false) -> void:
	character = char_data
	is_unlocked = char_data.is_unlocked if char_data else false
	is_selected = selected
	_update_display()

func _update_display() -> void:
	if not character:
		return

	# Update name
	if name_label:
		name_label.text = character.name

	# Update description
	if desc_label:
		desc_label.text = character.description

	# Update stats display
	_update_stats_display()

	# Update sprite
	if sprite and character.sprite_path:
		if ResourceLoader.exists(character.sprite_path):
			var texture = load(character.sprite_path)
			if texture:
				sprite.texture = texture

	# Update locked state
	if lock_overlay:
		lock_overlay.visible = not is_unlocked
	if lock_label and not is_unlocked:
		lock_label.text = character.unlock_requirement

	# Visual selection indicator - show clear selected state
	_update_selection_visual()

func _update_selection_visual() -> void:
	if is_selected:
		# Selected: green glow border + slight scale up
		scale = Vector2(1.05, 1.05)
		pivot_offset = size / 2
		if border_rect:
			# Draw a glowing border effect
			border_rect.color = SELECTED_COLOR
			border_rect.color.a = 0.3
		# Add outer glow via modulate
		modulate = Color(0.9, 1.0, 0.9)
	else:
		scale = Vector2(1.0, 1.0)
		if border_rect:
			border_rect.color = Color.TRANSPARENT
		modulate = Color.WHITE

func _update_stats_display() -> void:
	if not stats_container or not character:
		return

	# Clear existing stats
	for child in stats_container.get_children():
		child.queue_free()

	# Add stats
	_add_stat_label("HP", character.health_mult)
	_add_stat_label("Speed", character.speed_mult)
	_add_stat_label("Damage", character.damage_mult)
	_add_stat_label("XP", character.xp_mult)
	_add_stat_label("Pickup", character.pickup_range_mult)

func _add_stat_label(stat_name: String, multiplier: float) -> void:
	var label = Label.new()
	var percent = int((multiplier - 1.0) * 100)
	var sign_str = "+" if percent >= 0 else ""

	if percent == 0:
		label.text = "%s: --" % stat_name
		label.modulate = Color(0.7, 0.7, 0.7)
	elif percent > 0:
		label.text = "%s: %s%d%%" % [stat_name, sign_str, percent]
		label.modulate = Color(0.3, 1.0, 0.3)  # Green for buff
	else:
		label.text = "%s: %d%%" % [stat_name, percent]
		label.modulate = Color(1.0, 0.3, 0.3)  # Red for debuff

	label.add_theme_font_size_override("font_size", 10)
	stats_container.add_child(label)

## Handle card click - select this character
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_unlocked and not is_selected:
				selected.emit()

## Hover effects
func _mouse_enter() -> void:
	if is_unlocked and not is_selected:
		modulate = Color(0.9, 0.95, 1.0)
		scale = Vector2(1.03, 1.03)
		pivot_offset = size / 2
		if border_rect:
			border_rect.color = HOVER_COLOR
			border_rect.color.a = 0.2

func _mouse_exit() -> void:
	_update_selection_visual()
