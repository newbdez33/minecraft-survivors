# Phase 5 测试计划

**目标**: 为Phase 5所有功能建立完整的测试覆盖，包括单元测试和视觉测试。

---

## 测试架构

### 1. 测试类型

| 类型 | 工具 | 目的 |
|------|------|------|
| 单元测试 | test_runner.gd | 验证单个组件逻辑 |
| 集成测试 | test_runner.gd | 验证组件间交互 |
| 视觉测试 | visual_test_runner.gd | 截图验证UI/效果 |
| 自动游戏测试 | auto_player.gd | 模拟真实游戏流程 |

### 2. 测试模式 (Test Mode)

游戏内置测试模式，自动运行游戏并收集数据。

**启动方式:**
```bash
# 命令行启动测试模式
godot --path . scenes/main.tscn -- --test-mode

# 指定测试场景
godot --path . scenes/main.tscn -- --test-mode --test=poison

# 快速模式 (2倍速)
godot --path . scenes/main.tscn -- --test-mode --speed=2
```

**测试模式功能:**
- 自动玩家 (AutoPlayer) 控制Steve移动和战斗
- 自动截图在关键时刻
- 调试信息实时显示在屏幕上
- 测试结果输出到日志文件

---

## 测试基础设施

### 2.1 AutoPlayer (自动玩家)

```gdscript
# scripts/testing/auto_player.gd
class_name AutoPlayer
extends Node

## 自动控制玩家进行测试
## 模拟真实玩家行为：躲避敌人、收集XP、选择升级

signal test_event(event_name: String, data: Dictionary)
signal screenshot_requested(name: String)

enum Strategy {
    SURVIVE,      # 尽量存活（躲避为主）
    AGGRESSIVE,   # 积极战斗（冲向敌人）
    STATIONARY,   # 站立不动（测试伤害）
    COLLECT_XP,   # 优先收集XP
    TRIGGER_POISON # 故意触发中毒
}

@export var strategy: Strategy = Strategy.SURVIVE
@export var auto_upgrade: bool = true
@export var preferred_upgrades: Array[String] = []

var player: CharacterBody2D
var enemies: Array[Node2D] = []
var xp_orbs: Array[Node2D] = []

func _ready() -> void:
    # 查找玩家和游戏对象
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if not player or not player.is_inside_tree():
        return

    match strategy:
        Strategy.SURVIVE:
            _strategy_survive()
        Strategy.AGGRESSIVE:
            _strategy_aggressive()
        Strategy.STATIONARY:
            pass  # 不移动
        Strategy.COLLECT_XP:
            _strategy_collect_xp()
        Strategy.TRIGGER_POISON:
            _strategy_trigger_poison()

func _strategy_survive() -> void:
    # 计算最近敌人的方向，向反方向移动
    var nearest_enemy = _get_nearest_enemy()
    if nearest_enemy:
        var away_direction = (player.global_position - nearest_enemy.global_position).normalized()
        _move_player(away_direction)
    else:
        _move_towards_xp()

func _strategy_aggressive() -> void:
    # 冲向最近的敌人
    var nearest_enemy = _get_nearest_enemy()
    if nearest_enemy:
        var towards = (nearest_enemy.global_position - player.global_position).normalized()
        _move_player(towards)

func _strategy_collect_xp() -> void:
    _move_towards_xp()

func _strategy_trigger_poison() -> void:
    # 寻找女巫，靠近她
    var witch = _get_nearest_enemy_of_type("Witch")
    if witch:
        var towards = (witch.global_position - player.global_position).normalized()
        _move_player(towards)

func _move_player(direction: Vector2) -> void:
    # 设置玩家输入方向
    player.velocity = direction * player.speed

func _move_towards_xp() -> void:
    var nearest_xp = _get_nearest_xp()
    if nearest_xp:
        var towards = (nearest_xp.global_position - player.global_position).normalized()
        _move_player(towards)

func _get_nearest_enemy() -> Node2D:
    enemies = get_tree().get_nodes_in_group("enemies")
    var nearest: Node2D = null
    var nearest_dist: float = INF
    for enemy in enemies:
        var dist = player.global_position.distance_to(enemy.global_position)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = enemy
    return nearest

func _get_nearest_enemy_of_type(type_name: String) -> Node2D:
    enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.name.begins_with(type_name):
            return enemy
    return null

func _get_nearest_xp() -> Node2D:
    xp_orbs = get_tree().get_nodes_in_group("xp_orbs")
    var nearest: Node2D = null
    var nearest_dist: float = INF
    for orb in xp_orbs:
        var dist = player.global_position.distance_to(orb.global_position)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = orb
    return nearest

# 自动选择升级
func select_upgrade(upgrades: Array) -> int:
    if preferred_upgrades.size() > 0:
        for i in range(upgrades.size()):
            if upgrades[i].id in preferred_upgrades:
                return i
    # 默认选择中间选项
    return upgrades.size() / 2
```

### 2.2 TestDebugOverlay (调试信息显示)

```gdscript
# scripts/testing/test_debug_overlay.gd
class_name TestDebugOverlay
extends CanvasLayer

## 测试模式下显示调试信息

@onready var info_label: Label = $InfoLabel
@onready var event_log: RichTextLabel = $EventLog

var game_stats: GameStats
var player: Node2D
var status_manager: StatusEffectManager

var events: Array[String] = []
const MAX_EVENTS = 20

func _ready() -> void:
    layer = 100  # 最顶层
    visible = OS.has_feature("test_mode") or "--test-mode" in OS.get_cmdline_args()

func _process(_delta: float) -> void:
    if not visible:
        return
    _update_info()

func _update_info() -> void:
    var info = """[TEST MODE]
Time: %.1f s
Wave: %d
Kills: %d
Player HP: %d/%d
Player Level: %d
Enemies: %d
XP Orbs: %d
Status Effects: %s
FPS: %d
""" % [
        game_stats.survival_time if game_stats else 0.0,
        game_stats.wave if game_stats else 0,
        game_stats.kills if game_stats else 0,
        player.health.current_health if player and player.health else 0,
        player.health.max_health if player and player.health else 0,
        player.level if player else 0,
        get_tree().get_nodes_in_group("enemies").size(),
        get_tree().get_nodes_in_group("xp_orbs").size(),
        _get_status_effects_string(),
        Engine.get_frames_per_second()
    ]
    info_label.text = info

func _get_status_effects_string() -> String:
    if not status_manager:
        return "None"
    var effects = []
    for effect in status_manager.active_effects:
        effects.append("%s (%.1fs)" % [StatusEffect.Type.keys()[effect.type], effect.remaining_time])
    return ", ".join(effects) if effects.size() > 0 else "None"

func log_event(event: String) -> void:
    var timestamp = "%.1f" % (game_stats.survival_time if game_stats else 0.0)
    events.push_front("[%s] %s" % [timestamp, event])
    if events.size() > MAX_EVENTS:
        events.pop_back()
    _update_event_log()

func _update_event_log() -> void:
    event_log.text = "\n".join(events)
```

### 2.3 ScreenshotCapture (截图系统)

```gdscript
# scripts/testing/screenshot_capture.gd
class_name ScreenshotCapture
extends Node

## 自动截图系统

const SCREENSHOT_DIR = "user://test_screenshots/"

var screenshot_count: int = 0
var test_name: String = "default"

func _ready() -> void:
    # 确保目录存在
    DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)

func capture(name: String = "") -> String:
    await RenderingServer.frame_post_draw

    var image = get_viewport().get_texture().get_image()
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
    var filename = "%s_%s_%03d_%s.png" % [test_name, timestamp, screenshot_count, name]
    var path = SCREENSHOT_DIR + filename

    image.save_png(path)
    screenshot_count += 1

    print("[Screenshot] Saved: %s" % path)
    return path

func capture_with_delay(name: String, delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    capture(name)

# 预定义截图点
func capture_game_start() -> void:
    capture("game_start")

func capture_level_up() -> void:
    capture("level_up")

func capture_poison_applied() -> void:
    capture("poison_applied")

func capture_game_over() -> void:
    capture("game_over")

func capture_night_time() -> void:
    capture("night_time")

func capture_boss_spawn() -> void:
    capture("boss_spawn")
```

### 2.4 TestRunner 增强

```gdscript
# scripts/testing/visual_test_runner.gd
class_name VisualTestRunner
extends Node

## 视觉测试运行器
## 自动运行游戏场景并在关键点截图

signal test_started(test_name: String)
signal test_completed(test_name: String, passed: bool, screenshots: Array)
signal all_tests_completed(results: Dictionary)

var auto_player: AutoPlayer
var debug_overlay: TestDebugOverlay
var screenshot: ScreenshotCapture
var current_test: String = ""
var test_results: Dictionary = {}

# 测试配置
var tests_to_run: Array[Dictionary] = [
    {
        "name": "poison_visual_test",
        "duration": 30.0,
        "strategy": AutoPlayer.Strategy.TRIGGER_POISON,
        "screenshots": ["poison_applied", "poison_effect", "poison_cured"],
        "validators": ["validate_poison_visual"]
    },
    {
        "name": "night_cycle_test",
        "duration": 120.0,
        "strategy": AutoPlayer.Strategy.SURVIVE,
        "screenshots": ["dawn", "morning", "midday", "afternoon", "dusk", "night"],
        "validators": ["validate_night_tint"]
    },
    {
        "name": "combo_visual_test",
        "duration": 60.0,
        "strategy": AutoPlayer.Strategy.AGGRESSIVE,
        "screenshots": ["combo_10", "combo_25", "combo_50"],
        "validators": ["validate_combo_display"]
    },
    {
        "name": "upgrade_ui_test",
        "duration": 45.0,
        "strategy": AutoPlayer.Strategy.COLLECT_XP,
        "screenshots": ["upgrade_shown", "upgrade_timer", "upgrade_selected"],
        "validators": ["validate_upgrade_ui"]
    },
    {
        "name": "game_over_test",
        "duration": 60.0,
        "strategy": AutoPlayer.Strategy.STATIONARY,
        "screenshots": ["low_health", "game_over_screen", "score_display"],
        "validators": ["validate_game_over"]
    }
]

func run_all_tests() -> void:
    for test in tests_to_run:
        await run_test(test)
    all_tests_completed.emit(test_results)
    _save_results()

func run_test(test: Dictionary) -> void:
    current_test = test.name
    screenshot.test_name = test.name
    test_started.emit(test.name)

    # 设置策略
    auto_player.strategy = test.strategy

    # 运行测试
    var start_time = Time.get_ticks_msec()
    var test_duration = test.duration * 1000  # 转换为毫秒

    while Time.get_ticks_msec() - start_time < test_duration:
        await get_tree().process_frame
        # 检查截图触发条件
        _check_screenshot_triggers(test)

    # 验证结果
    var passed = true
    for validator in test.validators:
        if not call(validator):
            passed = false
            break

    test_results[test.name] = {
        "passed": passed,
        "duration": test.duration,
        "screenshots": screenshot.screenshot_count
    }

    test_completed.emit(test.name, passed, [])

func _check_screenshot_triggers(test: Dictionary) -> void:
    # 根据游戏状态自动截图
    pass

func _save_results() -> void:
    var file = FileAccess.open("user://test_results.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(test_results, "\t"))
    file.close()
```

---

## 单元测试用例

### 3.1 Status Effect System (状态效果系统)

#### T5.1.1 - T5.1.5: StatusEffect 基础

```gdscript
# tests/unit/test_status_effect.gd

func test_T5_1_1_status_effect_script_loads():
    var script = load("res://scripts/components/status_effect.gd")
    assert_not_null(script, "StatusEffect script should load")

func test_T5_1_2_status_effect_has_type_enum():
    var effect = StatusEffect.new()
    assert_true(StatusEffect.Type.has("POISON"), "Should have POISON type")
    assert_true(StatusEffect.Type.has("BURN"), "Should have BURN type")
    assert_true(StatusEffect.Type.has("SLOW"), "Should have SLOW type")

func test_T5_1_3_status_effect_has_duration():
    var effect = StatusEffect.new()
    effect.duration = 5.0
    assert_eq(effect.duration, 5.0, "Duration should be 5.0")

func test_T5_1_4_status_effect_has_tick_interval():
    var effect = StatusEffect.new()
    effect.tick_interval = 0.5
    assert_eq(effect.tick_interval, 0.5, "Tick interval should be 0.5")

func test_T5_1_5_status_effect_has_damage_per_tick():
    var effect = StatusEffect.new()
    effect.damage_per_tick = 2
    assert_eq(effect.damage_per_tick, 2, "Damage per tick should be 2")
```

#### T5.1.6 - T5.1.11: StatusEffectManager

```gdscript
# tests/unit/test_status_effect_manager.gd

var manager: StatusEffectManager

func before_each():
    manager = StatusEffectManager.new()
    add_child(manager)

func after_each():
    manager.queue_free()

func test_T5_1_6_manager_script_loads():
    assert_not_null(manager, "Manager should exist")

func test_T5_1_7_manager_has_apply_effect():
    assert_true(manager.has_method("apply_effect"), "Should have apply_effect method")

func test_T5_1_8_manager_has_remove_effect():
    assert_true(manager.has_method("remove_effect"), "Should have remove_effect method")

func test_T5_1_9_manager_has_has_effect():
    assert_true(manager.has_method("has_effect"), "Should have has_effect method")

func test_T5_1_10_manager_emits_effect_applied():
    var signal_received = false
    manager.effect_applied.connect(func(_e): signal_received = true)

    var effect = StatusEffect.new()
    effect.type = StatusEffect.Type.POISON
    manager.apply_effect(effect)

    assert_true(signal_received, "Should emit effect_applied signal")

func test_T5_1_11_manager_emits_effect_tick():
    var tick_count = 0
    manager.effect_tick.connect(func(_e, _d): tick_count += 1)

    var effect = StatusEffect.new()
    effect.type = StatusEffect.Type.POISON
    effect.duration = 1.0
    effect.tick_interval = 0.1
    effect.damage_per_tick = 2
    manager.apply_effect(effect)

    # 模拟时间流逝
    await get_tree().create_timer(0.5).timeout

    assert_gt(tick_count, 0, "Should have ticked at least once")
```

#### T5.1.12 - T5.1.14: Player Integration

```gdscript
# tests/unit/test_player_status_effect.gd

var player: CharacterBody2D

func before_each():
    player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

func after_each():
    player.queue_free()

func test_T5_1_12_player_has_status_effect_manager():
    var manager = player.get_node_or_null("StatusEffectManager")
    assert_not_null(manager, "Player should have StatusEffectManager")

func test_T5_1_13_player_takes_poison_damage():
    var initial_health = player.health.current_health
    var manager = player.get_node("StatusEffectManager")

    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    poison.duration = 1.0
    poison.tick_interval = 0.2
    poison.damage_per_tick = 5
    manager.apply_effect(poison)

    await get_tree().create_timer(0.5).timeout

    assert_lt(player.health.current_health, initial_health, "Player should have taken damage")

func test_T5_1_14_player_shows_poison_visual():
    var manager = player.get_node("StatusEffectManager")

    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    manager.apply_effect(poison)

    # 检查视觉效果
    var sprite = player.get_node("Sprite2D")
    assert_eq(sprite.modulate, Color(0.5, 1.0, 0.5, 1.0), "Player should have green tint")
```

#### T5.1.15 - T5.1.19: Potion Enhancement

```gdscript
# tests/unit/test_potion_poison.gd

var potion: Area2D

func before_each():
    potion = preload("res://scenes/projectiles/potion.tscn").instantiate()
    add_child(potion)

func after_each():
    potion.queue_free()

func test_T5_1_15_potion_splash_radius_is_100():
    assert_eq(potion.splash_radius, 100.0, "Splash radius should be 100")

func test_T5_1_16_potion_has_applies_poison():
    assert_true("applies_poison" in potion, "Should have applies_poison property")
    assert_true(potion.applies_poison, "applies_poison should be true")

func test_T5_1_17_potion_has_poison_duration():
    assert_eq(potion.poison_duration, 5.0, "Poison duration should be 5.0")

func test_T5_1_18_potion_applies_poison_on_hit():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)
    player.global_position = potion.global_position

    potion.explode()

    var manager = player.get_node("StatusEffectManager")
    assert_true(manager.has_effect(StatusEffect.Type.POISON), "Player should be poisoned")

    player.queue_free()

func test_T5_1_19_poison_deals_damage_over_time():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)
    player.global_position = potion.global_position

    var initial_health = player.health.current_health
    potion.explode()

    # 等待中毒伤害
    await get_tree().create_timer(2.0).timeout

    var expected_damage = 2 * 4  # 2 damage per tick, 4 ticks in 2 seconds
    var actual_damage = initial_health - player.health.current_health
    assert_gte(actual_damage, expected_damage - 2, "Should have taken poison damage")

    player.queue_free()
```

#### T5.1.20 - T5.1.23: Visual Effects Assets

```gdscript
# tests/unit/test_poison_assets.gd

func test_T5_1_20_poison_explosion_asset_exists():
    var texture = load("res://assets/effects/poison_explosion.svg")
    assert_not_null(texture, "poison_explosion.svg should exist")

func test_T5_1_21_status_poison_icon_exists():
    var texture = load("res://assets/ui/status_poison.svg")
    assert_not_null(texture, "status_poison.svg should exist")

func test_T5_1_22_player_green_tint_when_poisoned():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

    var manager = player.get_node("StatusEffectManager")
    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    manager.apply_effect(poison)

    var sprite = player.get_node("Sprite2D")
    assert_true(sprite.modulate.g > sprite.modulate.r, "Green should be dominant")

    player.queue_free()

func test_T5_1_23_hud_shows_poison_icon():
    var hud = preload("res://scenes/ui/hud.tscn").instantiate()
    add_child(hud)

    hud.show_status_effect(StatusEffect.Type.POISON, 5.0)

    var status_container = hud.get_node("StatusContainer")
    assert_gt(status_container.get_child_count(), 0, "Should show poison icon")

    hud.queue_free()
```

#### T5.1.24 - T5.1.26: HUD Status Display

```gdscript
# tests/unit/test_hud_status.gd

var hud: CanvasLayer

func before_each():
    hud = preload("res://scenes/ui/hud.tscn").instantiate()
    add_child(hud)

func after_each():
    hud.queue_free()

func test_T5_1_24_hud_has_status_container():
    var container = hud.get_node_or_null("StatusContainer")
    assert_not_null(container, "HUD should have StatusContainer")

func test_T5_1_25_hud_shows_poison_icon_when_poisoned():
    hud.show_status_effect(StatusEffect.Type.POISON, 5.0)

    var poison_icon = hud.get_node_or_null("StatusContainer/PoisonIcon")
    assert_not_null(poison_icon, "Should show poison icon")
    assert_true(poison_icon.visible, "Poison icon should be visible")

func test_T5_1_26_hud_shows_poison_remaining_time():
    hud.show_status_effect(StatusEffect.Type.POISON, 5.0)

    var time_label = hud.get_node_or_null("StatusContainer/PoisonIcon/TimeLabel")
    assert_not_null(time_label, "Should have time label")
    assert_true(time_label.text.contains("5"), "Should show remaining time")
```

#### T5.1.27 - T5.1.30: Poison Auto-Cure

```gdscript
# tests/unit/test_poison_auto_cure.gd

func test_T5_1_27_poison_auto_cures_after_duration():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

    var manager = player.get_node("StatusEffectManager")
    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    poison.duration = 1.0
    manager.apply_effect(poison)

    assert_true(manager.has_effect(StatusEffect.Type.POISON), "Should be poisoned")

    await get_tree().create_timer(1.5).timeout

    assert_false(manager.has_effect(StatusEffect.Type.POISON), "Should be auto-cured")

    player.queue_free()

func test_T5_1_28_poison_visual_removed_after_cure():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

    var manager = player.get_node("StatusEffectManager")
    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    poison.duration = 0.5
    manager.apply_effect(poison)

    await get_tree().create_timer(1.0).timeout

    var sprite = player.get_node("Sprite2D")
    assert_eq(sprite.modulate, Color.WHITE, "Should return to normal color")

    player.queue_free()

func test_T5_1_29_new_poison_refreshes_duration():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

    var manager = player.get_node("StatusEffectManager")

    # 第一次中毒
    var poison1 = StatusEffect.new()
    poison1.type = StatusEffect.Type.POISON
    poison1.duration = 2.0
    manager.apply_effect(poison1)

    await get_tree().create_timer(1.0).timeout

    # 第二次中毒（刷新时间）
    var poison2 = StatusEffect.new()
    poison2.type = StatusEffect.Type.POISON
    poison2.duration = 2.0
    manager.apply_effect(poison2)

    await get_tree().create_timer(1.5).timeout

    # 应该还在中毒状态
    assert_true(manager.has_effect(StatusEffect.Type.POISON), "Should still be poisoned")

    player.queue_free()

func test_T5_1_30_poison_total_damage_correct():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)
    player.health.current_health = 100

    var manager = player.get_node("StatusEffectManager")
    var poison = StatusEffect.new()
    poison.type = StatusEffect.Type.POISON
    poison.duration = 5.0
    poison.tick_interval = 0.5
    poison.damage_per_tick = 2
    manager.apply_effect(poison)

    await get_tree().create_timer(5.5).timeout

    var damage_taken = 100 - player.health.current_health
    var expected_damage = 20  # 5s / 0.5s * 2 = 20
    assert_eq(damage_taken, expected_damage, "Total poison damage should be 20")

    player.queue_free()
```

---

### 3.2 Scoreboard (排行榜)

#### T5.2.1 - T5.2.6: Score Calculator

```gdscript
# tests/unit/test_score_calculator.gd

func test_T5_2_1_score_calculator_loads():
    var calculator = ScoreCalculator.new()
    assert_not_null(calculator, "ScoreCalculator should load")

func test_T5_2_2_has_calculate_method():
    assert_true(ScoreCalculator.has_method("calculate"), "Should have calculate method")

func test_T5_2_3_kill_points_10_per_kill():
    var stats = GameStats.new()
    stats.kills = 10
    stats.survival_time = 0
    stats.level = 1
    stats.wave = 1

    var score = ScoreCalculator.calculate(stats)
    var kill_points = 10 * 10  # 100
    assert_gte(score, kill_points, "Should include kill points")

func test_T5_2_4_time_points_1_per_second():
    var stats = GameStats.new()
    stats.kills = 0
    stats.survival_time = 60.0
    stats.level = 1
    stats.wave = 1

    var score = ScoreCalculator.calculate(stats)
    assert_gte(score, 60, "Should include time points")

func test_T5_2_5_level_points_50_per_level():
    var stats = GameStats.new()
    stats.kills = 0
    stats.survival_time = 0
    stats.level = 5
    stats.wave = 1

    var score = ScoreCalculator.calculate(stats)
    var level_points = 5 * 50  # 250
    assert_gte(score, level_points, "Should include level points")

func test_T5_2_6_wave_points_100_per_wave():
    var stats = GameStats.new()
    stats.kills = 0
    stats.survival_time = 0
    stats.level = 1
    stats.wave = 3

    var score = ScoreCalculator.calculate(stats)
    var wave_points = 3 * 100  # 300
    assert_gte(score, wave_points, "Should include wave points")

func test_T5_2_6b_score_formula_correct():
    var stats = GameStats.new()
    stats.kills = 50
    stats.survival_time = 120.0
    stats.level = 8
    stats.wave = 4

    var score = ScoreCalculator.calculate(stats)
    var expected = 50 * 10 + 120 + 8 * 50 + 4 * 100  # 500 + 120 + 400 + 400 = 1420
    assert_eq(score, expected, "Score formula should be correct")
```

#### T5.2.7 - T5.2.12: Score Storage

```gdscript
# tests/unit/test_score_storage.gd

var storage: ScoreStorage

func before_each():
    storage = ScoreStorage.new()
    add_child(storage)
    # 清除之前的测试数据
    storage.clear_all()

func after_each():
    storage.queue_free()

func test_T5_2_7_storage_loads():
    assert_not_null(storage, "ScoreStorage should load")

func test_T5_2_8_has_save_score():
    assert_true(storage.has_method("save_score"), "Should have save_score method")

func test_T5_2_9_has_load_scores():
    assert_true(storage.has_method("load_scores"), "Should have load_scores method")

func test_T5_2_10_limits_to_10_entries():
    for i in range(15):
        storage.save_score(i * 100, {"kills": i})

    var scores = storage.load_scores()
    assert_eq(scores.size(), 10, "Should limit to 10 entries")

func test_T5_2_11_sorts_by_score_descending():
    storage.save_score(100, {})
    storage.save_score(500, {})
    storage.save_score(300, {})

    var scores = storage.load_scores()
    assert_eq(scores[0].score, 500, "Highest score should be first")
    assert_eq(scores[1].score, 300, "Second highest next")
    assert_eq(scores[2].score, 100, "Lowest last")

func test_T5_2_12_persists_to_file():
    storage.save_score(1000, {"kills": 100})

    # 创建新的storage实例
    var storage2 = ScoreStorage.new()
    add_child(storage2)

    var scores = storage2.load_scores()
    assert_gt(scores.size(), 0, "Should persist to file")
    assert_eq(scores[0].score, 1000, "Should load saved score")

    storage2.queue_free()
```

#### T5.2.13 - T5.2.20: Scoreboard UI & Integration

```gdscript
# tests/unit/test_scoreboard_ui.gd

func test_T5_2_13_scoreboard_ui_loads():
    var ui = preload("res://scenes/ui/scoreboard_ui.tscn").instantiate()
    assert_not_null(ui, "ScoreboardUI should load")
    ui.queue_free()

func test_T5_2_14_scoreboard_scene_loads():
    var scene = load("res://scenes/ui/scoreboard_ui.tscn")
    assert_not_null(scene, "Scoreboard scene should load")

func test_T5_2_15_has_show_scoreboard():
    var ui = preload("res://scenes/ui/scoreboard_ui.tscn").instantiate()
    assert_true(ui.has_method("show_scoreboard"), "Should have show_scoreboard")
    ui.queue_free()

func test_T5_2_16_displays_top_10():
    var ui = preload("res://scenes/ui/scoreboard_ui.tscn").instantiate()
    add_child(ui)

    # 添加测试数据
    var storage = ScoreStorage.new()
    for i in range(10):
        storage.save_score((10 - i) * 100, {})

    ui.show_scoreboard()

    var list = ui.get_node("ScoreList")
    assert_eq(list.get_child_count(), 10, "Should display 10 entries")

    ui.queue_free()
    storage.queue_free()

func test_T5_2_17_game_over_shows_score():
    var game_over = preload("res://scenes/ui/game_over_ui.tscn").instantiate()
    add_child(game_over)

    var stats = GameStats.new()
    stats.kills = 50
    stats.survival_time = 120.0
    stats.level = 5
    stats.wave = 3

    game_over.show_game_over(stats)

    var score_label = game_over.get_node("ScoreLabel")
    assert_true(score_label.text.length() > 0, "Should show score")

    game_over.queue_free()

func test_T5_2_18_game_over_shows_rank():
    var game_over = preload("res://scenes/ui/game_over_ui.tscn").instantiate()
    add_child(game_over)

    var stats = GameStats.new()
    stats.kills = 100
    game_over.show_game_over(stats)

    var rank_label = game_over.get_node("RankLabel")
    assert_true(rank_label.visible, "Should show rank if in top 10")

    game_over.queue_free()

func test_T5_2_19_score_saved_on_game_over():
    var storage = ScoreStorage.new()
    var initial_count = storage.load_scores().size()

    # 模拟游戏结束
    var game = preload("res://scenes/main.tscn").instantiate()
    add_child(game)
    game.game_stats.kills = 50
    game._on_player_died()

    var new_count = storage.load_scores().size()
    assert_gt(new_count, initial_count, "Score should be saved")

    game.queue_free()
    storage.queue_free()

func test_T5_2_20_scoreboard_accessible_from_game_over():
    var game_over = preload("res://scenes/ui/game_over_ui.tscn").instantiate()
    add_child(game_over)

    var scoreboard_button = game_over.get_node_or_null("ScoreboardButton")
    assert_not_null(scoreboard_button, "Should have scoreboard button")

    game_over.queue_free()
```

---

### 3.3 Achievement System (成就系统)

```gdscript
# tests/unit/test_achievements.gd

func test_T5_3_1_achievement_manager_loads():
    var manager = AchievementManager.new()
    assert_not_null(manager, "AchievementManager should load")

func test_T5_3_2_has_check_achievement():
    var manager = AchievementManager.new()
    assert_true(manager.has_method("check_achievement"), "Should have check_achievement")

func test_T5_3_3_first_kill_unlocks():
    var manager = AchievementManager.new()
    manager.on_enemy_killed("Zombie")
    assert_true(manager.is_unlocked("first_kill"), "First kill achievement should unlock")

func test_T5_3_4_hundred_kills_unlocks():
    var manager = AchievementManager.new()
    for i in range(100):
        manager.on_enemy_killed("Zombie")
    assert_true(manager.is_unlocked("hundred_kills"), "100 kills achievement should unlock")

func test_T5_3_5_survive_5_minutes_unlocks():
    var manager = AchievementManager.new()
    manager.on_time_survived(300.0)
    assert_true(manager.is_unlocked("survive_5min"), "5 min survival should unlock")

func test_T5_3_6_achievement_gives_reward():
    var manager = AchievementManager.new()
    var reward = manager.get_achievement_reward("first_kill")
    assert_eq(reward.emeralds, 10, "First kill should give 10 emeralds")

func test_T5_3_7_achievement_emits_unlocked_signal():
    var manager = AchievementManager.new()
    var unlocked = false
    manager.achievement_unlocked.connect(func(_a): unlocked = true)
    manager.on_enemy_killed("Zombie")
    assert_true(unlocked, "Should emit unlocked signal")

func test_T5_3_8_achievements_persist():
    var manager = AchievementManager.new()
    manager.on_enemy_killed("Zombie")
    manager.save()

    var manager2 = AchievementManager.new()
    manager2.load()
    assert_true(manager2.is_unlocked("first_kill"), "Achievements should persist")

func test_T5_3_9_achievement_ui_shows():
    var ui = preload("res://scenes/ui/achievement_popup.tscn").instantiate()
    add_child(ui)
    ui.show_achievement("first_kill")
    assert_true(ui.visible, "Achievement popup should show")
    ui.queue_free()

func test_T5_3_10_enderman_hunter_achievement():
    var manager = AchievementManager.new()
    for i in range(50):
        manager.on_enemy_killed("Enderman")
    assert_true(manager.is_unlocked("enderman_hunter"), "Enderman hunter should unlock")

func test_T5_3_11_witch_slayer_achievement():
    var manager = AchievementManager.new()
    for i in range(30):
        manager.on_enemy_killed("Witch")
    assert_true(manager.is_unlocked("witch_slayer"), "Witch slayer should unlock")

func test_T5_3_12_poison_immune_achievement():
    var manager = AchievementManager.new()
    manager.on_kill_while_poisoned(10)
    assert_true(manager.is_unlocked("poison_immune"), "Poison immune should unlock")
```

---

### 3.4 Unlockable Characters (可解锁角色)

```gdscript
# tests/unit/test_characters.gd

func test_T5_4_1_steve_is_default():
    var char_manager = CharacterManager.new()
    assert_true(char_manager.is_unlocked("steve"), "Steve should be unlocked by default")

func test_T5_4_2_alex_unlock_condition():
    var char_manager = CharacterManager.new()
    assert_false(char_manager.is_unlocked("alex"), "Alex should be locked initially")
    char_manager.on_survival_time(900.0)  # 15分钟
    assert_true(char_manager.is_unlocked("alex"), "Alex should unlock after 15min")

func test_T5_4_3_alex_stats_correct():
    var char_manager = CharacterManager.new()
    var alex = char_manager.get_character_stats("alex")
    assert_eq(alex.hp, 90, "Alex HP should be 90")
    assert_eq(alex.speed_multiplier, 1.2, "Alex speed should be 120%")
    assert_eq(alex.pickup_range_multiplier, 1.5, "Alex pickup range should be 150%")

func test_T5_4_4_character_selection_works():
    var char_manager = CharacterManager.new()
    char_manager.select_character("steve")
    assert_eq(char_manager.selected_character, "steve", "Should select character")
```

---

### 3.5 Combo System (连击系统)

```gdscript
# tests/unit/test_combo.gd

var combo: ComboSystem

func before_each():
    combo = ComboSystem.new()
    add_child(combo)

func after_each():
    combo.queue_free()

func test_T5_5_1_combo_system_loads():
    assert_not_null(combo, "ComboSystem should load")

func test_T5_5_2_combo_increments_on_kill():
    combo.on_enemy_killed()
    assert_eq(combo.current_combo, 1, "Combo should be 1")
    combo.on_enemy_killed()
    assert_eq(combo.current_combo, 2, "Combo should be 2")

func test_T5_5_3_combo_resets_on_timeout():
    combo.on_enemy_killed()
    await get_tree().create_timer(4.0).timeout  # 超过3秒
    assert_eq(combo.current_combo, 0, "Combo should reset")

func test_T5_5_4_combo_resets_on_damage():
    combo.on_enemy_killed()
    combo.on_player_damaged()
    assert_eq(combo.current_combo, 0, "Combo should reset on damage")

func test_T5_5_5_combo_10_gives_bonus():
    for i in range(10):
        combo.on_enemy_killed()
    assert_eq(combo.get_xp_bonus(), 0.1, "10 combo should give 10% XP bonus")

func test_T5_5_6_combo_50_gives_bonus():
    for i in range(50):
        combo.on_enemy_killed()
    assert_eq(combo.get_xp_bonus(), 0.5, "50 combo should give 50% XP bonus")

func test_T5_5_7_combo_emits_milestone_signal():
    var milestone_reached = false
    combo.milestone_reached.connect(func(_m): milestone_reached = true)
    for i in range(10):
        combo.on_enemy_killed()
    assert_true(milestone_reached, "Should emit milestone signal at 10")

func test_T5_5_8_combo_display_updates():
    var hud = preload("res://scenes/ui/hud.tscn").instantiate()
    add_child(hud)

    combo.on_enemy_killed()
    hud.update_combo(combo.current_combo)

    var combo_label = hud.get_node("ComboLabel")
    assert_true(combo_label.text.contains("1"), "Should display combo count")

    hud.queue_free()
```

---

### 3.6 Weapon Evolution (武器进化)

```gdscript
# tests/unit/test_weapon_evolution.gd

func test_T5_6_1_bow_exists():
    var bow = preload("res://scenes/weapons/bow.tscn").instantiate()
    assert_not_null(bow, "Bow should exist")
    bow.queue_free()

func test_T5_6_2_bow_evolves_to_crossbow():
    var evo_manager = WeaponEvolutionManager.new()
    var can_evolve = evo_manager.can_evolve("bow", 5, {"sharpness": 5})
    assert_true(can_evolve, "Bow should be able to evolve")

func test_T5_6_3_crossbow_has_pierce():
    var crossbow = preload("res://scenes/weapons/crossbow.tscn").instantiate()
    assert_true(crossbow.can_pierce, "Crossbow should pierce")
    crossbow.queue_free()

func test_T5_6_4_evolution_increases_damage():
    var bow = preload("res://scenes/weapons/bow.tscn").instantiate()
    var bow_damage = bow.damage
    bow.queue_free()

    var crossbow = preload("res://scenes/weapons/crossbow.tscn").instantiate()
    assert_gt(crossbow.damage, bow_damage * 1.4, "Crossbow damage should be 50% higher")
    crossbow.queue_free()
```

---

### 3.7 Lucky Drop (幸运掉落)

```gdscript
# tests/unit/test_lucky_drop.gd

func test_T5_7_1_drop_system_loads():
    var drop = LuckyDropSystem.new()
    assert_not_null(drop, "LuckyDropSystem should load")

func test_T5_7_2_diamond_drop_exists():
    var drop = LuckyDropSystem.new()
    assert_true(drop.has_drop("diamond"), "Diamond drop should exist")

func test_T5_7_3_golden_apple_heals():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)
    player.health.current_health = 50

    var drop = LuckyDropSystem.new()
    drop.apply_drop("golden_apple", player)

    assert_eq(player.health.current_health, 100, "Golden apple should heal to full")
    player.queue_free()

func test_T5_7_4_experience_bottle_levels_up():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)
    var initial_level = player.level

    var drop = LuckyDropSystem.new()
    drop.apply_drop("experience_bottle", player)

    assert_eq(player.level, initial_level + 1, "Should gain 1 level")
    player.queue_free()

func test_T5_7_5_totem_prevents_death():
    var player = preload("res://scenes/player.tscn").instantiate()
    add_child(player)

    var drop = LuckyDropSystem.new()
    drop.apply_drop("totem", player)

    player.health.take_damage(200)  # 超过最大生命

    assert_gt(player.health.current_health, 0, "Totem should prevent death")
    player.queue_free()

func test_T5_7_6_drop_probability_correct():
    var drop = LuckyDropSystem.new()
    assert_approx_eq(drop.get_probability("diamond"), 0.005, 0.001, "Diamond should be 0.5%")

func test_T5_7_7_boss_always_drops():
    var drop = LuckyDropSystem.new()
    var dropped = drop.roll_drop(true)  # is_boss = true
    assert_not_null(dropped, "Boss should always drop something")

func test_T5_7_8_drop_visual_spawns():
    var drop = LuckyDropSystem.new()
    var pickup = drop.spawn_drop("diamond", Vector2(100, 100))
    assert_not_null(pickup, "Should spawn visual pickup")
    pickup.queue_free()
```

---

### 3.8 Screen Feedback (屏幕反馈)

```gdscript
# tests/unit/test_screen_feedback.gd

func test_T5_8_1_camera_shake_exists():
    var camera = preload("res://scenes/camera.tscn").instantiate()
    assert_true(camera.has_method("shake"), "Camera should have shake method")
    camera.queue_free()

func test_T5_8_2_hit_shake_works():
    var camera = preload("res://scenes/camera.tscn").instantiate()
    add_child(camera)
    var initial_offset = camera.offset
    camera.shake(5.0, 0.1)  # intensity, duration
    await get_tree().process_frame
    assert_ne(camera.offset, initial_offset, "Camera should shake")
    camera.queue_free()

func test_T5_8_3_damage_numbers_spawn():
    var feedback = ScreenFeedback.new()
    add_child(feedback)
    var number = feedback.spawn_damage_number(25, Vector2(100, 100), false)
    assert_not_null(number, "Damage number should spawn")
    feedback.queue_free()

func test_T5_8_4_crit_damage_is_yellow():
    var feedback = ScreenFeedback.new()
    add_child(feedback)
    var number = feedback.spawn_damage_number(50, Vector2(100, 100), true)
    assert_eq(number.modulate, Color.YELLOW, "Crit should be yellow")
    feedback.queue_free()

func test_T5_8_5_level_up_slowmo():
    var feedback = ScreenFeedback.new()
    feedback.trigger_level_up_effect()
    assert_lt(Engine.time_scale, 1.0, "Should slow down time")
    await get_tree().create_timer(0.5).timeout
    assert_eq(Engine.time_scale, 1.0, "Should return to normal")

func test_T5_8_6_screen_flash_on_damage():
    var feedback = ScreenFeedback.new()
    add_child(feedback)
    feedback.flash_screen(Color.RED, 0.1)
    var overlay = feedback.get_node("FlashOverlay")
    assert_gt(overlay.modulate.a, 0, "Should flash red")
    feedback.queue_free()
```

---

## 视觉测试用例

### 4.1 Poison Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.1.1 | 中毒爆炸效果 | AutoPlayer靠近女巫 | 绿色爆炸动画 | poison_explosion |
| VT5.1.2 | 玩家中毒颜色 | 被药水击中 | Steve变绿色 | player_poisoned |
| VT5.1.3 | 中毒粒子效果 | 中毒状态 | 绿色粒子环绕 | poison_particles |
| VT5.1.4 | HUD中毒图标 | 中毒状态 | 显示毒药瓶图标+倒计时 | hud_poison_icon |
| VT5.1.5 | 中毒解除效果 | 等待5秒 | 颜色恢复，图标消失 | poison_cured |

### 4.2 Day/Night Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.2.1 | 黎明效果 | 等待0-5s | 橙色色调 | dawn |
| VT5.2.2 | 早晨效果 | 等待5-20s | 明亮色调 | morning |
| VT5.2.3 | 正午效果 | 等待20-40s | 正常色调 | midday |
| VT5.2.4 | 下午效果 | 等待40-55s | 温暖色调 | afternoon |
| VT5.2.5 | 黄昏效果 | 等待55-60s | 橙红色调 | dusk |
| VT5.2.6 | 夜间效果 | 等待60-120s | 深蓝色调 | night |
| VT5.2.7 | 夜间敌人增强 | 夜间战斗 | 敌人更快更强 | night_combat |

### 4.3 Combo Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.3.1 | 连击计数显示 | 连续击杀 | HUD显示连击数 | combo_count |
| VT5.3.2 | 10连击效果 | 达到10连击 | "不错"文字+特效 | combo_10 |
| VT5.3.3 | 50连击效果 | 达到50连击 | "疯狂"文字+屏幕特效 | combo_50 |
| VT5.3.4 | 连击断裂 | 3秒无击杀 | 连击数归零 | combo_break |

### 4.4 Upgrade UI Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.4.1 | 升级界面显示 | 升级触发 | 显示3个选项 | upgrade_show |
| VT5.4.2 | 倒计时显示 | 升级界面 | 显示5秒倒计时 | upgrade_timer |
| VT5.4.3 | 选项高亮 | 自动选择 | 中间选项高亮 | upgrade_highlight |
| VT5.4.4 | 弓箭选项 | 升级界面 | 显示弓箭图标和描述 | upgrade_bow |

### 4.5 Game Over Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.5.1 | 游戏结束界面 | 玩家死亡 | 显示结束界面 | game_over |
| VT5.5.2 | 分数显示 | 游戏结束 | 显示总分 | score_display |
| VT5.5.3 | 排名显示 | 进入前10 | 显示排名 | rank_display |
| VT5.5.4 | 统计显示 | 游戏结束 | 显示击杀/时间/等级/波数 | stats_display |

### 4.6 Achievement Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.6.1 | 成就解锁弹窗 | 首次击杀 | 弹出成就提示 | achievement_popup |
| VT5.6.2 | 成就图标 | 解锁成就 | 显示成就图标 | achievement_icon |
| VT5.6.3 | 成就奖励 | 解锁成就 | 显示奖励数量 | achievement_reward |

### 4.7 Screen Feedback Visual Test

| ID | 测试名称 | 操作 | 预期结果 | 截图点 |
|----|----------|------|----------|--------|
| VT5.7.1 | 攻击命中震动 | 攻击敌人 | 轻微屏幕震动 | hit_shake |
| VT5.7.2 | 伤害数字 | 攻击敌人 | 白色数字弹出 | damage_number |
| VT5.7.3 | 暴击效果 | 暴击触发 | 黄色大字"CRIT!" | crit_effect |
| VT5.7.4 | 受伤红闪 | 玩家受伤 | 屏幕边缘红色闪烁 | damage_flash |
| VT5.7.5 | 升级慢动作 | 升级 | 短暂慢动作+金光 | level_up_effect |

---

## 视觉测试场景配置

### 5.1 测试场景列表

```
tests/visual/
├── visual_test_runner.tscn       # 主测试运行器
├── visual_test_runner.gd
├── test_poison_visuals.tscn      # 中毒视觉测试
├── test_poison_visuals.gd
├── test_day_night_cycle.tscn     # 日夜循环测试
├── test_day_night_cycle.gd
├── test_combo_visuals.tscn       # 连击视觉测试
├── test_combo_visuals.gd
├── test_upgrade_ui.tscn          # 升级界面测试
├── test_upgrade_ui.gd
├── test_game_over.tscn           # 游戏结束测试
├── test_game_over.gd
├── test_screen_feedback.tscn     # 屏幕反馈测试
├── test_screen_feedback.gd
└── auto_player_test.tscn         # 完整自动游戏测试
```

### 5.2 Poison Visual Test Scene

```gdscript
# tests/visual/test_poison_visuals.gd
extends Node2D

var auto_player: AutoPlayer
var screenshot: ScreenshotCapture
var debug_overlay: TestDebugOverlay

var test_stages = [
    {"time": 5.0, "action": "wait_for_witch", "screenshot": "waiting_for_witch"},
    {"time": 15.0, "action": "approach_witch", "screenshot": "approaching_witch"},
    {"time": 20.0, "action": "check_poison", "screenshot": "poison_applied"},
    {"time": 22.0, "action": "check_particles", "screenshot": "poison_particles"},
    {"time": 25.0, "action": "check_hud", "screenshot": "hud_poison_icon"},
    {"time": 30.0, "action": "wait_cure", "screenshot": "poison_cured"}
]

var current_stage: int = 0
var elapsed_time: float = 0.0

func _ready() -> void:
    screenshot = ScreenshotCapture.new()
    screenshot.test_name = "poison_visual"
    add_child(screenshot)

    auto_player = $AutoPlayer
    auto_player.strategy = AutoPlayer.Strategy.TRIGGER_POISON

    debug_overlay = $TestDebugOverlay
    debug_overlay.log_event("Poison visual test started")

func _process(delta: float) -> void:
    elapsed_time += delta

    if current_stage < test_stages.size():
        var stage = test_stages[current_stage]
        if elapsed_time >= stage.time:
            _execute_stage(stage)
            current_stage += 1
    else:
        _finish_test()

func _execute_stage(stage: Dictionary) -> void:
    debug_overlay.log_event("Stage: %s" % stage.action)
    screenshot.capture(stage.screenshot)

    match stage.action:
        "check_poison":
            var player = get_tree().get_first_node_in_group("player")
            var manager = player.get_node("StatusEffectManager")
            if manager.has_effect(StatusEffect.Type.POISON):
                debug_overlay.log_event("✓ Player is poisoned")
            else:
                debug_overlay.log_event("✗ Player NOT poisoned!")
        "check_particles":
            var player = get_tree().get_first_node_in_group("player")
            var particles = player.get_node_or_null("PoisonParticles")
            if particles and particles.emitting:
                debug_overlay.log_event("✓ Poison particles active")
            else:
                debug_overlay.log_event("✗ Poison particles NOT active!")
        "check_hud":
            var hud = get_tree().get_first_node_in_group("hud")
            var poison_icon = hud.get_node_or_null("StatusContainer/PoisonIcon")
            if poison_icon and poison_icon.visible:
                debug_overlay.log_event("✓ HUD poison icon visible")
            else:
                debug_overlay.log_event("✗ HUD poison icon NOT visible!")

func _finish_test() -> void:
    debug_overlay.log_event("Poison visual test completed")
    await get_tree().create_timer(2.0).timeout
    get_tree().quit()
```

### 5.3 Full Auto Test Scene

```gdscript
# tests/visual/auto_player_test.gd
extends Node2D

## 完整自动游戏测试
## 运行完整游戏流程，自动截图关键时刻

var auto_player: AutoPlayer
var screenshot: ScreenshotCapture
var debug_overlay: TestDebugOverlay
var game_stats: GameStats

var screenshot_triggers = {
    "first_kill": false,
    "level_2": false,
    "level_5": false,
    "wave_2": false,
    "wave_3": false,
    "combo_10": false,
    "night_time": false,
    "poison_applied": false,
    "low_health": false,
    "game_over": false
}

var last_kills: int = 0
var last_level: int = 1
var last_wave: int = 1

func _ready() -> void:
    screenshot = ScreenshotCapture.new()
    screenshot.test_name = "auto_game"
    add_child(screenshot)

    auto_player = AutoPlayer.new()
    auto_player.strategy = AutoPlayer.Strategy.SURVIVE
    add_child(auto_player)

    debug_overlay = preload("res://scenes/testing/test_debug_overlay.tscn").instantiate()
    add_child(debug_overlay)

    # 连接信号
    var game = get_tree().get_first_node_in_group("game")
    if game:
        game_stats = game.game_stats
        debug_overlay.game_stats = game_stats

        game.player.died.connect(_on_player_died)
        game.player.leveled_up.connect(_on_player_leveled_up)

        var status_manager = game.player.get_node_or_null("StatusEffectManager")
        if status_manager:
            status_manager.effect_applied.connect(_on_effect_applied)
            debug_overlay.status_manager = status_manager

func _process(_delta: float) -> void:
    if not game_stats:
        return

    _check_triggers()

func _check_triggers() -> void:
    # 首次击杀
    if game_stats.kills > 0 and not screenshot_triggers["first_kill"]:
        screenshot_triggers["first_kill"] = true
        screenshot.capture("first_kill")
        debug_overlay.log_event("First kill!")

    # 等级触发
    if game_stats.level >= 2 and not screenshot_triggers["level_2"]:
        screenshot_triggers["level_2"] = true
        screenshot.capture("level_2")
        debug_overlay.log_event("Reached level 2")

    if game_stats.level >= 5 and not screenshot_triggers["level_5"]:
        screenshot_triggers["level_5"] = true
        screenshot.capture("level_5")
        debug_overlay.log_event("Reached level 5")

    # 波数触发
    if game_stats.wave >= 2 and not screenshot_triggers["wave_2"]:
        screenshot_triggers["wave_2"] = true
        screenshot.capture("wave_2")
        debug_overlay.log_event("Wave 2 started")

    if game_stats.wave >= 3 and not screenshot_triggers["wave_3"]:
        screenshot_triggers["wave_3"] = true
        screenshot.capture("wave_3")
        debug_overlay.log_event("Wave 3 started")

    # 夜间
    var day_night = get_tree().get_first_node_in_group("day_night_cycle")
    if day_night and day_night.is_night and not screenshot_triggers["night_time"]:
        screenshot_triggers["night_time"] = true
        screenshot.capture("night_time")
        debug_overlay.log_event("Night time!")

    # 低血量
    var player = get_tree().get_first_node_in_group("player")
    if player and player.health:
        var hp_percent = float(player.health.current_health) / player.health.max_health
        if hp_percent < 0.3 and not screenshot_triggers["low_health"]:
            screenshot_triggers["low_health"] = true
            screenshot.capture("low_health")
            debug_overlay.log_event("Low health warning!")

func _on_effect_applied(effect: StatusEffect) -> void:
    if effect.type == StatusEffect.Type.POISON and not screenshot_triggers["poison_applied"]:
        screenshot_triggers["poison_applied"] = true
        screenshot.capture("poison_applied")
        debug_overlay.log_event("Poison applied!")

func _on_player_leveled_up(level: int) -> void:
    debug_overlay.log_event("Level up: %d" % level)
    screenshot.capture("level_%d" % level)

func _on_player_died() -> void:
    if not screenshot_triggers["game_over"]:
        screenshot_triggers["game_over"] = true
        screenshot.capture("game_over")
        debug_overlay.log_event("Game Over!")

        # 输出测试总结
        _print_test_summary()

        await get_tree().create_timer(3.0).timeout
        get_tree().quit()

func _print_test_summary() -> void:
    print("\n========== AUTO TEST SUMMARY ==========")
    print("Survival Time: %.1f seconds" % game_stats.survival_time)
    print("Kills: %d" % game_stats.kills)
    print("Level: %d" % game_stats.level)
    print("Wave: %d" % game_stats.wave)
    print("\nScreenshot Triggers:")
    for trigger in screenshot_triggers:
        var status = "✓" if screenshot_triggers[trigger] else "✗"
        print("  %s %s" % [status, trigger])
    print("========================================\n")
```

---

## 测试运行命令

### 6.1 单元测试

```bash
# 运行所有单元测试
godot --headless --script tests/test_runner.gd

# 运行特定测试文件
godot --headless --script tests/test_runner.gd -- --filter=status_effect

# 运行Phase 5测试
godot --headless --script tests/test_runner.gd -- --filter=T5
```

### 6.2 视觉测试

```bash
# 运行所有视觉测试
godot --path . tests/visual/visual_test_runner.tscn

# 运行特定视觉测试
godot --path . tests/visual/test_poison_visuals.tscn

# 2倍速运行
godot --path . tests/visual/visual_test_runner.tscn -- --speed=2
```

### 6.3 自动游戏测试

```bash
# 完整自动测试 (直到游戏结束)
godot --path . tests/visual/auto_player_test.tscn

# 测试模式启动主游戏
godot --path . scenes/main.tscn -- --test-mode

# 指定策略
godot --path . scenes/main.tscn -- --test-mode --strategy=aggressive
```

### 6.4 截图输出位置

```
user://test_screenshots/
├── poison_visual_2026-01-24_12-30-00_001_poison_applied.png
├── poison_visual_2026-01-24_12-30-05_002_poison_cured.png
├── auto_game_2026-01-24_12-35-00_001_first_kill.png
├── auto_game_2026-01-24_12-35-30_002_level_2.png
└── ...
```

---

## 测试用例总数

| 类别 | 单元测试 | 视觉测试 | 总计 |
|------|----------|----------|------|
| 5.0 Main Menu | 10 | 5 | 15 |
| 5.1 Poison System | 30 | 5 | 35 |
| 5.2 Scoreboard | 20 | 4 | 24 |
| 5.3 Achievement | 12 | 3 | 15 |
| 5.4 Characters | 4 | 2 | 6 |
| 5.5 Combo | 8 | 4 | 12 |
| 5.6 Weapon Evolution | 4 | 2 | 6 |
| 5.7 Lucky Drop | 8 | 3 | 11 |
| 5.8 Screen Feedback | 6 | 5 | 11 |
| **总计** | **102** | **33** | **135** |

---

## 附录：调试信息格式

### 测试日志输出

```
[TEST MODE] 2026-01-24 12:30:00
================================
Test: poison_visual_test
Stage: 3/6 (check_poison)
Time: 20.5s

Game State:
- Wave: 2
- Kills: 15
- Player HP: 78/100
- Player Level: 3
- Enemies: 23
- Status Effects: POISON (3.5s)

Event Log:
[20.5] ✓ Player is poisoned
[20.0] Stage: check_poison
[15.2] Poison applied by Witch
[10.0] Stage: approach_witch
[5.0] Stage: wait_for_witch
[0.0] Poison visual test started

Screenshot: poison_visual_003_check_poison.png
================================
```

### 测试结果JSON

```json
{
    "test_name": "poison_visual_test",
    "timestamp": "2026-01-24T12:30:00",
    "duration": 35.5,
    "passed": true,
    "screenshots": [
        "poison_visual_001_waiting_for_witch.png",
        "poison_visual_002_approaching_witch.png",
        "poison_visual_003_poison_applied.png",
        "poison_visual_004_poison_particles.png",
        "poison_visual_005_hud_poison_icon.png",
        "poison_visual_006_poison_cured.png"
    ],
    "validations": {
        "player_poisoned": true,
        "particles_active": true,
        "hud_icon_visible": true,
        "auto_cure_worked": true
    },
    "game_stats": {
        "survival_time": 35.5,
        "kills": 8,
        "level": 2,
        "wave": 1
    }
}
```
