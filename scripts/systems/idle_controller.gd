extends Node
class_name IdleController
## AI controller for idle/auto-play mode
## Kites enemies at attack range, dodges projectiles, collects pickups
## Activated after unlocking "Idle Master" achievement (survive past wave 30)

signal idle_toggled(active: bool)

enum UpgradeStrategy { WEAPON_FIRST, BALANCED, DEFENSIVE }

var player: CharacterBody2D = null
var _enabled: bool = false
var _danger_distance: float = 50.0    # Too close - must flee (inside melee range)
var _kite_distance: float = 70.0      # Ideal range: sword hits, enemy melee misses
var _safe_distance: float = 200.0     # Comfortable distance for projectile awareness
var _pickup_radius: float = 200.0     # Collect pickups within this range
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
		# 2. Kite enemies: stay at attack range (not flee, not chase)
		var kite_vector = _get_kite_vector(tree)
		if kite_vector != Vector2.ZERO:
			move_dir = kite_vector
		else:
			# 3. Collect nearby pickups when no enemies nearby
			var pickup_dir = _get_pickup_direction(tree)
			if pickup_dir != Vector2.ZERO:
				move_dir = pickup_dir
			else:
				# 4. Move toward nearest enemy to engage combat
				var engage_dir = _get_engage_direction(tree)
				if engage_dir != Vector2.ZERO:
					move_dir = engage_dir
				else:
					# 5. Idle wander
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

## Kiting logic: maintain optimal combat distance from enemies
## - Too close (< danger): flee outward
## - At kite range: strafe around enemy (circle-kite)
## - Too far from all enemies: return Vector2.ZERO (let engage handle it)
func _get_kite_vector(tree: SceneTree) -> Vector2:
	var enemies = tree.get_nodes_in_group("enemies")
	if enemies.is_empty():
		return Vector2.ZERO

	var result = Vector2.ZERO
	var nearest_dist = INF
	var nearest_enemy: Node2D = null

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy

	if not nearest_enemy:
		return Vector2.ZERO

	var to_enemy = nearest_enemy.global_position - player.global_position
	var away_from_enemy = -to_enemy.normalized()

	if nearest_dist < _danger_distance:
		# Too close! Flee urgently (weighted by how close)
		var urgency = 1.0 - (nearest_dist / _danger_distance)
		result = away_from_enemy * (0.5 + urgency * 0.5)

		# Also flee from other nearby enemies
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy == nearest_enemy:
				continue
			var d = player.global_position.distance_to(enemy.global_position)
			if d < _danger_distance * 1.5:
				result += (player.global_position - enemy.global_position).normalized() * 0.3
	elif nearest_dist < _kite_distance + 20.0:
		# At good kiting range - strafe perpendicular (circle the enemy)
		var perp = Vector2(-to_enemy.y, to_enemy.x).normalized()
		# Slight outward bias to maintain range
		var outward_bias = away_from_enemy * 0.2
		result = perp + outward_bias
	else:
		# Beyond kite range but within pickup range - no kiting needed
		return Vector2.ZERO

	return result.normalized() if result != Vector2.ZERO else Vector2.ZERO

## Move toward nearest enemy when there are enemies but none in kiting range
func _get_engage_direction(tree: SceneTree) -> Vector2:
	var enemies = tree.get_nodes_in_group("enemies")
	if enemies.is_empty():
		return Vector2.ZERO

	var nearest: Node2D = null
	var min_dist = INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	if nearest and min_dist > _kite_distance + 20.0:
		# Approach enemy to get within attack range
		return (nearest.global_position - player.global_position).normalized()
	return Vector2.ZERO

func _get_projectile_dodge_vector(tree: SceneTree) -> Vector2:
	var projectiles = tree.get_nodes_in_group("projectiles")
	if projectiles.is_empty():
		return Vector2.ZERO

	var dodge = Vector2.ZERO
	for proj in projectiles:
		if not is_instance_valid(proj):
			continue
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
			dodge += to_player.normalized()
			continue

		# Dodge perpendicular to projectile direction
		var perpendicular = Vector2(-proj_vel.y, proj_vel.x).normalized()
		var side_a = player.global_position + perpendicular * 50.0
		var side_b = player.global_position - perpendicular * 50.0
		var dist_a = side_a.distance_to(proj.global_position)
		var dist_b = side_b.distance_to(proj.global_position)
		dodge += perpendicular if dist_a > dist_b else -perpendicular

	if dodge != Vector2.ZERO:
		return dodge.normalized()
	return Vector2.ZERO

func _get_pickup_direction(tree: SceneTree) -> Vector2:
	# Only collect pickups when no enemies are dangerously close
	var enemies = tree.get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if player.global_position.distance_to(enemy.global_position) < _kite_distance:
			return Vector2.ZERO  # Enemy too close, kiting takes priority

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
	for pickup in tree.get_nodes_in_group("pickups"):
		if not is_instance_valid(pickup):
			continue
		var dist = player.global_position.distance_to(pickup.global_position)
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
func select_upgrade(enchant_upgrades: Array, weapon_upgrades: Array) -> Dictionary:
	# Returns {"section": "enchant"|"weapon", "index": int}
	# ALWAYS prefer weapon upgrades first regardless of strategy
	if weapon_upgrades.size() > 0:
		return {"section": "weapon", "index": 0}

	match _strategy:
		UpgradeStrategy.WEAPON_FIRST:
			return _select_weapon_first(enchant_upgrades)
		UpgradeStrategy.DEFENSIVE:
			return _select_defensive(enchant_upgrades)
		_:
			return _select_balanced(enchant_upgrades)

func _select_weapon_first(enchant_upgrades: Array) -> Dictionary:
	# Priority: weapon-related enchantments
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var uname = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in WEAPON_KEYWORDS:
			if uname.containsn(keyword):
				return {"section": "enchant", "index": i}

	# Secondary: sweeping edge etc
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var uname = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in WEAPON_SECONDARY:
			if uname.containsn(keyword):
				return {"section": "enchant", "index": i}

	# Fallback: first available
	return {"section": "enchant", "index": 0}

func _select_defensive(enchant_upgrades: Array) -> Dictionary:
	for i in range(enchant_upgrades.size()):
		var upgrade = enchant_upgrades[i]
		var uname = upgrade.display_name if "display_name" in upgrade else str(upgrade)
		for keyword in DEFENSE_KEYWORDS:
			if uname.containsn(keyword):
				return {"section": "enchant", "index": i}
	return {"section": "enchant", "index": 0}

func _select_balanced(enchant_upgrades: Array) -> Dictionary:
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
