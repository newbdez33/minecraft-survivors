extends RefCounted
class_name ScoreCalculator
## Calculates score based on kills, time, level, and waves

const KILL_POINTS: int = 10
const TIME_POINTS: int = 1
const LEVEL_POINTS: int = 50
const WAVE_POINTS: int = 100

static func calculate(kills: int, time_seconds: int, level: int, waves: int) -> int:
	var score = 0
	score += kills * KILL_POINTS
	score += time_seconds * TIME_POINTS
	score += level * LEVEL_POINTS
	score += waves * WAVE_POINTS
	return score

static func calculate_from_stats(stats: Dictionary) -> int:
	var kills = stats.get("kills", 0)
	var time = stats.get("time", 0)
	var level = stats.get("level", 0)
	var waves = stats.get("waves", 0)
	return calculate(kills, time, level, waves)
