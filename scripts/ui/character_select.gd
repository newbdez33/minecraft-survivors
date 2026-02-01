extends Control
class_name CharacterSelectUI
## Character selection panel
## Shows available characters and allows selection

signal character_selected(character_id: String)
signal closed()

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var grid_container: HBoxContainer = $VBoxContainer/CharacterContainer
@onready var close_button: BaseButton = $VBoxContainer/CloseButton

var character_manager: Node = null
var character_card_scene: PackedScene = null

func _ready() -> void:
	# Load character card scene
	character_card_scene = load("res://scenes/ui/character_card.tscn")

	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Start hidden
	visible = false

func set_character_manager(manager: Node) -> void:
	character_manager = manager
	if manager:
		manager.character_unlocked.connect(_on_character_unlocked)

func populate_characters() -> void:
	if not character_manager or not grid_container:
		return

	# Clear existing cards
	for child in grid_container.get_children():
		child.queue_free()

	# Get all characters
	var all_characters = character_manager.get_all_characters()
	var selected_id = character_manager.selected_character_id

	for character in all_characters:
		_create_character_card(character, character.id == selected_id)

func _create_character_card(character, is_selected: bool) -> void:
	if not character_card_scene or not grid_container:
		return

	var card = character_card_scene.instantiate()
	if card.has_method("set_character"):
		card.set_character(character, is_selected)
	if card.has_signal("selected"):
		card.selected.connect(_on_card_selected.bind(character.id))
	grid_container.add_child(card)

func _on_card_selected(character_id: String) -> void:
	if character_manager and character_manager.select_character(character_id):
		character_selected.emit(character_id)
		populate_characters()  # Refresh to update selection

func _on_character_unlocked(_character) -> void:
	# Refresh the display
	populate_characters()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

func show_panel() -> void:
	populate_characters()
	visible = true

func hide_panel() -> void:
	visible = false
