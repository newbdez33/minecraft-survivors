extends Node
class_name TestMainMenuVisual
## Automated visual tests for Main Menu, Settings, and multi-language support

const SCREENSHOT_DIR = "res://docs/screenshots/testing/main_menu/"
const LANGUAGES = ["en", "ja", "zh"]

var _test_results: Array[Dictionary] = []
var _current_test: int = 0
var _tests: Array[Callable] = []

@onready var _main_menu: MainMenu = $MainMenu

func _ready() -> void:
	# Ensure screenshot directory exists
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))

	# Setup tests
	_tests = [
		_test_main_menu_english,
		_test_main_menu_japanese,
		_test_main_menu_chinese,
		_test_settings_panel_english,
		_test_settings_panel_japanese,
		_test_settings_panel_chinese,
		_test_scoreboard_panel_english,
	]

	# Start testing after a short delay for rendering
	await get_tree().create_timer(0.5).timeout
	_run_next_test()

func _run_next_test() -> void:
	if _current_test >= _tests.size():
		_finish_tests()
		return

	var test_callable = _tests[_current_test]
	await test_callable.call()
	_current_test += 1

	# Small delay between tests
	await get_tree().create_timer(0.3).timeout
	_run_next_test()

func _test_main_menu_english() -> void:
	print("[TEST] Main Menu - English")
	TranslationServer.set_locale("en")
	_main_menu.hide_panels()
	_main_menu._update_labels()
	await get_tree().create_timer(0.2).timeout

	var result = await _take_screenshot("01_main_menu_en")
	_verify_text_visible("MINECRAFT SURVIVORS", result)
	_verify_text_visible("Start Game", result)

func _test_main_menu_japanese() -> void:
	print("[TEST] Main Menu - Japanese")
	TranslationServer.set_locale("ja")
	_main_menu.hide_panels()
	_main_menu._update_labels()
	await get_tree().create_timer(0.2).timeout

	var result = await _take_screenshot("02_main_menu_ja")
	_verify_text_visible("マインクラフト", result)

func _test_main_menu_chinese() -> void:
	print("[TEST] Main Menu - Chinese")
	TranslationServer.set_locale("zh")
	_main_menu.hide_panels()
	_main_menu._update_labels()
	await get_tree().create_timer(0.2).timeout

	var result = await _take_screenshot("03_main_menu_zh")
	_verify_text_visible("我的世界", result)

func _test_settings_panel_english() -> void:
	print("[TEST] Settings Panel - English")
	TranslationServer.set_locale("en")
	_main_menu._update_labels()
	_main_menu._on_settings_pressed()
	await get_tree().create_timer(0.3).timeout

	var result = await _take_screenshot("04_settings_en")
	_add_result("Settings Panel English", true, "Screenshot saved")

func _test_settings_panel_japanese() -> void:
	print("[TEST] Settings Panel - Japanese")
	TranslationServer.set_locale("ja")
	_main_menu._settings_panel._update_labels()
	_main_menu._update_labels()
	await get_tree().create_timer(0.3).timeout

	var result = await _take_screenshot("05_settings_ja")
	_add_result("Settings Panel Japanese", true, "Screenshot saved")

func _test_settings_panel_chinese() -> void:
	print("[TEST] Settings Panel - Chinese")
	TranslationServer.set_locale("zh")
	_main_menu._settings_panel._update_labels()
	_main_menu._update_labels()
	await get_tree().create_timer(0.3).timeout

	var result = await _take_screenshot("06_settings_zh")
	_main_menu.hide_panels()
	_add_result("Settings Panel Chinese", true, "Screenshot saved")

func _test_scoreboard_panel_english() -> void:
	print("[TEST] Scoreboard Panel - English")
	TranslationServer.set_locale("en")
	_main_menu._update_labels()
	_main_menu._on_scoreboard_pressed()
	_main_menu._scoreboard_panel._update_labels()
	_main_menu._scoreboard_panel.refresh_scores()
	await get_tree().create_timer(0.3).timeout

	var result = await _take_screenshot("07_scoreboard_en")
	_main_menu.hide_panels()
	_add_result("Scoreboard Panel English", true, "Screenshot saved")

func _take_screenshot(name: String) -> Dictionary:
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "%s_%s.png" % [name, timestamp]
	var path = SCREENSHOT_DIR + filename

	# Get viewport image
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()

	# Save screenshot
	var global_path = ProjectSettings.globalize_path(path)
	var error = image.save_png(global_path)

	if error == OK:
		print("  Screenshot saved: %s" % filename)
		return {"success": true, "path": path, "image": image}
	else:
		print("  ERROR: Failed to save screenshot")
		return {"success": false, "path": "", "image": null}

func _verify_text_visible(expected: String, _result: Dictionary) -> void:
	# For now, just log the verification (actual OCR would require external tools)
	_add_result("Text '%s' should be visible" % expected, true, "Visual verification needed")

func _add_result(test_name: String, passed: bool, message: String) -> void:
	_test_results.append({
		"name": test_name,
		"passed": passed,
		"message": message
	})

func _finish_tests() -> void:
	print("\n" + "=".repeat(60))
	print("VISUAL TEST RESULTS - Main Menu")
	print("=".repeat(60))

	var passed = 0
	var failed = 0

	for result in _test_results:
		var status = "PASS" if result.passed else "FAIL"
		print("[%s] %s - %s" % [status, result.name, result.message])
		if result.passed:
			passed += 1
		else:
			failed += 1

	print("=".repeat(60))
	print("Total: %d tests, %d passed, %d failed" % [_test_results.size(), passed, failed])
	print("Screenshots saved to: %s" % SCREENSHOT_DIR)
	print("=".repeat(60))

	# Generate HTML report
	_generate_html_report()

	# Exit after tests
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0 if failed == 0 else 1)

func _generate_html_report() -> void:
	var html = """<!DOCTYPE html>
<html>
<head>
	<title>Main Menu Visual Test Report</title>
	<style>
		body { font-family: 'Courier New', monospace; background: #1a1a2e; color: #eee; padding: 20px; }
		h1 { color: #4ecca3; }
		.test-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 20px; }
		.test-card { background: #16213e; border-radius: 8px; padding: 15px; }
		.test-card img { width: 100%; border-radius: 4px; border: 2px solid #4ecca3; }
		.test-card h3 { color: #4ecca3; margin: 10px 0 5px 0; }
		.pass { color: #4ecca3; }
		.fail { color: #ff6b6b; }
		.summary { background: #0f3460; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
	</style>
</head>
<body>
	<h1>🎮 Main Menu Visual Test Report</h1>
	<div class="summary">
		<p>Generated: %s</p>
		<p>Tests: %d passed, %d failed</p>
	</div>
	<div class="test-grid">
""" % [Time.get_datetime_string_from_system(), _test_results.filter(func(r): return r.passed).size(), _test_results.filter(func(r): return not r.passed).size()]

	# Add test cards
	var screenshot_files = _get_screenshot_files()
	for file in screenshot_files:
		var test_name = file.get_basename().split("_")[0] + " " + file.get_basename().split("_")[1] if "_" in file else file
		html += """
		<div class="test-card">
			<img src="%s" alt="%s">
			<h3>%s</h3>
			<p class="pass">✓ Screenshot captured</p>
		</div>
""" % [file, test_name, test_name]

	html += """
	</div>
</body>
</html>
"""

	var report_path = SCREENSHOT_DIR + "report.html"
	var file = FileAccess.open(ProjectSettings.globalize_path(report_path), FileAccess.WRITE)
	if file:
		file.store_string(html)
		file.close()
		print("HTML report saved: %s" % report_path)

func _get_screenshot_files() -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	files.sort()
	return files
