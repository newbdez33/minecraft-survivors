extends CanvasLayer
class_name PauseMenu

## Pause menu shown when player presses ESC

signal resume_pressed
signal main_menu_pressed

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var language_container: HBoxContainer = $CenterContainer/VBoxContainer/LanguageContainer

var _language_buttons: Array[Button] = []
var _localization_manager: Node = null

func _ready() -> void:
	# Set process mode to always run even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Get LocalizationManager autoload
	_localization_manager = get_node_or_null("/root/LocalizationManager")
	if _localization_manager:
		_localization_manager.language_changed.connect(_on_language_changed)

	_update_texts()
	_setup_language_buttons()

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func show_menu() -> void:
	visible = true
	_update_texts()
	_update_language_button_states()
	if resume_button:
		resume_button.grab_focus()

func hide_menu() -> void:
	visible = false

func _update_texts() -> void:
	if title_label:
		title_label.text = tr("PAUSED")
	if resume_button:
		resume_button.text = tr("RESUME")
	if main_menu_button:
		main_menu_button.text = tr("MAIN_MENU")

func _on_language_changed(_locale: String) -> void:
	_update_texts()
	_update_language_button_states()

func _setup_language_buttons() -> void:
	if not language_container:
		return

	# Clear existing buttons
	for child in language_container.get_children():
		child.queue_free()
	_language_buttons.clear()

	# Create buttons for each language
	var locales = _localization_manager.get_supported_locales() if _localization_manager else ["en", "zh", "ja"]
	for locale in locales:
		var btn = Button.new()
		btn.text = _localization_manager.get_locale_name(locale) if _localization_manager else locale
		btn.custom_minimum_size = Vector2(50, 40)
		btn.pressed.connect(_on_language_button_pressed.bind(locale))
		language_container.add_child(btn)
		_language_buttons.append(btn)

	_update_language_button_states()

func _update_language_button_states() -> void:
	var current = _localization_manager.get_locale() if _localization_manager else "en"
	var locales = _localization_manager.get_supported_locales() if _localization_manager else ["en", "zh", "ja"]

	for i in range(_language_buttons.size()):
		var btn = _language_buttons[i]
		if i < locales.size() and locales[i] == current:
			btn.disabled = true
			btn.modulate = Color(1.0, 0.8, 0.2)  # Gold for selected
		else:
			btn.disabled = false
			btn.modulate = Color.WHITE

func _on_language_button_pressed(locale: String) -> void:
	if _localization_manager:
		_localization_manager.set_locale(locale)
