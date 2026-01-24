extends RefCounted
class_name Upgrade
## Single upgrade/enchantment that can be applied to the player

var id: String = ""
var _name_key: String = ""  # Translation key or display name
var _desc_key: String = ""  # Translation key or description
var icon_path: String = ""
var current_level: int = 0
var max_level: int = 1
var effect_per_level: float = 0.0
var use_translation: bool = false  # If true, use tr() for name/desc

func _init(upgrade_id: String = "", name: String = "", desc: String = "", max_lvl: int = 1, effect: float = 0.0) -> void:
	id = upgrade_id
	_name_key = name
	_desc_key = desc
	max_level = max_lvl
	effect_per_level = effect

## Get display name (translated if use_translation is true)
var display_name: String:
	get:
		if use_translation:
			return tr(_name_key)
		return _name_key

## Get description (translated if use_translation is true)
var description: String:
	get:
		if use_translation:
			return tr(_desc_key)
		return _desc_key

func can_upgrade() -> bool:
	return current_level < max_level

func get_current_effect() -> float:
	return effect_per_level * current_level

func get_next_effect() -> float:
	return effect_per_level * (current_level + 1)

func get_description_with_values() -> String:
	var next_val = get_next_effect()
	return description.replace("{value}", str(int(next_val)))

func apply(_player: Node) -> void:
	# Override in subclasses or use upgrade_manager
	current_level += 1
