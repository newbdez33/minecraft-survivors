extends Node
class_name WeaponEvolutionManager
## Manages weapon evolution system

signal evolution_available(evolution: RefCounted)
signal weapon_evolved(old_weapon: String, new_weapon: String)

const EvolutionClass = preload("res://scripts/systems/weapon_evolution.gd")

var evolutions: Array = []  # Array of WeaponEvolution
var player: Node = null
var upgrade_manager: Node = null

# Evolution definitions
const EVOLUTION_DEFS = {
	"crossbow": {
		"base": "bow",
		"upgrade": "sharpness",
		"level": 5,
		"scene": "res://scenes/weapons/crossbow.tscn"
	}
}

func _ready() -> void:
	_init_evolutions()

func _init_evolutions() -> void:
	evolutions.clear()
	for id in EVOLUTION_DEFS:
		var def = EVOLUTION_DEFS[id]
		var evolution = EvolutionClass.new(
			def.base,
			def.upgrade,
			def.level,
			id,
			def.scene
		)
		evolutions.append(evolution)

func set_player(p: Node) -> void:
	player = p

func set_upgrade_manager(um: Node) -> void:
	upgrade_manager = um

func check_evolutions() -> Array:
	var available: Array = []

	if not player or not upgrade_manager:
		return available

	var upgrades = _get_upgrade_levels()
	var weapons = _get_player_weapons()

	for evolution in evolutions:
		for weapon_id in weapons:
			if evolution.can_evolve(weapon_id, upgrades):
				available.append(evolution)
				evolution_available.emit(evolution)

	return available

func evolve_weapon(evolution: RefCounted) -> bool:
	if not player:
		return false

	var old_weapon = _find_weapon_node(evolution.base_weapon_id)
	if not old_weapon:
		return false

	# Remove old weapon
	var old_id = evolution.base_weapon_id
	old_weapon.queue_free()

	# Add evolved weapon
	var new_scene = load(evolution.result_scene_path)
	if not new_scene:
		return false

	var new_weapon = new_scene.instantiate()
	new_weapon.name = evolution.result_weapon_id.capitalize()
	player.add_child(new_weapon)

	weapon_evolved.emit(old_id, evolution.result_weapon_id)
	return true

func _get_upgrade_levels() -> Dictionary:
	var levels: Dictionary = {}

	if not upgrade_manager:
		return levels

	for upgrade in upgrade_manager.available_upgrades:
		levels[upgrade.id] = upgrade.current_level

	return levels

func _get_player_weapons() -> Array:
	var weapons: Array = []

	if not player:
		return weapons

	# Check for bow
	if player.get_node_or_null("Bow"):
		weapons.append("bow")

	# Check for sword
	if player.get_node_or_null("Sword"):
		weapons.append("sword")

	return weapons

func _find_weapon_node(weapon_id: String) -> Node:
	if not player:
		return null

	match weapon_id:
		"bow":
			return player.get_node_or_null("Bow")
		"sword":
			return player.get_node_or_null("Sword")

	return null

func get_evolution_by_id(id: String) -> RefCounted:
	for evolution in evolutions:
		if evolution.result_weapon_id == id:
			return evolution
	return null
