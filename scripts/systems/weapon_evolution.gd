extends RefCounted
class_name WeaponEvolution
## Defines a weapon evolution recipe

var base_weapon_id: String
var required_upgrade_id: String
var required_upgrade_level: int
var result_weapon_id: String
var result_scene_path: String

func _init(base: String = "", upgrade: String = "", level: int = 5, result: String = "", scene: String = "") -> void:
	base_weapon_id = base
	required_upgrade_id = upgrade
	required_upgrade_level = level
	result_weapon_id = result
	result_scene_path = scene

func can_evolve(current_weapon_id: String, upgrades: Dictionary) -> bool:
	if current_weapon_id != base_weapon_id:
		return false

	var upgrade_level = upgrades.get(required_upgrade_id, 0)
	return upgrade_level >= required_upgrade_level
