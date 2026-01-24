extends RefCounted
class_name Achievement
## Single achievement definition

var id: String
var name: String
var description: String
var icon_path: String
var reward_emeralds: int
var unlock_condition: String  # Description of how to unlock
var is_unlocked: bool = false
var unlock_date: String = ""
var progress: int = 0
var target: int = 1

func _init(p_id: String, p_name: String, p_desc: String, p_target: int = 1, p_reward: int = 10) -> void:
	id = p_id
	name = p_name
	description = p_desc
	target = p_target
	reward_emeralds = p_reward

func check_progress(current: int) -> bool:
	progress = current
	if not is_unlocked and progress >= target:
		unlock()
		return true
	return false

func unlock() -> void:
	is_unlocked = true
	unlock_date = Time.get_datetime_string_from_system()

func get_progress_percent() -> float:
	if target <= 0:
		return 1.0 if is_unlocked else 0.0
	return clampf(float(progress) / float(target), 0.0, 1.0)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"is_unlocked": is_unlocked,
		"unlock_date": unlock_date,
		"progress": progress
	}

func from_dict(data: Dictionary) -> void:
	if "is_unlocked" in data:
		is_unlocked = data.is_unlocked
	if "unlock_date" in data:
		unlock_date = data.unlock_date
	if "progress" in data:
		progress = data.progress
