extends Node
class_name CharacterManager
## Manages unlockable characters

signal character_unlocked(character: RefCounted)
signal character_selected(character: RefCounted)

const CharacterClass = preload("res://scripts/systems/character.gd")
const SAVE_PATH = "user://characters.json"

var characters: Dictionary = {}  # id -> GameCharacter
var selected_character_id: String = "steve"

# Character definitions
const CHARACTER_DEFS = {
	"steve": {
		"name": "Steve",
		"desc": "Balanced fighter with no special abilities",
		"sprite": "res://assets/characters/steve.svg",
		"unlocked": true,
		"health": 1.0,
		"speed": 1.0,
		"damage": 1.0,
		"xp": 1.0,
		"pickup": 1.0,
		"unlock_type": "",
		"unlock_value": 0,
		"unlock_desc": "Default character"
	},
	"alex": {
		"name": "Alex",
		"desc": "Fast and agile, +20% speed, +50% pickup range, -10% HP",
		"sprite": "res://assets/characters/alex.svg",
		"unlocked": false,
		"health": 0.9,
		"speed": 1.2,
		"damage": 1.0,
		"xp": 1.0,
		"pickup": 1.5,
		"unlock_type": "survival_time",
		"unlock_value": 900,  # 15 minutes
		"unlock_desc": "Survive for 15 minutes"
	}
}

func _ready() -> void:
	_init_characters()
	load_characters()

func _init_characters() -> void:
	characters.clear()
	for id in CHARACTER_DEFS:
		var def = CHARACTER_DEFS[id]
		var character = CharacterClass.new(id, def.name, def.desc)
		character.sprite_path = def.sprite
		character.is_unlocked = def.unlocked
		character.health_mult = def.health
		character.speed_mult = def.speed
		character.damage_mult = def.damage
		character.xp_mult = def.xp
		character.pickup_range_mult = def.pickup
		character.unlock_condition_type = def.unlock_type
		character.unlock_condition_value = def.unlock_value
		character.unlock_requirement = def.unlock_desc
		characters[id] = character

func get_character(id: String) -> RefCounted:
	return characters.get(id)

func get_selected_character() -> RefCounted:
	return characters.get(selected_character_id)

func select_character(id: String) -> bool:
	if id not in characters:
		return false

	var character = characters[id]
	if not character.is_unlocked:
		return false

	selected_character_id = id
	character_selected.emit(character)
	save_characters()
	return true

func apply_selected_to_player(player: Node) -> void:
	var character = get_selected_character()
	if character:
		character.apply_to_player(player)

func check_unlock_conditions(stats: Dictionary) -> void:
	for id in characters:
		var character = characters[id]
		if character.is_unlocked:
			continue

		var should_unlock = false

		match character.unlock_condition_type:
			"survival_time":
				if stats.get("survival_time", 0) >= character.unlock_condition_value:
					should_unlock = true
			"kills":
				if stats.get("kills", 0) >= character.unlock_condition_value:
					should_unlock = true
			"level":
				if stats.get("level", 0) >= character.unlock_condition_value:
					should_unlock = true
			"wave":
				if stats.get("wave", 0) >= character.unlock_condition_value:
					should_unlock = true

		if should_unlock:
			character.is_unlocked = true
			character_unlocked.emit(character)
			save_characters()

func get_unlocked_characters() -> Array:
	var result = []
	for character in characters.values():
		if character.is_unlocked:
			result.append(character)
	return result

func get_all_characters() -> Array:
	return characters.values()

func save_characters() -> void:
	var data = {
		"selected": selected_character_id,
		"characters": {}
	}

	for id in characters:
		data.characters[id] = characters[id].to_dict()

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(data, "\t")
		file.store_string(json)
		file.close()

func load_characters() -> void:
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

	if "selected" in data:
		selected_character_id = data.selected

	if "characters" in data:
		for id in data.characters:
			if id in characters:
				characters[id].from_dict(data.characters[id])
