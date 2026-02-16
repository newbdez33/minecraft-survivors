extends Node
class_name AchievementManager
## Manages all achievements, tracks progress, saves/loads

signal achievement_unlocked(achievement: RefCounted)
signal progress_updated(achievement_id: String, progress: int, target: int)

const AchievementClass = preload("res://scripts/systems/achievement.gd")
const SAVE_PATH = "user://achievements.json"

var achievements: Dictionary = {}  # id -> Achievement
var total_emeralds: int = 0

# Achievement definitions
const ACHIEVEMENT_DEFS = {
	# Kill achievements
	"first_kill": {"name": "First Blood", "desc": "Kill your first enemy", "target": 1, "reward": 10},
	"kills_100": {"name": "Centurion", "desc": "Kill 100 enemies in one game", "target": 100, "reward": 50},
	"kills_1000": {"name": "Massacre", "desc": "Kill 1000 enemies in one game", "target": 1000, "reward": 200},

	# Survival achievements
	"survive_60": {"name": "Survivor", "desc": "Survive for 1 minute", "target": 60, "reward": 20},
	"survive_300": {"name": "Endurance", "desc": "Survive for 5 minutes", "target": 300, "reward": 50},
	"survive_600": {"name": "Ironman", "desc": "Survive for 10 minutes", "target": 600, "reward": 100},
	"survive_900": {"name": "Legend", "desc": "Survive for 15 minutes", "target": 900, "reward": 200},

	# Level achievements
	"level_5": {"name": "Getting Strong", "desc": "Reach level 5", "target": 5, "reward": 20},
	"level_10": {"name": "Veteran", "desc": "Reach level 10", "target": 10, "reward": 50},
	"level_20": {"name": "Master", "desc": "Reach level 20", "target": 20, "reward": 150},

	# Wave achievements
	"wave_3": {"name": "Wave Rider", "desc": "Reach wave 3", "target": 3, "reward": 20},
	"wave_5": {"name": "Wave Master", "desc": "Reach wave 5", "target": 5, "reward": 40},
	"wave_10": {"name": "Wave Legend", "desc": "Reach wave 10", "target": 10, "reward": 200},

	# Special achievements
	"poison_survive": {"name": "Toxic Resistance", "desc": "Survive poison 10 times", "target": 10, "reward": 60},
	"combo_50": {"name": "Combo King", "desc": "Reach 50 combo", "target": 50, "reward": 80},
	"combo_100": {"name": "Unstoppable", "desc": "Reach 100 combo", "target": 100, "reward": 150},
	"no_damage_60": {"name": "Untouchable", "desc": "Survive 60 seconds without damage", "target": 60, "reward": 100},

	# Unlock achievements
	"unlock_zhao_yun": {"name": "New Ally", "desc": "Unlock Zhao Yun", "target": 1, "reward": 50},
	"unlock_bow": {"name": "Archer", "desc": "Get the Bow weapon", "target": 1, "reward": 30},
	"evolve_weapon": {"name": "Evolution", "desc": "Evolve a weapon", "target": 1, "reward": 100},

	# Idle mode unlock
	"idle_master": {"name": "Idle Master", "desc": "Survive past wave 30", "target": 31, "reward": 150},
}

func _ready() -> void:
	_init_achievements()
	load_achievements()

func _init_achievements() -> void:
	achievements.clear()
	for id in ACHIEVEMENT_DEFS:
		var def = ACHIEVEMENT_DEFS[id]
		var achievement = AchievementClass.new(id, def.name, def.desc, def.target, def.reward)
		achievement.icon_path = "res://assets/ui/achievements/%s.svg" % id
		achievements[id] = achievement

func check_kill_count(kills: int) -> void:
	_check_achievement("first_kill", kills)
	_check_achievement("kills_100", kills)
	_check_achievement("kills_1000", kills)

func check_survival_time(seconds: int) -> void:
	_check_achievement("survive_60", seconds)
	_check_achievement("survive_300", seconds)
	_check_achievement("survive_600", seconds)
	_check_achievement("survive_900", seconds)

func check_level(level: int) -> void:
	_check_achievement("level_5", level)
	_check_achievement("level_10", level)
	_check_achievement("level_20", level)

func check_wave(wave: int) -> void:
	_check_achievement("wave_3", wave)
	_check_achievement("wave_5", wave)
	_check_achievement("wave_10", wave)
	_check_achievement("idle_master", wave)

func check_combo(combo: int) -> void:
	_check_achievement("combo_50", combo)
	_check_achievement("combo_100", combo)

func check_poison_survived(count: int) -> void:
	_check_achievement("poison_survive", count)

func check_no_damage_time(seconds: int) -> void:
	_check_achievement("no_damage_60", seconds)

func unlock_character_achievement() -> void:
	_check_achievement("unlock_zhao_yun", 1)

func unlock_bow_achievement() -> void:
	_check_achievement("unlock_bow", 1)

func unlock_evolution_achievement() -> void:
	_check_achievement("evolve_weapon", 1)

func _check_achievement(id: String, value: int) -> void:
	if id not in achievements:
		return

	var achievement = achievements[id]
	if achievement.check_progress(value):
		total_emeralds += achievement.reward_emeralds
		achievement_unlocked.emit(achievement)
		save_achievements()
	else:
		progress_updated.emit(id, achievement.progress, achievement.target)

func is_achievement_unlocked(id: String) -> bool:
	var achievement = achievements.get(id)
	return achievement != null and achievement.is_unlocked

func get_achievement(id: String) -> RefCounted:
	return achievements.get(id)

func get_all_achievements() -> Array:
	return achievements.values()

func get_unlocked_count() -> int:
	var count = 0
	for achievement in achievements.values():
		if achievement.is_unlocked:
			count += 1
	return count

func get_total_count() -> int:
	return achievements.size()

func save_achievements() -> void:
	var data = {
		"total_emeralds": total_emeralds,
		"achievements": {}
	}

	for id in achievements:
		data.achievements[id] = achievements[id].to_dict()

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(data, "\t")
		file.store_string(json)
		file.close()

func load_achievements() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return

	var data = json.data
	if not data is Dictionary:
		return

	if "total_emeralds" in data:
		total_emeralds = data.total_emeralds

	if "achievements" in data:
		for id in data.achievements:
			if id in achievements:
				achievements[id].from_dict(data.achievements[id])

func reset_all() -> void:
	total_emeralds = 0
	for achievement in achievements.values():
		achievement.is_unlocked = false
		achievement.unlock_date = ""
		achievement.progress = 0
	save_achievements()
