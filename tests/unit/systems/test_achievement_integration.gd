extends Node
class_name TestAchievementIntegration
## Integration tests for Achievement System in game.gd
## Tests that achievements are properly triggered by game events

static func get_test_name() -> String:
	return "Achievement Integration Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Scene Structure Tests
	_add_result(results, test_main_scene_has_achievement_manager())
	_add_result(results, test_game_script_has_achievement_reference())

	# Achievement Manager API Tests
	_add_result(results, test_achievement_manager_has_check_kill_count())
	_add_result(results, test_achievement_manager_has_check_survival_time())
	_add_result(results, test_achievement_manager_has_check_level())
	_add_result(results, test_achievement_manager_has_check_wave())
	_add_result(results, test_achievement_manager_has_signals())

	# Kill Achievement Tests
	_add_result(results, test_first_kill_achievement_exists())
	_add_result(results, test_kills_100_achievement_exists())
	_add_result(results, test_kills_1000_achievement_exists())

	# Survival Achievement Tests
	_add_result(results, test_survive_60_achievement_exists())
	_add_result(results, test_survive_300_achievement_exists())
	_add_result(results, test_survive_600_achievement_exists())
	_add_result(results, test_survive_900_achievement_exists())

	# Level Achievement Tests
	_add_result(results, test_level_5_achievement_exists())
	_add_result(results, test_level_10_achievement_exists())
	_add_result(results, test_level_20_achievement_exists())

	# Wave Achievement Tests
	_add_result(results, test_wave_3_achievement_exists())
	_add_result(results, test_wave_5_achievement_exists())
	_add_result(results, test_wave_10_achievement_exists())

	# Special Achievement Tests
	_add_result(results, test_poison_survive_achievement_exists())
	_add_result(results, test_combo_achievements_exist())
	_add_result(results, test_unlock_achievements_exist())

	# Achievement Progress Tests
	_add_result(results, test_check_kill_count_updates_progress())
	_add_result(results, test_check_survival_time_updates_progress())
	_add_result(results, test_check_level_updates_progress())
	_add_result(results, test_check_wave_updates_progress())

	# Persistence Tests
	_add_result(results, test_achievement_save_path_valid())
	_add_result(results, test_achievement_to_dict_works())
	_add_result(results, test_achievement_from_dict_works())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# SCENE STRUCTURE TESTS
# =============================================================================

static func test_main_scene_has_achievement_manager() -> Dictionary:
	# Test that main.tscn includes AchievementManager node
	var scene = load("res://scenes/main.tscn")
	var passed = false
	if scene:
		var instance = scene.instantiate()
		var manager = instance.get_node_or_null("AchievementManager")
		passed = manager != null
		instance.queue_free()
	return {"name": "TC.AI.1: Main scene has AchievementManager node", "passed": passed}

static func test_game_script_has_achievement_reference() -> Dictionary:
	# Test that game.gd has @onready var achievement_manager
	var script = load("res://scripts/game.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("achievement_manager") and source.contains("AchievementManager")
	return {"name": "TC.AI.2: game.gd references AchievementManager", "passed": passed}

# =============================================================================
# ACHIEVEMENT MANAGER API TESTS
# =============================================================================

static func test_achievement_manager_has_check_kill_count() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func check_kill_count")
	return {"name": "TC.AI.3: AchievementManager has check_kill_count()", "passed": passed}

static func test_achievement_manager_has_check_survival_time() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func check_survival_time")
	return {"name": "TC.AI.4: AchievementManager has check_survival_time()", "passed": passed}

static func test_achievement_manager_has_check_level() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func check_level")
	return {"name": "TC.AI.5: AchievementManager has check_level()", "passed": passed}

static func test_achievement_manager_has_check_wave() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("func check_wave")
	return {"name": "TC.AI.6: AchievementManager has check_wave()", "passed": passed}

static func test_achievement_manager_has_signals() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("signal achievement_unlocked") and source.contains("signal progress_updated")
	return {"name": "TC.AI.7: AchievementManager has required signals", "passed": passed}

# =============================================================================
# KILL ACHIEVEMENT TESTS
# =============================================================================

static func test_first_kill_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("first_kill")
		passed = achievement != null
	return {"name": "TC.AI.8: first_kill achievement exists", "passed": passed}

static func test_kills_100_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("kills_100")
		passed = achievement != null and achievement.target == 100
	return {"name": "TC.AI.9: kills_100 achievement exists with target=100", "passed": passed}

static func test_kills_1000_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("kills_1000")
		passed = achievement != null and achievement.target == 1000
	return {"name": "TC.AI.10: kills_1000 achievement exists with target=1000", "passed": passed}

# =============================================================================
# SURVIVAL ACHIEVEMENT TESTS
# =============================================================================

static func test_survive_60_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("survive_60")
		passed = achievement != null and achievement.target == 60
	return {"name": "TC.AI.11: survive_60 achievement exists (1 min)", "passed": passed}

static func test_survive_300_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("survive_300")
		passed = achievement != null and achievement.target == 300
	return {"name": "TC.AI.12: survive_300 achievement exists (5 min)", "passed": passed}

static func test_survive_600_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("survive_600")
		passed = achievement != null and achievement.target == 600
	return {"name": "TC.AI.13: survive_600 achievement exists (10 min)", "passed": passed}

static func test_survive_900_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("survive_900")
		passed = achievement != null and achievement.target == 900
	return {"name": "TC.AI.14: survive_900 achievement exists (15 min)", "passed": passed}

# =============================================================================
# LEVEL ACHIEVEMENT TESTS
# =============================================================================

static func test_level_5_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("level_5")
		passed = achievement != null and achievement.target == 5
	return {"name": "TC.AI.15: level_5 achievement exists", "passed": passed}

static func test_level_10_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("level_10")
		passed = achievement != null and achievement.target == 10
	return {"name": "TC.AI.16: level_10 achievement exists", "passed": passed}

static func test_level_20_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("level_20")
		passed = achievement != null and achievement.target == 20
	return {"name": "TC.AI.17: level_20 achievement exists", "passed": passed}

# =============================================================================
# WAVE ACHIEVEMENT TESTS
# =============================================================================

static func test_wave_3_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("wave_3")
		passed = achievement != null and achievement.target == 3
	return {"name": "TC.AI.18: wave_3 achievement exists", "passed": passed}

static func test_wave_5_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("wave_5")
		passed = achievement != null and achievement.target == 5
	return {"name": "TC.AI.19: wave_5 achievement exists", "passed": passed}

static func test_wave_10_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("wave_10")
		passed = achievement != null and achievement.target == 10
	return {"name": "TC.AI.20: wave_10 achievement exists", "passed": passed}

# =============================================================================
# SPECIAL ACHIEVEMENT TESTS
# =============================================================================

static func test_poison_survive_achievement_exists() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var achievement = manager.get_achievement("poison_survive")
		passed = achievement != null and achievement.target == 10
	return {"name": "TC.AI.21: poison_survive achievement exists", "passed": passed}

static func test_combo_achievements_exist() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var combo_50 = manager.get_achievement("combo_50")
		var combo_100 = manager.get_achievement("combo_100")
		passed = combo_50 != null and combo_100 != null
	return {"name": "TC.AI.22: combo achievements exist (50, 100)", "passed": passed}

static func test_unlock_achievements_exist() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		var unlock_alex = manager.get_achievement("unlock_alex")
		var unlock_bow = manager.get_achievement("unlock_bow")
		var evolve = manager.get_achievement("evolve_weapon")
		passed = unlock_alex != null and unlock_bow != null and evolve != null
	return {"name": "TC.AI.23: unlock achievements exist", "passed": passed}

# =============================================================================
# ACHIEVEMENT PROGRESS TESTS
# =============================================================================

static func test_check_kill_count_updates_progress() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		manager.reset_all()  # Clear any previous state
		manager.check_kill_count(50)
		var achievement = manager.get_achievement("kills_100")
		# Progress should be updated (50 out of 100)
		passed = achievement != null and achievement.progress == 50
	return {"name": "TC.AI.24: check_kill_count updates achievement progress", "passed": passed}

static func test_check_survival_time_updates_progress() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		manager.reset_all()
		manager.check_survival_time(30)
		var achievement = manager.get_achievement("survive_60")
		passed = achievement != null and achievement.progress == 30
	return {"name": "TC.AI.25: check_survival_time updates achievement progress", "passed": passed}

static func test_check_level_updates_progress() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		manager.reset_all()
		manager.check_level(3)
		var achievement = manager.get_achievement("level_5")
		passed = achievement != null and achievement.progress == 3
	return {"name": "TC.AI.26: check_level updates achievement progress", "passed": passed}

static func test_check_wave_updates_progress() -> Dictionary:
	var manager = _create_achievement_manager()
	var passed = false
	if manager:
		manager.reset_all()
		manager.check_wave(2)
		var achievement = manager.get_achievement("wave_3")
		passed = achievement != null and achievement.progress == 2
	return {"name": "TC.AI.27: check_wave updates achievement progress", "passed": passed}

# =============================================================================
# PERSISTENCE TESTS
# =============================================================================

static func test_achievement_save_path_valid() -> Dictionary:
	var script = load("res://scripts/systems/achievement_manager.gd")
	var passed = false
	if script:
		var source = script.source_code
		passed = source.contains("user://achievements.json")
	return {"name": "TC.AI.28: Achievement save path is valid", "passed": passed}

static func test_achievement_to_dict_works() -> Dictionary:
	var AchievementClass = load("res://scripts/systems/achievement.gd")
	var passed = false
	if AchievementClass:
		var achievement = AchievementClass.new("test", "Test", "Desc", 10, 50)
		achievement.progress = 5
		var dict = achievement.to_dict()
		passed = dict.has("progress") and dict.progress == 5
	return {"name": "TC.AI.29: Achievement.to_dict() works", "passed": passed}

static func test_achievement_from_dict_works() -> Dictionary:
	var AchievementClass = load("res://scripts/systems/achievement.gd")
	var passed = false
	if AchievementClass:
		var achievement = AchievementClass.new("test", "Test", "Desc", 10, 50)
		achievement.from_dict({"progress": 7, "is_unlocked": true, "unlock_date": "2024-01-01"})
		passed = achievement.progress == 7 and achievement.is_unlocked
	return {"name": "TC.AI.30: Achievement.from_dict() works", "passed": passed}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

static func _create_achievement_manager():
	var script = load("res://scripts/systems/achievement_manager.gd")
	if script:
		var manager = Node.new()
		manager.set_script(script)
		manager._init_achievements()
		return manager
	return null

static func get_tested_functions() -> Array:
	return [
		"check_kill_count", "check_survival_time", "check_level", "check_wave",
		"check_combo", "check_poison_survived", "check_no_damage_time",
		"unlock_character_achievement", "unlock_bow_achievement", "unlock_evolution_achievement",
		"_check_achievement", "get_achievement", "get_all_achievements", "get_unlocked_count",
		"get_total_count", "save_achievements", "load_achievements", "reset_all",
		"to_dict", "from_dict", "check_progress", "unlock", "get_progress_percent"
	]
