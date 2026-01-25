# Feature Design: Night Mechanics, Enderman Dodge & Poison Hearts

本文档详细描述三个新功能的设计方案。

---

## Feature 1: 夜间刷怪机制 + 火把系统

### 1.1 需求概述
- 夜晚时刷怪**频率**和**数量**翻倍
- 玩家可以购买**火把**来照亮夜晚（减轻夜间debuff）

### 1.2 现有系统分析

**Day/Night Cycle (`scripts/systems/day_night_cycle.gd`)**
- 白天60秒 + 夜晚60秒循环
- 信号: `night_started()`, `day_started()`, `time_changed()`
- `is_night()` 方法返回当前是否为夜晚

**Wave Manager (`scripts/systems/wave_manager.gd`)**
- 已有 `night_multiplier: 2.0` 变量（数量翻倍逻辑已存在）
- 但需要连接 `day_night_cycle` 引用才能生效

**Spawner (`scripts/spawner.gd`)**
- 控制刷怪频率（`spawn_interval`）
- 目前无夜间逻辑

### 1.3 详细设计

#### 1.3.1 夜间刷怪翻倍

**修改文件:**
- `scripts/spawner.gd`
- `scripts/game.gd`

**Spawner 新增属性:**
```gdscript
@export var night_spawn_multiplier: float = 0.5  # 夜间间隔减半 = 频率翻倍
var day_night_cycle: Node = null
var _base_spawn_interval: float = 2.0
var _is_night: bool = false
```

**Spawner 新增方法:**
```gdscript
func _on_night_started() -> void:
    _is_night = true
    _apply_night_modifier()

func _on_day_started() -> void:
    _is_night = false
    _remove_night_modifier()

func _apply_night_modifier() -> void:
    var night_interval = _base_spawn_interval * night_spawn_multiplier
    set_spawn_rate(night_interval)

func _remove_night_modifier() -> void:
    set_spawn_rate(_base_spawn_interval)
```

**Game.gd 连接:**
```gdscript
func _ready():
    # 连接 day_night_cycle 到 wave_manager（激活已有数量翻倍）
    wave_manager.day_night_cycle = day_night_cycle

    # 连接 day_night_cycle 到 spawner（新增频率翻倍）
    spawner.day_night_cycle = day_night_cycle
    day_night_cycle.night_started.connect(spawner._on_night_started)
    day_night_cycle.day_started.connect(spawner._on_day_started)
```

#### 1.3.2 火把系统

**设计方案: 火把作为可购买升级**

**新增资源:**
- `assets/ui/upgrade_torch.svg` - 火把图标
- `assets/effects/torch_light.svg` - 火把光效

**Upgrade定义 (upgrade_manager.gd):**
```gdscript
const UPGRADE_DEFS = {
    # ... existing upgrades ...
    "torch": {
        "name": "UPGRADE_TORCH",
        "description": "UPGRADE_TORCH_DESC",
        "icon": "res://assets/ui/upgrade_torch.svg",
        "max_level": 3,
        "type": "torch"
    }
}
```

**火把效果等级:**
| 等级 | 效果 |
|------|------|
| 1 | 夜间亮度+25%，刷怪频率减少25% |
| 2 | 夜间亮度+50%，刷怪频率减少50% |
| 3 | 夜间亮度+75%，刷怪频率恢复正常 |

**实现逻辑:**

**新增: TorchManager (`scripts/systems/torch_manager.gd`)**
```gdscript
class_name TorchManager
extends Node

signal torch_level_changed(level: int)

var torch_level: int = 0
var day_night_cycle: Node = null

# 火把对夜间效果的减免比例
const TORCH_REDUCTION = [0.0, 0.25, 0.5, 0.75]  # 等级0-3

func get_night_brightness_bonus() -> float:
    return TORCH_REDUCTION[torch_level]

func get_spawn_rate_reduction() -> float:
    # 火把等级3时，夜间刷怪频率恢复正常
    return TORCH_REDUCTION[torch_level]

func upgrade_torch() -> void:
    if torch_level < 3:
        torch_level += 1
        torch_level_changed.emit(torch_level)
```

**DayNightCycle 修改:**
```gdscript
var torch_manager: Node = null

func _get_night_tint() -> Color:
    var base_tint = Color(0.2, 0.2, 0.4)  # 原夜间颜色
    if torch_manager:
        var brightness_bonus = torch_manager.get_night_brightness_bonus()
        # 插值到白色（更亮）
        return base_tint.lerp(Color.WHITE, brightness_bonus)
    return base_tint
```

**Spawner 修改:**
```gdscript
var torch_manager: Node = null

func _apply_night_modifier() -> void:
    var base_night_interval = _base_spawn_interval * night_spawn_multiplier
    if torch_manager:
        var reduction = torch_manager.get_spawn_rate_reduction()
        # 火把减少夜间加速效果
        var adjusted_multiplier = lerp(night_spawn_multiplier, 1.0, reduction)
        base_night_interval = _base_spawn_interval * adjusted_multiplier
    set_spawn_rate(base_night_interval)
```

**本地化键 (translations.csv):**
```csv
UPGRADE_TORCH,Torch,松明,火把
UPGRADE_TORCH_DESC,Illuminate the night,夜を照らす,照亮夜晚
```

---

## Feature 2: Enderman 躲避弓箭

### 2.1 需求概述
- Enderman 可以感知接近的弓箭
- 在弓箭命中前主动传送躲避

### 2.2 现有系统分析

**Enderman (`scripts/enemies/enderman.gd`)**
- 当前: 只在受到伤害后传送（被动）
- `teleport_cooldown: 3.0` 秒冷却
- `teleport_range: 200` 像素传送距离

**箭矢 (`scripts/projectiles/player_arrow.gd`)**
- 速度: 400 像素/秒（弓）/ 600 像素/秒（弩）
- 碰撞层: 8（玩家投射物）
- Enderman 当前碰撞掩码不包含此层

### 2.3 详细设计

**设计思路:**
1. 给 Enderman 添加"箭矢感知区域"（Area2D）
2. 检测进入感知范围的箭矢
3. 预判箭矢轨迹，判断是否会命中
4. 在命中前触发传送

**修改文件:**
- `scripts/enemies/enderman.gd`
- `scenes/enemies/enderman.tscn`

**新增场景结构:**
```
Enderman (CharacterBody2D)
├── ... (existing nodes)
├── ArrowDetectionArea (Area2D)  # 新增
│   └── DetectionShape (CircleShape2D, radius=120)
```

**ArrowDetectionArea 配置:**
```gdscript
collision_layer = 0  # 不被检测
collision_mask = 8   # 检测玩家投射物（PlayerArrow层）
```

**Enderman 新增属性:**
```gdscript
@export var arrow_dodge_enabled: bool = true
@export var arrow_detection_radius: float = 120.0  # 感知范围
@export var dodge_reaction_time: float = 0.15      # 反应时间（秒）
@export var dodge_chance: float = 0.8              # 躲避成功率 80%
```

**Enderman 新增方法:**
```gdscript
var _arrow_detection_area: Area2D = null

func _ready():
    # ... existing code ...
    _setup_arrow_detection()

func _setup_arrow_detection() -> void:
    _arrow_detection_area = $ArrowDetectionArea
    if _arrow_detection_area:
        _arrow_detection_area.area_entered.connect(_on_arrow_entered)

func _on_arrow_entered(area: Area2D) -> void:
    if not arrow_dodge_enabled or not can_teleport:
        return

    # 检查是否为玩家箭矢
    if not area.is_in_group("player_projectiles"):
        return

    # 随机判定是否躲避
    if randf() > dodge_chance:
        return

    # 预判箭矢是否会命中
    if _will_arrow_hit(area):
        _dodge_teleport(area)

func _will_arrow_hit(arrow: Area2D) -> bool:
    # 获取箭矢方向和速度
    var arrow_pos = arrow.global_position
    var arrow_velocity = arrow.direction * arrow.speed if arrow.has_method("get_velocity") else arrow.get("velocity")

    if arrow_velocity == null or arrow_velocity == Vector2.ZERO:
        # 如果无法获取速度，根据位置判断
        arrow_velocity = (global_position - arrow_pos).normalized() * 400

    # 预测箭矢轨迹
    var my_radius = 28.0  # Enderman碰撞半径
    var to_me = global_position - arrow_pos
    var arrow_dir = arrow_velocity.normalized()

    # 点到直线距离
    var perpendicular_dist = abs(to_me.cross(arrow_dir))

    # 如果箭矢轨迹会穿过 Enderman 范围内
    return perpendicular_dist < my_radius + 16  # 16 = 箭矢半宽

func _dodge_teleport(arrow: Area2D) -> void:
    # 计算躲避方向（垂直于箭矢方向）
    var arrow_dir = Vector2.ZERO
    if arrow.has_method("get_direction"):
        arrow_dir = arrow.get_direction()
    else:
        arrow_dir = (global_position - arrow.global_position).normalized()

    # 垂直方向传送
    var dodge_dir = arrow_dir.rotated(PI / 2)
    if randf() > 0.5:
        dodge_dir = -dodge_dir

    # 传送到躲避位置
    var dodge_distance = randf_range(80, 150)
    var new_pos = global_position + dodge_dir * dodge_distance

    # 执行传送
    _teleport_to(new_pos)
```

**PlayerArrow 新增组:**
```gdscript
func _ready():
    add_to_group("player_projectiles")
```

**CrossbowBolt 新增组:**
```gdscript
func _ready():
    add_to_group("player_projectiles")
```

**平衡性考虑:**
- 躲避成功率 80%（不是100%，保持可击杀性）
- 传送冷却 3 秒（躲避后也消耗冷却）
- 感知范围 120 像素（给玩家瞄准调整的机会）
- 弩箭速度快(600)，更难躲避

---

## Feature 3: 中毒状态 HUD 红心变绿

### 3.1 需求概述
- 当玩家处于中毒状态时，HUD 上的红心变为绿色
- 中毒结束后恢复红色

### 3.2 现有系统分析

**HUD (`scripts/ui/hud.gd`)**
- `heart_nodes: Array` 存储所有心形图标
- `update_health()` 方法更新心形显示
- 使用纹理切换（full/half/empty）

**StatusEffectManager**
- `effect_applied` 信号 - 效果应用时触发
- `effect_removed` 信号 - 效果移除时触发
- `has_effect(type)` 方法 - 检查是否有特定效果

**Player**
- 已连接 StatusEffectManager 信号
- `_on_status_effect_applied/removed` 处理视觉效果

### 3.3 详细设计

**修改文件:**
- `scripts/ui/hud.gd`
- `scripts/game.gd`

**HUD 新增属性:**
```gdscript
var _is_poisoned: bool = false
const POISON_HEART_COLOR = Color(0.3, 0.8, 0.3)  # 绿色
const NORMAL_HEART_COLOR = Color.WHITE           # 正常（无调色）
```

**HUD 新增方法:**
```gdscript
func set_poisoned(poisoned: bool) -> void:
    if _is_poisoned == poisoned:
        return

    _is_poisoned = poisoned
    _update_heart_colors()

func _update_heart_colors() -> void:
    var target_color = POISON_HEART_COLOR if _is_poisoned else NORMAL_HEART_COLOR

    for heart in heart_nodes:
        # 使用 tween 平滑过渡颜色
        var tween = create_tween()
        tween.tween_property(heart, "modulate", target_color, 0.3)
```

**Game.gd 修改:**
```gdscript
func _ready():
    # ... existing code ...

    # 连接玩家状态效果信号到 HUD
    if player and hud:
        var status_manager = player.get_node_or_null("StatusEffectManager")
        if status_manager:
            status_manager.effect_applied.connect(_on_player_effect_applied)
            status_manager.effect_removed.connect(_on_player_effect_removed)

func _on_player_effect_applied(effect) -> void:
    var StatusEffectClass = load("res://scripts/components/status_effect.gd")
    if effect.type == StatusEffectClass.Type.POISON:
        if hud:
            hud.set_poisoned(true)

func _on_player_effect_removed(effect) -> void:
    var StatusEffectClass = load("res://scripts/components/status_effect.gd")
    if effect.type == StatusEffectClass.Type.POISON:
        if hud:
            hud.set_poisoned(false)
```

**可选增强: 脉动效果**
```gdscript
func _update_heart_colors() -> void:
    var target_color = POISON_HEART_COLOR if _is_poisoned else NORMAL_HEART_COLOR

    for heart in heart_nodes:
        var tween = create_tween()
        tween.tween_property(heart, "modulate", target_color, 0.3)

    if _is_poisoned:
        _start_poison_pulse()
    else:
        _stop_poison_pulse()

var _poison_pulse_tween: Tween = null

func _start_poison_pulse() -> void:
    if _poison_pulse_tween:
        _poison_pulse_tween.kill()

    _poison_pulse_tween = create_tween()
    _poison_pulse_tween.set_loops()  # 无限循环

    var bright_green = Color(0.4, 1.0, 0.4)
    var dark_green = Color(0.2, 0.6, 0.2)

    for heart in heart_nodes:
        _poison_pulse_tween.tween_property(heart, "modulate", bright_green, 0.5)
        _poison_pulse_tween.tween_property(heart, "modulate", dark_green, 0.5)

func _stop_poison_pulse() -> void:
    if _poison_pulse_tween:
        _poison_pulse_tween.kill()
        _poison_pulse_tween = null
```

---

## Implementation Order (实施顺序)

### Phase 1: 基础夜间机制
1. 连接 `day_night_cycle` 到 `wave_manager`（激活已有数量翻倍）
2. 修改 `spawner.gd` 添加夜间频率翻倍
3. 在 `game.gd` 中连接信号

### Phase 2: 火把系统
1. 创建 `TorchManager` 系统
2. 添加火把升级定义
3. 创建火把图标资源
4. 修改 `DayNightCycle` 支持火把亮度
5. 修改 `Spawner` 支持火把减速
6. 添加本地化文本

### Phase 3: Enderman 躲箭
1. 给 `PlayerArrow` 和 `CrossbowBolt` 添加 group
2. 修改 `enderman.tscn` 添加感知区域
3. 修改 `enderman.gd` 添加躲避逻辑

### Phase 4: 中毒绿心
1. 修改 `hud.gd` 添加心形变色逻辑
2. 修改 `game.gd` 连接状态效果信号

---

## Testing Checklist (测试清单)

### 夜间机制
- [ ] 夜晚刷怪数量是白天的2倍
- [ ] 夜晚刷怪频率是白天的2倍
- [ ] 白天恢复正常刷怪

### 火把系统
- [ ] 火把升级正常出现在选项中
- [ ] 等级1: 夜间稍微变亮，刷怪减少25%
- [ ] 等级2: 夜间更亮，刷怪减少50%
- [ ] 等级3: 夜间接近白天亮度，刷怪恢复正常
- [ ] 本地化文本正确显示

### Enderman 躲箭
- [ ] Enderman 能感知接近的箭矢
- [ ] 躲避成功率约80%
- [ ] 躲避后消耗传送冷却
- [ ] 弩箭更难躲避（速度快）
- [ ] 近距离射击更难躲避

### 中毒绿心
- [ ] 中毒时心形变绿
- [ ] 颜色过渡平滑
- [ ] 中毒结束后恢复红色
- [ ] 多次中毒不会导致显示异常
