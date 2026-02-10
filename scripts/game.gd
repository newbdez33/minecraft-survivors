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
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var torch_manager: Node = $TorchManager
@onready var fog_of_war: ColorRect = $FogOfWarLayer/FogOfWar
@onready var boss_health_bar: CanvasLayer = $BossHealthBar
@onready var achievement_manager: Node = $AchievementManager
@onready var character_manager: Node = $CharacterManager

const WaveScalerClass = preload("res://scripts/systems/wave_scaler.gd")

var evoker_scene: PackedScene = preload("res://scenes/enemies/evoker.tscn")
var elder_guardian_scene: PackedScene = preload("res://scenes/enemies/elder_guardian.tscn")
var ravager_scene: PackedScene = preload("res://scenes/enemies/ravager.tscn")
var warden_scene: PackedScene = preload("res://scenes/enemies/warden.tscn")
var wither_scene: PackedScene = preload("res://scenes/enemies/wither.tscn")
var ender_dragon_scene: PackedScene = preload("res://scenes/enemies/ender_dragon.tscn")
var _sword: Node = null
var _current_boss: Node = null
var _total_time: float = 0.0
var _is_paused: bool = false
var _fog_material: ShaderMaterial = null
var _idle_controller: Node = null

func _ready() -> void:
	# Load language setting
	_load_language_setting()

	# Check for test mode
	_check_test_mode()

	# Start tracking game stats
	if game_stats:
		game_stats.start_tracking()

	# Connect wave manager signals and start it
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		# Connect day/night cycle to wave manager for night multiplier
		if day_night_cycle:
			wave_manager.day_night_cycle = day_night_cycle
		wave_manager.start()

	# Connect day/night cycle signals and start it
	if day_night_cycle:
		day_night_cycle.time_changed.connect(_on_time_changed)
		# Connect night/day signals to spawner for spawn rate changes
		if spawner:
			spawner.day_night_cycle = day_night_cycle
			day_night_cycle.night_started.connect(spawner._on_night_started)
			day_night_cycle.day_started.connect(spawner._on_day_started)
		day_night_cycle.start()

	# Connect player health to HUD
	if player and hud:
		player.health_changed.connect(_on_player_health_changed)
		player.died.connect(_on_player_died)
		player.xp_changed.connect(_on_player_xp_changed)
		player.leveled_up.connect(_on_player_leveled_up)

		# Connect status effects to HUD for poison heart color
		var status_manager = player.get_node_or_null("StatusEffectManager")
		if status_manager:
			status_manager.effect_applied.connect(_on_player_effect_applied)
			status_manager.effect_removed.connect(_on_player_effect_removed)

		# Initialize HUD with player's starting values
		hud.update_health(player.current_health, player.max_health)
		hud.update_xp(player.current_xp, player.xp_to_next_level)
		hud.set_level(player.current_level)
		hud.set_wave(1)
		hud.set_kills(0)

	# Setup torch manager connections for fog of war
	if torch_manager:
		torch_manager.torch_level_changed.connect(_on_torch_level_changed)

	# Setup fog of war system
	_setup_fog_of_war()

	# Setup upgrade manager
	if upgrade_manager and player:
		upgrade_manager.set_player(player)
		# Connect torch manager to upgrade manager
		if torch_manager:
			upgrade_manager.torch_manager = torch_manager

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

	# Connect pause menu
	if pause_menu:
		pause_menu.resume_pressed.connect(_on_resume_pressed)
		pause_menu.hide_menu()

	# Connect achievement manager signals
	if achievement_manager:
		achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Apply selected character stats if character manager is present
	if character_manager and player:
		character_manager.apply_selected_to_player(player)

	# Setup idle controller (always present, disabled by default)
	var IdleControllerClass = preload("res://scripts/systems/idle_controller.gd")
	_idle_controller = IdleControllerClass.new()
	_idle_controller.name = "IdleController"
	_idle_controller.player = player
	add_child(_idle_controller)

	# Show idle mode hint if unlocked
	if hud and hud.has_method("set_idle_unlocked") and achievement_manager:
		hud.set_idle_unlocked(achievement_manager.is_achievement_unlocked("idle_master"))

var _last_survival_check: int = 0  # Track last checked second for achievements

func _process(delta: float) -> void:
	if not _is_paused:
		_total_time += delta
		if hud:
			hud.set_time(_total_time)

		# Check survival time achievements every second
		var current_second = int(_total_time)
		if current_second > _last_survival_check:
			_last_survival_check = current_second
			if achievement_manager:
				achievement_manager.check_survival_time(current_second)
			# Check character unlock conditions based on survival time
			if character_manager:
				var stats = {"survival_time": _total_time}
				if game_stats:
					stats.kills = game_stats.kills
					stats.wave = game_stats.highest_wave
					stats.level = game_stats.highest_level if "highest_level" in game_stats else 1
				character_manager.check_unlock_conditions(stats)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_toggle_pause()

	# Tab key toggles idle mode
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		_toggle_idle_mode()

func _toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	if pause_menu:
		if _is_paused:
			pause_menu.show_menu()
		else:
			pause_menu.hide_menu()

func _toggle_idle_mode() -> void:
	# Check if idle mode is unlocked
	if achievement_manager and not achievement_manager.is_achievement_unlocked("idle_master"):
		if hud and hud.has_method("show_notification"):
			hud.show_notification(tr("IDLE_MODE_LOCKED"))
		return

	if not _idle_controller or not player:
		return

	var new_state = not _idle_controller.is_enabled()
	_idle_controller.set_enabled(new_state)
	player.idle_mode = new_state

	# Toggle upgrade auto-select
	if upgrade_ui:
		upgrade_ui.set_use_timer(new_state)
		upgrade_ui.idle_controller = _idle_controller if new_state else null

	# Update HUD indicator
	if hud and hud.has_method("set_idle_mode"):
		hud.set_idle_mode(new_state)

	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx("level_up" if new_state else "pickup")

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_player_health_changed(current: int, maximum: int) -> void:
	if hud:
		hud.update_health(current, maximum)

func _on_player_xp_changed(current: int, needed: int) -> void:
	if hud:
		hud.update_xp(current, needed)

func _on_player_leveled_up(new_level: int) -> void:
	if hud:
		hud.set_level(new_level)

	# Check level achievements
	if achievement_manager:
		achievement_manager.check_level(new_level)

	# Show upgrade selection
	if upgrade_manager and upgrade_ui:
		var upgrades = upgrade_manager.get_random_upgrades(3)
		var weapon_upgrades = upgrade_manager.get_weapon_upgrades()
		if upgrades.size() > 0 or weapon_upgrades.size() > 0:
			upgrade_ui.show_upgrades(upgrades, weapon_upgrades)

func _on_upgrade_selected(upgrade) -> void:
	if upgrade_manager:
		upgrade_manager.apply_upgrade(upgrade)

		# Check for bow acquisition achievement
		if upgrade.id == "bow" and upgrade.current_level == 1:
			if achievement_manager:
				achievement_manager.unlock_bow_achievement()

func _on_player_died() -> void:
	# Stop spawning
	if spawner:
		spawner.set_process(false)

	# Stop tracking stats
	if game_stats:
		game_stats.stop_tracking()
		game_stats.set_level(player.current_level if player else 1)

	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx("game_over")

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
		# Check kill achievements
		if achievement_manager:
			achievement_manager.check_kill_count(game_stats.kills)

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
	# Check evolution achievement
	if achievement_manager:
		achievement_manager.unlock_evolution_achievement()

## Called when an achievement is unlocked
func _on_achievement_unlocked(achievement) -> void:
	print("[ACHIEVEMENT] Unlocked: %s" % achievement.name)
	if hud and hud.has_method("show_notification"):
		hud.show_notification("Achievement: %s!" % achievement.name)
	# Show idle mode hint when idle_master is unlocked
	if achievement.id == "idle_master" and hud and hud.has_method("set_idle_unlocked"):
		hud.set_idle_unlocked(true)

func _on_wave_started(wave_number: int) -> void:
	if hud:
		hud.set_wave(wave_number)
	# Update spawner difficulty based on wave
	if spawner:
		spawner.set_wave(wave_number)
	# Track highest wave in game stats
	if game_stats:
		game_stats.set_wave(wave_number)

	# Check wave achievements
	if achievement_manager:
		achievement_manager.check_wave(wave_number)

	# Check for boss wave
	if wave_manager and wave_manager.is_boss_wave(wave_number):
		_spawn_boss(wave_number)


## Spawn a boss for boss waves
func _spawn_boss(wave_number: int) -> void:
	if not player:
		return

	var boss_type = wave_manager.get_boss_for_wave(wave_number)
	if boss_type.is_empty():
		return

	# Get boss scene based on type
	var boss_scene: PackedScene = null
	var boss_name: String = ""
	match boss_type:
		"evoker":
			boss_scene = evoker_scene
			boss_name = tr("BOSS_EVOKER") if TranslationServer.get_locale() else "Evoker"
		"elder_guardian":
			boss_scene = elder_guardian_scene
			boss_name = tr("BOSS_ELDER_GUARDIAN") if TranslationServer.get_locale() else "Elder Guardian"
		"ravager":
			boss_scene = ravager_scene
			boss_name = tr("BOSS_RAVAGER") if TranslationServer.get_locale() else "Ravager"
		"warden":
			boss_scene = warden_scene
			boss_name = tr("BOSS_WARDEN") if TranslationServer.get_locale() else "Warden"
		"wither":
			boss_scene = wither_scene
			boss_name = tr("BOSS_WITHER") if TranslationServer.get_locale() else "Wither"
		"ender_dragon":
			boss_scene = ender_dragon_scene
			boss_name = tr("BOSS_ENDER_DRAGON") if TranslationServer.get_locale() else "Ender Dragon"

	if not boss_scene:
		return

	# Pause normal spawning during boss fight
	if spawner:
		spawner.pause_spawning()

	# Spawn boss at edge of screen
	var boss = boss_scene.instantiate()
	var spawn_angle = randf() * TAU
	var spawn_distance = 500.0
	boss.global_position = player.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance

	# Apply post-wave-30 scaling to boss
	WaveScalerClass.apply_scaling(boss, wave_number, true)

	# Connect boss signals
	if boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

	# Connect Warden darkness aura signal
	if boss.has_signal("darkness_aura_changed"):
		boss.darkness_aura_changed.connect(_on_warden_darkness)

	# Add boss to scene
	add_child(boss)
	_current_boss = boss
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx("boss_appear")

	# Show boss health bar
	if boss_health_bar:
		boss_health_bar.set_boss(boss, boss_name)
		boss_health_bar.boss_defeated.connect(_on_boss_defeated, CONNECT_ONE_SHOT)


## Called when boss dies
func _on_boss_died(_xp: int) -> void:
	pass  # Health bar handles the UI, _on_boss_defeated handles spawner


## Called when boss health bar finishes (after death animation)
func _on_boss_defeated() -> void:
	_current_boss = null
	# Restore fog of war in case Warden darkness was active
	_update_fog_of_war()
	# Resume normal spawning
	if spawner:
		spawner.resume_spawning()


## Called when Warden darkness aura activates/deactivates
func _on_warden_darkness(active: bool) -> void:
	if not _fog_material:
		return
	if active:
		_fog_material.set_shader_parameter("enabled", true)
		var base_radius = 0.25
		if torch_manager and torch_manager.has_method("get_visibility_radius"):
			base_radius = torch_manager.get_visibility_radius()
		_fog_material.set_shader_parameter("visibility_radius", base_radius * (1.0 - darkness_visibility_reduction))
	else:
		# Fully restore fog state based on current time of day
		var is_night = day_night_cycle and day_night_cycle.is_night()
		if is_night:
			_update_fog_of_war()
		else:
			_fog_material.set_shader_parameter("enabled", false)

## Warden darkness visibility reduction (matches warden.gd export)
var darkness_visibility_reduction: float = 0.40


func _on_torch_level_changed(_level: int) -> void:
	# Update fog visibility radius when torch is upgraded
	_update_fog_of_war()

## Called when a status effect is applied to player
func _on_player_effect_applied(effect) -> void:
	var StatusEffectClass = load("res://scripts/components/status_effect.gd")
	if StatusEffectClass and effect.type == StatusEffectClass.Type.POISON:
		if hud and hud.has_method("set_poisoned"):
			hud.set_poisoned(true)

## Called when a status effect is removed from player
func _on_player_effect_removed(effect) -> void:
	var StatusEffectClass = load("res://scripts/components/status_effect.gd")
	if StatusEffectClass and effect.type == StatusEffectClass.Type.POISON:
		if hud and hud.has_method("set_poisoned"):
			hud.set_poisoned(false)

func _on_time_changed(time: float, _is_night: bool) -> void:
	# Update time icon with 8-phase granularity (uses cycling time for day/night phases)
	if hud and day_night_cycle:
		hud.set_time_icon(time, day_night_cycle.day_duration, day_night_cycle.night_duration)
	# Update game stats survival time (use total time, not cycling time)
	if game_stats:
		game_stats.survival_time = _total_time
	# Apply visual day/night tint (disabled when player has torch)
	if day_night_cycle and day_night_overlay:
		var has_torch = torch_manager and torch_manager.torch_level > 0
		if has_torch:
			# With torch: no overall tint, only fog circle effect
			day_night_overlay.color = Color.WHITE
		else:
			day_night_overlay.color = day_night_cycle.get_current_tint()
	# Update fog of war
	_update_fog_of_war()

## Setup fog of war shader material
func _setup_fog_of_war() -> void:
	if fog_of_war and fog_of_war.material is ShaderMaterial:
		_fog_material = fog_of_war.material as ShaderMaterial
		# Initial update
		_update_fog_of_war()

## Update fog of war based on time and torch level
func _update_fog_of_war() -> void:
	if not _fog_material:
		return

	var is_night = day_night_cycle and day_night_cycle.is_night()
	_fog_material.set_shader_parameter("enabled", is_night)

	if is_night:
		# Player is always at center since camera follows them
		_fog_material.set_shader_parameter("player_pos", Vector2(0.5, 0.5))

		# Pass screen size for aspect ratio correction (perfect circle)
		var viewport_size = get_viewport_rect().size
		_fog_material.set_shader_parameter("screen_size", viewport_size)

		# Get visibility radius from torch manager
		var radius = TorchManager.BASE_VISIBILITY_RADIUS  # Default
		if torch_manager and torch_manager.has_method("get_visibility_radius"):
			radius = torch_manager.get_visibility_radius()
		_fog_material.set_shader_parameter("visibility_radius", radius)

		# Check if player has torch (torch_level > 0 means player owns torch)
		var has_torch = torch_manager and torch_manager.torch_level > 0
		_fog_material.set_shader_parameter("has_torch", has_torch)

## Load language setting from saved settings
func _load_language_setting() -> void:
	var save_path = "user://settings.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			file.close()
			if error == OK and json.data is Dictionary:
				if json.data.has("language"):
					TranslationServer.set_locale(json.data.language)
					print("[GAME] Language set to: " + json.data.language)

## Test Mode Support
func _check_test_mode() -> void:
	var args = OS.get_cmdline_args()
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
		"BOUNDARY_TEST": return 7
		_: return 0
