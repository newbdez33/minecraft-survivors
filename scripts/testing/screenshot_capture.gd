extends Node
class_name ScreenshotCapture
## Captures screenshots at key moments during test mode

signal screenshot_taken(path: String)

const SCREENSHOT_BASE = "res://docs/screenshots/testing/"

var screenshot_dir: String = ""
var screenshot_count: int = 0
var _capture_queue: Array[String] = []
var _is_capturing: bool = false

# Key moments to capture automatically
var _captured_events: Dictionary = {}

func _ready() -> void:
	# Create session folder with timestamp in project folder
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	screenshot_dir = SCREENSHOT_BASE + timestamp + "/"

	# Use globalized path for DirAccess since res:// is read-only at runtime
	var global_path = ProjectSettings.globalize_path(screenshot_dir)
	DirAccess.make_dir_recursive_absolute(global_path)
	print("[Screenshot] Saving to: %s" % global_path)

func capture(name: String, force: bool = false) -> void:
	# Avoid duplicate captures unless forced
	if not force and name in _captured_events:
		return

	_captured_events[name] = true
	_capture_queue.append(name)

	if not _is_capturing:
		_process_queue()

func _process_queue() -> void:
	if _capture_queue.is_empty():
		_is_capturing = false
		return

	_is_capturing = true
	var name = _capture_queue.pop_front()
	await _take_screenshot(name)
	_process_queue()

func _take_screenshot(name: String) -> void:
	# Wait for frame to render
	await RenderingServer.frame_post_draw

	var img = get_viewport().get_texture().get_image()
	screenshot_count += 1

	var filename = "%03d_%s.png" % [screenshot_count, name]
	# Use globalized path for saving
	var path = ProjectSettings.globalize_path(screenshot_dir) + filename

	var err = img.save_png(path)
	if err == OK:
		print("[Screenshot] Saved: %s" % filename)
		screenshot_taken.emit(path)
	else:
		print("[Screenshot] FAILED: %s (error %d)" % [filename, err])

# Convenience methods for common capture points
func capture_game_start() -> void:
	capture("game_start")

func capture_first_enemy() -> void:
	capture("first_enemy_spawn")

func capture_first_kill() -> void:
	capture("first_kill")

func capture_level_up(level: int) -> void:
	capture("level_up_%02d" % level, true)

func capture_upgrade_selection() -> void:
	capture("upgrade_selection", true)

func capture_poison_applied() -> void:
	capture("poison_applied")

func capture_poison_damage() -> void:
	capture("poison_tick", true)

func capture_low_health() -> void:
	capture("low_health")

func capture_game_over() -> void:
	capture("game_over")

func capture_wave_start(wave: int) -> void:
	capture("wave_%02d_start" % wave, true)

func capture_night_time() -> void:
	capture("night_time")

func capture_day_time() -> void:
	capture("day_time")

func capture_combo_milestone(combo: int) -> void:
	capture("combo_%d" % combo)

func capture_custom(name: String) -> void:
	capture(name, true)

func get_screenshot_dir() -> String:
	return ProjectSettings.globalize_path(screenshot_dir).rstrip("/")
