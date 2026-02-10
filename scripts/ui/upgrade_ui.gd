extends CanvasLayer
class_name UpgradeUI
## UI for selecting upgrades when leveling up
## - Left side: Random upgrades (enchantments)
## - Right side: Weapon upgrades only (sword, bow)
## - WASD/Arrow keys to navigate
## - 5 second timer to auto-select

signal upgrade_selected(upgrade)

@onready var container: Control = $Container
@onready var title_label: Label = $Container/MainVBox/TitleLabel
@onready var cards_container: HBoxContainer = $Container/MainVBox/SectionsContainer/EnchantSection/CardsContainer
@onready var weapon_cards_container: HBoxContainer = $Container/MainVBox/SectionsContainer/WeaponSection/WeaponCardsContainer
@onready var weapon_section: VBoxContainer = $Container/MainVBox/SectionsContainer/WeaponSection
@onready var weapon_label: Label = $Container/MainVBox/SectionsContainer/WeaponSection/WeaponLabel
@onready var timer_label: Label = $Container/MainVBox/TimerLabel

## Selection timeout in seconds
@export var selection_timeout: float = 5.0
## Whether to use auto-select timer (can be set via settings in future)
@export var use_timer: bool = false

## Weapon upgrade IDs
const WEAPON_UPGRADES = ["sword", "bow"]

var _upgrades: Array = []
var _weapon_upgrades: Array = []
var _card_buttons: Array[Button] = []
var _weapon_card_buttons: Array[Button] = []
var _selected_index: int = 0
var _in_weapon_section: bool = false
var _weapon_section_available: bool = true
var _timer: float = 0.0
var _is_active: bool = false
var _upgrade_manager: Node = null
var _evolution_cards: Array[bool] = []  # Track which weapon cards are evolution upgrades
var idle_controller: Node = null  # Set by game.gd when idle mode is active

## Normal, selected, and disabled styles
var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat
var _disabled_style: StyleBoxFlat
var _weapon_style: StyleBoxFlat
var _weapon_selected_style: StyleBoxFlat
var _evolution_style: StyleBoxFlat
var _evolution_selected_style: StyleBoxFlat

func _ready() -> void:
	visible = false
	if container:
		container.visible = false
	_create_styles()

func _create_styles() -> void:
	# Normal card style (enchantments)
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	_normal_style.border_color = Color(0.4, 0.4, 0.4)
	_normal_style.set_border_width_all(2)
	_normal_style.set_corner_radius_all(8)

	# Selected card style (gold border)
	_selected_style = StyleBoxFlat.new()
	_selected_style.bg_color = Color(0.25, 0.25, 0.2, 0.95)
	_selected_style.border_color = Color(1.0, 0.84, 0.0)  # Gold
	_selected_style.set_border_width_all(4)
	_selected_style.set_corner_radius_all(8)

	# Disabled card style (grayed out)
	_disabled_style = StyleBoxFlat.new()
	_disabled_style.bg_color = Color(0.15, 0.15, 0.15, 0.5)
	_disabled_style.border_color = Color(0.3, 0.3, 0.3, 0.5)
	_disabled_style.set_border_width_all(2)
	_disabled_style.set_corner_radius_all(8)

	# Weapon card style (cyan border)
	_weapon_style = StyleBoxFlat.new()
	_weapon_style.bg_color = Color(0.15, 0.2, 0.25, 0.9)
	_weapon_style.border_color = Color(0.3, 0.7, 0.9)  # Cyan
	_weapon_style.set_border_width_all(2)
	_weapon_style.set_corner_radius_all(8)

	# Weapon selected style (cyan + gold)
	_weapon_selected_style = StyleBoxFlat.new()
	_weapon_selected_style.bg_color = Color(0.15, 0.25, 0.3, 0.95)
	_weapon_selected_style.border_color = Color(0.3, 0.9, 1.0)  # Bright cyan
	_weapon_selected_style.set_border_width_all(4)
	_weapon_selected_style.set_corner_radius_all(8)

	# Evolution style (purple/gold glow for tier upgrades)
	_evolution_style = StyleBoxFlat.new()
	_evolution_style.bg_color = Color(0.2, 0.1, 0.3, 0.95)
	_evolution_style.border_color = Color(0.8, 0.5, 1.0)  # Purple
	_evolution_style.set_border_width_all(4)
	_evolution_style.set_corner_radius_all(12)

	# Evolution selected style (bright purple/gold)
	_evolution_selected_style = StyleBoxFlat.new()
	_evolution_selected_style.bg_color = Color(0.25, 0.15, 0.35, 0.98)
	_evolution_selected_style.border_color = Color(1.0, 0.8, 0.2)  # Gold
	_evolution_selected_style.set_border_width_all(6)
	_evolution_selected_style.set_corner_radius_all(12)

func _process(delta: float) -> void:
	if not _is_active:
		return

	# Only use timer if enabled
	if use_timer:
		_timer -= delta
		if _timer <= 0:
			_auto_select_upgrade()
			return

		# Update timer display
		if timer_label:
			timer_label.text = "%0.1f" % _timer
			timer_label.visible = true
	else:
		# Hide timer when not using auto-select
		if timer_label:
			timer_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return

	# Navigation with WASD or Arrow keys
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		_move_selection(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		_move_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_selection()
		get_viewport().set_input_as_handled()

func _move_selection(direction: int) -> void:
	if _in_weapon_section:
		# In weapon section
		var new_index = _selected_index + direction
		if new_index >= 0 and new_index < _weapon_card_buttons.size():
			_selected_index = new_index
			if use_timer:
				_timer = selection_timeout
		elif new_index < 0 and _card_buttons.size() > 0:
			# Move to enchantment section
			_in_weapon_section = false
			_selected_index = _card_buttons.size() - 1
			if use_timer:
				_timer = selection_timeout
	else:
		# In enchantment section
		var new_index = _selected_index + direction
		if new_index >= 0 and new_index < _card_buttons.size():
			_selected_index = new_index
			if use_timer:
				_timer = selection_timeout
		elif new_index >= _card_buttons.size() and _weapon_section_available and _weapon_card_buttons.size() > 0:
			# Move to weapon section
			_in_weapon_section = true
			_selected_index = 0
			if use_timer:
				_timer = selection_timeout

	_update_selection_visuals()

func _update_selection_visuals() -> void:
	# Update enchantment cards
	for i in range(_card_buttons.size()):
		var card = _card_buttons[i]
		if not _in_weapon_section and i == _selected_index:
			card.add_theme_stylebox_override("normal", _selected_style)
			card.add_theme_stylebox_override("hover", _selected_style)
			card.add_theme_stylebox_override("pressed", _selected_style)
		else:
			card.add_theme_stylebox_override("normal", _normal_style)
			card.add_theme_stylebox_override("hover", _normal_style)
			card.add_theme_stylebox_override("pressed", _normal_style)

	# Update weapon cards
	for i in range(_weapon_card_buttons.size()):
		var card = _weapon_card_buttons[i]
		var is_evolution = i < _evolution_cards.size() and _evolution_cards[i]

		if not _weapon_section_available:
			card.add_theme_stylebox_override("normal", _disabled_style)
			card.add_theme_stylebox_override("hover", _disabled_style)
			card.add_theme_stylebox_override("pressed", _disabled_style)
		elif _in_weapon_section and i == _selected_index:
			if is_evolution:
				card.add_theme_stylebox_override("normal", _evolution_selected_style)
				card.add_theme_stylebox_override("hover", _evolution_selected_style)
				card.add_theme_stylebox_override("pressed", _evolution_selected_style)
			else:
				card.add_theme_stylebox_override("normal", _weapon_selected_style)
				card.add_theme_stylebox_override("hover", _weapon_selected_style)
				card.add_theme_stylebox_override("pressed", _weapon_selected_style)
		else:
			if is_evolution:
				card.add_theme_stylebox_override("normal", _evolution_style)
				card.add_theme_stylebox_override("hover", _evolution_style)
				card.add_theme_stylebox_override("pressed", _evolution_style)
			else:
				card.add_theme_stylebox_override("normal", _weapon_style)
				card.add_theme_stylebox_override("hover", _weapon_style)
				card.add_theme_stylebox_override("pressed", _weapon_style)

func _confirm_selection() -> void:
	var selected = null
	if _in_weapon_section and _weapon_section_available:
		if _selected_index < _weapon_upgrades.size():
			selected = _weapon_upgrades[_selected_index]
	else:
		if _selected_index < _upgrades.size():
			selected = _upgrades[_selected_index]

	if selected:
		upgrade_selected.emit(selected)
	hide_ui()

func _auto_select_upgrade() -> void:
	if idle_controller and idle_controller.has_method("select_upgrade"):
		var choice = idle_controller.select_upgrade(_upgrades, _weapon_upgrades)
		if choice.section == "weapon" and _weapon_section_available and choice.index < _weapon_upgrades.size():
			_in_weapon_section = true
			_selected_index = choice.index
		elif choice.index < _upgrades.size():
			_in_weapon_section = false
			_selected_index = choice.index
	_confirm_selection()

func set_upgrade_manager(manager: Node) -> void:
	_upgrade_manager = manager

func show_upgrades(upgrades: Array, weapon_upgrades: Array = []) -> void:
	_upgrades = upgrades
	_weapon_upgrades = weapon_upgrades
	_weapon_section_available = weapon_upgrades.size() > 0

	_create_cards()
	_create_weapon_cards()

	# Default to middle enchantment option
	_in_weapon_section = false
	_selected_index = _upgrades.size() / 2 if _upgrades.size() > 0 else 0
	_update_selection_visuals()

	# Update weapon section label if disabled
	if weapon_label:
		if _weapon_section_available:
			weapon_label.text = tr("WEAPONS")
			weapon_label.modulate = Color(1, 1, 1, 1)
		else:
			weapon_label.text = tr("WEAPONS_MAX")
			weapon_label.modulate = Color(0.5, 0.5, 0.5, 0.7)

	# Start timer only if enabled
	if use_timer:
		_timer = selection_timeout
		# Must process while paused so auto-select timer ticks
		process_mode = Node.PROCESS_MODE_ALWAYS
	_is_active = true

	visible = true
	if container:
		container.visible = true
	get_tree().paused = true

func hide_ui() -> void:
	_is_active = false
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = false
	if container:
		container.visible = false
	get_tree().paused = false

func _create_cards() -> void:
	# Clear existing cards
	if cards_container:
		for child in cards_container.get_children():
			child.queue_free()
	_card_buttons.clear()

	# Create card for each upgrade
	for i in range(_upgrades.size()):
		var upgrade = _upgrades[i]
		var card = _create_card(upgrade, i, false, false)
		if cards_container:
			cards_container.add_child(card)
		_card_buttons.append(card)

func _create_weapon_cards() -> void:
	# Clear existing weapon cards
	if weapon_cards_container:
		for child in weapon_cards_container.get_children():
			child.queue_free()
	_weapon_card_buttons.clear()
	_evolution_cards.clear()

	# Create card for each weapon upgrade
	for i in range(_weapon_upgrades.size()):
		var upgrade = _weapon_upgrades[i]
		# Check if this is an evolution upgrade
		var is_evolution = false
		if _upgrade_manager and _upgrade_manager.has_method("will_evolve_tier"):
			is_evolution = _upgrade_manager.will_evolve_tier(upgrade.id)
		_evolution_cards.append(is_evolution)

		var card = _create_card(upgrade, i, true, is_evolution)
		if weapon_cards_container:
			weapon_cards_container.add_child(card)
		_weapon_card_buttons.append(card)

	# If no weapon upgrades available, show placeholder
	if _weapon_upgrades.size() == 0 and weapon_cards_container:
		var placeholder = _create_disabled_placeholder()
		weapon_cards_container.add_child(placeholder)

func _create_disabled_placeholder() -> Control:
	var card = Button.new()
	card.custom_minimum_size = Vector2(160, 220)
	card.disabled = true

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var label = Label.new()
	label.text = tr("ALL_MAXED")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(label)

	card.add_child(vbox)
	card.add_theme_stylebox_override("normal", _disabled_style)
	card.add_theme_stylebox_override("hover", _disabled_style)
	card.add_theme_stylebox_override("pressed", _disabled_style)
	card.add_theme_stylebox_override("disabled", _disabled_style)

	return card

func _create_card(upgrade, index: int, is_weapon: bool, is_evolution: bool = false) -> Button:
	var card = Button.new()
	card.clip_contents = true  # Clip any overflow

	# HUGE card for evolution upgrades
	if is_evolution:
		card.custom_minimum_size = Vector2(280, 350)
	elif is_weapon:
		card.custom_minimum_size = Vector2(160, 220)
	else:
		card.custom_minimum_size = Vector2(180, 250)

	# Margin container to add padding inside card
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)

	# Card content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4 if not is_evolution else 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Evolution banner at top
	if is_evolution:
		var evolution_label = Label.new()
		evolution_label.text = tr("EVOLUTION")
		evolution_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		evolution_label.add_theme_font_size_override("font_size", 18)
		evolution_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))  # Gold
		vbox.add_child(evolution_label)

	# Icon - use NEXT tier icon for evolution, current for regular
	var icon_path = upgrade.icon_path
	if is_weapon and _upgrade_manager:
		if is_evolution and _upgrade_manager.has_method("get_next_evolution_icon"):
			# Show the NEXT tier icon for evolution (works for both sword and bow)
			var next_icon = _upgrade_manager.get_next_evolution_icon(upgrade.id)
			if next_icon != "":
				icon_path = next_icon
		elif _upgrade_manager.has_method("get_weapon_icon"):
			icon_path = _upgrade_manager.get_weapon_icon(upgrade.id)

	if icon_path and icon_path != "":
		var icon_texture = load(icon_path)
		if icon_texture:
			var icon_container = CenterContainer.new()
			var icon = TextureRect.new()
			icon.texture = icon_texture
			# Icon sizes
			if is_evolution:
				icon.custom_minimum_size = Vector2(72, 72)
			elif is_weapon:
				icon.custom_minimum_size = Vector2(40, 40)
			else:
				icon.custom_minimum_size = Vector2(48, 48)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_container.add_child(icon)
			vbox.add_child(icon_container)

	# Name label - show NEXT tier name for evolution
	var name_label = Label.new()
	if is_evolution and _upgrade_manager and _upgrade_manager.has_method("get_next_tier_name"):
		name_label.text = _upgrade_manager.get_next_tier_name(upgrade.id)
	else:
		name_label.text = upgrade.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_evolution:
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))  # Bright gold
	elif is_weapon:
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))  # Cyan for weapons
	else:
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Gold for enchantments
	vbox.add_child(name_label)

	# Level label
	var level_label = Label.new()
	level_label.text = tr("LEVEL") + " " + str(upgrade.current_level + 1) + "/" + str(upgrade.max_level)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 11 if not is_evolution else 14)
	level_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(level_label)

	# Description label
	var desc_label = Label.new()
	desc_label.text = upgrade.get_description_with_values()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12 if not is_evolution else 14)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)

	# Evolution bonus label (only for evolution upgrades)
	if is_evolution and _upgrade_manager and _upgrade_manager.has_method("get_evolution_bonus_description"):
		var bonus_text = _upgrade_manager.get_evolution_bonus_description(upgrade.id)
		if bonus_text != "":
			var bonus_label = Label.new()
			bonus_label.text = tr("BONUS") + ": " + bonus_text
			bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			bonus_label.add_theme_font_size_override("font_size", 12)
			bonus_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))  # Green for bonus
			bonus_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.add_child(bonus_label)

	margin.add_child(vbox)
	card.add_child(margin)

	# Apply evolution style
	if is_evolution:
		card.add_theme_stylebox_override("normal", _evolution_style)
		card.add_theme_stylebox_override("hover", _evolution_style)
		card.add_theme_stylebox_override("pressed", _evolution_style)

	# Connect button
	if is_weapon:
		card.pressed.connect(_on_weapon_card_pressed.bind(index))
	else:
		card.pressed.connect(_on_card_pressed.bind(index))

	return card

func _on_card_pressed(index: int) -> void:
	_in_weapon_section = false
	_selected_index = index
	_confirm_selection()

func _on_weapon_card_pressed(index: int) -> void:
	if _weapon_section_available:
		_in_weapon_section = true
		_selected_index = index
		_confirm_selection()

## Get current selected index (for testing)
func get_selected_index() -> int:
	return _selected_index

## Get remaining time (for testing)
func get_remaining_time() -> float:
	return _timer

## Check if UI is active (for testing)
func is_active() -> bool:
	return _is_active

## Check if in weapon section (for testing)
func is_in_weapon_section() -> bool:
	return _in_weapon_section

## Set whether to use auto-select timer (for settings menu)
func set_use_timer(enabled: bool) -> void:
	use_timer = enabled

## Get whether auto-select timer is enabled
func get_use_timer() -> bool:
	return use_timer
