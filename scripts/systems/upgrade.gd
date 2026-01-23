extends RefCounted
class_name Upgrade
## Single upgrade/enchantment that can be applied to the player

var id: String = ""
var display_name: String = ""
var description: String = ""
var icon_path: String = ""
var current_level: int = 0
var max_level: int = 1
var effect_per_level: float = 0.0

func _init(upgrade_id: String = "", name: String = "", desc: String = "", max_lvl: int = 1, effect: float = 0.0) -> void:
	id = upgrade_id
	display_name = name
	description = desc
	max_level = max_lvl
	effect_per_level = effect

func can_upgrade() -> bool:
	return current_level < max_level

func get_current_effect() -> float:
	return effect_per_level * current_level

func get_next_effect() -> float:
	return effect_per_level * (current_level + 1)

func get_description_with_values() -> String:
	var next_val = get_next_effect()
	return description.replace("{value}", str(next_val))

func apply(_player: Node) -> void:
	# Override in subclasses or use upgrade_manager
	current_level += 1
