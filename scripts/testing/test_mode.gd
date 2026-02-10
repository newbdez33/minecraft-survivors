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
	WEAPON_TEST,    # Test sword + bow together
	BOUNDARY_TEST,  # Test ALL bosses and ALL weapon upgrades to max
	IDLE_TEST       # Test idle mode AI (uses IdleController instead of AutoPlayer)
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

# Boundary test tracking
var _bosses_defeated: Array[String] = []
var _bosses_encountered: Array[String] = []
var _weapons_maxed: Array[String] = []
var _bow: Node = null
var _torch: Node = null
var _wave_manager: Node = null
var _boundary_test_complete: bool = false
const ALL_BOSSES = ["evoker", "elder_guardian", "ravager", "warden", "wither", "ender_dragon"]
const ALL_WEAPONS = ["sword", "bow", "torch"]

# Performance monitoring
var _perf_log_interval: float = 10.0  # Log every 10 seconds
var _perf_timer: float = 0.0
var _perf_log: Array[Dictionary] = []
var _initial_objects: int = 0
var _initial_orphans: int = 0

func _ready() -> void:
	# Process even when tree is paused (upgrade UI pauses tree)
	process_mode = Node.PROCESS_MODE_ALWAYS

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
	# Create AutoPlayer (skipped for IDLE_TEST - uses game's IdleController instead)
	if scenario != TestScenario.IDLE_TEST:
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

		# Apply god mode if enabled (also for SWORD_TEST, WEAPON_TEST, BOUNDARY_TEST scenarios)
		if god_mode or scenario == TestScenario.SWORD_TEST or scenario == TestScenario.WEAPON_TEST or scenario == TestScenario.BOUNDARY_TEST:
			_player.god_mode = true
			god_mode = true
			print("[TEST] God mode enabled - player is invincible")

		# Apply fast progression if enabled (also for SWORD_TEST, WEAPON_TEST, BOUNDARY_TEST scenarios)
		if fast_progression or scenario == TestScenario.SWORD_TEST or scenario == TestScenario.WEAPON_TEST or scenario == TestScenario.BOUNDARY_TEST:
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
			# Track actual upgrade selections for IDLE_TEST
			if scenario == TestScenario.IDLE_TEST:
				upgrade_ui.upgrade_selected.connect(_on_idle_upgrade_selected)

		# Game over
		var game_over_ui = main.get_node_or_null("GameOverUI")
		if game_over_ui and game_over_ui.has_signal("shown"):
			game_over_ui.shown.connect(_on_game_over)

	# Connect boundary test specific events
	_connect_boundary_test_events()

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
		TestScenario.BOUNDARY_TEST:
			_configure_boundary_test()
		TestScenario.IDLE_TEST:
			_configure_idle_test()

	if auto_player:
		debug_overlay.set_strategy(strategy_names[auto_player.strategy])
	else:
		debug_overlay.set_strategy("IDLE_MODE")

func _start_test() -> void:
	_is_running = true
	_test_start_time = Time.get_ticks_msec() / 1000.0

	# Record initial performance baseline
	_initial_objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	_initial_orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_log_performance("initial")

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

	# Performance monitoring
	_perf_timer += delta
	if _perf_timer >= _perf_log_interval:
		_perf_timer = 0.0
		_log_performance("periodic")

	# Periodic screenshots for idle test (uses real delta, not paused delta)
	if scenario == TestScenario.IDLE_TEST and auto_screenshots:
		_idle_screenshot_timer += delta
		if _idle_screenshot_timer >= IDLE_SCREENSHOT_INTERVAL:
			_idle_screenshot_timer = 0.0
			screenshot_capture.capture_custom("idle_%.0fs" % elapsed)

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


func _log_performance(reason: String) -> void:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - _test_start_time
	var current_objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphan_nodes = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var memory_static = Performance.get_monitor(Performance.MEMORY_STATIC)
	var render_objects = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)

	var perf_entry = {
		"time": elapsed,
		"reason": reason,
		"fps": fps,
		"objects": current_objects,
		"object_delta": current_objects - _initial_objects,
		"orphan_nodes": orphan_nodes,
		"orphan_delta": orphan_nodes - _initial_orphans,
		"memory_mb": memory_static / 1048576.0,
		"render_objects": render_objects
	}
	_perf_log.append(perf_entry)

	# Print warning if objects are growing significantly
	var object_growth = current_objects - _initial_objects
	var orphan_growth = orphan_nodes - _initial_orphans

	if orphan_growth > 100:
		print("[PERF WARNING] %.1fs - Orphan nodes: %d (+%d from start) - POSSIBLE MEMORY LEAK!" % [
			elapsed, orphan_nodes, orphan_growth
		])
	elif object_growth > 500:
		print("[PERF] %.1fs - Objects: %d (+%d), Orphans: %d (+%d), FPS: %.0f, Mem: %.1fMB" % [
			elapsed, current_objects, object_growth, orphan_nodes, orphan_growth, fps, memory_static / 1048576.0
		])
	else:
		print("[PERF] %.1fs - Objects: %d (+%d), FPS: %.0f" % [elapsed, current_objects, object_growth, fps])

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

	# For boundary test, check for boss waves
	if scenario == TestScenario.BOUNDARY_TEST:
		_check_boss_wave(wave)

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

	# In IDLE_TEST, upgrade auto-select is handled by upgrade_ui timer + idle_controller
	if scenario == TestScenario.IDLE_TEST:
		_test_results["upgrades_selected"] += 1
		return

	# Let auto player handle selection
	var main = get_tree().current_scene
	if main and auto_player:
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

	# Track weapon levels for boundary test
	if scenario == TestScenario.BOUNDARY_TEST and event_name == "upgrade_selected":
		var upgrade_id = data.get("upgrade", "")
		var level = data.get("level", 0) + 1  # level is current level before upgrade
		if data.get("is_weapon", false):
			_check_weapon_maxed(upgrade_id, level)

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

	# Final performance log
	_log_performance("final")
	_test_results["performance_log"] = _perf_log

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

	# Boundary test specific results
	if scenario == TestScenario.BOUNDARY_TEST:
		print("  --- BOUNDARY TEST RESULTS ---")
		print("  Bosses Encountered: %d/%d %s" % [_bosses_encountered.size(), ALL_BOSSES.size(), str(_bosses_encountered)])
		print("  Bosses Defeated: %d/%d %s" % [_bosses_defeated.size(), ALL_BOSSES.size(), str(_bosses_defeated)])
		print("  Weapons Maxed: %d/%d %s" % [_weapons_maxed.size(), ALL_WEAPONS.size(), str(_weapons_maxed)])
		_test_results["bosses_encountered"] = _bosses_encountered
		_test_results["bosses_defeated"] = _bosses_defeated
		_test_results["weapons_maxed"] = _weapons_maxed
		_test_results["boundary_complete"] = _boundary_test_complete

	# Performance summary
	if _perf_log.size() > 0:
		var first_log = _perf_log[0]
		var last_log = _perf_log[_perf_log.size() - 1]
		print("  --- PERFORMANCE SUMMARY ---")
		print("  Initial Objects: %d" % first_log.get("objects", 0))
		print("  Final Objects: %d (+%d)" % [last_log.get("objects", 0), last_log.get("object_delta", 0)])
		print("  Final Orphan Nodes: %d (+%d)" % [last_log.get("orphan_nodes", 0), last_log.get("orphan_delta", 0)])
		print("  Final Memory: %.1f MB" % last_log.get("memory_mb", 0))
		print("  Final FPS: %.0f" % last_log.get("fps", 0))

		# Check for concerning metrics
		if last_log.get("orphan_delta", 0) > 100:
			print("  ⚠️ WARNING: Significant orphan node growth detected!")
		if last_log.get("object_delta", 0) > 1000:
			print("  ⚠️ WARNING: Large object growth detected!")

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

## ==================== IDLE TEST FUNCTIONS ====================

var _idle_screenshot_timer: float = 0.0
const IDLE_SCREENSHOT_INTERVAL: float = 15.0  # Screenshot every 15 real seconds

const WEAPON_IDS = ["sword", "bow", "torch"]

func _on_idle_upgrade_selected(upgrade) -> void:
	var upgrade_id = upgrade.id if "id" in upgrade else ""
	var is_weapon = upgrade_id in WEAPON_IDS
	if is_weapon:
		_test_results["sword_upgrades"] += 1
		if _sword and "level" in _sword:
			_test_results["sword_level"] = _sword.level
		print("[IDLE TEST] Weapon upgrade selected: %s" % upgrade_id)
	else:
		print("[IDLE TEST] Enchant upgrade selected: %s" % upgrade_id)

func _configure_idle_test() -> void:
	print("\n[IDLE TEST] Configuring idle mode auto-play test...")

	# Enable god mode + fast progression for testing
	god_mode = true
	fast_progression = true

	# Force idle mode on via game.gd
	var main = get_tree().current_scene
	if main and main.has_method("force_idle_mode"):
		main.force_idle_mode()
		print("[IDLE TEST] Idle mode force-enabled via game.gd")
	else:
		print("[IDLE TEST] WARNING: Could not force idle mode - game.gd missing force_idle_mode()")

	print("[IDLE TEST] Configuration complete! AI will auto-dodge, collect, and upgrade.")
	print("[IDLE TEST] Periodic screenshots every %.0fs" % IDLE_SCREENSHOT_INTERVAL)

## ==================== BOUNDARY TEST FUNCTIONS ====================

func _configure_boundary_test() -> void:
	print("\n[BOUNDARY TEST] Configuring comprehensive boundary test...")
	print("[BOUNDARY TEST] Will test: ALL 6 Bosses + ALL Weapons to Max Level")

	# Aggressive strategy to kill enemies fast
	auto_player.strategy = 1  # AGGRESSIVE
	auto_player.auto_upgrade = true

	# Prioritize all weapons
	auto_player.preferred_upgrades.clear()
	auto_player.preferred_upgrades.append("sword")
	auto_player.preferred_upgrades.append("bow")
	auto_player.preferred_upgrades.append("torch")

	# Long duration to reach wave 30
	test_duration = 600.0  # 10 minutes max

	# Enable all fast options
	god_mode = true
	fast_progression = true
	fast_sword_evolution = true

	# Speed up game for faster testing
	speed_multiplier = 2.0
	Engine.time_scale = speed_multiplier
	print("[BOUNDARY TEST] Game speed set to 2x")

	# Get main scene references
	var main = get_tree().current_scene
	if main:
		# Configure wave manager for fast waves
		_wave_manager = main.get_node_or_null("WaveManager")
		if _wave_manager:
			_wave_manager.wave_interval = 5.0  # 5 seconds between waves (fast!)
			print("[BOUNDARY TEST] Wave interval set to 5 seconds")

		# Prioritize all weapons in upgrade manager
		var upgrade_manager = main.get_node_or_null("UpgradeManager")
		if upgrade_manager:
			upgrade_manager.prioritized_upgrades.clear()
			upgrade_manager.prioritized_upgrades.append("sword")
			upgrade_manager.prioritized_upgrades.append("bow")
			upgrade_manager.prioritized_upgrades.append("torch")
			print("[BOUNDARY TEST] All weapons prioritized in upgrades")

	print("[BOUNDARY TEST] Configuration complete!")
	print("[BOUNDARY TEST] Bosses to defeat: %s" % str(ALL_BOSSES))
	print("[BOUNDARY TEST] Weapons to max: %s" % str(ALL_WEAPONS))

func _connect_boundary_test_events() -> void:
	if scenario != TestScenario.BOUNDARY_TEST:
		return

	var main = get_tree().current_scene
	if not main:
		return

	# Get weapon references for tracking
	if _player:
		_bow = _player.get_node_or_null("Bow")
		var weapon_slots = _player.get_node_or_null("WeaponSlots")
		if weapon_slots:
			for child in weapon_slots.get_children():
				if "Bow" in child.name:
					_bow = child
				elif "Torch" in child.name:
					_torch = child

	print("[BOUNDARY TEST] Boundary test events connected")

func _check_boss_wave(wave: int) -> void:
	# Boss waves are 5, 10, 15, 20, 25, 30
	if wave % 5 != 0 or wave == 0:
		return

	var boss_map = {
		5: "evoker",
		10: "elder_guardian",
		15: "ravager",
		20: "warden",
		25: "wither",
		30: "ender_dragon"
	}

	var boss_type = boss_map.get(wave, "")
	if boss_type.is_empty():
		return

	print("[BOUNDARY TEST] Boss wave %d - expecting: %s" % [wave, boss_type])

	# Wait a moment for boss to spawn then connect
	await get_tree().create_timer(1.0).timeout
	_connect_current_boss(boss_type)

func _connect_current_boss(boss_type: String) -> void:
	# Find boss in scene
	var bosses = get_tree().get_nodes_in_group("boss")
	for boss in bosses:
		if is_instance_valid(boss):
			if boss_type not in _bosses_encountered:
				_bosses_encountered.append(boss_type)
				_log_event("boss_encountered", {"boss": boss_type, "wave": _test_results["max_wave"]})
				print("[BOUNDARY TEST] Boss encountered: %s" % boss_type)

				if auto_screenshots:
					await get_tree().create_timer(0.5).timeout
					screenshot_capture.capture_custom("boss_%s_wave%02d" % [boss_type, _test_results["max_wave"]])

				# Connect to boss death
				if boss.has_signal("died") and not boss.died.is_connected(_make_boss_death_callback(boss_type)):
					boss.died.connect(_make_boss_death_callback(boss_type))

func _make_boss_death_callback(boss_type: String) -> Callable:
	return func(_xp): _on_boss_defeated(boss_type)

func _on_boss_defeated(boss_type: String) -> void:
	if boss_type not in _bosses_defeated:
		_bosses_defeated.append(boss_type)
		_log_event("boss_defeated", {"boss": boss_type, "total_defeated": _bosses_defeated.size()})
		print("[BOUNDARY TEST] Boss defeated: %s (%d/%d)" % [boss_type, _bosses_defeated.size(), ALL_BOSSES.size()])

		if auto_screenshots:
			screenshot_capture.capture_custom("boss_%s_defeated" % boss_type)

		_check_boundary_test_complete()

func _check_weapon_maxed(weapon_id: String, level: int) -> void:
	if scenario != TestScenario.BOUNDARY_TEST:
		return

	var max_levels = {"sword": 12, "bow": 12, "torch": 5}
	var max_level = max_levels.get(weapon_id, 12)

	if level >= max_level and weapon_id not in _weapons_maxed:
		_weapons_maxed.append(weapon_id)
		_log_event("weapon_maxed", {"weapon": weapon_id, "level": level})
		print("[BOUNDARY TEST] Weapon maxed: %s at level %d (%d/%d)" % [weapon_id, level, _weapons_maxed.size(), ALL_WEAPONS.size()])

		if auto_screenshots:
			screenshot_capture.capture_custom("weapon_%s_maxed" % weapon_id)

		_check_boundary_test_complete()

func _check_boundary_test_complete() -> void:
	if _boundary_test_complete:
		return

	var all_bosses_done = _bosses_defeated.size() >= ALL_BOSSES.size()
	var all_weapons_done = _weapons_maxed.size() >= ALL_WEAPONS.size()

	print("[BOUNDARY TEST] Progress: Bosses %d/%d, Weapons %d/%d" % [
		_bosses_defeated.size(), ALL_BOSSES.size(),
		_weapons_maxed.size(), ALL_WEAPONS.size()
	])

	if all_bosses_done and all_weapons_done:
		_boundary_test_complete = true
		_log_event("boundary_test_complete", {
			"bosses_defeated": _bosses_defeated,
			"weapons_maxed": _weapons_maxed
		})
		print("\n" + "=".repeat(50))
		print("  [BOUNDARY TEST] ALL BOUNDARIES TESTED!")
		print("  Bosses defeated: %s" % str(_bosses_defeated))
		print("  Weapons maxed: %s" % str(_weapons_maxed))
		print("=".repeat(50) + "\n")

		if auto_screenshots:
			screenshot_capture.capture_custom("boundary_test_complete")

		_end_test("boundary_test_complete")
