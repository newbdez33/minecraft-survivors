extends RefCounted
class_name ComboSystem
## Tracks kill combos and provides XP bonuses

signal combo_changed(combo: int)
signal milestone_reached(combo: int, bonus: float)

const MILESTONES: Dictionary = {
	10: 0.1,   # 10 combo = +10% XP
	25: 0.2,   # 25 combo = +20% XP
	50: 0.3,   # 50 combo = +30% XP
	100: 0.5,  # 100 combo = +50% XP
}

var current_combo: int = 0
var combo_timeout: float = 3.0
var _time_since_last_kill: float = 0.0
var _highest_combo: int = 0

func update(delta: float) -> void:
	if current_combo > 0:
		_time_since_last_kill += delta
		if _time_since_last_kill >= combo_timeout:
			reset_combo()

func on_enemy_killed() -> void:
	current_combo += 1
	_time_since_last_kill = 0.0

	if current_combo > _highest_combo:
		_highest_combo = current_combo

	combo_changed.emit(current_combo)

	# Check for milestones
	if current_combo in MILESTONES:
		milestone_reached.emit(current_combo, MILESTONES[current_combo])

func on_player_damaged() -> void:
	reset_combo()

func reset_combo() -> void:
	if current_combo > 0:
		current_combo = 0
		_time_since_last_kill = 0.0
		combo_changed.emit(current_combo)

func get_xp_bonus() -> float:
	var bonus: float = 0.0
	for milestone in MILESTONES:
		if current_combo >= milestone:
			bonus = MILESTONES[milestone]
	return bonus

func get_highest_combo() -> int:
	return _highest_combo
