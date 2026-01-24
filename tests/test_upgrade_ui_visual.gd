extends Node

var _timer: float = 0.0
var _screenshot_taken: bool = false

func _ready() -> void:
	# Set Chinese locale
	TranslationServer.set_locale("zh")
	print("[TEST] Locale set to: zh")
	
	# Wait for scene to load
	await get_tree().create_timer(1.0).timeout
	
	# Force show upgrade UI
	var upgrade_ui = get_tree().root.find_child("UpgradeUI", true, false)
	if upgrade_ui:
		print("[TEST] Found UpgradeUI, showing it...")
		upgrade_ui.visible = true
		upgrade_ui.show_upgrade_options()
	else:
		print("[TEST] ERROR: UpgradeUI not found")

func _process(delta: float) -> void:
	_timer += delta
	if _timer > 2.0 and not _screenshot_taken:
		_screenshot_taken = true
		_take_screenshot()

func _take_screenshot() -> void:
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var path = "res://docs/screenshots/testing/upgrade_ui_zh.png"
	image.save_png(ProjectSettings.globalize_path(path))
	print("[TEST] Screenshot saved: " + path)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)
