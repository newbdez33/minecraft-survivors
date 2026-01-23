extends CanvasLayer
class_name UpgradeUI
## UI for selecting upgrades when leveling up
## - Default selection is the middle option
## - WASD/Arrow keys to navigate
## - 5 second timer to auto-select

signal upgrade_selected(upgrade)

@onready var container: Control = $Container
@onready var title_label: Label = $Container/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $Container/VBoxContainer/CardsContainer
@onready var timer_label: Label = $Container/VBoxContainer/TimerLabel

## Selection timeout in seconds
@export var selection_timeout: float = 5.0

var _upgrades: Array = []
var _card_buttons: Array[Button] = []
var _selected_index: int = 0
var _timer: float = 0.0
var _is_active: bool = false

## Normal and selected styles
var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat

func _ready() -> void:
	visible = false
	if container:
		container.visible = false
	_create_styles()

func _create_styles() -> void:
	# Normal card style
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

func _process(delta: float) -> void:
	if not _is_active:
		return

	# Update timer
	_timer -= delta
	if _timer <= 0:
		_confirm_selection()
		return

	# Update timer display
	if timer_label:
		timer_label.text = "%0.1f" % _timer

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
	var new_index = _selected_index + direction
	if new_index >= 0 and new_index < _card_buttons.size():
		_selected_index = new_index
		_update_selection_visuals()
		_timer = selection_timeout  # Reset timer on manual selection

func _update_selection_visuals() -> void:
	for i in range(_card_buttons.size()):
		var card = _card_buttons[i]
		if i == _selected_index:
			card.add_theme_stylebox_override("normal", _selected_style)
			card.add_theme_stylebox_override("hover", _selected_style)
			card.add_theme_stylebox_override("pressed", _selected_style)
		else:
			card.add_theme_stylebox_override("normal", _normal_style)
			card.add_theme_stylebox_override("hover", _normal_style)
			card.add_theme_stylebox_override("pressed", _normal_style)

func _confirm_selection() -> void:
	if _selected_index < _upgrades.size():
		var selected = _upgrades[_selected_index]
		upgrade_selected.emit(selected)
		hide_ui()

func show_upgrades(upgrades: Array) -> void:
	_upgrades = upgrades
	_create_cards()

	# Default to middle option
	_selected_index = _upgrades.size() / 2
	_update_selection_visuals()

	# Start timer
	_timer = selection_timeout
	_is_active = true

	visible = true
	if container:
		container.visible = true
	get_tree().paused = true

func hide_ui() -> void:
	_is_active = false
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
		var card = _create_card(upgrade, i)
		if cards_container:
			cards_container.add_child(card)
		_card_buttons.append(card)

func _create_card(upgrade, index: int) -> Button:
	var card = Button.new()
	card.custom_minimum_size = Vector2(200, 280)

	# Card content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Icon
	if upgrade.icon_path and upgrade.icon_path != "":
		var icon_texture = load(upgrade.icon_path)
		if icon_texture:
			var icon_container = CenterContainer.new()
			var icon = TextureRect.new()
			icon.texture = icon_texture
			icon.custom_minimum_size = Vector2(64, 64)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_container.add_child(icon)
			vbox.add_child(icon_container)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Name label
	var name_label = Label.new()
	name_label.text = upgrade.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Gold color
	vbox.add_child(name_label)

	# Level label
	var level_label = Label.new()
	level_label.text = "Level " + str(upgrade.current_level + 1) + "/" + str(upgrade.max_level)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(level_label)

	# Description label
	var desc_label = Label.new()
	desc_label.text = upgrade.get_description_with_values()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(desc_label)

	card.add_child(vbox)

	# Connect button
	card.pressed.connect(_on_card_pressed.bind(index))

	return card

func _on_card_pressed(index: int) -> void:
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
