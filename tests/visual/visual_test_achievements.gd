extends Node
## Visual Test Script for Achievement System
## Tests achievement triggers and UI notifications

var _test_index: int = 0
var _screenshot_count: int = 0
var _achievement_manager: Node = null
var _unlocked_achievements: Array = []

const ACHIEVEMENT_TESTS = [
	{"id": "first_kill", "trigger": "kills", "value": 1},
	{"id": "survive_60", "trigger": "survival", "value": 60},
	{"id": "wave_3", "trigger": "wave", "value": 3},
	{"id": "level_5", "trigger": "level", "value": 5},
]

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Achievement System")
	print("=".repeat(50))

	await get_tree().process_frame

	# Find achievement manager
	_achievement_manager = get_tree().current_scene.get_node_or_null("AchievementManager")

	if not _achievement_manager:
		print("ERROR: AchievementManager not found!")
		await get_tree().create_timer(2.0).timeout
		get_tree().quit(1)
		return

	print("AchievementManager found: %s" % _achievement_manager)

	# Connect to achievement signals
	_achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Report achievement definitions
	_report_achievements()

	# Test manual achievement triggers
	await get_tree().create_timer(1.0).timeout
	await _test_achievement_triggers()

	_finish_tests()

func _report_achievements() -> void:
	print("\n[ACHIEVEMENT DEFINITIONS]")
	var all_achievements = _achievement_manager.get_all_achievements()
	print("  Total achievements: %d" % all_achievements.size())

	var unlocked = 0
	for ach in all_achievements:
		if ach.is_unlocked:
			unlocked += 1
		print("  - %s: %s (target: %d, reward: %d) [%s]" % [
			ach.id,
			ach.name,
			ach.target,
			ach.reward_emeralds,
			"UNLOCKED" if ach.is_unlocked else "locked"
		])

	print("  Unlocked: %d / %d" % [unlocked, all_achievements.size()])

func _test_achievement_triggers() -> void:
	print("\n[TESTING ACHIEVEMENT TRIGGERS]")

	# Reset achievements for clean test
	_achievement_manager.reset_all()
	print("  Achievements reset for testing")

	await get_tree().create_timer(0.5).timeout

	# Test kill achievement
	print("\n  Testing kill achievements...")
	_achievement_manager.check_kill_count(1)
	await get_tree().create_timer(1.5).timeout
	_take_screenshot("first_kill")

	# Test survival achievement
	print("\n  Testing survival achievements...")
	_achievement_manager.check_survival_time(60)
	await get_tree().create_timer(1.5).timeout
	_take_screenshot("survive_60")

	# Test wave achievement
	print("\n  Testing wave achievements...")
	_achievement_manager.check_wave(3)
	await get_tree().create_timer(1.5).timeout
	_take_screenshot("wave_3")

	# Test level achievement
	print("\n  Testing level achievements...")
	_achievement_manager.check_level(5)
	await get_tree().create_timer(1.5).timeout
	_take_screenshot("level_5")

	# Final summary
	print("\n[UNLOCKED DURING TEST]")
	for ach_name in _unlocked_achievements:
		print("  - %s" % ach_name)

func _on_achievement_unlocked(achievement) -> void:
	print("  >>> ACHIEVEMENT UNLOCKED: %s <<<" % achievement.name)
	_unlocked_achievements.append(achievement.name)

func _take_screenshot(name: String) -> void:
	_screenshot_count += 1
	var filename = "user://visual_test_achievement_%02d_%s.png" % [_screenshot_count, name]

	var image = get_viewport().get_texture().get_image()
	if image:
		var error = image.save_png(filename)
		if error == OK:
			print("    Screenshot saved: %s" % filename)

func _finish_tests() -> void:
	print("\n" + "=".repeat(50))
	print("  ACHIEVEMENT TEST COMPLETE")
	print("  Achievements unlocked: %d" % _unlocked_achievements.size())
	print("  Screenshots saved: %d" % _screenshot_count)
	print("=".repeat(50))

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
