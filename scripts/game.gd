extends Node2D
## Main game controller
## Connects player signals to HUD, manages upgrades and game state

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var spawner: Node = $MobSpawner
@onready var upgrade_manager: Node = $UpgradeManager
@onready var upgrade_ui: CanvasLayer = $UpgradeUI

func _ready() -> void:
	# Connect player health to HUD
	if player and hud:
		player.health_changed.connect(_on_player_health_changed)
		player.died.connect(_on_player_died)
		player.xp_changed.connect(_on_player_xp_changed)
		player.leveled_up.connect(_on_player_leveled_up)

		# Initialize HUD with player's starting values
		hud.update_health(player.current_health, player.max_health)
		hud.update_xp(player.current_xp, player.xp_to_next_level)
		hud.set_level(player.current_level)

	# Setup upgrade manager
	if upgrade_manager and player:
		upgrade_manager.set_player(player)

	# Connect upgrade UI
	if upgrade_ui:
		upgrade_ui.upgrade_selected.connect(_on_upgrade_selected)

func _on_player_health_changed(current: int, maximum: int) -> void:
	if hud:
		hud.update_health(current, maximum)

func _on_player_xp_changed(current: int, needed: int) -> void:
	if hud:
		hud.update_xp(current, needed)

func _on_player_leveled_up(new_level: int) -> void:
	if hud:
		hud.set_level(new_level)

	# Show upgrade selection
	if upgrade_manager and upgrade_ui:
		var upgrades = upgrade_manager.get_random_upgrades(3)
		if upgrades.size() > 0:
			upgrade_ui.show_upgrades(upgrades)

func _on_upgrade_selected(upgrade) -> void:
	if upgrade_manager:
		upgrade_manager.apply_upgrade(upgrade)

func _on_player_died() -> void:
	# Stop spawning
	if spawner:
		spawner.set_process(false)

	# TODO: Show game over screen
	print("GAME OVER")

	# Restart after delay (temporary)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
