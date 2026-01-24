extends RefCounted
class_name ScoreStorage
## Saves and loads high scores to/from file

const MAX_ENTRIES: int = 10
const SAVE_PATH: String = "user://high_scores.json"

var scores: Array = []

func _init() -> void:
	load_scores()

func save_score(score: int, stats: Dictionary = {}) -> void:
	var entry = {
		"score": score,
		"date": Time.get_datetime_string_from_system(),
		"stats": stats
	}

	scores.append(entry)
	scores.sort_custom(_compare_scores)

	# Keep only top entries
	if scores.size() > MAX_ENTRIES:
		scores.resize(MAX_ENTRIES)

	_save_to_file()

func load_scores() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		scores = []
		return scores

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			scores = json.data
		else:
			scores = []
	else:
		scores = []

	return scores

func get_high_score() -> int:
	if scores.is_empty():
		return 0
	return scores[0].get("score", 0)

func is_high_score(score: int) -> bool:
	if scores.size() < MAX_ENTRIES:
		return true
	return score > scores[-1].get("score", 0)

func get_rank(score: int) -> int:
	for i in range(scores.size()):
		if score > scores[i].get("score", 0):
			return i + 1
	return scores.size() + 1

func _compare_scores(a: Dictionary, b: Dictionary) -> bool:
	return a.get("score", 0) > b.get("score", 0)

func _save_to_file() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(scores, "\t")
		file.store_string(json_string)
		file.close()
