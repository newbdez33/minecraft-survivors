extends Control
## Visual test for sword artwork - displays all swords and takes screenshots

@onready var status_label: Label = $VBox/StatusLabel

var screenshot_dir: String = "res://docs/screenshots/testing/swords/"
var auto_screenshot: bool = true

func _ready() -> void:
	# Create screenshot directory
	DirAccess.make_dir_recursive_absolute(screenshot_dir.replace("res://", ProjectSettings.globalize_path("res://")))

	status_label.text = "Visual Test Ready"

	# Auto-take screenshot after a short delay
	if auto_screenshot:
		await get_tree().create_timer(0.5).timeout
		_take_screenshot()
		await get_tree().create_timer(0.5).timeout
		status_label.text = "Screenshot saved! Press ESC to exit."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			_take_screenshot()

func _take_screenshot() -> void:
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var filename = "sword_visual_test_%s.png" % timestamp
	var path = screenshot_dir + filename

	# Get viewport image
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()

	# Save to file
	var global_path = ProjectSettings.globalize_path(path)
	var error = image.save_png(global_path)

	if error == OK:
		status_label.text = "Screenshot saved: " + filename
		print("[VISUAL TEST] Screenshot saved: " + global_path)
	else:
		status_label.text = "Failed to save screenshot!"
		print("[VISUAL TEST] Failed to save screenshot: " + str(error))
