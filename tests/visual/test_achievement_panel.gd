extends Control
## Test scene to capture achievement panel with all achievements unlocked

const AchievementManagerClass = preload("res://scripts/systems/achievement_manager.gd")
const AchievementPanelScene = preload("res://scenes/ui/achievement_panel.tscn")

var _achievement_manager: Node = null
var _achievement_panel: Control = null

func _ready() -> void:
	await get_tree().process_frame
	
	_create_achievement_manager()
	_unlock_all_achievements()
	_create_achievement_panel()
	
	await get_tree().create_timer(0.5).timeout
	await get_tree().process_frame
	_take_screenshot()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _create_achievement_manager() -> void:
	_achievement_manager = AchievementManagerClass.new()
	add_child(_achievement_manager)

func _unlock_all_achievements() -> void:
	# Unlock all 21 achievements
	_achievement_manager.check_kill_count(1000)
	_achievement_manager.check_survival_time(900)
	_achievement_manager.check_level(20)
	_achievement_manager.check_wave(31)
	_achievement_manager.check_combo(100)
	_achievement_manager.check_poison_survived(10)
	_achievement_manager.check_no_damage_time(60)
	_achievement_manager.unlock_character_achievement()
	_achievement_manager.unlock_bow_achievement()
	_achievement_manager.unlock_evolution_achievement()
	
	print("[Test] Unlocked achievements: %d / %d" % [
		_achievement_manager.get_unlocked_count(),
		_achievement_manager.get_total_count()
	])

func _create_achievement_panel() -> void:
	_achievement_panel = AchievementPanelScene.instantiate()
	add_child(_achievement_panel)
	_achievement_panel.set_achievement_manager(_achievement_manager)
	_achievement_panel.show_panel()
	
	print("[Test] Achievement panel displayed")

func _take_screenshot() -> void:
	var viewport = get_viewport()
	if not viewport:
		print("[Test] ERROR: No viewport")
		return
	
	var texture = viewport.get_texture()
	if not texture:
		print("[Test] ERROR: No viewport texture")
		return
	
	var image = texture.get_image()
	if not image:
		print("[Test] ERROR: Could not get image from viewport")
		return
	
	var save_path = "res://docs/screenshots/achievement_all_unlocked.png"
	var error = image.save_png(save_path)
	if error == OK:
		print("[Test] Screenshot saved to: %s" % save_path)
	else:
		print("[Test] Failed to save screenshot: error %d" % error)
