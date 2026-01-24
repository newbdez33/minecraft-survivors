extends Node2D
## Main game controller
## Connects player signals to HUD, manages upgrades and game state
##
## Test Mode: Run with --test-mode to enable automatic testing
## Options: --scenario=FULL_AUTO --duration=120 --speed=1.0 --no-screenshots

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var spawner: Node = $MobSpawner
@onready var upgrade_manager: Node = $UpgradeManager
@onready var upgrade_ui: CanvasLayer = $UpgradeUI
@onready var game_over_ui: CanvasLayer = $GameOverUI
@onready var day_night_cycle: Node = $DayNightCycle
@onready var wave_manager: Node = $WaveManager
@onready var game_stats: Node = $GameStats
@onready var day_night_overlay: CanvasModulate = $DayNightOverlay

var _sword: Node = null

func _ready() -> void:
	# Check for test mode
	_check_test_mode()

	# Start tracking game stats
	if game_stats:
		game_stats.start_tracking()

	# Connect wave manager signals and start it
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.start()

	# Connect day/night cycle signals and start it
	if day_night_cycle:
		day_night_cycle.time_changed.connect(_on_time_changed)
		day_night_cycle.start()

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
		if upgrade_manager:
			upgrade_ui.set_upgrade_manager(upgrade_manager)

	# Connect game over UI
	if game_over_ui:
		game_over_ui.restart_pressed.connect(_on_restart_pressed)
		game_over_ui.quit_pressed.connect(_on_quit_pressed)

	# Connect spawner enemy_killed signal
	if spawner:
		spawner.enemy_killed.connect(_on_enemy_killed)

	# Connect sword evolution
	if player:
		_sword = player.get_node_or_null("Sword")
		if _sword and _sword.has_signal("evolved"):
			_sword.evolved.connect(_on_sword_evolved)

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
		var weapon_upgrades = upgrade_manager.get_weapon_upgrades()
		if upgrades.size() > 0 or weapon_upgrades.size() > 0:
			upgrade_ui.show_upgrades(upgrades, weapon_upgrades)

func _on_upgrade_selected(upgrade) -> void:
	if upgrade_manager:
		upgrade_manager.apply_upgrade(upgrade)

func _on_player_died() -> void:
	# Stop spawning
	if spawner:
		spawner.set_process(false)

	# Stop tracking stats
	if game_stats:
		game_stats.stop_tracking()
		game_stats.set_level(player.current_level if player else 1)

	# Show game over screen
	if game_over_ui:
		if game_stats:
			game_over_ui.set_stats(game_stats.get_stats())
		game_over_ui.show_game_over()
	else:
		# Fallback: restart after delay
		print("GAME OVER")
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

## Called when an enemy is killed via spawner signal
func _on_enemy_killed(_xp_value: int) -> void:
	if game_stats:
		game_stats.add_kill()
		# Update kills display
		if hud:
			hud.set_kills(game_stats.kills)

	# Notify sword for evolution tracking
	if _sword and _sword.has_method("on_enemy_killed"):
		_sword.on_enemy_killed()

## Called when sword evolves to a new tier
func _on_sword_evolved(new_tier: int) -> void:
	if _sword and _sword.has_method("get_tier_name"):
		var tier_name = _sword.get_tier_name()
		print("[GAME] Sword evolved to: %s" % tier_name)
		if hud and hud.has_method("show_notification"):
			hud.show_notification("Sword evolved to %s!" % tier_name)

func _on_wave_started(wave_number: int) -> void:
	if hud:
		hud.set_wave(wave_number)
	# Update spawner difficulty based on wave
	if spawner:
		spawner.set_wave(wave_number)
	# Track highest wave in game stats
	if game_stats:
		game_stats.set_wave(wave_number)

func _on_time_changed(time: float, is_night: bool) -> void:
	if hud:
		hud.set_time(time)
		# Update time icon with 8-phase granularity
		if day_night_cycle:
			hud.set_time_icon(time, day_night_cycle.day_duration, day_night_cycle.night_duration)
	# Update game stats survival time
	if game_stats:
		game_stats.survival_time = time
	# Apply visual day/night tint
	if day_night_cycle and day_night_overlay:
		day_night_overlay.color = day_night_cycle.get_current_tint()

## Test Mode Support
func _check_test_mode() -> void:
	var args = OS.get_cmdline_user_args()
	var test_mode_enabled = false

	for arg in args:
		if arg == "--test-mode" or arg.begins_with("--test"):
			test_mode_enabled = true
			break

	if test_mode_enabled:
		_start_test_mode(args)

func _start_test_mode(args: PackedStringArray) -> void:
	print("[GAME] Test mode detected, loading test framework...")

	var test_mode_scene = load("res://scenes/testing/test_mode.tscn")
	if not test_mode_scene:
		print("[GAME] ERROR: Could not load test mode scene")
		return

	var test_mode = test_mode_scene.instantiate()

	# Parse test mode arguments
	for arg in args:
		if arg.begins_with("--scenario="):
			var scenario_name = arg.split("=")[1].to_upper()
			test_mode.scenario = _get_scenario_enum(scenario_name)
		elif arg.begins_with("--duration="):
			test_mode.test_duration = float(arg.split("=")[1])
		elif arg.begins_with("--speed="):
			test_mode.speed_multiplier = float(arg.split("=")[1])
		elif arg == "--no-screenshots":
			test_mode.auto_screenshots = false
		elif arg == "--god-mode":
			test_mode.god_mode = true
		elif arg == "--fast-progression":
			test_mode.fast_progression = true
		elif arg == "--fast-sword" or arg == "--fast-evolution":
			test_mode.fast_sword_evolution = true
		elif arg == "--fast-all":
			test_mode.god_mode = true
			test_mode.fast_progression = true
			test_mode.fast_sword_evolution = true

	add_child(test_mode)
	print("[GAME] Test mode started: %s" % test_mode.TestScenario.keys()[test_mode.scenario])

func _get_scenario_enum(scenario_name: String) -> int:
	match scenario_name:
		"FULL_AUTO": return 0
		"POISON_TEST": return 1
		"SURVIVAL_TEST": return 2
		"UPGRADE_TEST": return 3
		"DAY_NIGHT_TEST": return 4
		"SWORD_TEST": return 5
		"WEAPON_TEST": return 6
		_: return 0
