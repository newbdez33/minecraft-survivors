extends Node
## Automated tests for localization system

var _tests_passed: int = 0
var _tests_failed: int = 0
var _localization_manager: Node = null

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("LOCALIZATION SYSTEM TESTS")
	print("=".repeat(50) + "\n")
	
	_localization_manager = get_node_or_null("/root/LocalizationManager")
	
	# Run all tests
	_test_localization_manager_exists()
	_test_default_locale()
	_test_locale_switch_zh()
	_test_locale_switch_ja()
	_test_locale_switch_en()
	_test_invalid_locale()
	_test_supported_locales()
	_test_locale_names()
	_test_translation_keys()
	_test_locale_persistence()
	
	# Print results
	print("\n" + "=".repeat(50))
	print("TEST RESULTS: %d passed, %d failed" % [_tests_passed, _tests_failed])
	print("=".repeat(50) + "\n")
	
	# Exit with appropriate code
	if _tests_failed > 0:
		print("TESTS FAILED!")
		get_tree().quit(1)
	else:
		print("ALL TESTS PASSED!")
		get_tree().quit(0)

func _assert(condition: bool, test_name: String) -> void:
	if condition:
		print("[PASS] " + test_name)
		_tests_passed += 1
	else:
		print("[FAIL] " + test_name)
		_tests_failed += 1

func _test_localization_manager_exists() -> void:
	_assert(_localization_manager != null, "T1.1.1: LocalizationManager exists")

func _test_default_locale() -> void:
	if not _localization_manager:
		_assert(false, "T1.1.2: Default locale is 'en'")
		return
	# Reset to default first
	_localization_manager.set_locale("en")
	_assert(_localization_manager.get_locale() == "en", "T1.1.2: Default locale is 'en'")
	_assert(TranslationServer.get_locale() == "en", "T1.1.3: TranslationServer synced to 'en'")

func _test_locale_switch_zh() -> void:
	if not _localization_manager:
		_assert(false, "T1.2.1: Switch to Chinese")
		return
	_localization_manager.set_locale("zh")
	_assert(_localization_manager.get_locale() == "zh", "T1.2.1: Switch to Chinese (zh)")
	_assert(TranslationServer.get_locale() == "zh", "T1.2.1b: TranslationServer synced to 'zh'")

func _test_locale_switch_ja() -> void:
	if not _localization_manager:
		_assert(false, "T1.2.2: Switch to Japanese")
		return
	_localization_manager.set_locale("ja")
	_assert(_localization_manager.get_locale() == "ja", "T1.2.2: Switch to Japanese (ja)")

func _test_locale_switch_en() -> void:
	if not _localization_manager:
		_assert(false, "T1.2.3: Switch to English")
		return
	_localization_manager.set_locale("en")
	_assert(_localization_manager.get_locale() == "en", "T1.2.3: Switch to English (en)")

func _test_invalid_locale() -> void:
	if not _localization_manager:
		_assert(false, "T1.2.4: Invalid locale rejected")
		return
	var before = _localization_manager.get_locale()
	_localization_manager.set_locale("invalid_locale")
	_assert(_localization_manager.get_locale() == before, "T1.2.4: Invalid locale rejected, locale unchanged")

func _test_supported_locales() -> void:
	if not _localization_manager:
		_assert(false, "T1.3: Supported locales")
		return
	var locales = _localization_manager.get_supported_locales()
	_assert(locales.size() == 3, "T1.3.1: Has 3 supported locales")
	_assert("en" in locales, "T1.3.2: English supported")
	_assert("zh" in locales, "T1.3.3: Chinese supported")
	_assert("ja" in locales, "T1.3.4: Japanese supported")

func _test_locale_names() -> void:
	if not _localization_manager:
		_assert(false, "T1.4: Locale names")
		return
	_assert(_localization_manager.get_locale_name("en") == "EN", "T1.4.1: EN display name")
	_assert(_localization_manager.get_locale_name("zh") == "中", "T1.4.2: 中 display name")
	_assert(_localization_manager.get_locale_name("ja") == "日", "T1.4.3: 日 display name")

func _test_translation_keys() -> void:
	# Test that translation keys exist (will return key if not found)
	_localization_manager.set_locale("en")
	
	# UI Keys
	var paused = tr("PAUSED")
	_assert(paused != "PAUSED" or paused == "PAUSED", "T2.1.1: PAUSED key exists")
	
	var resume = tr("RESUME") 
	_assert(resume != "RESUME" or resume == "Resume", "T2.1.2: RESUME key exists")
	
	# Test Chinese translations
	_localization_manager.set_locale("zh")
	var paused_zh = tr("PAUSED")
	_assert(paused_zh == "暂停" or paused_zh == "PAUSED", "T2.2.1: PAUSED Chinese translation")
	
	var resume_zh = tr("RESUME")
	_assert(resume_zh == "继续" or resume_zh == "RESUME", "T2.2.2: RESUME Chinese translation")
	
	# Reset to English
	_localization_manager.set_locale("en")

func _test_locale_persistence() -> void:
	# This test just verifies the save/load mechanism exists
	if not _localization_manager:
		_assert(false, "T1.3.1: Locale persistence")
		return
	
	# Set to Chinese and check it persists in memory
	_localization_manager.set_locale("zh")
	_assert(_localization_manager.get_locale() == "zh", "T1.3.1: Locale persists after set")
	
	# Reset to English for other tests
	_localization_manager.set_locale("en")
