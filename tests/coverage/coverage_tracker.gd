extends RefCounted
class_name CoverageTracker
## Coverage tracking system for Minecraft Survivors test suite
## Tracks which functions have been tested and generates coverage reports

## Dictionary of script_path -> {functions: Array, tested: Dictionary}
var _scripts: Dictionary = {}

## Dictionary of script_path -> Array of public function names
var _registered_functions: Dictionary = {}

## Dictionary of script_path -> Dictionary of tested function names -> bool
var _tested_functions: Dictionary = {}

## List of script paths to track
const TRACKED_SCRIPTS: Array = [
	"res://scripts/player.gd",
	"res://scripts/game.gd",
	"res://scripts/spawner.gd",
	"res://scripts/arena.gd",
	"res://scripts/camera.gd",
	# Components
	"res://scripts/components/health.gd",
	"res://scripts/components/status_effect.gd",
	"res://scripts/components/status_effect_manager.gd",
	"res://scripts/components/weapon_slots.gd",
	# Enemies
	"res://scripts/enemies/zombie.gd",
	"res://scripts/enemies/skeleton.gd",
	"res://scripts/enemies/spider.gd",
	"res://scripts/enemies/creeper.gd",
	"res://scripts/enemies/enderman.gd",
	"res://scripts/enemies/witch.gd",
	"res://scripts/enemies/evoker.gd",
	"res://scripts/enemies/vex.gd",
	# Weapons
	"res://scripts/weapons/sword_base.gd",
	"res://scripts/weapons/diamond_sword.gd",
	"res://scripts/weapons/bow.gd",
	"res://scripts/weapons/crossbow.gd",
	"res://scripts/weapons/torch.gd",
	# Projectiles
	"res://scripts/projectiles/arrow.gd",
	"res://scripts/projectiles/player_arrow.gd",
	"res://scripts/projectiles/crossbow_bolt.gd",
	"res://scripts/projectiles/potion.gd",
	# Pickups
	"res://scripts/pickups/xp_orb.gd",
	"res://scripts/pickups/health_pickup.gd",
	"res://scripts/pickups/meat_pickup.gd",
	"res://scripts/pickups/emerald_pickup.gd",
	"res://scripts/pickups/totem_pickup.gd",
	"res://scripts/pickups/lucky_drop_pickup.gd",
	# Effects
	"res://scripts/effects/death_poof.gd",
	"res://scripts/effects/effect_base.gd",
	"res://scripts/effects/explosion.gd",
	"res://scripts/effects/hit_effect.gd",
	"res://scripts/effects/damage_number.gd",
	"res://scripts/effects/screen_shake.gd",
	"res://scripts/effects/poison_cloud.gd",
	"res://scripts/effects/evoker_fang.gd",
	# Systems
	"res://scripts/systems/upgrade_manager.gd",
	"res://scripts/systems/upgrade.gd",
	"res://scripts/systems/wave_manager.gd",
	"res://scripts/systems/day_night_cycle.gd",
	"res://scripts/systems/game_stats.gd",
	"res://scripts/systems/combo_system.gd",
	"res://scripts/systems/score_calculator.gd",
	"res://scripts/systems/score_storage.gd",
	"res://scripts/systems/health_pickup_spawner.gd",
	"res://scripts/systems/localization_manager.gd",
	"res://scripts/systems/achievement.gd",
	"res://scripts/systems/achievement_manager.gd",
	"res://scripts/systems/character.gd",
	"res://scripts/systems/character_manager.gd",
	"res://scripts/systems/weapon_evolution.gd",
	"res://scripts/systems/weapon_evolution_manager.gd",
	"res://scripts/systems/lucky_drop.gd",
	"res://scripts/systems/torch_manager.gd",
	# UI
	"res://scripts/ui/hud.gd",
	"res://scripts/ui/upgrade_ui.gd",
	"res://scripts/ui/game_over_ui.gd",
	"res://scripts/ui/main_menu.gd",
	"res://scripts/ui/pause_menu.gd",
	"res://scripts/ui/settings_panel.gd",
	"res://scripts/ui/scoreboard_panel.gd",
	"res://scripts/ui/status_container.gd",
	"res://scripts/ui/status_icon.gd",
	"res://scripts/ui/boss_health_bar.gd",
	"res://scripts/ui/splash_screen.gd",
]

func _init() -> void:
	_initialize_tracking()

func _initialize_tracking() -> void:
	for script_path in TRACKED_SCRIPTS:
		_registered_functions[script_path] = []
		_tested_functions[script_path] = {}

		var script = load(script_path)
		if script:
			var functions = _extract_public_functions(script_path)
			_registered_functions[script_path] = functions
			for func_name in functions:
				_tested_functions[script_path][func_name] = false

## Extract public function names from a script (excluding private _ prefixed)
func _extract_public_functions(script_path: String) -> Array:
	var functions: Array = []
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return functions

	var content = file.get_as_text()
	file.close()

	# Parse function declarations
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("func "):
			var func_name = _extract_func_name(line)
			# Include all functions including private ones for complete coverage
			if func_name and func_name != "":
				functions.append(func_name)

	return functions

func _extract_func_name(line: String) -> String:
	# Extract function name from "func name(...) -> type:" or "func name(...):"
	var start = line.find("func ") + 5
	var end = line.find("(")
	if end > start:
		return line.substr(start, end - start).strip_edges()
	return ""

## Mark a function as tested
func mark_tested(script_path: String, func_name: String) -> void:
	if script_path in _tested_functions:
		if func_name in _tested_functions[script_path]:
			_tested_functions[script_path][func_name] = true

## Mark multiple functions as tested
func mark_functions_tested(script_path: String, func_names: Array) -> void:
	for func_name in func_names:
		mark_tested(script_path, func_name)

## Get coverage percentage for a specific script
func get_script_coverage(script_path: String) -> float:
	if script_path not in _registered_functions:
		return 0.0

	var total = _registered_functions[script_path].size()
	if total == 0:
		return 100.0  # No functions = 100% covered

	var tested = 0
	for func_name in _tested_functions[script_path]:
		if _tested_functions[script_path][func_name]:
			tested += 1

	return (float(tested) / float(total)) * 100.0

## Get overall coverage percentage
func get_total_coverage() -> float:
	var total_functions = 0
	var tested_functions = 0

	for script_path in _registered_functions:
		total_functions += _registered_functions[script_path].size()
		for func_name in _tested_functions[script_path]:
			if _tested_functions[script_path][func_name]:
				tested_functions += 1

	if total_functions == 0:
		return 100.0

	return (float(tested_functions) / float(total_functions)) * 100.0

## Get list of untested functions for a script
func get_untested_functions(script_path: String) -> Array:
	var untested: Array = []
	if script_path not in _tested_functions:
		return untested

	for func_name in _tested_functions[script_path]:
		if not _tested_functions[script_path][func_name]:
			untested.append(func_name)

	return untested

## Get all untested functions across all scripts
func get_all_untested_functions() -> Dictionary:
	var result: Dictionary = {}
	for script_path in _tested_functions:
		var untested = get_untested_functions(script_path)
		if untested.size() > 0:
			result[script_path] = untested
	return result

## Generate coverage report as Dictionary
func generate_report() -> Dictionary:
	var report: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total_coverage_percent": get_total_coverage(),
		"total_functions": 0,
		"tested_functions": 0,
		"scripts": {}
	}

	for script_path in _registered_functions:
		var total = _registered_functions[script_path].size()
		var tested = 0
		var untested: Array = []

		for func_name in _tested_functions[script_path]:
			if _tested_functions[script_path][func_name]:
				tested += 1
			else:
				untested.append(func_name)

		report.total_functions += total
		report.tested_functions += tested

		report.scripts[script_path] = {
			"total_functions": total,
			"tested_functions": tested,
			"coverage_percent": get_script_coverage(script_path),
			"untested": untested
		}

	return report

## Generate and save coverage report to JSON file
func save_report(file_path: String = "res://tests/coverage/report.json") -> bool:
	var report = generate_report()
	var json_string = JSON.stringify(report, "\t")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("[COVERAGE] Failed to write report to: " + file_path)
		return false

	file.store_string(json_string)
	file.close()
	print("[COVERAGE] Report saved to: " + file_path)
	return true

## Print coverage summary to console
func print_summary() -> void:
	print("")
	print("=".repeat(60))
	print("  COVERAGE REPORT")
	print("=".repeat(60))

	var total = get_total_coverage()
	print("  Total Coverage: %.1f%%" % total)
	print("")

	# Group by category
	var categories = {
		"Core": [],
		"Components": [],
		"Enemies": [],
		"Weapons": [],
		"Projectiles": [],
		"Pickups": [],
		"Effects": [],
		"Systems": [],
		"UI": []
	}

	for script_path in _registered_functions:
		var coverage = get_script_coverage(script_path)
		var script_name = script_path.get_file().replace(".gd", "")
		var entry = {"name": script_name, "coverage": coverage, "path": script_path}

		if "/components/" in script_path:
			categories["Components"].append(entry)
		elif "/enemies/" in script_path:
			categories["Enemies"].append(entry)
		elif "/weapons/" in script_path:
			categories["Weapons"].append(entry)
		elif "/projectiles/" in script_path:
			categories["Projectiles"].append(entry)
		elif "/pickups/" in script_path:
			categories["Pickups"].append(entry)
		elif "/effects/" in script_path:
			categories["Effects"].append(entry)
		elif "/systems/" in script_path:
			categories["Systems"].append(entry)
		elif "/ui/" in script_path:
			categories["UI"].append(entry)
		else:
			categories["Core"].append(entry)

	for category in categories:
		if categories[category].size() > 0:
			print("  [%s]" % category)
			for entry in categories[category]:
				var status = "OK" if entry.coverage >= 100.0 else "%.0f%%" % entry.coverage
				var icon = "^" if entry.coverage >= 100.0 else "!"
				print("    %s %s: %s" % [icon, entry.name, status])
			print("")

	# Print scripts needing attention (< 100% coverage)
	var needs_attention = []
	for script_path in _registered_functions:
		var coverage = get_script_coverage(script_path)
		if coverage < 100.0:
			var untested = get_untested_functions(script_path)
			needs_attention.append({
				"path": script_path,
				"coverage": coverage,
				"untested_count": untested.size()
			})

	if needs_attention.size() > 0:
		print("  [NEEDS ATTENTION: %d scripts]" % needs_attention.size())
		for item in needs_attention:
			print("    - %s (%.0f%%, %d untested)" % [item.path.get_file(), item.coverage, item.untested_count])

	print("=".repeat(60))
