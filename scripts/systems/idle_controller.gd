extends Node
class_name IdleController
## AI controller for idle/auto-play mode
## Reads enemy positions and makes movement decisions to keep player alive
## Activated after unlocking "Idle Master" achievement (survive past wave 30)

signal idle_toggled(active: bool)

enum UpgradeStrategy { WEAPON_FIRST, BALANCED, DEFENSIVE }

var player: CharacterBody2D = null
var _enabled: bool = false
var _flee_distance: float = 100.0
var _safe_distance: float = 200.0
var _pickup_radius: float = 150.0
var _strategy: UpgradeStrategy = UpgradeStrategy.WEAPON_FIRST

# Weapon-priority upgrade keywords
const WEAPON_KEYWORDS = ["Sword", "Bow", "Sharpness", "Haste"]
const WEAPON_SECONDARY = ["Sweeping"]
const DEFENSE_KEYWORDS = ["Protection", "Swiftness"]

func _physics_process(_delta: float) -> void:
	if not _enabled or not player or not is_instance_valid(player):
		return

	var tree = get_tree()
	if not tree:
		return

	# Don't move if game is paused (upgrade screen open)
	if tree.paused:
		return

	var move_dir = Vector2.ZERO

	# 1. Boss projectile dodge (highest priority)
	var projectile_dodge = _get_projectile_dodge_vector(tree)
	if projectile_dodge != Vector2.ZERO:
		move_dir = projectile_dodge
	else:
		# 2. Threat assessment - flee from nearby enemies
		var flee_vector = _get_flee_vector(tree)
		if flee_vector != Vector2.ZERO:
			move_dir = flee_vector
		else:
			# 3. Collect nearby pickups when safe
			var pickup_dir = _get_pickup_direction(tree)
			if pickup_dir != Vector2.ZERO:
				move_dir = pickup_dir
			else:
				# 4. Idle wander - slight orbit to avoid standing still
				move_dir = _get_wander_direction()

	# Apply movement to player
	if move_dir != Vector2.ZERO:
		player.velocity = move_dir.normalized() * player.speed
		var new_facing = move_dir.normalized()
		if new_facing != player.facing_direction:
			player.facing_direction = new_facing
			player.facing_changed.emit(new_facing)
	else:
		player.velocity = Vector2.ZERO

func _get_flee_vector(tree: SceneTree) -> Vector2:
	var enemies = tree.get_nodes_in_group("enemies")
	if enemies.is_empty():
		return Vector2.ZERO

	var flee = Vector2.ZERO
	var threat_count = 0

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < _flee_distance:
			# Weight inversely by distance (closer = stronger push)
			var weight = 1.0 - (dist / _flee_distance)
			flee += (player.global_position - enemy.global_position).normalized() * weight
			threat_count += 1

	if threat_count > 0:
		return flee.normalized()
	return Vector2.ZERO

func _get_projectile_dodge_vector(tree: SceneTree) -> Vector2:
	var projectiles = tree.get_nodes_in_group("projectiles")
	if projectiles.is_empty():
		return Vector2.ZERO

	var dodge = Vector2.ZERO
	for proj in projectiles:
		if not is_instance_valid(proj):
			continue
		# Only dodge enemy projectiles heading toward player
		var to_player = player.global_position - proj.global_position
		var dist = to_player.length()
		if dist > _safe_distance:
			continue

		# Get projectile velocity direction
		var proj_vel = Vector2.ZERO
		if proj is CharacterBody2D:
			proj_vel = proj.velocity
		elif "direction" in proj:
			proj_vel = proj.direction
		elif "velocity" in proj:
			proj_vel = proj.velocity

		if proj_vel == Vector2.ZERO:
			# No velocity info, just flee from it
			dodge += to_player.normalized()
			continue

		# Dodge perpendicular to projectile direction
		var perpendicular = Vector2(-proj_vel.y, proj_vel.x).normalized()
		# Choose the side that moves us further from the projectile
		var side_a = player.global_position + perpendicular * 50.0
		var side_b = player.global_position - perpendicular * 50.0
		var dist_a = side_a.distance_to(proj.global_position)
		var dist_b = side_b.distance_to(proj.global_position)
		dodge += perpendicular if dist_a > dist_b else -perpendicular

	if dodge != Vector2.ZERO:
		return dodge.normalized()
	return Vector2.ZERO

func _get_pickup_direction(tree: SceneTree) -> Vector2:
	var best_target: Node2D = null
	var best_dist = _pickup_radius

	# Check XP orbs
	for orb in tree.get_nodes_in_group("xp_orbs"):
		if not is_instance_valid(orb):
			continue
		var dist = player.global_position.distance_to(orb.global_position)
		if dist < best_dist:
			best_dist = dist
			best_target = orb

	# Check health pickups (prioritize if low health)
	var health_ratio = float(player.current_health) / float(player.max_health)
	var pickup_groups = ["pickups"]
	for group in pickup_groups:
		for pickup in tree.get_nodes_in_group(group):
			if not is_instance_valid(pickup):
				continue
			var dist = player.global_position.distance_to(pickup.global_position)
			# Prioritize health pickups when low health
			var effective_dist = dist * (0.5 if health_ratio < 0.5 else 1.0)
			if effective_dist < best_dist:
				best_dist = effective_dist
				best_target = pickup

	if best_target:
		return (best_target.global_position - player.global_position).normalized()
	return Vector2.ZERO

var _wander_angle: float = 0.0

func _get_wander_direction() -> Vector2:
	_wander_angle += 0.02
	return Vector2(cos(_wander_angle), sin(_wander_angle)) * 0.3

## Select the best upgrade based on current strategy
## Returns the index of the preferred upgrade from the combined options
func select_upgrade(enchant_upgrades: Array, weapon_upgrades: Array) -> Dictionary:
	# Returns {"section": "enchant"|"weapon", "index": int}
	match _strategy:
		UpgradeStrategy.WEAPON_FIRST:
			return _select_weapon_first(enchant_upgrades, weapon_upgrades)
		UpgradeStrategy.DEFENSIVE:
			return _select_defensive(enchant_upgrades, weapon_upgrades)
		_:
			return _select_balanced(enchant_upgrades, weapon_upgrades)

func _select_weapon_first(enchant_upgrades: Array, weapon_upgrades: Array) -> Dictionary:
	# First priority: weapon upgrades (sword/bow levels)
	if weapon_upgrades.size() > 0:
		return {"section": "weapon", "index": 0}

	# Second priority: weapon-related enchantments
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var name = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in WEAPON_KEYWORDS:
			if name.containsn(keyword):
				return {"section": "enchant", "index": i}

	# Third priority: secondary weapon enchantments
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var name = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in WEAPON_SECONDARY:
			if name.containsn(keyword):
				return {"section": "enchant", "index": i}

	# Fallback: first available
	if enchant_upgrades.size() > 0:
		return {"section": "enchant", "index": 0}
	return {"section": "enchant", "index": 0}

func _select_defensive(enchant_upgrades: Array, weapon_upgrades: Array) -> Dictionary:
	# First priority: defense enchantments
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var name = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in DEFENSE_KEYWORDS:
			if name.containsn(keyword):
				return {"section": "enchant", "index": i}

	# Second priority: weapon upgrades
	if weapon_upgrades.size() > 0:
		return {"section": "weapon", "index": 0}

	# Fallback
	if enchant_upgrades.size() > 0:
		return {"section": "enchant", "index": 0}
	return {"section": "enchant", "index": 0}

func _select_balanced(enchant_upgrades: Array, weapon_upgrades: Array) -> Dictionary:
	# Alternate between weapon and enchant
	var total = enchant_upgrades.size() + weapon_upgrades.size()
	if total == 0:
		return {"section": "enchant", "index": 0}

	# Pick randomly
	if weapon_upgrades.size() > 0 and (enchant_upgrades.is_empty() or randf() < 0.5):
		return {"section": "weapon", "index": randi() % weapon_upgrades.size()}
	if enchant_upgrades.size() > 0:
		return {"section": "enchant", "index": randi() % enchant_upgrades.size()}
	return {"section": "enchant", "index": 0}

func set_enabled(value: bool) -> void:
	_enabled = value
	idle_toggled.emit(value)

func is_enabled() -> bool:
	return _enabled

func get_strategy() -> UpgradeStrategy:
	return _strategy

func set_strategy(value: UpgradeStrategy) -> void:
	_strategy = value
