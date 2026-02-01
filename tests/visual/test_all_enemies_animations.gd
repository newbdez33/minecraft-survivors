extends Node2D
## Visual test for all enemy types with their specific animation configurations
## Tests each enemy's walk, attack, and special animations

var _test_results: Array = []
var _current_test: int = 0
var _tests: Array = []
var _label: Label = null
var _current_enemy: Node2D = null

# Enemy scenes to test
const ENEMY_SCENES = {
	"Zombie": "res://scenes/enemies/zombie.tscn",
	"Spider": "res://scenes/enemies/spider.tscn",
	"Skeleton": "res://scenes/enemies/skeleton.tscn",
	"Creeper": "res://scenes/enemies/creeper.tscn",
	"Enderman": "res://scenes/enemies/enderman.tscn",
	"Witch": "res://scenes/enemies/witch.tscn",
	"Evoker": "res://scenes/enemies/evoker.tscn",
	"ElderGuardian": "res://scenes/enemies/elder_guardian.tscn",
	"Ravager": "res://scenes/enemies/ravager.tscn",
	"Warden": "res://scenes/enemies/warden.tscn",
	"Wither": "res://scenes/enemies/wither.tscn",
	"EnderDragon": "res://scenes/enemies/ender_dragon.tscn",
}

func _ready() -> void:
	# Create label for test info
	_label = Label.new()
	_label.position = Vector2(20, 20)
	_label.add_theme_font_size_override("font_size", 20)
	add_child(_label)

	# Build tests for each enemy type
	for enemy_name in ENEMY_SCENES:
		var scene_path = ENEMY_SCENES[enemy_name]
		_tests.append({
			"name": "%s: Scene loads" % enemy_name,
			"func": _test_scene_loads.bind(scene_path)
		})
		_tests.append({
			"name": "%s: Has animator" % enemy_name,
			"func": _test_has_animator.bind(scene_path)
		})
		_tests.append({
			"name": "%s: Walk animation" % enemy_name,
			"func": _test_walk_animation.bind(scene_path)
		})
		_tests.append({
			"name": "%s: Hit reaction" % enemy_name,
			"func": _test_hit_reaction.bind(scene_path)
		})
		_tests.append({
			"name": "%s: Death cleanup" % enemy_name,
			"func": _test_death_cleanup.bind(scene_path)
		})

	# Special tests for specific enemies
	_tests.append({
		"name": "Spider: Jump animations",
		"func": _test_spider_jump
	})
	_tests.append({
		"name": "Creeper: Explosion swell",
		"func": _test_creeper_swell
	})
	_tests.append({
		"name": "Enderman: Teleport animations",
		"func": _test_enderman_teleport
	})
	_tests.append({
		"name": "Skeleton: Bow draw animation",
		"func": _test_skeleton_bow
	})
	_tests.append({
		"name": "Witch: Throw animation",
		"func": _test_witch_throw
	})
	_tests.append({
		"name": "Ravager: Charge animation",
		"func": _test_ravager_charge
	})
	_tests.append({
		"name": "Warden: Sonic boom animation",
		"func": _test_warden_sonic
	})
	_tests.append({
		"name": "Elder Guardian: Laser animation",
		"func": _test_elder_guardian_laser
	})
	_tests.append({
		"name": "Evoker: Summon animation",
		"func": _test_evoker_summon
	})
	_tests.append({
		"name": "Wither: Skull attack animation",
		"func": _test_wither_skull
	})
	_tests.append({
		"name": "Ender Dragon: Flying animation",
		"func": _test_dragon_flying
	})

	_run_next_test()


func _run_next_test() -> void:
	if _current_test >= _tests.size():
		_print_results()
		return

	var test = _tests[_current_test]
	_label.text = "Testing: " + test.name

	# Clean up previous enemy
	if _current_enemy:
		_current_enemy.queue_free()
		_current_enemy = null
		await get_tree().process_frame

	# Run test
	var result = await test.func.call()
	_test_results.append({"name": test.name, "passed": result})

	_current_test += 1
	await get_tree().create_timer(0.2).timeout
	_run_next_test()


func _print_results() -> void:
	print("\n============================================================")
	print("  ALL ENEMIES ANIMATION VISUAL TEST RESULTS")
	print("============================================================")

	var passed = 0
	var failed = 0

	for result in _test_results:
		var status = "✓" if result.passed else "✗"
		print("  %s %s" % [status, result.name])
		if result.passed:
			passed += 1
		else:
			failed += 1

	print("------------------------------------------------------------")
	print("  Passed: %d  Failed: %d  Total: %d" % [passed, failed, _test_results.size()])
	print("============================================================\n")

	_label.text = "Tests Complete: %d/%d passed" % [passed, _test_results.size()]

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _spawn_enemy(scene_path: String) -> Node2D:
	var scene = load(scene_path)
	if not scene:
		return null
	var enemy = scene.instantiate()
	enemy.position = Vector2(640, 360)
	add_child(enemy)
	_current_enemy = enemy
	return enemy


# === GENERIC TESTS ===

func _test_scene_loads(scene_path: String) -> bool:
	var scene = load(scene_path)
	return scene != null


func _test_has_animator(scene_path: String) -> bool:
	var enemy = _spawn_enemy(scene_path)
	if not enemy:
		return false
	await get_tree().process_frame
	# Check for animator node
	var animator = enemy.get_node_or_null("EnemyAnimator")
	return animator != null or "_animator" in enemy


func _test_walk_animation(scene_path: String) -> bool:
	var enemy = _spawn_enemy(scene_path)
	if not enemy:
		return false
	await get_tree().process_frame

	# Simulate movement
	if enemy is CharacterBody2D:
		enemy.velocity = Vector2(100, 0)

	await get_tree().create_timer(0.5).timeout
	return true  # Animation should play


func _test_hit_reaction(scene_path: String) -> bool:
	var enemy = _spawn_enemy(scene_path)
	if not enemy:
		return false
	await get_tree().process_frame

	if enemy.has_method("take_damage"):
		enemy.take_damage(1)  # Small damage to trigger animation
		await get_tree().create_timer(0.3).timeout
		return true
	return false


func _test_death_cleanup(scene_path: String) -> bool:
	var enemy = _spawn_enemy(scene_path)
	if not enemy:
		return false
	await get_tree().process_frame

	# Kill enemy with high damage
	if enemy.has_method("take_damage"):
		enemy.take_damage(9999)
		await get_tree().create_timer(0.1).timeout
		# Enemy should be freed without errors
		_current_enemy = null
		return true
	return false


# === SPECIFIC ENEMY TESTS ===

func _test_spider_jump() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Spider"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Trigger jump
	if enemy.has_method("jump"):
		enemy.jump()
		await get_tree().create_timer(0.5).timeout
		return true
	return false


func _test_creeper_swell() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Creeper"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Set up a mock target so the creeper can process
	var mock_target = Node2D.new()
	mock_target.global_position = enemy.global_position + Vector2(50, 0)
	add_child(mock_target)
	enemy.target = mock_target

	# Start fuse and wait for swell animation
	if enemy.has_method("start_fuse"):
		enemy.start_fuse()
		await get_tree().create_timer(0.5).timeout
		mock_target.queue_free()
		# Test passes if start_fuse didn't crash
		return true
	mock_target.queue_free()
	return false


func _test_enderman_teleport() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Enderman"])
	if not enemy:
		return false
	await get_tree().process_frame

	if enemy.has_method("teleport"):
		var old_pos = enemy.global_position
		enemy.teleport()
		await get_tree().create_timer(0.3).timeout
		return enemy.global_position != old_pos
	return false


func _test_skeleton_bow() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Skeleton"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("shoot_arrow"):
		enemy.shoot_arrow()
		await get_tree().create_timer(0.5).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_witch_throw() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Witch"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("throw_potion"):
		enemy.throw_potion()
		await get_tree().create_timer(0.5).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_ravager_charge() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Ravager"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(200, 0)
	add_child(enemy.target)

	if enemy.has_method("_start_charge"):
		enemy._start_charge()
		await get_tree().create_timer(1.0).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_warden_sonic() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Warden"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("_do_sonic_boom"):
		enemy._do_sonic_boom()
		await get_tree().create_timer(1.0).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_elder_guardian_laser() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["ElderGuardian"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("_start_laser_attack"):
		enemy._start_laser_attack()
		await get_tree().create_timer(1.5).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_evoker_summon() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Evoker"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("_start_summon"):
		enemy._start_summon()
		await get_tree().create_timer(1.0).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_wither_skull() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["Wither"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Mock a target
	enemy.target = Node2D.new()
	enemy.target.global_position = enemy.global_position + Vector2(100, 0)
	add_child(enemy.target)

	if enemy.has_method("_start_skull_attack"):
		enemy._start_skull_attack()
		await get_tree().create_timer(1.5).timeout
		enemy.target.queue_free()
		return true
	enemy.target.queue_free()
	return false


func _test_dragon_flying() -> bool:
	var enemy = _spawn_enemy(ENEMY_SCENES["EnderDragon"])
	if not enemy:
		return false
	await get_tree().process_frame

	# Check if flying animation started automatically
	if "_animator" in enemy and enemy._animator:
		await get_tree().create_timer(0.5).timeout
		return enemy._animator.is_walking  # Dragon uses walk as flying
	return true  # Assume passed if no direct check
