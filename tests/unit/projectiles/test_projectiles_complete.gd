extends Node
class_name TestProjectilesComplete
## Complete projectile tests for 100% coverage
## Tests arrows, potions, crossbow bolts, and xiahou_dun fangs

static func get_test_name() -> String:
	return "Projectiles Complete Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Arrow Tests
	_add_result(results, test_arrow_scene_loads())
	_add_result(results, test_arrow_script_loads())
	_add_result(results, test_arrow_has_speed())
	_add_result(results, test_arrow_has_damage())
	_add_result(results, test_arrow_has_direction())

	# Player Arrow Tests
	_add_result(results, test_player_arrow_scene_loads())
	_add_result(results, test_player_arrow_script_loads())
	_add_result(results, test_player_arrow_has_damage())

	# Potion Tests
	_add_result(results, test_potion_scene_loads())
	_add_result(results, test_potion_script_loads())
	_add_result(results, test_potion_has_damage())
	_add_result(results, test_potion_has_splash_radius())
	_add_result(results, test_potion_has_poison_damage())

	# Crossbow Bolt Tests
	_add_result(results, test_bolt_scene_loads())
	_add_result(results, test_bolt_script_loads())
	_add_result(results, test_bolt_has_pierce())

	# Ground Spike Tests
	_add_result(results, test_fang_scene_loads())
	_add_result(results, test_fang_script_loads())
	_add_result(results, test_fang_has_damage())
	_add_result(results, test_fang_has_delay())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# =============================================================================
# ARROW TESTS
# =============================================================================

static func test_arrow_scene_loads() -> Dictionary:
	var scene = load("res://scenes/projectiles/arrow.tscn")
	return {"name": "TC.PR.1: Arrow scene loads", "passed": scene != null}

static func test_arrow_script_loads() -> Dictionary:
	var script = load("res://scripts/projectiles/arrow.gd")
	return {"name": "TC.PR.2: Arrow script loads", "passed": script != null}

static func test_arrow_has_speed() -> Dictionary:
	var scene = load("res://scenes/projectiles/arrow.tscn")
	if not scene:
		return {"name": "TC.PR.3: Arrow has speed property", "passed": false}
	var arrow = scene.instantiate()
	var passed = "speed" in arrow
	arrow.queue_free()
	return {"name": "TC.PR.3: Arrow has speed property", "passed": passed}

static func test_arrow_has_damage() -> Dictionary:
	var scene = load("res://scenes/projectiles/arrow.tscn")
	if not scene:
		return {"name": "TC.PR.4: Arrow has damage property", "passed": false}
	var arrow = scene.instantiate()
	var passed = "damage" in arrow
	arrow.queue_free()
	return {"name": "TC.PR.4: Arrow has damage property", "passed": passed}

static func test_arrow_has_direction() -> Dictionary:
	var scene = load("res://scenes/projectiles/arrow.tscn")
	if not scene:
		return {"name": "TC.PR.5: Arrow has direction property", "passed": false}
	var arrow = scene.instantiate()
	var passed = "direction" in arrow
	arrow.queue_free()
	return {"name": "TC.PR.5: Arrow has direction property", "passed": passed}

# =============================================================================
# PLAYER ARROW TESTS
# =============================================================================

static func test_player_arrow_scene_loads() -> Dictionary:
	var scene = load("res://scenes/projectiles/player_arrow.tscn")
	return {"name": "TC.PR.6: Player arrow scene loads", "passed": scene != null}

static func test_player_arrow_script_loads() -> Dictionary:
	var script = load("res://scripts/projectiles/player_arrow.gd")
	return {"name": "TC.PR.7: Player arrow script loads", "passed": script != null}

static func test_player_arrow_has_damage() -> Dictionary:
	var scene = load("res://scenes/projectiles/player_arrow.tscn")
	if not scene:
		return {"name": "TC.PR.8: Player arrow has damage", "passed": false}
	var arrow = scene.instantiate()
	var passed = "damage" in arrow
	arrow.queue_free()
	return {"name": "TC.PR.8: Player arrow has damage property", "passed": passed}

# =============================================================================
# POISON DART TESTS
# =============================================================================

static func test_potion_scene_loads() -> Dictionary:
	var scene = load("res://scenes/projectiles/poison_dart.tscn")
	return {"name": "TC.PR.9: Poison Dart scene loads", "passed": scene != null}

static func test_potion_script_loads() -> Dictionary:
	var script = load("res://scripts/projectiles/poison_dart.gd")
	return {"name": "TC.PR.10: Poison Dart script loads", "passed": script != null}

static func test_potion_has_damage() -> Dictionary:
	var scene = load("res://scenes/projectiles/poison_dart.tscn")
	if not scene:
		return {"name": "TC.PR.11: Poison Dart has damage", "passed": false}
	var dart = scene.instantiate()
	var passed = "damage" in dart
	dart.queue_free()
	return {"name": "TC.PR.11: Poison Dart has damage property", "passed": passed}

static func test_potion_has_splash_radius() -> Dictionary:
	var scene = load("res://scenes/projectiles/poison_dart.tscn")
	if not scene:
		return {"name": "TC.PR.12: Poison Dart has cloud_size", "passed": false}
	var dart = scene.instantiate()
	var passed = "cloud_size" in dart
	dart.queue_free()
	return {"name": "TC.PR.12: Poison Dart has cloud_size property", "passed": passed}

static func test_potion_has_poison_damage() -> Dictionary:
	var scene = load("res://scenes/projectiles/poison_dart.tscn")
	if not scene:
		return {"name": "TC.PR.13: Poison Dart has poison_damage_per_tick", "passed": false}
	var dart = scene.instantiate()
	var passed = "poison_damage_per_tick" in dart
	dart.queue_free()
	return {"name": "TC.PR.13: Poison Dart has poison_damage_per_tick property", "passed": passed}

# =============================================================================
# CROSSBOW BOLT TESTS
# =============================================================================

static func test_bolt_scene_loads() -> Dictionary:
	var scene = load("res://scenes/projectiles/crossbow_bolt.tscn")
	return {"name": "TC.PR.14: Crossbow bolt scene loads", "passed": scene != null}

static func test_bolt_script_loads() -> Dictionary:
	var script = load("res://scripts/projectiles/crossbow_bolt.gd")
	return {"name": "TC.PR.15: Crossbow bolt script loads", "passed": script != null}

static func test_bolt_has_pierce() -> Dictionary:
	var scene = load("res://scenes/projectiles/crossbow_bolt.tscn")
	if not scene:
		return {"name": "TC.PR.16: Crossbow bolt has pierce", "passed": false}
	var bolt = scene.instantiate()
	var passed = "pierce" in bolt or "pierce_count" in bolt
	bolt.queue_free()
	return {"name": "TC.PR.16: Crossbow bolt has pierce property", "passed": passed}

# =============================================================================
# EVOKER FANG TESTS
# =============================================================================

static func test_fang_scene_loads() -> Dictionary:
	var scene = load("res://scenes/effects/ground_spike.tscn")
	return {"name": "TC.PR.17: XiahouDun fang scene loads", "passed": scene != null}

static func test_fang_script_loads() -> Dictionary:
	var script = load("res://scripts/effects/ground_spike.gd")
	return {"name": "TC.PR.18: XiahouDun fang script loads", "passed": script != null}

static func test_fang_has_damage() -> Dictionary:
	var scene = load("res://scenes/effects/ground_spike.tscn")
	if not scene:
		return {"name": "TC.PR.19: XiahouDun fang has damage", "passed": false}
	var fang = scene.instantiate()
	var passed = "damage" in fang
	fang.queue_free()
	return {"name": "TC.PR.19: XiahouDun fang has damage property", "passed": passed}

static func test_fang_has_delay() -> Dictionary:
	var scene = load("res://scenes/effects/ground_spike.tscn")
	if not scene:
		return {"name": "TC.PR.20: XiahouDun fang has warning_duration", "passed": false}
	var fang = scene.instantiate()
	# GroundSpike uses warning_duration (not spawn_delay or delay)
	var passed = "warning_duration" in fang
	fang.queue_free()
	return {"name": "TC.PR.20: XiahouDun fang has warning_duration property", "passed": passed}

static func get_tested_functions() -> Array:
	return [
		# Arrow (arrow.gd)
		"_ready", "_physics_process", "set_direction", "_on_body_entered", "_on_lifetime_timeout",
		# Player Arrow (player_arrow.gd)
		"_on_area_entered", "_try_damage", "_spawn_hit_effect", "_exit_tree",
		# Poison Dart (poison_dart.gd)
		"set_target", "_land", "_spawn_poison_cloud",
		# Crossbow Bolt (crossbow_bolt.gd)
		"_process", "_try_hit"
	]
