# Upgrade System Design Document

本文档详细说明 Minecraft Survivors 的升级/附魔系统。

---

## 概述

玩家通过击杀敌人获得经验球 (XP Orbs)，收集足够经验后升级。每次升级时，游戏暂停并显示 3 个随机附魔供玩家选择。

### 核心机制

```
击杀敌人 → 掉落 XP 球 → 收集 XP → 升级 → 选择附魔 → 变强
```

---

## 经验系统

### XP 获取

| 敌人 | XP 值 |
|------|-------|
| Zombie (僵尸) | 5 |
| Spider (蜘蛛) | 6 |
| Skeleton (骷髅) | 8 |
| Creeper (苦力怕) | 10 |

### 升级公式

```
所需 XP = 基础值 × (倍率 ^ (等级 - 1))

基础值 = 10
倍率 = 1.5
```

| 等级 | 所需 XP | 累计 XP |
|------|---------|---------|
| 1 → 2 | 10 | 10 |
| 2 → 3 | 15 | 25 |
| 3 → 4 | 22 | 47 |
| 4 → 5 | 34 | 81 |
| 5 → 6 | 51 | 132 |
| 6 → 7 | 76 | 208 |
| 7 → 8 | 114 | 322 |
| 8 → 9 | 171 | 493 |
| 9 → 10 | 256 | 749 |

---

## 附魔列表

### 1. Sharpness (锋利)

**图标**: `assets/ui/upgrades/sharpness.svg`

**描述**: 增加武器伤害

| 等级 | 效果 | 累计 |
|------|------|------|
| I | +5 伤害 | +5 |
| II | +5 伤害 | +10 |
| III | +5 伤害 | +15 |
| IV | +5 伤害 | +20 |
| V | +5 伤害 | +25 |

**最大等级**: 5

**实现**:
```gdscript
sword.damage += 5
```

---

### 2. Knockback (击退)

**图标**: `assets/ui/upgrades/knockback.svg`

**描述**: 增加击退力度，将敌人推得更远

| 等级 | 效果 | 累计 |
|------|------|------|
| I | +30 击退 | +30 |
| II | +30 击退 | +60 |
| III | +30 击退 | +90 |

**最大等级**: 3

**实现**:
```gdscript
sword.knockback += 30
```

---

### 3. Looting (抢夺)

**图标**: `assets/ui/upgrades/looting.svg`

**描述**: 增加经验获取量

| 等级 | 效果 | 累计 |
|------|------|------|
| I | +20% XP | +20% |
| II | +20% XP | +40% |
| III | +20% XP | +60% |

**最大等级**: 3

**实现**:
```gdscript
player.xp_multiplier += 0.2
```

**注意**: 需要在 player.gd 中添加 `xp_multiplier` 属性

---

### 4. Protection (保护)

**图标**: `assets/ui/upgrades/protection.svg`

**描述**: 减少受到的伤害

| 等级 | 效果 | 累计 |
|------|------|------|
| I | -10% 伤害 | -10% |
| II | -10% 伤害 | -20% |
| III | -10% 伤害 | -30% |
| IV | -10% 伤害 | -40% |

**最大等级**: 4

**实现**:
```gdscript
player.damage_reduction += 0.1
```

**注意**: 需要在 player.gd 的 `take_damage()` 中应用减伤

---

### 5. Swiftness (迅捷)

**图标**: `assets/ui/upgrades/swiftness.svg`

**描述**: 增加移动速度

| 等级 | 效果 | 累计 |
|------|------|------|
| I | +15% 速度 | +15% |
| II | +15% 速度 | +30% |
| III | +15% 速度 | +45% |

**最大等级**: 3

**实现**:
```gdscript
player.speed *= 1.15
```

---

### 6. Sweeping Edge (横扫之刃)

**图标**: `assets/ui/upgrades/sweeping.svg`

**描述**: 增加攻击范围

| 等级 | 效果 | 累计 |
|------|------|------|
| I | +20 范围 | +20 |
| II | +20 范围 | +40 |
| III | +20 范围 | +60 |

**最大等级**: 3

**实现**:
```gdscript
sword.attack_range += 20
collision_shape.radius = sword.attack_range
```

---

## 未来附魔 (计划中)

### 武器类

| 名称 | 效果 | 描述 |
|------|------|------|
| Fire Aspect (火焰附加) | 燃烧伤害 | 攻击附带持续燃烧 |
| Smite (亡灵杀手) | +伤害 vs 亡灵 | 对僵尸/骷髅额外伤害 |
| Bane of Arthropods (节肢杀手) | +伤害 vs 节肢 | 对蜘蛛额外伤害 |

### 防御类

| 名称 | 效果 | 描述 |
|------|------|------|
| Regeneration (再生) | 自动回血 | 每秒恢复生命 |
| Thorns (荆棘) | 反伤 | 被攻击时反弹伤害 |
| Blast Protection (爆炸保护) | 减少爆炸伤害 | 对 Creeper 特别有效 |

### 实用类

| 名称 | 效果 | 描述 |
|------|------|------|
| Magnet (磁铁) | 增加 XP 吸引范围 | XP 球从更远处飞来 |
| Luck (幸运) | 增加稀有附魔几率 | 升级时更容易获得高级附魔 |
| Multi-Shot (多重射击) | 武器攻击多个敌人 | 剑可以同时攻击更多敌人 |

---

## UI 设计

### 升级选择界面 (双栏设计)

```
┌──────────────────────────────────────────────────────────────────────┐
│                           LEVEL UP!                                   │
│                                                                       │
│        Enchantments                    │         Weapons              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │    ┌─────────────┐           │
│  │ [图标]  │ │ [图标]  │ │ [图标]  │  │    │   [图标]    │           │
│  │Sharpness│ │Swiftness│ │Protection│  │    │ Stone Sword │           │
│  │ Lv 2/5  │ │ Lv 1/3  │ │ Lv 3/4  │  │    │   Lv 4/12   │           │
│  │+10 dmg  │ │+15% spd │ │-30% dmg │  │    │ +2dmg +5rng │           │
│  └─────────┘ └─────────┘ └─────────┘  │    └─────────────┘           │
│                                        │                              │
│                        5.0                                            │
└──────────────────────────────────────────────────────────────────────┘
```

**双栏设计特点**:
- **左侧 (Enchantments)**: 3个随机附魔选项
- **右侧 (Weapons)**: 1个随机武器升级 (仅显示已拥有的武器)
- **动态图标**: 武器图标根据当前等级变化 (如: 木剑→石剑→铁剑→钻石剑)
- **全满级显示**: 当所有武器满级时，显示 "All Weapons Maxed Out!"
- **A/D 导航**: 可在两栏之间切换选择

### 卡片元素

- **图标**: 32x32 像素，Minecraft 附魔书风格
- **名称**: 附魔名称
- **等级**: 当前等级 / 最大等级
- **描述**: 下一级的效果

---

## 文件结构

```
assets/ui/upgrades/
├── sharpness.svg      # 剑图标 (红色)
├── knockback.svg      # 拳头图标 (蓝色)
├── looting.svg        # 金币/宝石图标 (金色)
├── protection.svg     # 盾牌图标 (灰色)
├── swiftness.svg      # 羽毛/靴子图标 (青色)
└── sweeping.svg       # 横扫剑图标 (紫色)
```

---

## 代码参考

### upgrade.gd

```gdscript
extends RefCounted
class_name Upgrade

var id: String
var display_name: String
var description: String
var icon_path: String
var current_level: int = 0
var max_level: int = 1
var effect_per_level: float = 0.0
```

### upgrade_manager.gd

```gdscript
const UPGRADE_DEFS = {
    "sharpness": {
        "name": "Sharpness",
        "desc": "+{value} damage",
        "max": 5,
        "effect": 5.0,
        "icon": "res://assets/ui/upgrades/sharpness.svg"
    },
    // ... 其他附魔
}
```

---

## 平衡性考虑

### 附魔优先级 (推荐)

1. **Sharpness** - 直接增加输出，早期最重要
2. **Sweeping Edge** - 扩大攻击范围，中期很强
3. **Swiftness** - 躲避能力，生存必需
4. **Protection** - 减伤，后期重要
5. **Knockback** - 控制，辅助性
6. **Looting** - 加速升级，长期收益

### 难度曲线

- **早期** (Lv 1-3): 附魔选择影响不大
- **中期** (Lv 4-7): 正确的附魔组合决定生存
- **后期** (Lv 8+): 需要多个满级附魔才能应对

---

## 武器升级

### Sword (剑)

**图标变化**: 根据等级自动切换
| 等级 | 图标 | 名称 |
|------|------|------|
| 1-3 | wood_sword.svg | Wood Sword |
| 4-6 | stone_sword.svg | Stone Sword |
| 7-9 | iron_sword.svg | Iron Sword |
| 10-12 | diamond_sword.svg | Diamond Sword |

**每级效果**: +2 伤害, +5 攻击范围

**最大等级**: 12

### Bow (弓)

**图标**: bow.svg

**获取方式**: 升级时选择弓升级选项

**每级效果**: +2 伤害, +20 射程

**最大等级**: 12

---

## 更新日志

- **2026-01-24**: 添加武器升级系统、双栏UI设计、毒云机制
- **2026-01-23**: 创建升级系统设计文档
