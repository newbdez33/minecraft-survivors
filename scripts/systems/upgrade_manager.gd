extends Node
class_name UpgradeManager
## Manages all available upgrades and applies them to the player

const UpgradeClass = preload("res://scripts/systems/upgrade.gd")

signal upgrade_applied(upgrade)

var available_upgrades: Array = []
var player: Node = null

## For testing: always include these upgrades in the random selection if available
var prioritized_upgrades: Array[String] = []

# Upgrade definitions
## Weapon upgrade IDs (shown in separate section)
const WEAPON_UPGRADE_IDS = ["sword", "bow"]

const UPGRADE_DEFS = {
	"sword": {"name": "Sword", "desc": "+2 damage, +5 range", "max": 12, "effect": 1.0, "icon": "res://assets/weapons/wood_sword.svg"},
	"bow": {"name": "Bow", "desc": "+2 damage, +20 range", "max": 12, "effect": 1.0, "icon": "res://assets/weapons/bow.svg"},
	"sharpness": {"name": "Sharpness", "desc": "+{value} damage", "max": 5, "effect": 5.0, "icon": "res://assets/ui/upgrades/sharpness.svg"},
	"knockback": {"name": "Knockback", "desc": "+{value} knockback", "max": 3, "effect": 30.0, "icon": "res://assets/ui/upgrades/knockback.svg"},
	"looting": {"name": "Looting", "desc": "+{value}% XP gain", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/looting.svg"},
	"protection": {"name": "Protection", "desc": "-{value}% damage taken", "max": 4, "effect": 10.0, "icon": "res://assets/ui/upgrades/protection.svg"},
	"swiftness": {"name": "Swiftness", "desc": "+{value}% move speed", "max": 3, "effect": 15.0, "icon": "res://assets/ui/upgrades/swiftness.svg"},
	"sweeping": {"name": "Sweeping Edge", "desc": "+{value} attack range", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/sweeping.svg"},
	"haste": {"name": "Haste", "desc": "-{value}% attack cooldown", "max": 3, "effect": 10.0, "icon": "res://assets/ui/upgrades/haste.svg"},
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
	var prioritized: Array = []

	# Filter upgrades that can still be upgraded (exclude weapons - they have separate section)
	for upgrade in available_upgrades:
		if upgrade.can_upgrade() and upgrade.id not in WEAPON_UPGRADE_IDS:
			# Check if this is a prioritized upgrade
			if upgrade.id in prioritized_upgrades:
				prioritized.append(upgrade)
			else:
				upgradeable.append(upgrade)

	# Always include prioritized upgrades first (for testing)
	var result: Array = []
	for upgrade in prioritized:
		if result.size() < count:
			result.append(upgrade)

	# Fill remaining slots with random upgrades
	upgradeable.shuffle()
	for upgrade in upgradeable:
		if result.size() >= count:
			break
		result.append(upgrade)

	# Shuffle final result so prioritized aren't always first
	result.shuffle()
	return result

## Get available weapon upgrades (for right side of upgrade menu)
## Returns only 1 random weapon - either owned (for upgrade) or new (to acquire)
func get_weapon_upgrades() -> Array:
	if not player:
		return []

	var available_weapons: Array = []
	for upgrade in available_upgrades:
		if upgrade.id in WEAPON_UPGRADE_IDS and upgrade.can_upgrade():
			available_weapons.append(upgrade)

	# Return 1 random weapon upgrade
	if available_weapons.size() > 0:
		available_weapons.shuffle()
		return [available_weapons[0]]
	return []

## Map upgrade ID to weapon node name
func _get_weapon_node_name(upgrade_id: String) -> String:
	match upgrade_id:
		"sword":
			return "Sword"
		"bow":
			return "Bow"
		_:
			return upgrade_id.capitalize()

## Get the current icon path for a weapon based on its level/tier
func get_weapon_icon(upgrade_id: String) -> String:
	if not player:
		return UPGRADE_DEFS[upgrade_id].icon

	match upgrade_id:
		"sword":
			var sword = player.get_node_or_null("Sword")
			if sword and "current_tier" in sword:
				match sword.current_tier:
					1:  # WOOD
						return "res://assets/weapons/wood_sword.svg"
					2:  # STONE
						return "res://assets/weapons/stone_sword.svg"
					3:  # IRON
						return "res://assets/weapons/iron_sword.svg"
					4:  # DIAMOND
						return "res://assets/weapons/diamond_sword.svg"
			return "res://assets/weapons/wood_sword.svg"
		"bow":
			return "res://assets/weapons/bow.svg"
		_:
			return UPGRADE_DEFS[upgrade_id].icon if upgrade_id in UPGRADE_DEFS else ""

## Check if all weapon upgrades are maxed
func all_weapons_maxed() -> bool:
	for upgrade in available_upgrades:
		if upgrade.id in WEAPON_UPGRADE_IDS and upgrade.can_upgrade():
			return false
	return true

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
		"sword":
			_apply_sword(upgrade)
		"bow":
			_apply_bow(upgrade)
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
		"haste":
			_apply_haste(upgrade)

func _apply_sword(_upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword and sword.has_method("upgrade"):
		sword.upgrade()

func _apply_sharpness(upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword and "damage" in sword:
		sword.damage += int(upgrade.effect_per_level)

func _apply_knockback(upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
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
	var sword = player.get_node_or_null("Sword")
	if sword and "attack_range" in sword:
		sword.attack_range += upgrade.effect_per_level
		# Update collision shape
		var shape = sword.get_node_or_null("CollisionShape2D")
		if shape and shape.shape is CircleShape2D:
			shape.shape.radius = sword.attack_range
		# Update visual range indicator
		sword.queue_redraw()

func _apply_haste(upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword and "attack_speed" in sword:
		# Reduce cooldown by percentage (e.g., 10% per level)
		var reduction = upgrade.effect_per_level / 100.0
		sword.attack_speed *= (1.0 - reduction)
	elif sword and "cooldown" in sword:
		var reduction = upgrade.effect_per_level / 100.0
		sword.cooldown *= (1.0 - reduction)

func _apply_bow(upgrade) -> void:
	var bow = player.get_node_or_null("Bow")
	if not bow:
		# First time - add bow weapon to player
		var bow_scene = load("res://scenes/weapons/bow.tscn")
		if bow_scene:
			bow = bow_scene.instantiate()
			bow.name = "Bow"
			player.add_child(bow)
			# Register with weapon slots
			var weapon_slots = player.get_node_or_null("WeaponSlots")
			if weapon_slots:
				weapon_slots.register_weapon(bow)
	else:
		# Upgrade existing bow
		bow.upgrade()

func get_upgrade_by_id(id: String):
	for upgrade in available_upgrades:
		if upgrade.id == id:
			return upgrade
	return null
