extends Node
class_name AutoPlayer
## Automatically controls player for testing
## Simulates real player behavior: dodge enemies, collect XP, select upgrades

signal test_event(event_name: String, data: Dictionary)

enum Strategy {
	SURVIVE,       # Dodge enemies, stay alive
	AGGRESSIVE,    # Move towards enemies
	STATIONARY,    # Stand still (test damage intake)
	COLLECT_XP,    # Prioritize XP orbs
	TRIGGER_POISON # Seek witch potions
}

@export var strategy: Strategy = Strategy.SURVIVE
@export var auto_upgrade: bool = true
@export var preferred_upgrades: Array[String] = ["sharpness", "swiftness", "protection"]

var player: CharacterBody2D
var _input_direction: Vector2 = Vector2.ZERO
var _upgrade_ui: Node = null

func _ready() -> void:
	# Find player after scene is ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player:
		test_event.emit("auto_player_ready", {"strategy": Strategy.keys()[strategy]})

func _physics_process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		return

	match strategy:
		Strategy.SURVIVE:
			_strategy_survive()
		Strategy.AGGRESSIVE:
			_strategy_aggressive()
		Strategy.STATIONARY:
			_input_direction = Vector2.ZERO
		Strategy.COLLECT_XP:
			_strategy_collect_xp()
		Strategy.TRIGGER_POISON:
			_strategy_trigger_poison()

	# Inject input to player
	_apply_input()

func _strategy_survive() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		_strategy_collect_xp()
		return

	# Find nearest enemy
	var nearest = _get_nearest(enemies)
	if nearest:
		var distance = player.global_position.distance_to(nearest.global_position)
		if distance < 60:
			# Too close! Run away from nearest enemy
			_input_direction = (player.global_position - nearest.global_position).normalized()
		elif distance < 120:
			# In sword range - stand and fight (let sword do its job)
			_input_direction = Vector2.ZERO
		else:
			# Safe distance, collect XP
			_strategy_collect_xp()

func _strategy_aggressive() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		_input_direction = Vector2.ZERO
		return

	var nearest = _get_nearest(enemies)
	if nearest:
		_input_direction = (nearest.global_position - player.global_position).normalized()

func _strategy_collect_xp() -> void:
	var orbs = get_tree().get_nodes_in_group("xp_orbs")
	if orbs.is_empty():
		# Wander randomly
		if randf() < 0.02:
			_input_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		return

	var nearest = _get_nearest(orbs)
	if nearest:
		_input_direction = (nearest.global_position - player.global_position).normalized()

func _strategy_trigger_poison() -> void:
	# Find witches or potions
	var potions = get_tree().get_nodes_in_group("projectiles")
	var witches = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.name.contains("Witch") or (enemy.has_method("get_class") and "Witch" in str(enemy.get_script())):
			witches.append(enemy)

	# Prioritize potions
	if not potions.is_empty():
		var nearest = _get_nearest(potions)
		if nearest:
			_input_direction = (nearest.global_position - player.global_position).normalized()
			return

	# Move towards witches
	if not witches.is_empty():
		var nearest = _get_nearest(witches)
		if nearest:
			_input_direction = (nearest.global_position - player.global_position).normalized()
			return

	# Fallback to aggressive
	_strategy_aggressive()

func _get_nearest(nodes: Array) -> Node2D:
	var nearest: Node2D = null
	var min_dist = INF

	for node in nodes:
		if not is_instance_valid(node):
			continue
		var dist = player.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = node

	return nearest

func _apply_input() -> void:
	if not player:
		return

	# Directly set player velocity based on our direction
	if _input_direction != Vector2.ZERO:
		player.velocity = _input_direction.normalized() * player.speed
	else:
		player.velocity = Vector2.ZERO

func set_strategy(new_strategy: Strategy) -> void:
	strategy = new_strategy
	test_event.emit("strategy_changed", {"strategy": Strategy.keys()[strategy]})

func handle_upgrade_selection(upgrade_ui: Node) -> void:
	if not auto_upgrade:
		return

	_upgrade_ui = upgrade_ui

	# Wait a frame for UI to populate
	await get_tree().process_frame

	# First check weapon upgrades (right side) for preferred weapons like "sword", "bow"
	var weapon_upgrades = upgrade_ui.get("_weapon_upgrades")
	if weapon_upgrades and weapon_upgrades.size() > 0:
		for i in range(weapon_upgrades.size()):
			var upgrade = weapon_upgrades[i]
			if upgrade.id in preferred_upgrades:
				# Switch to weapon section and select
				upgrade_ui._in_weapon_section = true
				upgrade_ui._selected_index = i
				upgrade_ui._update_selection_visuals()
				# Wait 0.5s for screenshot capture before confirming
				await get_tree().create_timer(0.5).timeout
				upgrade_ui._confirm_selection()
				test_event.emit("upgrade_selected", {
					"upgrade": upgrade.id,
					"index": i,
					"level": upgrade.current_level,
					"is_weapon": true,
					"is_sword": upgrade.id == "sword"
				})
				return

	# Then check enchantment upgrades (left side)
	var upgrades = upgrade_ui.get("_upgrades")
	if upgrades:
		for i in range(upgrades.size()):
			var upgrade = upgrades[i]
			if upgrade.id in preferred_upgrades:
				upgrade_ui._in_weapon_section = false
				upgrade_ui._selected_index = i
				upgrade_ui._confirm_selection()
				test_event.emit("upgrade_selected", {
					"upgrade": upgrade.id,
					"index": i,
					"level": upgrade.current_level,
					"is_weapon": false,
					"is_sword": false
				})
				return

		# No preferred upgrade found, select first available enchantment
		var first_upgrade = upgrades[0] if upgrades.size() > 0 else null
		upgrade_ui._confirm_selection()
		test_event.emit("upgrade_selected", {
			"upgrade": first_upgrade.id if first_upgrade else "none",
			"index": 0,
			"level": first_upgrade.current_level if first_upgrade else 0,
			"is_weapon": false,
			"is_sword": false
		})
