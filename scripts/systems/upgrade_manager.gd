extends Node
class_name UpgradeManager
## Manages all available upgrades and applies them to the player

const UpgradeClass = preload("res://scripts/systems/upgrade.gd")
const UpgradeEffectClass = preload("res://scripts/effects/upgrade_effect.gd")
const StatPopupClass = preload("res://scripts/effects/stat_popup.gd")

signal upgrade_applied(upgrade)

var available_upgrades: Array = []
var player: Node = null
var torch_manager: Node = null  # Reference to TorchManager for torch upgrade

## For testing: always include these upgrades in the random selection if available
var prioritized_upgrades: Array[String] = []

# Upgrade definitions
## Weapon upgrade IDs (shown in separate section)
const WEAPON_UPGRADE_IDS = ["sword", "bow", "torch"]

## Upgrade definitions with translation keys
const UPGRADE_DEFS = {
	"sword": {"name_key": "UPGRADE_SWORD", "desc_key": "DESC_SWORD", "max": 12, "effect": 1.0, "icon": "res://assets/weapons/iron_blade.svg"},
	"bow": {"name_key": "UPGRADE_BOW", "desc_key": "DESC_BOW", "max": 4, "effect": 1.0, "icon": "res://assets/weapons/bow.svg"},
	"sharpness": {"name_key": "UPGRADE_SHARPNESS", "desc_key": "DESC_SHARPNESS", "max": 5, "effect": 5.0, "icon": "res://assets/ui/upgrades/sharpness.svg"},
	"knockback": {"name_key": "UPGRADE_KNOCKBACK", "desc_key": "DESC_KNOCKBACK", "max": 3, "effect": 30.0, "icon": "res://assets/ui/upgrades/knockback.svg"},
	"looting": {"name_key": "UPGRADE_LOOTING", "desc_key": "DESC_LOOTING", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/looting.svg"},
	"protection": {"name_key": "UPGRADE_PROTECTION", "desc_key": "DESC_PROTECTION", "max": 4, "effect": 10.0, "icon": "res://assets/ui/upgrades/protection.svg"},
	"swiftness": {"name_key": "UPGRADE_SWIFTNESS", "desc_key": "DESC_SWIFTNESS", "max": 3, "effect": 15.0, "icon": "res://assets/ui/upgrades/swiftness.svg"},
	"sweeping": {"name_key": "UPGRADE_SWEEPING", "desc_key": "DESC_SWEEPING", "max": 3, "effect": 20.0, "icon": "res://assets/ui/upgrades/sweeping.svg"},
	"haste": {"name_key": "UPGRADE_HASTE", "desc_key": "DESC_HASTE", "max": 3, "effect": 10.0, "icon": "res://assets/ui/upgrades/haste.svg"},
	"torch": {"name_key": "UPGRADE_TORCH", "desc_key": "DESC_TORCH", "max": 3, "effect": 1.0, "icon": "res://assets/weapons/war_lantern.svg"},
}

func _ready() -> void:
	_init_upgrades()

func _init_upgrades() -> void:
	available_upgrades.clear()
	for id in UPGRADE_DEFS:
		var def = UPGRADE_DEFS[id]
		var upgrade = UpgradeClass.new(id, def.name_key, def.desc_key, def.max, def.effect)
		upgrade.icon_path = def.icon
		upgrade.use_translation = true  # Flag to use tr() for name/desc
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
## Returns only 1 weapon - prioritizes weapons player already owns
func get_weapon_upgrades() -> Array:
	if not player:
		return []

	var owned_weapons: Array = []  # Weapons player already has
	var new_weapons: Array = []    # Weapons player can acquire

	for upgrade in available_upgrades:
		if upgrade.id in WEAPON_UPGRADE_IDS and upgrade.can_upgrade():
			# Check if player owns this weapon
			var has_weapon = false
			match upgrade.id:
				"sword":
					has_weapon = player.get_node_or_null("Sword") != null
				"bow":
					has_weapon = player.get_node_or_null("Bow") != null or player.get_node_or_null("Crossbow") != null
				"torch":
					has_weapon = player.get_node_or_null("Torch") != null

			if has_weapon:
				owned_weapons.append(upgrade)
			else:
				new_weapons.append(upgrade)

	# 70% chance to show owned weapon upgrade, 30% chance to show new weapon
	# If no owned weapons, show new weapon; if no new weapons, show owned
	var show_owned = randf() < 0.7

	if show_owned and owned_weapons.size() > 0:
		owned_weapons.shuffle()
		return [owned_weapons[0]]
	elif new_weapons.size() > 0:
		new_weapons.shuffle()
		return [new_weapons[0]]
	elif owned_weapons.size() > 0:
		owned_weapons.shuffle()
		return [owned_weapons[0]]

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
		return UPGRADE_DEFS[upgrade_id].icon if upgrade_id in UPGRADE_DEFS else ""

	match upgrade_id:
		"sword":
			var sword = player.get_node_or_null("Sword")
			if sword and "current_tier" in sword:
				match sword.current_tier:
					1:  # IRON_BLADE
						return "res://assets/weapons/iron_blade.svg"
					2:  # STEEL_BLADE
						return "res://assets/weapons/steel_blade.svg"
					3:  # FINE_STEEL
						return "res://assets/weapons/fine_steel_blade.svg"
					4:  # DIVINE
						return "res://assets/weapons/divine_weapon.svg"
			return "res://assets/weapons/iron_blade.svg"
		"bow":
			# Check if we already have crossbow (repeating crossbow)
			var crossbow = player.get_node_or_null("Crossbow")
			if crossbow:
				return "res://assets/weapons/repeating_crossbow.svg"
			return "res://assets/weapons/bow.svg"
		"torch":
			return "res://assets/weapons/war_lantern.svg"
		_:
			return UPGRADE_DEFS[upgrade_id].icon if upgrade_id in UPGRADE_DEFS else ""

## Get the next evolution icon for display in evolution cards
func get_next_evolution_icon(upgrade_id: String) -> String:
	match upgrade_id:
		"sword":
			var sword = player.get_node_or_null("Sword") if player else null
			if sword and "current_tier" in sword:
				match sword.current_tier:
					1:  # IRON_BLADE -> STEEL_BLADE
						return "res://assets/weapons/steel_blade.svg"
					2:  # STEEL_BLADE -> FINE_STEEL
						return "res://assets/weapons/fine_steel_blade.svg"
					3:  # FINE_STEEL -> DIVINE
						return "res://assets/weapons/divine_weapon.svg"
			return ""
		"bow":
			return "res://assets/weapons/repeating_crossbow.svg"
		_:
			return ""

## Check if all weapon upgrades are maxed
func all_weapons_maxed() -> bool:
	for upgrade in available_upgrades:
		if upgrade.id in WEAPON_UPGRADE_IDS and upgrade.can_upgrade():
			return false
	return true

## Check if next upgrade will cause a tier/shape evolution
## Sword tiers: 1-3=Wood, 4-6=Stone, 7-9=Iron, 10-12=Diamond
## sword.level = upgrade.current_level + 1 (sword starts at level 1)
## Sword evolves when sword.level BECOMES 4, 7, 10
## So we show evolution UI when next upgrade.current_level is 3, 6, 9
## (because after upgrade, sword.level will be 4, 7, 10)
## Bow evolves to Crossbow when bow.level reaches 4 (upgrade.current_level = 3)
func will_evolve_tier(upgrade_id: String) -> bool:
	var upgrade = get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return false

	var next_level = upgrade.current_level + 1

	match upgrade_id:
		"sword":
			# Show evolution UI when next upgrade will trigger evolution
			# next_level 3 -> sword.level becomes 4 (Wood->Stone)
			# next_level 6 -> sword.level becomes 7 (Stone->Iron)
			# next_level 9 -> sword.level becomes 10 (Iron->Diamond)
			return next_level in [3, 6, 9]
		"bow":
			# Evolves to Crossbow when bow.level reaches 4
			# Bow is created at level 1 on first upgrade (current_level = 1)
			# So bow.level = current_level, evolution at bow.level = 4
			# Show evolution UI when next upgrade will trigger it (next_level = 4)
			return next_level == 4
		_:
			return false

## Get the next tier name for display (translated)
## Shows tier name when next upgrade will trigger evolution
## sword: next_level 3 -> evolves to Stone, 6 -> Iron, 9 -> Diamond
## bow: next_level 3 -> evolves to Crossbow
func get_next_tier_name(upgrade_id: String) -> String:
	var upgrade = get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return ""

	var next_level = upgrade.current_level + 1

	match upgrade_id:
		"sword":
			match next_level:
				3: return tr("STEEL_BLADE")
				6: return tr("FINE_STEEL_BLADE")
				9: return tr("DIVINE_WEAPON")
				_: return ""
		"bow":
			if next_level == 4:
				return tr("UPGRADE_CROSSBOW")
			return ""
		_:
			return ""

## Evolution bonus for bow→crossbow
const BOW_EVOLUTION_BONUS = {
	"damage": 12,
	"range": 100.0,
	"pierce": 3
}

## Get evolution bonus description for display
func get_evolution_bonus_description(upgrade_id: String) -> String:
	if not player:
		return ""

	match upgrade_id:
		"sword":
			var sword = player.get_node_or_null("Sword")
			if not sword or not sword.has_method("get_next_evolution_bonus"):
				return ""

			var bonus = sword.get_next_evolution_bonus()
			if bonus.is_empty():
				return ""

			var parts = []
			if bonus.has("damage") and bonus.damage > 0:
				parts.append("+%d DMG" % bonus.damage)
			if bonus.has("range") and bonus.range > 0:
				parts.append("+%.0f Range" % bonus.range)
			if bonus.has("cooldown_reduction") and bonus.cooldown_reduction > 0:
				parts.append("-%.0f%% CD" % (bonus.cooldown_reduction * 100))

			return " | ".join(parts)

		"bow":
			# Bow→Crossbow evolution bonus
			# Show when current_level = 3 (next_level = 4 triggers evolution)
			var upgrade = get_upgrade_by_id("bow")
			if upgrade and upgrade.current_level == 3:
				var parts = []
				parts.append("+%d DMG" % BOW_EVOLUTION_BONUS.damage)
				parts.append("+%.0f Range" % BOW_EVOLUTION_BONUS.range)
				parts.append("%d Pierce" % BOW_EVOLUTION_BONUS.pierce)
				return " | ".join(parts)
			return ""

		_:
			return ""

func apply_upgrade(upgrade) -> void:
	if not upgrade.can_upgrade():
		return

	upgrade.current_level += 1
	_apply_effect(upgrade)

	# Play visual feedback
	_play_upgrade_visual(upgrade)

	upgrade_applied.emit(upgrade)


func _play_upgrade_visual(upgrade) -> void:
	"""Play visual feedback for upgrade application"""
	if not player or not is_instance_valid(player):
		return

	# Play upgrade effect on player
	UpgradeEffectClass.play_upgrade_effect(player, upgrade.id, upgrade.current_level)

	# Spawn stat popup with upgrade info
	var popup_text = _get_upgrade_popup_text(upgrade)
	var popup_color = UpgradeEffectClass.get_upgrade_color(upgrade.id)
	UpgradeEffectClass.spawn_stat_popup(player, popup_text, popup_color)


func _get_upgrade_popup_text(upgrade) -> String:
	"""Get the stat change text for popup display"""
	match upgrade.id:
		"sharpness":
			return "+%d DMG" % int(upgrade.effect_per_level)
		"protection":
			return "-%d%% DMG Taken" % int(upgrade.effect_per_level)
		"swiftness":
			return "+%d%% Speed" % int(upgrade.effect_per_level)
		"knockback":
			return "+%d Knockback" % int(upgrade.effect_per_level)
		"looting":
			return "+%d%% XP" % int(upgrade.effect_per_level)
		"sweeping":
			return "+%d Range" % int(upgrade.effect_per_level)
		"haste":
			return "-%d%% Cooldown" % int(upgrade.effect_per_level)
		"sword":
			return "Sword Lv.%d" % upgrade.current_level
		"bow":
			return "Bow Lv.%d" % upgrade.current_level
		"torch":
			return "Torch Lv.%d" % upgrade.current_level
		_:
			return "Lv.%d" % upgrade.current_level

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
		"torch":
			_apply_torch(upgrade)

func _apply_sword(_upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword and sword.has_method("upgrade"):
		sword.upgrade()

func _apply_sharpness(upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword:
		# Add to enhancement bonus (persists through weapon upgrades)
		if "enhancement_damage_bonus" in sword:
			sword.enhancement_damage_bonus += int(upgrade.effect_per_level)
		# Also update current damage immediately
		sword.damage = sword.get_total_damage() if sword.has_method("get_total_damage") else sword.damage + int(upgrade.effect_per_level)

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
	if sword:
		# Add to enhancement bonus (persists through weapon upgrades)
		if "enhancement_range_bonus" in sword:
			sword.enhancement_range_bonus += upgrade.effect_per_level
		# Update current range immediately
		sword.attack_range = sword.get_total_range() if sword.has_method("get_total_range") else sword.attack_range + upgrade.effect_per_level
		# Update collision shape
		var shape = sword.get_node_or_null("CollisionShape2D")
		if shape and shape.shape is CircleShape2D:
			shape.shape.radius = sword.attack_range
		# Update visual range indicator
		sword.queue_redraw()

func _apply_haste(upgrade) -> void:
	var sword = player.get_node_or_null("Sword")
	if sword:
		# Add to enhancement cooldown reduction (persists through weapon upgrades)
		var reduction = upgrade.effect_per_level / 100.0
		if "enhancement_cooldown_reduction" in sword:
			sword.enhancement_cooldown_reduction += reduction
		# Update current cooldown immediately
		sword.attack_cooldown = sword.get_total_cooldown() if sword.has_method("get_total_cooldown") else sword.attack_cooldown * (1.0 - reduction)
		# Update timer
		var timer = sword.get_node_or_null("AttackTimer")
		if timer:
			timer.wait_time = sword.attack_cooldown

func _apply_torch(_upgrade) -> void:
	var torch = player.get_node_or_null("Torch") if player else null

	if not torch:
		# First time - add torch weapon to player
		var torch_scene = load("res://scenes/weapons/torch.tscn")
		if torch_scene:
			torch = torch_scene.instantiate()
			torch.name = "Torch"
			player.add_child(torch)
			# Register with weapon slots at LEFT position (slot 2)
			var weapon_slots = player.get_node_or_null("WeaponSlots")
			if weapon_slots:
				weapon_slots.register_weapon(torch, 2)  # Slot 2 = left
	else:
		# Upgrade existing torch
		if torch.has_method("upgrade"):
			torch.upgrade()

	# Also update TorchManager for fog of war visibility
	if torch_manager and torch_manager.has_method("upgrade_torch"):
		torch_manager.upgrade_torch()

func _apply_bow(upgrade) -> void:
	var bow = player.get_node_or_null("Bow")
	var crossbow = player.get_node_or_null("Crossbow")

	# If crossbow already exists, upgrade it instead
	if crossbow:
		crossbow.upgrade()
		return

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

		# Check for evolution to crossbow (level 4)
		if bow.level >= bow.MAX_LEVEL:
			_evolve_bow_to_crossbow(bow)

## Evolve bow to crossbow - replace bow node with crossbow
func _evolve_bow_to_crossbow(bow: Node) -> void:
	var weapon_slots = player.get_node_or_null("WeaponSlots")

	# Remove bow from weapon slots
	if weapon_slots and weapon_slots.has_method("remove_weapon"):
		weapon_slots.remove_weapon(bow)

	# Remove bow
	bow.queue_free()

	# Create crossbow
	var crossbow_scene = load("res://scenes/weapons/crossbow.tscn")
	if crossbow_scene:
		var crossbow = crossbow_scene.instantiate()
		crossbow.name = "Crossbow"
		player.add_child(crossbow)

		# Register crossbow with weapon slots
		if weapon_slots:
			weapon_slots.register_weapon(crossbow)

		print("[UPGRADE] Bow evolved to Crossbow!")

func get_upgrade_by_id(id: String):
	for upgrade in available_upgrades:
		if upgrade.id == id:
			return upgrade
	return null
