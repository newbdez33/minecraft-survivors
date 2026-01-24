extends CanvasLayer
class_name MainMenu
## Main menu UI with game options - Minecraft Dungeons style

signal start_pressed
signal settings_pressed
signal scoreboard_pressed
signal quit_pressed

@onready var _start_button: TextureButton = $Container/VBox/StartButton
@onready var _start_label: Label = $Container/VBox/StartButton/Label
@onready var _settings_button: TextureButton = $Container/VBox/SettingsButton
@onready var _settings_label: Label = $Container/VBox/SettingsButton/Label
@onready var _scoreboard_button: TextureButton = $Container/VBox/ScoreboardButton
@onready var _scoreboard_label: Label = $Container/VBox/ScoreboardButton/Label
@onready var _quit_button: TextureButton = $Container/VBox/QuitButton
@onready var _quit_label: Label = $Container/VBox/QuitButton/Label
@onready var _settings_panel: Control = $SettingsPanel
@onready var _scoreboard_panel: Control = $ScoreboardPanel
@onready var _dim_overlay: ColorRect = $DimOverlay

func _ready() -> void:
	# Load saved language setting
	_load_language_setting()

	# Update all labels with translations
	_update_labels()

	if _start_button:
		_start_button.pressed.connect(_on_start_pressed)
	if _settings_button:
		_settings_button.pressed.connect(_on_settings_pressed)
	if _scoreboard_button:
		_scoreboard_button.pressed.connect(_on_scoreboard_pressed)
	if _quit_button:
		_quit_button.pressed.connect(_on_quit_pressed)

	# Hide panels and overlay
	if _dim_overlay:
		_dim_overlay.visible = false
	if _settings_panel:
		_settings_panel.visible = false
		_settings_panel.settings_changed.connect(_on_settings_changed)
		_settings_panel.closed.connect(_on_panel_closed)
	if _scoreboard_panel:
		_scoreboard_panel.visible = false
		_scoreboard_panel.closed.connect(_on_panel_closed)

func _load_language_setting() -> void:
	var save_path = "user://settings.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			file.close()
			if error == OK and json.data is Dictionary:
				if json.data.has("language"):
					TranslationServer.set_locale(json.data.language)

func _update_labels() -> void:
	# Update button labels (TextureButtons with Label children)
	if _start_label:
		_start_label.text = tr("START_GAME")
	if _settings_label:
		_settings_label.text = tr("SETTINGS")
	if _scoreboard_label:
		_scoreboard_label.text = tr("SCOREBOARD")
	if _quit_label:
		_quit_label.text = tr("QUIT")

func _on_settings_changed() -> void:
	# Refresh labels when language changes
	_update_labels()

func _on_panel_closed() -> void:
	# Hide dim overlay when panel is closed
	if _dim_overlay:
		_dim_overlay.visible = false

func _on_start_pressed() -> void:
	start_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	settings_pressed.emit()
	if _dim_overlay:
		_dim_overlay.visible = true
	if _settings_panel:
		_settings_panel.visible = true

func _on_scoreboard_pressed() -> void:
	scoreboard_pressed.emit()
	if _dim_overlay:
		_dim_overlay.visible = true
	if _scoreboard_panel:
		_scoreboard_panel.visible = true

func _on_quit_pressed() -> void:
	quit_pressed.emit()
	get_tree().quit()

func hide_panels() -> void:
	if _settings_panel:
		_settings_panel.visible = false
	if _scoreboard_panel:
		_scoreboard_panel.visible = false
