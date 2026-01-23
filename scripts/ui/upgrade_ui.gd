extends CanvasLayer
class_name UpgradeUI
## UI for selecting upgrades when leveling up

signal upgrade_selected(upgrade)

@onready var container: Control = $Container
@onready var title_label: Label = $Container/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $Container/VBoxContainer/CardsContainer

var _upgrades: Array = []
var _card_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	if container:
		container.visible = false

func show_upgrades(upgrades: Array) -> void:
	_upgrades = upgrades
	_create_cards()
	visible = true
	if container:
		container.visible = true
	get_tree().paused = true

func hide_ui() -> void:
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
	if index < _upgrades.size():
		var selected = _upgrades[index]
		upgrade_selected.emit(selected)
		hide_ui()
