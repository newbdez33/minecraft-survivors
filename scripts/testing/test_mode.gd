extends Node
class_name TestMode
## Main test mode controller
## Orchestrates AutoPlayer, DebugOverlay, and ScreenshotCapture

signal test_completed(results: Dictionary)

const AutoPlayerScript = preload("res://scripts/testing/auto_player.gd")
const TestDebugOverlayScript = preload("res://scripts/testing/test_debug_overlay.gd")
const ScreenshotCaptureScript = preload("res://scripts/testing/screenshot_capture.gd")

enum TestScenario {
	FULL_AUTO,      # Complete automatic test
	POISON_TEST,    # Test poison mechanics
	SURVIVAL_TEST,  # Test survival time
	UPGRADE_TEST,   # Test upgrade system
	DAY_NIGHT_TEST, # Test day/night cycle
	SWORD_TEST,     # Test full sword upgrade path to Diamond
	WEAPON_TEST     # Test sword + bow together
}

@export var scenario: TestScenario = TestScenario.FULL_AUTO
@export var test_duration: float = 120.0  # 2 minutes default
@export var auto_screenshots: bool = true
@export var speed_multiplier: float = 1.0
@export var god_mode: bool = false  # Player invincibility
@export var fast_progression: bool = false  # Fast XP gain (10x)
@export var fast_sword_evolution: bool = false  # Low kill thresholds for sword tiers

var auto_player: Node
var debug_overlay: CanvasLayer
var screenshot_capture: Node

var _test_start_time: float = 0.0
var _test_results: Dictionary = {}
var _is_running: bool = false
var _player: Node = null
var _game_over_triggered: bool = false
var _sword: Node = null

# Event tracking
var _events_log: Array[Dictionary] = []
var _first_kill_logged: bool = false
var _first_poison_logged: bool = false
var _low_health_logged: bool = false
var _sword_evolutions_logged: Array[int] = []

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  TEST MODE INITIALIZED")
	print("  Scenario: %s" % TestScenario.keys()[scenario])
	print("  Duration: %.0fs" % test_duration)
	print("=".repeat(50) + "\n")

	# Set time scale
	Engine.time_scale = speed_multiplier

	# Initialize components
	_setup_components()

	# Wait for main scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	# Connect to game events
	_connect_game_events()

	# Configure based on scenario
	_configure_scenario()

	# Start test
	_start_test()

func _setup_components() -> void:
	# Create AutoPlayer
	auto_player = AutoPlayerScript.new()
	auto_player.name = "AutoPlayer"
	add_child(auto_player)
	auto_player.test_event.connect(_on_auto_player_event)

	# Create Debug Overlay
	debug_overlay = TestDebugOverlayScript.new()
	debug_overlay.name = "TestDebugOverlay"
	add_child(debug_overlay)

	# Create Screenshot Capture
	screenshot_capture = ScreenshotCaptureScript.new()
	screenshot_capture.name = "ScreenshotCapture"
	add_child(screenshot_capture)
	screenshot_capture.screenshot_taken.connect(_on_screenshot_taken)

func _connect_game_events() -> void:
	# Find player
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		if _player.has_signal("health_changed"):
			_player.health_changed.connect(_on_player_health_changed)
		if _player.has_signal("died"):
			_player.died.connect(_on_player_died)
		if _player.has_signal("leveled_up"):
			_player.leveled_up.connect(_on_player_level_up)

		# Connect to status effect manager
		var status_manager = _player.get_node_or_null("StatusEffectManager")
		if status_manager:
			status_manager.effect_applied.connect(_on_effect_applied)
			status_manager.effect_tick.connect(_on_effect_tick)

		# Connect to sword for evolution tracking
		_sword = _player.get_node_or_null("Sword")
		if _sword and _sword.has_signal("evolved"):
			_sword.evolved.connect(_on_sword_evolved)
			# Apply fast evolution if enabled
			if fast_sword_evolution:
				_apply_fast_sword_evolution()

		# Apply god mode if enabled (also for SWORD_TEST and WEAPON_TEST scenarios)
		if god_mode or scenario == TestScenario.SWORD_TEST or scenario == TestScenario.WEAPON_TEST:
			_player.god_mode = true
			god_mode = true
			print("[TEST] God mode enabled - player is invincible")

		# Apply fast progression if enabled (also for SWORD_TEST and WEAPON_TEST scenarios)
		if fast_progression or scenario == TestScenario.SWORD_TEST or scenario == TestScenario.WEAPON_TEST:
			_player.xp_multiplier = 10.0
			fast_progression = true
			print("[TEST] Fast progression enabled - 10x XP")

	# Find spawner for enemy events
	var main = get_tree().current_scene
	if main:
		var spawner = main.get_node_or_null("MobSpawner")
		if spawner and spawner.has_signal("enemy_spawned"):
			spawner.enemy_spawned.connect(_on_enemy_spawned)

		# Game stats for kills
		var game_stats = main.get_node_or_null("GameStats")
		if game_stats and game_stats.has_signal("kill_added"):
			game_stats.kill_added.connect(_on_kill_added)

		# Wave manager
		var wave_manager = main.get_node_or_null("WaveManager")
		if wave_manager and wave_manager.has_signal("wave_started"):
			wave_manager.wave_started.connect(_on_wave_started)

		# Day/night cycle
		var day_night = main.get_node_or_null("DayNightCycle")
		if day_night and day_night.has_signal("phase_changed"):
			day_night.phase_changed.connect(_on_day_night_changed)

		# Upgrade UI
		var upgrade_ui = main.get_node_or_null("UpgradeUI")
		if upgrade_ui:
			if upgrade_ui.has_signal("shown"):
				upgrade_ui.shown.connect(_on_upgrade_ui_shown)
			upgrade_ui.visibility_changed.connect(func():
				if upgrade_ui.visible:
					_on_upgrade_ui_shown()
			)

		# Game over
		var game_over_ui = main.get_node_or_null("GameOverUI")
		if game_over_ui and game_over_ui.has_signal("shown"):
			game_over_ui.shown.connect(_on_game_over)

func _configure_scenario() -> void:
	# Strategy enum values: SURVIVE=0, AGGRESSIVE=1, STATIONARY=2, COLLECT_XP=3, TRIGGER_POISON=4
	var strategy_names = ["SURVIVE", "AGGRESSIVE", "STATIONARY", "COLLECT_XP", "TRIGGER_POISON"]

	match scenario:
		TestScenario.FULL_AUTO:
			auto_player.strategy = 0  # SURVIVE
			auto_player.auto_upgrade = true
		TestScenario.POISON_TEST:
			auto_player.strategy = 4  # TRIGGER_POISON
			auto_player.auto_upgrade = true
			test_duration = 60.0
		TestScenario.SURVIVAL_TEST:
			auto_player.strategy = 0  # SURVIVE
			auto_player.auto_upgrade = true
		TestScenario.UPGRADE_TEST:
			auto_player.strategy = 1  # AGGRESSIVE
			auto_player.auto_upgrade = true
			auto_player.preferred_upgrades = ["sharpness", "sweeping", "looting"]
		TestScenario.DAY_NIGHT_TEST:
			auto_player.strategy = 0  # SURVIVE
			test_duration = 180.0  # 3 minutes to see full cycle
		TestScenario.SWORD_TEST:
			auto_player.strategy = 1  # AGGRESSIVE
			auto_player.auto_upgrade = true
			# Clear and add sword as preferred upgrade
			auto_player.preferred_upgrades.clear()
			auto_player.preferred_upgrades.append("sword")
			test_duration = 180.0  # 3 minutes should be enough for 12 levels
			# god_mode and fast_progression will be applied in _connect_game_events
			# Force sword to always appear in upgrade options
			var main = get_tree().current_scene
			if main:
				var upgrade_manager = main.get_node_or_null("UpgradeManager")
				if upgrade_manager:
					upgrade_manager.prioritized_upgrades.clear()
					upgrade_manager.prioritized_upgrades.append("sword")
					print("[TEST] Sword prioritized in upgrade selection")
		TestScenario.WEAPON_TEST:
			auto_player.strategy = 1  # AGGRESSIVE
			auto_player.auto_upgrade = true
			# Prioritize both sword and bow
			auto_player.preferred_upgrades.clear()
			auto_player.preferred_upgrades.append("bow")
			auto_player.preferred_upgrades.append("sword")
			test_duration = 60.0
			# Force sword and bow to always appear in upgrade options
			var main2 = get_tree().current_scene
			if main2:
				var upgrade_manager2 = main2.get_node_or_null("UpgradeManager")
				if upgrade_manager2:
					upgrade_manager2.prioritized_upgrades.clear()
					upgrade_manager2.prioritized_upgrades.append("bow")
					upgrade_manager2.prioritized_upgrades.append("sword")
					print("[TEST] Sword and Bow prioritized in upgrade selection")

	debug_overlay.set_strategy(strategy_names[auto_player.strategy])

func _start_test() -> void:
	_is_running = true
	_test_start_time = Time.get_ticks_msec() / 1000.0
	_test_results = {
		"scenario": TestScenario.keys()[scenario],
		"start_time": Time.get_datetime_string_from_system(),
		"duration": 0.0,
		"kills": 0,
		"max_level": 1,
		"max_wave": 1,
		"damage_taken": 0,
		"times_poisoned": 0,
		"upgrades_selected": 0,
		"sword_upgrades": 0,
		"screenshots": 0,
		"survived": true,
		"sword_tier": 1,
		"sword_level": 1,
		"sword_name": "Wood Sword",
		"sword_evolutions": 0,
		"events": []
	}

	_log_event("test_started", {"scenario": TestScenario.keys()[scenario]})

	if auto_screenshots:
		await get_tree().create_timer(1.0).timeout
		screenshot_capture.capture_game_start()

func _process(delta: float) -> void:
	if not _is_running:
		return

	var elapsed = (Time.get_ticks_msec() / 1000.0) - _test_start_time

	# Check test duration
	if elapsed >= test_duration and not _game_over_triggered:
		_end_test("duration_reached")

	# For SWORD_TEST, end when Diamond tier reached
	if scenario == TestScenario.SWORD_TEST and _sword:
		if _sword.current_tier == SwordBase.Tier.DIAMOND:
			_test_results["sword_tier"] = _sword.current_tier
			_test_results["sword_level"] = _sword.level if "level" in _sword else 0
			_test_results["sword_name"] = _sword.get_tier_name() if _sword.has_method("get_tier_name") else "Diamond Sword"
			_end_test("diamond_sword_reached")

func _on_player_health_changed(current: int, maximum: int) -> void:
	var pct = float(current) / float(maximum)

	if pct <= 0.25 and not _low_health_logged:
		_low_health_logged = true
		_log_event("low_health", {"health": current, "max": maximum})
		if auto_screenshots:
			screenshot_capture.capture_low_health()

func _on_player_died() -> void:
	_game_over_triggered = true
	_test_results["survived"] = false
	_log_event("player_died", {})

	if auto_screenshots:
		screenshot_capture.capture_game_over()

	# Wait for game over screen then end test
	await get_tree().create_timer(2.0).timeout
	_end_test("player_died")

func _on_player_level_up(new_level: int) -> void:
	_test_results["max_level"] = new_level
	_log_event("level_up", {"level": new_level})

	if auto_screenshots:
		screenshot_capture.capture_level_up(new_level)

func _on_enemy_spawned(_enemy: Node) -> void:
	pass  # Could track enemy types

func _on_kill_added(total_kills: int) -> void:
	_test_results["kills"] = total_kills

	if not _first_kill_logged:
		_first_kill_logged = true
		_log_event("first_kill", {"total": total_kills})
		if auto_screenshots:
			screenshot_capture.capture_first_kill()

func _on_wave_started(wave: int) -> void:
	_test_results["max_wave"] = wave
	_log_event("wave_started", {"wave": wave})

	if auto_screenshots and wave <= 5:
		screenshot_capture.capture_wave_start(wave)

func _on_day_night_changed(phase_name: String, _phase_index: int) -> void:
	_log_event("day_night_changed", {"phase": phase_name})

	if auto_screenshots:
		if "night" in phase_name.to_lower() or "moon" in phase_name.to_lower():
			screenshot_capture.capture_night_time()
		elif "dawn" in phase_name.to_lower() or "morning" in phase_name.to_lower():
			screenshot_capture.capture_day_time()

func _on_effect_applied(effect) -> void:
	if effect.type == 0:  # POISON
		_test_results["times_poisoned"] += 1
		_log_event("poison_applied", {"duration": effect.duration})

		if not _first_poison_logged:
			_first_poison_logged = true
			if auto_screenshots:
				screenshot_capture.capture_poison_applied()

func _on_effect_tick(effect, damage: int) -> void:
	if effect.type == 0:  # POISON
		_test_results["damage_taken"] += damage
		debug_overlay.set_last_event("Poison tick: -%d HP" % damage)

func _on_sword_evolved(new_tier: int) -> void:
	if new_tier not in _sword_evolutions_logged:
		_sword_evolutions_logged.append(new_tier)
		var tier_name = _sword.get_tier_name() if _sword else "Tier %d" % new_tier
		_log_event("sword_evolved", {"tier": new_tier, "name": tier_name})
		_test_results["sword_tier"] = new_tier
		_test_results["sword_name"] = tier_name

		if auto_screenshots:
			screenshot_capture.capture_custom("sword_evolution_%d" % new_tier)

		debug_overlay.set_last_event("Sword evolved: %s" % tier_name)

func _apply_fast_sword_evolution() -> void:
	# Set fast evolution threshold on sword for faster testing
	if not _sword:
		return

	# Use the sword's fast_evolution_threshold property
	# This overrides the normal kills_to_evolve values
	if "fast_evolution_threshold" in _sword:
		_sword.fast_evolution_threshold = 5  # Evolve every 5 kills
		print("[TEST] Fast sword evolution enabled - evolves every 5 kills")

func _on_upgrade_ui_shown() -> void:
	_log_event("upgrade_ui_shown", {})

	if auto_screenshots:
		screenshot_capture.capture_upgrade_selection()

	# Let auto player handle selection
	var main = get_tree().current_scene
	if main:
		var upgrade_ui = main.get_node_or_null("UpgradeUI")
		if upgrade_ui:
			auto_player.handle_upgrade_selection(upgrade_ui)
			_test_results["upgrades_selected"] += 1

func _on_game_over() -> void:
	if not _game_over_triggered:
		_game_over_triggered = true
		_log_event("game_over", {})
		if auto_screenshots:
			screenshot_capture.capture_game_over()

func _on_auto_player_event(event_name: String, data: Dictionary) -> void:
	_log_event("auto_player_" + event_name, data)
	debug_overlay.set_last_event(event_name)

	# Track sword upgrades specifically
	if event_name == "upgrade_selected" and data.get("is_sword", false):
		_test_results["sword_upgrades"] += 1
		# Update sword level from the actual sword
		if _sword and "level" in _sword:
			_test_results["sword_level"] = _sword.level
		debug_overlay.set_last_event("Sword upgraded to level %d" % _test_results["sword_level"])

func _on_screenshot_taken(_path: String) -> void:
	_test_results["screenshots"] += 1
	debug_overlay.set_screenshot_count(_test_results["screenshots"])

func _log_event(event_name: String, data: Dictionary) -> void:
	var event = {
		"time": (Time.get_ticks_msec() / 1000.0) - _test_start_time,
		"name": event_name,
		"data": data
	}
	_events_log.append(event)
	_test_results["events"] = _events_log
	print("[TEST] %.1fs - %s %s" % [event.time, event_name, data])

func _end_test(reason: String) -> void:
	_is_running = false
	_test_results["duration"] = (Time.get_ticks_msec() / 1000.0) - _test_start_time
	_test_results["end_reason"] = reason

	# Reset time scale
	Engine.time_scale = 1.0

	# Print results
	print("\n" + "=".repeat(50))
	print("  TEST COMPLETED")
	print("=".repeat(50))
	print("  Scenario: %s" % _test_results["scenario"])
	print("  Duration: %.1fs" % _test_results["duration"])
	print("  End Reason: %s" % reason)
	print("  Survived: %s" % _test_results["survived"])
	print("  Kills: %d" % _test_results["kills"])
	print("  Max Level: %d" % _test_results["max_level"])
	print("  Max Wave: %d" % _test_results["max_wave"])
	print("  Sword: %s (Tier %d, Level %d)" % [_test_results["sword_name"], _test_results["sword_tier"], _test_results["sword_level"]])
	print("  Sword Upgrades Selected: %d" % _test_results["sword_upgrades"])
	print("  Sword Evolutions: %d" % _sword_evolutions_logged.size())
	print("  Times Poisoned: %d" % _test_results["times_poisoned"])
	print("  Upgrades: %d" % _test_results["upgrades_selected"])
	print("  Screenshots: %d" % _test_results["screenshots"])
	print("  Screenshot Dir: %s" % screenshot_capture.get_screenshot_dir())
	print("=".repeat(50) + "\n")

	# Save results to file
	_save_results()

	test_completed.emit(_test_results)

	# Quit after a delay
	await get_tree().create_timer(3.0).timeout
	get_tree().quit(0 if _test_results["survived"] or reason == "duration_reached" else 1)

func _save_results() -> void:
	var path = "user://test_results.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(_test_results, "\t")
		file.store_string(json)
		file.close()
		print("[TEST] Results saved to: %s" % ProjectSettings.globalize_path(path))
