extends PanelContainer
class_name SettingsPanel
## Settings panel with game options

signal settings_changed
signal closed

const SAVE_PATH = "user://settings.json"

# Default settings
var settings: Dictionary = {
	"sfx_volume": 0.8,
	"music_volume": 0.6,
	"screen_shake": true,
	"damage_numbers": true,
	"pause_on_upgrade": true,
	"language": "en"
}

@onready var _title_label: Label = $MarginContainer/VBox/Title
@onready var _sfx_label: Label = $MarginContainer/VBox/SFXVolume/Label
@onready var _sfx_slider: HSlider = $MarginContainer/VBox/SFXVolume/Slider
@onready var _music_label: Label = $MarginContainer/VBox/MusicVolume/Label
@onready var _music_slider: HSlider = $MarginContainer/VBox/MusicVolume/Slider
@onready var _shake_label: Label = $MarginContainer/VBox/ScreenShake/Label
@onready var _shake_check: CheckBox = $MarginContainer/VBox/ScreenShake/CheckBox
@onready var _damage_label: Label = $MarginContainer/VBox/DamageNumbers/Label
@onready var _damage_check: CheckBox = $MarginContainer/VBox/DamageNumbers/CheckBox
@onready var _pause_label: Label = $MarginContainer/VBox/PauseUpgrade/Label
@onready var _pause_check: CheckBox = $MarginContainer/VBox/PauseUpgrade/CheckBox
@onready var _language_label: Label = $MarginContainer/VBox/Language/Label
@onready var _language_option: OptionButton = $MarginContainer/VBox/Language/OptionButton
@onready var _close_button: TextureButton = $MarginContainer/VBox/CloseButton
@onready var _close_label: Label = $MarginContainer/VBox/CloseButton/Label

func _ready() -> void:
	load_settings()
	_update_ui()
	_update_labels()

	if _sfx_slider:
		_sfx_slider.value_changed.connect(_on_sfx_changed)
	if _music_slider:
		_music_slider.value_changed.connect(_on_music_changed)
	if _shake_check:
		_shake_check.toggled.connect(_on_shake_toggled)
	if _damage_check:
		_damage_check.toggled.connect(_on_damage_toggled)
	if _pause_check:
		_pause_check.toggled.connect(_on_pause_toggled)
	if _language_option:
		_language_option.item_selected.connect(_on_language_selected)
	if _close_button:
		_close_button.pressed.connect(_on_close)

func _update_labels() -> void:
	if _title_label:
		_title_label.text = tr("SETTINGS")
	if _sfx_label:
		_sfx_label.text = tr("SFX_VOLUME")
	if _music_label:
		_music_label.text = tr("MUSIC_VOLUME")
	if _shake_label:
		_shake_label.text = tr("SCREEN_SHAKE")
	if _damage_label:
		_damage_label.text = tr("DAMAGE_NUMBERS")
	if _pause_label:
		_pause_label.text = tr("PAUSE_ON_UPGRADE")
	if _language_label:
		_language_label.text = tr("LANGUAGE")
	if _close_label:
		_close_label.text = tr("CLOSE")

func _update_ui() -> void:
	if _sfx_slider:
		_sfx_slider.value = settings.sfx_volume
	if _music_slider:
		_music_slider.value = settings.music_volume
	if _shake_check:
		_shake_check.button_pressed = settings.screen_shake
	if _damage_check:
		_damage_check.button_pressed = settings.damage_numbers
	if _pause_check:
		_pause_check.button_pressed = settings.pause_on_upgrade
	if _language_option:
		var lang_index = ["en", "ja", "zh"].find(settings.language)
		if lang_index >= 0:
			_language_option.selected = lang_index

func _on_sfx_changed(value: float) -> void:
	settings.sfx_volume = value
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.set_sfx_volume(value)
	_save_and_emit()

func _on_music_changed(value: float) -> void:
	settings.music_volume = value
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.set_music_volume(value)
	_save_and_emit()

func _on_shake_toggled(toggled: bool) -> void:
	settings.screen_shake = toggled
	_save_and_emit()

func _on_damage_toggled(toggled: bool) -> void:
	settings.damage_numbers = toggled
	_save_and_emit()

func _on_pause_toggled(toggled: bool) -> void:
	settings.pause_on_upgrade = toggled
	_save_and_emit()

func _on_language_selected(index: int) -> void:
	var languages = ["en", "ja", "zh"]
	if index >= 0 and index < languages.size():
		settings.language = languages[index]
		TranslationServer.set_locale(settings.language)
		_update_labels()  # Update settings panel labels
		_save_and_emit()

func _on_close() -> void:
	visible = false
	closed.emit()

func _save_and_emit() -> void:
	save_settings()
	settings_changed.emit()

func save_settings() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(settings, "\t")
		file.store_string(json)
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK and json.data is Dictionary:
			for key in json.data:
				if key in settings:
					settings[key] = json.data[key]
