extends Node
class_name LocalizationManager

## Localization Manager
## Manages game localization and language switching
## Supports: English (en), Japanese (ja), Chinese (zh)

signal language_changed(locale: String)

const SAVE_PATH = "user://settings.cfg"

## Available languages
const AVAILABLE_LANGUAGES: Dictionary = {
	"en": "English",
	"ja": "日本語",
	"zh": "简体中文"
}

## Current locale code
var current_locale: String = "en"


func _ready() -> void:
	_load_language_preference()


## Set the current language
func set_language(locale: String) -> void:
	if locale not in AVAILABLE_LANGUAGES:
		push_warning("Unknown locale: %s, falling back to 'en'" % locale)
		locale = "en"

	current_locale = locale
	TranslationServer.set_locale(locale)
	_save_language_preference()
	language_changed.emit(locale)


## Get the current language code
func get_current_language() -> String:
	return current_locale


## Get the current language display name
func get_current_language_name() -> String:
	return AVAILABLE_LANGUAGES.get(current_locale, "English")


## Get all available languages as dictionary {code: name}
func get_available_languages() -> Dictionary:
	return AVAILABLE_LANGUAGES.duplicate()


## Get list of language codes
func get_language_codes() -> Array:
	return AVAILABLE_LANGUAGES.keys()


## Cycle to next language
func cycle_language() -> void:
	var locales = AVAILABLE_LANGUAGES.keys()
	var current_index = locales.find(current_locale)
	var next_index = (current_index + 1) % locales.size()
	set_language(locales[next_index])


## Detect and set system language
func detect_system_language() -> void:
	var system_locale = OS.get_locale_language()

	# Try exact match first
	if system_locale in AVAILABLE_LANGUAGES:
		set_language(system_locale)
		return

	# Try language code without region (e.g., "en_US" -> "en")
	var lang_code = system_locale.split("_")[0]
	if lang_code in AVAILABLE_LANGUAGES:
		set_language(lang_code)
		return

	# Default to English
	set_language("en")


## Save language preference to file
func _save_language_preference() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "language", current_locale)
	var err = config.save(SAVE_PATH)
	if err != OK:
		push_warning("Failed to save language preference")


## Load language preference from file
func _load_language_preference() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err == OK:
		var saved_locale = config.get_value("settings", "language", "")
		if saved_locale in AVAILABLE_LANGUAGES:
			set_language(saved_locale)
			return

	# No saved preference, detect system language
	detect_system_language()
