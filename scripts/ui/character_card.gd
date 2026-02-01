extends PanelContainer
class_name CharacterCard
## Individual character card for selection
## Shows sprite, name, stats, and unlock status
## Click anywhere on the card to select (if unlocked)

signal selected()

@onready var sprite: TextureRect = $MarginContainer/VBox/Sprite
@onready var name_label: Label = $MarginContainer/VBox/NameLabel
@onready var stats_container: VBoxContainer = $MarginContainer/VBox/StatsContainer
@onready var desc_label: Label = $MarginContainer/VBox/DescLabel
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

	# Update name (use translation key if available)
	if name_label:
		var name_key = "CHARACTER_" + character.id.to_upper()
		var translated_name = tr(name_key)
		# Use translation if found, otherwise fall back to character.name
		name_label.text = translated_name if translated_name != name_key else character.name

	# Update description (use translation key if available)
	if desc_label:
		var desc_key = "DESC_" + character.id.to_upper()
		var translated_desc = tr(desc_key)
		# Use translation if found, otherwise fall back to character.description
		desc_label.text = translated_desc if translated_desc != desc_key else character.description

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
		# Try to translate the unlock requirement
		var unlock_key = character.unlock_requirement.to_upper().replace(" ", "_").replace("FOR", "")
		var translated_req = tr(unlock_key)
		lock_label.text = translated_req if translated_req != unlock_key else character.unlock_requirement

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

	# Add stats with translation keys
	_add_stat_label("STAT_HP", character.health_mult)
	_add_stat_label("STAT_SPEED", character.speed_mult)
	_add_stat_label("STAT_DAMAGE", character.damage_mult)
	_add_stat_label("STAT_XP", character.xp_mult)
	_add_stat_label("STAT_PICKUP", character.pickup_range_mult)

func _add_stat_label(stat_key: String, multiplier: float) -> void:
	var label = Label.new()
	var percent = int((multiplier - 1.0) * 100)
	var sign_str = "+" if percent >= 0 else ""
	var stat_name = tr(stat_key)

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
