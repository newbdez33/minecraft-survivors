extends Node2D
## Visual Test: Day/Night Icon Transitions
## Takes screenshots at each phase and auto-exits after full cycle

@onready var hud: CanvasLayer = $HUD
@onready var day_night_cycle: Node = $DayNightCycle
@onready var overlay: CanvasModulate = $DayNightOverlay
@onready var phase_label: Label = $PhaseLabel

var screenshot_dir: String = "res://docs/screenshots/day_night_icons/"
var screenshot_times: Array = [2.5, 12.5, 30.0, 47.5, 57.5, 67.5, 90.0, 110.0, 117.5]
var screenshot_names: Array = ["01_dawn", "02_morning", "03_midday", "04_afternoon", "05_dusk", "06_moon_rise", "07_night", "08_late_night", "09_moon_set"]
var screenshots_taken: int = 0
var test_duration: float = 125.0  # Full cycle + buffer
var elapsed_time: float = 0.0  # Track actual elapsed time
var current_phase: String = ""

func _ready() -> void:
	# Ensure screenshot directory exists
	DirAccess.make_dir_recursive_absolute(screenshot_dir.replace("res://", ""))

	# Speed up the cycle for testing (still visible but faster)
	if day_night_cycle:
		day_night_cycle.day_duration = 60.0
		day_night_cycle.night_duration = 60.0
		day_night_cycle.start()

	print("=== DAY/NIGHT ICON VISUAL TEST ===")
	print("Test will run for ~125 seconds")
	print("Screenshots will be saved to: " + screenshot_dir)
	print("Phases: Dawn → Morning → Midday → Afternoon → Dusk → Moon Rise → Night → Late Night → Moon Set")
	print("")

func _process(delta: float) -> void:
	if not day_night_cycle:
		return

	elapsed_time += delta
	var time = day_night_cycle.current_time

	# Update HUD
	if hud:
		hud.set_time(time)
		hud.set_time_icon(time, day_night_cycle.day_duration, day_night_cycle.night_duration)

	# Update overlay tint
	if overlay and day_night_cycle:
		overlay.color = day_night_cycle.get_current_tint()

	# Update phase label
	var phase = _get_phase_name(time)
	if phase != current_phase:
		current_phase = phase
		if phase_label:
			phase_label.text = "Phase: " + phase + "\nTime: " + "%.1f" % time + "s\nElapsed: " + "%.1f" % elapsed_time + "s"
		print("[%.1fs] Phase: %s" % [time, phase])

	# Take screenshots at specific times (based on cycle time)
	if screenshots_taken < screenshot_times.size():
		var target_time = screenshot_times[screenshots_taken]
		if time >= target_time and time < target_time + 1.0:
			_take_screenshot(screenshot_names[screenshots_taken], time)
			screenshots_taken += 1

	# Auto-exit after test duration (based on elapsed time)
	if elapsed_time >= test_duration:
		print("")
		print("=== TEST COMPLETE ===")
		print("Screenshots taken: %d" % screenshots_taken)
		print("Elapsed time: %.1fs" % elapsed_time)
		print("Location: " + screenshot_dir)
		get_tree().quit()

func _get_phase_name(time: float) -> String:
	if time < 5.0:
		return "Dawn"
	elif time < 20.0:
		return "Morning"
	elif time < 40.0:
		return "Midday"
	elif time < 55.0:
		return "Afternoon"
	elif time < 60.0:
		return "Dusk"
	elif time < 75.0:
		return "Moon Rise"
	elif time < 105.0:
		return "Night"
	elif time < 115.0:
		return "Late Night"
	else:
		return "Moon Set"

func _take_screenshot(name: String, time: float) -> void:
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	var path = screenshot_dir + name + ".png"
	var error = img.save_png(path)
	if error == OK:
		print("  Screenshot: %s (%.1fs)" % [name, time])
	else:
		print("  ERROR saving screenshot: %s" % name)
