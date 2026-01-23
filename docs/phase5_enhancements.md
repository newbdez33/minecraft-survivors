# Phase 5: Game Enhancements (TDD Approach)

本阶段实现游戏增强功能：状态效果系统、技能增强、新机制等。

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

---

## 功能列表

### 5.1 Poison Status Effect (中毒状态效果)

**描述**: 女巫投掷的药水瓶爆炸后，会在大范围内造成中毒效果，使Steve持续掉血。

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| splash_radius | 100.0 | 爆炸范围 (原60→100) |
| poison_duration | 5.0 | 中毒持续时间 (秒) |
| poison_damage | 2 | 每次中毒伤害 |
| poison_tick_interval | 0.5 | 中毒伤害间隔 (秒) |
| poison_total_damage | 20 | 总中毒伤害 (5s × 2dmg/0.5s) |

**视觉效果**:
| 效果 | 描述 |
|------|------|
| 爆炸特效 | 绿色毒雾扩散动画 |
| 中毒指示 | Steve变绿色/闪烁绿色 |
| HUD显示 | 中毒状态图标 + 倒计时 |
| 粒子效果 | 绿色毒雾粒子围绕Steve |

**实现步骤**:

#### Step 1: Status Effect System (状态效果系统)
创建通用状态效果组件，支持多种状态效果。

```gdscript
# scripts/components/status_effect.gd
class_name StatusEffect
extends RefCounted

enum Type { POISON, BURN, SLOW, STUN }

var type: Type
var duration: float
var tick_interval: float
var damage_per_tick: int
var remaining_time: float
var tick_timer: float
```

**测试用例**:
- [ ] T5.1.1: StatusEffect script loads
- [ ] T5.1.2: StatusEffect has Type enum with POISON
- [ ] T5.1.3: StatusEffect has duration property
- [ ] T5.1.4: StatusEffect has tick_interval property
- [ ] T5.1.5: StatusEffect has damage_per_tick property

#### Step 2: Status Effect Manager (状态效果管理器)
管理玩家身上的所有状态效果。

```gdscript
# scripts/components/status_effect_manager.gd
class_name StatusEffectManager
extends Node

signal effect_applied(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)
signal effect_tick(effect: StatusEffect, damage: int)

var active_effects: Array[StatusEffect] = []

func apply_effect(effect: StatusEffect) -> void
func remove_effect(effect: StatusEffect) -> void
func has_effect(type: StatusEffect.Type) -> bool
func clear_all_effects() -> void
```

**测试用例**:
- [ ] T5.1.6: StatusEffectManager script loads
- [ ] T5.1.7: StatusEffectManager has apply_effect method
- [ ] T5.1.8: StatusEffectManager has remove_effect method
- [ ] T5.1.9: StatusEffectManager has has_effect method
- [ ] T5.1.10: StatusEffectManager emits effect_applied signal
- [ ] T5.1.11: StatusEffectManager emits effect_tick signal

#### Step 3: Update Player (更新玩家)
添加状态效果管理器到玩家。

**测试用例**:
- [ ] T5.1.12: Player has StatusEffectManager child
- [ ] T5.1.13: Player takes damage from poison tick
- [ ] T5.1.14: Player shows poison visual effect when poisoned

#### Step 4: Update Potion (更新药水)
增强药水的爆炸范围和添加中毒效果。

```gdscript
# 更新 scripts/projectiles/potion.gd
@export var splash_radius: float = 100.0  # 原60
@export var applies_poison: bool = true
@export var poison_duration: float = 5.0
@export var poison_damage_per_tick: int = 2
@export var poison_tick_interval: float = 0.5

func explode() -> void:
    # 扩大爆炸范围
    # 对范围内的玩家施加中毒效果
```

**测试用例**:
- [ ] T5.1.15: Potion splash_radius is 100
- [ ] T5.1.16: Potion has applies_poison property
- [ ] T5.1.17: Potion has poison_duration property
- [ ] T5.1.18: Potion applies poison effect on hit
- [ ] T5.1.19: Poison effect deals damage over time

#### Step 5: Poison Visual Effects (中毒视觉效果)

**需要的资源**:
| 资源 | 文件 | 描述 |
|------|------|------|
| 毒雾爆炸 | poison_explosion.svg | 绿色爆炸特效 |
| 中毒状态图标 | status_poison.svg | HUD中毒图标 |
| 毒雾粒子 | poison_particle.svg | 围绕玩家的粒子 |

**测试用例**:
- [ ] T5.1.20: poison_explosion.svg asset exists
- [ ] T5.1.21: status_poison.svg asset exists
- [ ] T5.1.22: Player shows green tint when poisoned
- [ ] T5.1.23: HUD shows poison status icon

#### Step 6: HUD Status Display (HUD状态显示)
在HUD上显示当前状态效果。

**测试用例**:
- [ ] T5.1.24: HUD has status_container node
- [ ] T5.1.25: HUD shows poison icon when player is poisoned
- [ ] T5.1.26: HUD shows poison remaining time

---

### 5.2 Antidote/Cure (解毒机制) [可选]

**描述**: 玩家可以通过某些方式解除中毒效果。

**可能的实现**:
| 方式 | 描述 |
|------|------|
| 牛奶桶 | 收集牛奶桶道具解除所有负面效果 |
| 金苹果 | 收集金苹果获得短暂免疫 |
| 升级选项 | "抗性"升级减少中毒伤害/时间 |

---

## 节点结构变更

### Player 新结构
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── DiamondSword (Area2D)
├── StatusEffectManager (Node)  # 新增
│   └── PoisonEffect (Timer)    # 动态创建
└── PoisonVisual (GPUParticles2D)  # 新增
```

### Potion 新结构
```
Potion (Area2D)
├── Sprite2D
├── CollisionShape2D
├── PoisonArea (Area2D)  # 新增，用于中毒范围
│   └── CollisionShape2D (圆形，radius=100)
└── ExplosionEffect (GPUParticles2D)  # 新增
```

---

## 信号流程

```
Witch.throw_potion()
  → Potion spawned
  → Potion hits ground/player
  → Potion.explode()
    → Check players in splash_radius
    → Apply poison effect to player
      → StatusEffectManager.apply_effect(poison)
        → effect_applied signal
        → Start poison tick timer
          → Every 0.5s: effect_tick signal
            → Player.take_damage(2)
        → After 5s: effect_removed signal
```

---

## 实现优先级

1. **高优先级**: Status Effect System + Poison基础功能
2. **中优先级**: 视觉效果 (绿色闪烁、粒子)
3. **低优先级**: HUD状态显示、解毒机制

---

## 测试用例汇总

共 26 个测试用例:
- Status Effect System: T5.1.1 - T5.1.5 (5个)
- Status Effect Manager: T5.1.6 - T5.1.11 (6个)
- Player Integration: T5.1.12 - T5.1.14 (3个)
- Potion Enhancement: T5.1.15 - T5.1.19 (5个)
- Visual Effects: T5.1.20 - T5.1.23 (4个)
- HUD Status: T5.1.24 - T5.1.26 (3个)

---

## 参考

### Minecraft 中毒效果
- 持续时间: 通常 0:33 到 1:30
- 伤害: 每1.25秒1点伤害
- 最低血量: 不会致死 (最低保留半颗心)

### 我们的实现
- 持续时间: 5秒 (游戏节奏更快)
- 伤害: 每0.5秒2点伤害
- 可以致死 (增加紧张感)
