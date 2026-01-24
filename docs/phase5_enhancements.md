# Phase 5: Game Enhancements (TDD Approach)

本阶段实现游戏增强功能：状态效果系统、技能增强、新机制等。

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

---

## 核心机制详解

### 武器系统

**当前武器 (Phase 1-4):**
| 武器 | 类型 | 获取方式 | 描述 |
|------|------|----------|------|
| 钻石剑 | 近战 | 初始装备 | 自动攻击最近敌人 |

**新武器 (Phase 5):**
| 武器 | 类型 | 获取方式 | 描述 |
|------|------|----------|------|
| 弓箭 | 远程 | 升级选择 | 自动射击最近敌人 |

**弓箭属性:**
| 等级 | 伤害 | 攻速 | 射程 |
|------|------|------|------|
| 1 | 8 | 1.0/s | 300px |
| 2 | 10 | 1.1/s | 320px |
| 3 | 12 | 1.2/s | 340px |
| 4 | 15 | 1.3/s | 360px |
| 5 | 18 | 1.5/s | 400px |

> 更多武器 (十字弓、三叉戟、火焰剑等) 见 [backlog.md](./backlog.md)

**多武器机制:**
```
┌─────────────────────────────────────────────────────┐
│  玩家最多可同时装备 3 个武器                           │
│  每个武器独立攻击，独立冷却                            │
├─────────────────────────────────────────────────────┤
│  武器槽位:                                           │
│  [槽位1: 钻石剑] [槽位2: 空] [槽位3: 空]              │
│                                                     │
│  Phase 5 可用武器:                                   │
│  - 钻石剑 (初始)                                     │
│  - 弓箭 (升级获得)                                   │
│                                                     │
│  获得弓箭方式:                                        │
│  - 升级时选择 "获得弓箭" 选项                          │
│                                                     │
│  (第3个槽位为未来武器预留)                             │
└─────────────────────────────────────────────────────┘
```

**武器升级:**
- 每个武器有独立等级 (1-5级)
- 升级时可选择升级已有武器或获得新武器
- 同一武器多次选择 = 升级该武器
- 5级武器 + 对应升级5级 = 武器进化

**武器攻击逻辑:**
```gdscript
# 所有武器同时工作，各自独立
weapons: Array[Weapon] = [sword, bow, trident]

func _process(delta):
    for weapon in weapons:
        weapon.update_cooldown(delta)
        if weapon.can_attack():
            var target = find_target(weapon.target_type)
            weapon.attack(target)
```

---

### 升级系统

**升级选项池:**
| 类别 | 选项 | 效果 | 最大等级 |
|------|------|------|----------|
| 武器升级 | 钻石剑 +1 | 伤害+20%, 范围+10% | 5 |
| 武器升级 | 弓箭 +1 | 伤害+15%, 攻速+10% | 5 |
| 新武器 | 获得弓箭 | 添加弓箭到槽位2 | 1 |
| 被动升级 | Sharpness | 所有伤害+10% | 5 |
| 被动升级 | Protection | 受伤-8% | 5 |
| 被动升级 | Swiftness | 移速+5% | 5 |
| 被动升级 | **Haste (急迫)** | **攻速+12%** | **5** |
| 被动升级 | Looting | XP获取+15% | 5 |
| 被动升级 | Knockback | 击退距离+20% | 5 |
| 被动升级 | Sweeping | 攻击范围+10% | 5 |

**Haste (急迫) 攻速升级详情:**
| 等级 | 攻速加成 | 冷却时间减少 |
|------|----------|--------------|
| 1 | +12% | 0.88x |
| 2 | +24% | 0.76x |
| 3 | +36% | 0.64x |
| 4 | +48% | 0.52x |
| 5 | +60% | 0.40x |

**升级选择规则:**
```
每次升级显示 3 个选项:
- 至少1个武器相关 (升级或新武器)
- 至少1个被动升级
- 第3个随机

如果武器槽已满(3个)，不再出现"新武器"选项
如果某升级已满级(5级)，不再出现该选项
```

---

### 角色系统

**角色切换:**
- 主菜单选择角色
- 游戏中不可切换
- 每个角色有不同初始属性和特殊能力

**角色属性 (Phase 5可用):**
```
┌────────────────────────────────────────────────┐
│ Steve (默认)                                    │
├────────────────────────────────────────────────┤
│ HP: 100  |  移速: 100%  |  伤害: 100%          │
│ 初始武器: 钻石剑                                │
│ 特殊能力: 无                                    │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ Alex (解锁条件: 存活15分钟)                      │
├────────────────────────────────────────────────┤
│ HP: 90   |  移速: 120%  |  伤害: 100%          │
│ 初始武器: 钻石剑                                │
│ 特殊能力: 拾取范围+50%                          │
└────────────────────────────────────────────────┘

(更多角色见 Backlog)
```

---

### 战斗系统

**伤害计算:**
```
最终伤害 = 基础伤害 × 武器等级加成 × 被动加成 × 连击加成 × 暴击加成

基础伤害: 武器的base_damage
武器等级加成: 1 + (weapon_level - 1) × 0.2
被动加成: 1 + sharpness_level × 0.1
连击加成: 1 + combo_bonus (0% ~ 200%)
暴击加成: 暴击时 ×2，否则 ×1
```

**暴击系统:**
- 基础暴击率: 5%
- 暴击伤害: 200%
- 可通过升级/装备提高暴击率

**受伤计算:**
```
最终受伤 = 敌人伤害 × (1 - 减伤率)

减伤率 = protection_level × 0.08
最大减伤: 40% (5级Protection)
```

---

### 敌人系统

**敌人属性 (Phase 5 调整):**
| 敌人 | HP | 伤害 | 速度 | 特殊能力 | XP |
|------|-----|------|------|----------|-----|
| Zombie | 30 | 10 | 40 | 无 | 5 |
| Skeleton | 25 | 8 | 50 | 远程射箭 | 8 |
| Spider | 20 | 8 | 80 | 跳跃攻击 | 6 |
| **Creeper** | **50** | **40** | **45** | **爆炸(范围120)** | **15** |
| **Enderman** | **60** | **20** | **90** | **受伤传送+愤怒** | **20** |
| Witch | 20 | 12 | 35 | 投掷毒药水 | 12 |

**Creeper 增强 (原: 35HP, 25dmg):**
- HP: 35 → **50** (+43%)
- 爆炸伤害: 25 → **40** (+60%)
- 爆炸范围: 80 → **120** (+50%)
- 引爆时间: 2s → **1.5s** (更快)
- 新增: 爆炸时屏幕震动
- 新增: 爆炸留下3秒毒雾区域 (每秒5伤害)

**Enderman 增强 (原: 40HP, 15dmg):**
- HP: 40 → **60** (+50%)
- 伤害: 15 → **20** (+33%)
- 速度: 70 → **90** (+29%)
- 传送冷却: 3s → **2s** (更频繁)
- 新增: **愤怒机制** - 被攻击后5秒内攻击力×1.5
- 新增: 传送后立即攻击 (无攻击冷却)
- 新增: 低于30% HP时每次传送恢复5 HP

**敌人生成规则:**
| 波数 | 新增敌人 | 生成间隔 | 最大数量 |
|------|----------|----------|----------|
| 1 | Zombie | 2.0s | 30 |
| 2 | +Skeleton | 1.85s | 35 |
| 3 | +Spider | 1.7s | 40 |
| 4 | +Creeper | 1.55s | 45 |
| 5 | +Enderman | 1.4s | 50 |
| 6 | +Witch | 1.25s | 55 |
| 7+ | 精英敌人 | 1.1s | 60 |
| 10 | Boss出现 | - | - |

**精英敌人 (7波后):**
- 有5%概率生成精英版本
- 精英敌人: HP×2, 伤害×1.5, 体型×1.3
- 金色边框标识
- 掉落更多XP

**Boss敌人:**
- 每10波出现一次
- 独立HP条显示在屏幕顶部
- 击败后必掉稀有物品

---

### 游戏流程

```
┌─────────────────────────────────────────────────────────────┐
│                        游戏启动                              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  主菜单                                                      │
│  [开始游戏] [选择角色] [排行榜] [成就] [设置]                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  角色选择 (如果点击选择角色)                                   │
│  显示所有角色，已解锁的可选择，未解锁的显示解锁条件             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  游戏开始                                                    │
│  - 加载选中角色属性                                          │
│  - 初始化武器                                                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  游戏循环                                                    │
│  击杀敌人 → 获得XP → 升级选择 → 变强 → 击杀更多                │
│      ↑                                               ↓       │
│      └───────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  游戏结束 (玩家死亡)                                          │
│  - 显示本局统计                                              │
│  - 计算并保存分数                                            │
│  - 检查成就解锁                                              │
│  - 检查角色解锁                                              │
│  [再来一局] [返回主菜单]                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 功能列表

### 5.0 Main Menu & Settings (主菜单与设置)

**描述**: 游戏启动后显示主菜单，提供各种入口和设置选项。

**主菜单布局:**
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│              MINECRAFT SURVIVORS                    │
│                                                     │
│              [  开始游戏  ]                          │
│              [  选择角色  ]                          │
│              [  排行榜    ]                          │
│              [  成就      ]                          │
│              [  设置      ]                          │
│                                                     │
│                          v1.0.0                     │
└─────────────────────────────────────────────────────┘
```

**设置选项:**
| 设置项 | 类型 | 默认值 | 描述 |
|--------|------|--------|------|
| 升级时暂停 | 开关 | 开 | 升级选择时是否暂停游戏 |
| 音效音量 | 滑块 | 80% | 0-100% |
| 音乐音量 | 滑块 | 60% | 0-100% |
| 屏幕震动 | 开关 | 开 | 是否启用屏幕震动效果 |
| 伤害数字 | 开关 | 开 | 是否显示伤害数字 |
| 语言 | 选择 | English | EN/日本語/中文 |

**设置存储:**
```gdscript
# user://settings.json
{
    "pause_on_upgrade": true,
    "sfx_volume": 0.8,
    "music_volume": 0.6,
    "screen_shake": true,
    "damage_numbers": true,
    "language": "en"
}
```

**测试用例**: T5.0.1 - T5.0.10 (10个)
- T5.0.1: MainMenu scene loads
- T5.0.2: MainMenu has start button
- T5.0.3: MainMenu has settings button
- T5.0.4: Settings panel opens/closes
- T5.0.5: Settings saves to file
- T5.0.6: Settings loads on startup
- T5.0.7: Pause on upgrade setting works
- T5.0.8: Volume settings work
- T5.0.9: Language setting changes text
- T5.0.10: Screen shake setting works

---

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
| auto_cure | true | 中毒会自动解除 |

**自动解毒机制**:
- 中毒效果在 `poison_duration` (5秒) 后自动解除
- 中毒期间 Steve 显示绿色闪烁效果
- 解毒后恢复正常颜色
- 可被新的中毒效果刷新持续时间

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

### 5.2 Scoreboard (排行榜)

**描述**: 记录玩家最高分数，显示排行榜。

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| max_entries | 10 | 最多保存10条记录 |
| storage | user://scores.json | 本地存储位置 |
| sort_by | score | 按分数排序 |

**分数计算**:
| 因素 | 分值 | 描述 |
|------|------|------|
| 击杀数 | kills × 10 | 每击杀1个敌人+10分 |
| 存活时间 | time × 1 | 每秒+1分 |
| 等级 | level × 50 | 每级+50分 |
| 波数 | wave × 100 | 每波+100分 |

**公式**: `score = kills × 10 + time + level × 50 + wave × 100`

**UI显示**:
| 位置 | 内容 |
|------|------|
| Game Over屏幕 | 当前分数 + 排名 |
| 主菜单 | "排行榜"按钮 |
| 排行榜界面 | Top 10列表 (排名、分数、日期) |

**实现步骤**:

#### Step 1: Score Calculator (分数计算器)
```gdscript
# scripts/systems/score_calculator.gd
class_name ScoreCalculator
extends RefCounted

const KILL_POINTS: int = 10
const TIME_POINTS: int = 1
const LEVEL_POINTS: int = 50
const WAVE_POINTS: int = 100

static func calculate(stats: GameStats) -> int:
    return stats.kills * KILL_POINTS + \
           int(stats.survival_time) * TIME_POINTS + \
           stats.level * LEVEL_POINTS + \
           stats.wave * WAVE_POINTS
```

**测试用例**:
- [ ] T5.2.1: ScoreCalculator script loads
- [ ] T5.2.2: ScoreCalculator has calculate method
- [ ] T5.2.3: Kill points = 10 per kill
- [ ] T5.2.4: Time points = 1 per second
- [ ] T5.2.5: Level points = 50 per level
- [ ] T5.2.6: Wave points = 100 per wave

#### Step 2: Score Storage (分数存储)
```gdscript
# scripts/systems/score_storage.gd
class_name ScoreStorage
extends Node

const SAVE_PATH = "user://scores.json"
const MAX_ENTRIES = 10

var scores: Array = []

func save_score(score: int, stats: Dictionary) -> int  # 返回排名
func load_scores() -> Array
func get_high_score() -> int
func is_high_score(score: int) -> bool
```

**测试用例**:
- [ ] T5.2.7: ScoreStorage script loads
- [ ] T5.2.8: ScoreStorage has save_score method
- [ ] T5.2.9: ScoreStorage has load_scores method
- [ ] T5.2.10: ScoreStorage limits to 10 entries
- [ ] T5.2.11: ScoreStorage sorts by score descending
- [ ] T5.2.12: ScoreStorage persists to file

#### Step 3: Scoreboard UI (排行榜界面)
```gdscript
# scripts/ui/scoreboard_ui.gd
class_name ScoreboardUI
extends CanvasLayer

func show_scoreboard() -> void
func hide_scoreboard() -> void
func highlight_rank(rank: int) -> void
```

**测试用例**:
- [ ] T5.2.13: ScoreboardUI script loads
- [ ] T5.2.14: ScoreboardUI scene loads
- [ ] T5.2.15: ScoreboardUI has show_scoreboard method
- [ ] T5.2.16: ScoreboardUI displays top 10 scores

#### Step 4: Integration (集成)

**测试用例**:
- [ ] T5.2.17: GameOverUI shows current score
- [ ] T5.2.18: GameOverUI shows rank if in top 10
- [ ] T5.2.19: Score saved on game over
- [ ] T5.2.20: Scoreboard accessible from game over

---

### 5.3 Achievement System (成就系统) ⭐ 上瘾核心

**描述**: 完成特定目标解锁成就，获得奖励和满足感。

**成就列表**:
| 成就 | 条件 | 奖励 |
|------|------|------|
| 🏆 初次击杀 | 击杀第一个敌人 | 10绿宝石 |
| 🏆 百人斩 | 单局击杀100敌人 | 50绿宝石 |
| 🏆 千人斩 | 单局击杀1000敌人 | 200绿宝石 |
| 🏆 存活5分钟 | 存活300秒 | 30绿宝石 |
| 🏆 存活10分钟 | 存活600秒 | 100绿宝石 |
| 🏆 存活20分钟 | 存活1200秒 | 300绿宝石 + 解锁Alex |
| 🏆 达到10级 | 单局达到10级 | 50绿宝石 |
| 🏆 达到20级 | 单局达到20级 | 150绿宝石 |
| 🏆 通过第5波 | 存活到第5波 | 40绿宝石 |
| 🏆 通过第10波 | 存活到第10波 | 200绿宝石 + 解锁新武器 |
| 🏆 末影猎人 | 击杀50个末影人 | 100绿宝石 |
| 🏆 女巫克星 | 击杀30个女巫 | 80绿宝石 |
| 🏆 爆炸专家 | 被苦力怕炸死5次 | 20绿宝石 (安慰奖) |
| 🏆 中毒免疫 | 中毒状态下击杀10敌人 | 60绿宝石 |
| 🏆 完美主义 | 不受伤存活60秒 | 150绿宝石 |

**测试用例**: T5.3.1 - T5.3.12 (12个)

---

### 5.4 Unlockable Characters (可解锁角色) ⭐ 上瘾核心

**描述**: 通过完成成就或达成条件解锁新角色，每个角色有独特属性。

**可用角色 (Phase 5):**
| 角色 | 解锁条件 | 特殊能力 |
|------|----------|----------|
| Steve | 默认 | 平衡型，无特殊能力 |
| Alex | 存活15分钟 | +20%移速，+50%拾取范围，-10%HP |

**测试用例**: T5.4.1 - T5.4.4 (4个)

---

### 5.5 Combo System (连击系统) ⭐ 上瘾核心

**描述**: 短时间内连续击杀敌人获得连击数，连击越高奖励越多。

**机制**:
| 连击数 | 名称 | XP加成 | 绿宝石加成 |
|--------|------|--------|----------|
| 10+ | 不错 | +10% | +5% |
| 25+ | 很棒 | +25% | +15% |
| 50+ | 疯狂 | +50% | +30% |
| 100+ | 无敌 | +100% | +50% |
| 200+ | 神级 | +200% | +100% |

**规则**:
- 击杀后3秒内再次击杀维持连击
- 超时或受伤重置连击
- 连击数显示在屏幕中央
- 达到里程碑时屏幕闪光+音效

**测试用例**: T5.5.1 - T5.5.8 (8个)

---

### 5.6 Weapon Evolution (武器进化) ⭐ 上瘾核心

**描述**: 武器满级+对应被动满级时自动进化成更强的武器。

**Phase 5 可用进化:**
| 基础武器 | + 被动 | = 进化武器 | 效果 |
|----------|--------|------------|------|
| 弓箭 Lv5 | Sharpness V | 十字弓 | 箭矢穿透敌人，伤害+50% |

**进化条件**:
- 武器等级达到5级
- 对应被动升级也达到5级
- 自动进化，无需选择
- 进化后武器继承原等级加成

> 更多武器进化 (火焰剑、横扫剑等) 见 [backlog.md](./backlog.md)

**测试用例**: T5.6.1 - T5.6.4 (4个)

---

### 5.7 Lucky Drop (幸运掉落) ⭐ 上瘾核心

**描述**: 敌人有小概率掉落稀有道具，增加随机惊喜感。

**掉落物**:
| 物品 | 概率 | 效果 |
|------|------|------|
| 💎 钻石 | 0.5% | +50绿宝石 |
| 🍎 金苹果 | 1% | 恢复50%生命 |
| ⭐ 经验瓶 | 2% | 立即获得1级 |
| 🧪 力量药水 | 1.5% | 10秒内伤害翻倍 |
| 👟 速度药水 | 2% | 10秒内移速翻倍 |
| 🛡️ 不死图腾 | 0.1% | 下次死亡时复活 |
| 📦 宝箱 | 0.3% | 随机获得3个升级 |

**Boss掉落**:
- Boss敌人100%掉落稀有物品
- 稀有度更高的物品

**测试用例**: T5.7.1 - T5.7.8 (8个)

---

### 5.8 Screen Shake & Feedback (屏幕震动与反馈) ⭐ 上瘾核心

**描述**: 增强打击感，让玩家感受到每次攻击的力量。

**视觉反馈**:
| 事件 | 效果 |
|------|------|
| 攻击命中 | 轻微屏幕震动 + 白闪 |
| 暴击 | 中等震动 + 黄色伤害数字 |
| 击杀 | 敌人爆炸粒子 + 满足音效 |
| 连击里程碑 | 屏幕边缘光效 + 文字提示 |
| 升级 | 全屏金光 + 慢动作0.2秒 |
| 受伤 | 屏幕红闪 + 震动 |
| Boss出现 | 强烈震动 + 警告音效 |

**伤害数字**:
- 普通伤害: 白色小字
- 暴击: 黄色大字 + "CRIT!"
- 连击加成: 绿色 + "+X%"
- 中毒伤害: 紫色

**测试用例**: T5.8.1 - T5.8.6 (6个)

---

### 5.9 Antidote/Cure (解毒机制) [可选]

**描述**: 玩家可以通过某些方式解除中毒效果。

**可能的实现**:
| 方式 | 描述 |
|------|------|
| 牛奶桶 | 收集牛奶桶道具解除所有负面效果 |
| 金苹果 | 收集金苹果获得短暂免疫 |
| 升级选项 | "抗性"升级减少中毒伤害/时间 |

---

---

> **待定功能**: 查看 [backlog.md](./backlog.md) 了解更多角色、每日挑战、Boss等低优先级功能。

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

共 **98** 个测试用例:

### 5.0 Main Menu & Settings (10个)
- T5.0.1 - T5.0.10: 主菜单界面与设置功能

### 5.1 Poison System (26个)
- Status Effect System: T5.1.1 - T5.1.5 (5个)
- Status Effect Manager: T5.1.6 - T5.1.11 (6个)
- Player Integration: T5.1.12 - T5.1.14 (3个)
- Potion Enhancement: T5.1.15 - T5.1.19 (5个)
- Visual Effects: T5.1.20 - T5.1.23 (4个)
- HUD Status: T5.1.24 - T5.1.26 (3个)

### 5.2 Scoreboard (20个)
- Score Calculator: T5.2.1 - T5.2.6 (6个)
- Score Storage: T5.2.7 - T5.2.12 (6个)
- Scoreboard UI: T5.2.13 - T5.2.16 (4个)
- Integration: T5.2.17 - T5.2.20 (4个)

### 5.3 Achievement System (12个)
- T5.3.1 - T5.3.12: 成就解锁与奖励

### 5.4 Unlockable Characters (4个)
- T5.4.1 - T5.4.4: Steve和Alex角色

### 5.5 Combo System (8个)
- T5.5.1 - T5.5.8: 连击计数与奖励加成

### 5.6 Weapon Evolution (4个)
- T5.6.1 - T5.6.4: 弓箭→十字弓进化

### 5.7 Lucky Drop (8个)
- T5.7.1 - T5.7.8: 稀有掉落物与概率

### 5.8 Screen Feedback (6个)
- T5.8.1 - T5.8.6: 屏幕震动与视觉反馈

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
