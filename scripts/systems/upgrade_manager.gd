extends Node
class_name UpgradeManager
## Manages all available upgrades and applies them to the player

const UpgradeClass = preload("res://scripts/systems/upgrade.gd")

signal upgrade_applied(upgrade)

var available_upgrades: Array = []
var player: Node = null

# Upgrade definitions
const UPGRADE_DEFS = {
	"sharpness": {"name": "Sharpness", "desc": "+{value} damage", "max": 5, "effect": 5.0, "icon": "res://assets/ui/upgrades/sharpness.svg"},
	"knockback": {"name": "Knockback", "desc": "+{value} knockback", "max": 3, "effect": 30.0, "icon": "res://assets/ui/upgrades/knockback.svg"},
	"looting": {"name": "Looting", "desc": "+{value}% XP gain", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/looting.svg"},
	"protection": {"name": "Protection", "desc": "-{value}% damage taken", "max": 4, "effect": 10.0, "icon": "res://assets/ui/upgrades/protection.svg"},
	"swiftness": {"name": "Swiftness", "desc": "+{value}% move speed", "max": 3, "effect": 15.0, "icon": "res://assets/ui/upgrades/swiftness.svg"},
	"sweeping": {"name": "Sweeping Edge", "desc": "+{value} attack range", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/sweeping.svg"},
}

func _ready() -> void:
	_init_upgrades()

func _init_upgrades() -> void:
	available_upgrades.clear()
	for id in UPGRADE_DEFS:
		var def = UPGRADE_DEFS[id]
		var upgrade = UpgradeClass.new(id, def.name, def.desc, def.max, def.effect)
		upgrade.icon_path = def.icon
		available_upgrades.append(upgrade)

func set_player(p: Node) -> void:
	player = p

func get_random_upgrades(count: int = 3) -> Array:
	var upgradeable: Array = []

	# Filter upgrades that can still be upgraded
	for upgrade in available_upgrades:
		if upgrade.can_upgrade():
			upgradeable.append(upgrade)

	# Shuffle and take first N
	upgradeable.shuffle()

	var result: Array = []
	for i in range(min(count, upgradeable.size())):
		result.append(upgradeable[i])

	return result

func apply_upgrade(upgrade) -> void:
	if not upgrade.can_upgrade():
		return

	upgrade.current_level += 1
	_apply_effect(upgrade)
	upgrade_applied.emit(upgrade)

func _apply_effect(upgrade) -> void:
	if not player:
		return

	match upgrade.id:
		"sharpness":
			_apply_sharpness(upgrade)
		"knockback":
			_apply_knockback(upgrade)
		"looting":
			_apply_looting(upgrade)
		"protection":
			_apply_protection(upgrade)
		"swiftness":
			_apply_swiftness(upgrade)
		"sweeping":
			_apply_sweeping(upgrade)

func _apply_sharpness(upgrade) -> void:
	var sword = player.get_node_or_null("DiamondSword")
	if sword and "damage" in sword:
		sword.damage += int(upgrade.effect_per_level)

func _apply_knockback(upgrade) -> void:
	var sword = player.get_node_or_null("DiamondSword")
	if sword and "knockback" in sword:
		sword.knockback += upgrade.effect_per_level

func _apply_looting(_upgrade) -> void:
	# Store looting bonus on player
	if not "xp_multiplier" in player:
		return
	player.xp_multiplier += 0.2

func _apply_protection(_upgrade) -> void:
	# Store protection bonus on player
	if not "damage_reduction" in player:
		return
	player.damage_reduction += 0.1

func _apply_swiftness(upgrade) -> void:
	if "speed" in player:
		player.speed += player.speed * (upgrade.effect_per_level / 100.0)

func _apply_sweeping(upgrade) -> void:
	var sword = player.get_node_or_null("DiamondSword")
	if sword and "attack_range" in sword:
		sword.attack_range += upgrade.effect_per_level
		# Update collision shape
		var shape = sword.get_node_or_null("CollisionShape2D")
		if shape and shape.shape is CircleShape2D:
			shape.shape.radius = sword.attack_range
		# Update visual range indicator
		sword.queue_redraw()

func get_upgrade_by_id(id: String):
	for upgrade in available_upgrades:
		if upgrade.id == id:
			return upgrade
	return null
