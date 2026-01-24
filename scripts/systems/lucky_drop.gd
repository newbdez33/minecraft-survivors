extends RefCounted
class_name LuckyDrop
## Handles random drops from enemies

signal drop_spawned(drop_type: String, position: Vector2)

enum DropType {
	NONE,
	DIAMOND,      # +50 emeralds (future)
	GOLDEN_APPLE, # Heal 50% HP
	XP_BOTTLE,    # Instant level up
	STRENGTH,     # 10s damage boost
	SPEED,        # 10s speed boost
	TOTEM,        # Revive on death
	CHEST         # 3 random upgrades
}

# Drop chances (out of 1000 for precision)
const DROP_TABLE: Dictionary = {
	DropType.DIAMOND: 5,       # 0.5%
	DropType.GOLDEN_APPLE: 10, # 1%
	DropType.XP_BOTTLE: 20,    # 2%
	DropType.STRENGTH: 15,     # 1.5%
	DropType.SPEED: 20,        # 2%
	DropType.TOTEM: 1,         # 0.1%
	DropType.CHEST: 3          # 0.3%
}

const DROP_NAMES: Dictionary = {
	DropType.DIAMOND: "Diamond",
	DropType.GOLDEN_APPLE: "Golden Apple",
	DropType.XP_BOTTLE: "XP Bottle",
	DropType.STRENGTH: "Strength Potion",
	DropType.SPEED: "Speed Potion",
	DropType.TOTEM: "Totem of Undying",
	DropType.CHEST: "Treasure Chest"
}

static func roll_drop() -> DropType:
	var roll = randi_range(1, 1000)
	var cumulative = 0

	for drop_type in DROP_TABLE:
		cumulative += DROP_TABLE[drop_type]
		if roll <= cumulative:
			return drop_type

	return DropType.NONE

static func get_drop_name(drop_type: DropType) -> String:
	return DROP_NAMES.get(drop_type, "Unknown")

static func apply_drop(player: Node, drop_type: DropType) -> void:
	match drop_type:
		DropType.GOLDEN_APPLE:
			_apply_golden_apple(player)
		DropType.XP_BOTTLE:
			_apply_xp_bottle(player)
		DropType.STRENGTH:
			_apply_strength(player)
		DropType.SPEED:
			_apply_speed(player)
		DropType.TOTEM:
			_apply_totem(player)
		DropType.CHEST:
			_apply_chest(player)
		DropType.DIAMOND:
			pass  # Future: add emeralds

static func _apply_golden_apple(player: Node) -> void:
	if player.has_method("heal"):
		var heal_amount = int(player.max_health * 0.5)
		player.heal(heal_amount)

static func _apply_xp_bottle(player: Node) -> void:
	if "xp_to_next_level" in player:
		player.add_xp(player.xp_to_next_level)

static func _apply_strength(player: Node) -> void:
	# Temporary damage boost
	var sword = player.get_node_or_null("Sword")
	if sword and "damage" in sword:
		var original_damage = sword.damage
		sword.damage *= 2

		# Reset after 10 seconds
		var timer = player.get_tree().create_timer(10.0)
		timer.timeout.connect(func(): sword.damage = original_damage)

static func _apply_speed(player: Node) -> void:
	if "speed" in player:
		var original_speed = player.speed
		player.speed *= 2

		# Reset after 10 seconds
		var timer = player.get_tree().create_timer(10.0)
		timer.timeout.connect(func(): player.speed = original_speed)

static func _apply_totem(player: Node) -> void:
	# Set flag for revive
	if not "has_totem" in player:
		player.set_meta("has_totem", true)
	else:
		player.has_totem = true

static func _apply_chest(player: Node) -> void:
	# Trigger upgrade UI 3 times
	var main = player.get_tree().current_scene
	if main:
		var upgrade_manager = main.get_node_or_null("UpgradeManager")
		var upgrade_ui = main.get_node_or_null("UpgradeUI")
		if upgrade_manager and upgrade_ui:
			# Queue 3 upgrade selections
			for i in range(3):
				var upgrades = upgrade_manager.get_random_upgrades(3)
				var weapon_upgrades = upgrade_manager.get_weapon_upgrades()
				if upgrades.size() > 0 or weapon_upgrades.size() > 0:
					upgrade_ui.show_upgrades(upgrades, weapon_upgrades)
					await upgrade_ui.upgrade_selected
