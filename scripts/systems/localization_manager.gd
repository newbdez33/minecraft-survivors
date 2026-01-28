extends Node
## Manages game localization and language switching
## Autoload singleton - access via LocalizationManager

signal language_changed(locale: String)

const SUPPORTED_LOCALES = ["en", "zh", "ja"]
const LOCALE_NAMES = {"en": "EN", "zh": "中", "ja": "日"}
const CONFIG_PATH = "user://settings.cfg"

var current_locale: String = "en"

func _ready() -> void:
	_load_saved_locale()

## Set the current locale
func set_locale(locale: String) -> void:
	if locale not in SUPPORTED_LOCALES:
		push_warning("Unsupported locale: " + locale)
		return
	
	if locale == current_locale:
		return
	
	current_locale = locale
	TranslationServer.set_locale(locale)
	_save_locale()
	language_changed.emit(locale)
	print("[LOCALIZATION] Language changed to: " + locale)

## Get the current locale
func get_locale() -> String:
	return current_locale

## Get display name for a locale
func get_locale_name(locale: String) -> String:
	return LOCALE_NAMES.get(locale, locale)

## Get all supported locales
func get_supported_locales() -> Array:
	return SUPPORTED_LOCALES.duplicate()

## Cycle to next language
func cycle_language() -> void:
	var idx = SUPPORTED_LOCALES.find(current_locale)
	var next_idx = (idx + 1) % SUPPORTED_LOCALES.size()
	set_locale(SUPPORTED_LOCALES[next_idx])

## Load saved locale from config file, or detect from system
func _load_saved_locale() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		var saved_locale = config.get_value("settings", "locale", "")
		if saved_locale in SUPPORTED_LOCALES:
			current_locale = saved_locale
			TranslationServer.set_locale(current_locale)
			print("[LOCALIZATION] Loaded saved locale: " + current_locale)
			return

	# No saved locale, detect from system
	current_locale = _detect_system_locale()
	TranslationServer.set_locale(current_locale)
	print("[LOCALIZATION] Detected system locale: " + current_locale)

## Detect locale from system settings
func _detect_system_locale() -> String:
	var system_locale = OS.get_locale()  # e.g., "en_US", "zh_CN", "ja_JP"
	var lang_code = system_locale.split("_")[0]  # Extract "en", "zh", "ja"

	if lang_code in SUPPORTED_LOCALES:
		return lang_code

	# Fallback to English
	return "en"

## Save current locale to config file
func _save_locale() -> void:
	var config = ConfigFile.new()
	config.load(CONFIG_PATH)  # Load existing settings if any
	config.set_value("settings", "locale", current_locale)
	config.save(CONFIG_PATH)

## Helper: Get translated text with value substitution
func tr_format(key: String, values: Dictionary = {}) -> String:
	var text = tr(key)
	for k in values:
		text = text.replace("{" + k + "}", str(values[k]))
	return text
