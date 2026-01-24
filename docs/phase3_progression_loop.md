# Phase 3: Progression Loop (TDD Approach)

本阶段实现游戏核心循环：击杀敌人 → 获得经验 → 升级 → 选择强化

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

---

## 功能列表

### 3.1 XP Orb (经验球)

**描述**: 敌人死亡时掉落，自动飞向玩家

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| xp_value | 5 | 经验值 (可变) |
| pickup_radius | 50 | 自动拾取范围 |
| attract_radius | 150 | 开始吸引的范围 |
| attract_speed | 300 | 飞向玩家的速度 |
| bob_amplitude | 3 | 上下浮动幅度 |

**测试用例**:
- [ ] T3.1.1: XP orb script loads
- [ ] T3.1.2: XP orb scene loads
- [ ] T3.1.3: XP orb has xp_value property
- [ ] T3.1.4: XP orb has pickup_radius property
- [ ] T3.1.5: XP orb has attract_radius property
- [ ] T3.1.6: XP orb is Area2D
- [ ] T3.1.7: XP orb has collected signal

**节点结构**:
```
XPOrb (Area2D)
├── Sprite2D (xp_orb.svg)
├── CollisionShape2D (CircleShape2D, radius=pickup_radius)
└── AnimationPlayer (bob animation)
```

---

### 3.2 XP/Level System (经验/等级系统)

**描述**: 玩家收集经验球升级

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| current_xp | 0 | 当前经验值 |
| current_level | 1 | 当前等级 |
| xp_to_next_level | 10 | 升级所需经验 |
| level_scaling | 1.5 | 每级经验需求倍率 |

**升级公式**: `xp_needed = base_xp * (level_scaling ^ (level - 1))`
- Level 1→2: 10 XP
- Level 2→3: 15 XP
- Level 3→4: 22 XP
- Level 4→5: 34 XP

**测试用例**:
- [ ] T3.2.1: Player has current_xp property
- [ ] T3.2.2: Player has current_level property
- [ ] T3.2.3: Player has add_xp method
- [ ] T3.2.4: Player XP increases when add_xp called
- [ ] T3.2.5: Player level increases when XP threshold reached
- [ ] T3.2.6: Player emits leveled_up signal
- [ ] T3.2.7: XP threshold increases after level up
- [ ] T3.2.8: Excess XP carries over after level up

---

### 3.3 XP Bar HUD (经验条)

**描述**: 显示当前经验进度和等级

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| position | bottom | 屏幕底部 |
| width | 80% | 屏幕宽度占比 |
| height | 8px | 条高度 |
| color | #7EE87E | 绿色 (Minecraft XP) |

**测试用例**:
- [ ] T3.3.1: XP bar script loads
- [ ] T3.3.2: XP bar has update_xp method
- [ ] T3.3.3: XP bar has set_level method
- [ ] T3.3.4: XP bar displays level number

---

### 3.4 Upgrade System (强化系统)

**描述**: 升级时暂停游戏，选择一个强化

**可用强化 (Enchantments)**:
| ID | 名称 | 效果 | 最大等级 |
|----|------|------|----------|
| sharpness | Sharpness (锋利) | +5 damage | 5 |
| knockback | Knockback (击退) | +30 knockback | 3 |
| looting | Looting (抢夺) | +20% XP gain | 3 |
| protection | Protection (保护) | -10% damage taken | 4 |
| swiftness | Swiftness (迅捷) | +15% move speed | 3 |
| sweeping | Sweeping Edge (横扫) | +20 attack range | 3 |

**测试用例**:
- [ ] T3.4.1: Upgrade manager script loads
- [ ] T3.4.2: Upgrade manager has available_upgrades
- [ ] T3.4.3: Upgrade manager has get_random_upgrades method
- [ ] T3.4.4: get_random_upgrades returns 3 upgrades
- [ ] T3.4.5: Upgrade has id, name, description properties
- [ ] T3.4.6: Upgrade has current_level, max_level properties
- [ ] T3.4.7: Upgrade has apply method

---

### 3.5 Upgrade Selection UI (强化选择界面)

**描述**: 显示3个随机强化供玩家选择

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| options_count | 3 | 显示选项数量 |
| pause_game | true | 暂停游戏 |
| card_size | 200x280 | 卡片大小 |

**测试用例**:
- [ ] T3.5.1: Upgrade UI script loads
- [ ] T3.5.2: Upgrade UI scene loads
- [ ] T3.5.3: Upgrade UI has show_upgrades method
- [ ] T3.5.4: Upgrade UI pauses game when shown
- [ ] T3.5.5: Upgrade UI resumes game when closed
- [ ] T3.5.6: Upgrade UI emits upgrade_selected signal

**节点结构**:
```
UpgradeUI (CanvasLayer)
├── ColorRect (dimmed background)
├── VBoxContainer
│   ├── Label ("Level Up!")
│   └── HBoxContainer
│       ├── UpgradeCard1
│       ├── UpgradeCard2
│       └── UpgradeCard3
```

---

### 3.6 New Enemies (新敌人)

#### 3.6.1 Skeleton (骷髅)

**描述**: 远程敌人，射箭攻击

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 15 | 生命值 |
| speed | 40 | 移动速度 (比僵尸慢) |
| damage | 8 | 箭矢伤害 |
| attack_range | 300 | 射击距离 |
| attack_cooldown | 2.0 | 射击间隔 |
| xp_value | 8 | 掉落经验 |

**测试用例**:
- [ ] T3.6.1: Skeleton script loads
- [ ] T3.6.2: Skeleton scene loads
- [ ] T3.6.3: Skeleton has correct health (15)
- [ ] T3.6.4: Skeleton has correct speed (40)
- [ ] T3.6.5: Skeleton has shoot_arrow method
- [ ] T3.6.6: Skeleton keeps distance from player
- [ ] T3.6.7: Skeleton is in "enemies" group

**节点结构**:
```
Skeleton (CharacterBody2D)
├── Sprite2D (skeleton.svg)
├── CollisionShape2D
├── HitBox (Area2D)
├── AttackTimer (Timer)
└── ArrowSpawnPoint (Marker2D)
```

#### 3.6.2 Arrow (箭矢)

**描述**: 骷髅射出的投射物

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| speed | 250 | 飞行速度 |
| damage | 8 | 伤害 |
| lifetime | 3.0 | 存在时间 |

**测试用例**:
- [ ] T3.6.8: Arrow script loads
- [ ] T3.6.9: Arrow scene loads
- [ ] T3.6.10: Arrow has speed property
- [ ] T3.6.11: Arrow has damage property
- [ ] T3.6.12: Arrow moves in set direction

**节点结构**:
```
Arrow (Area2D)
├── Sprite2D (arrow.svg)
├── CollisionShape2D
└── LifetimeTimer (Timer)
```

#### 3.6.3 Creeper (苦力怕)

**描述**: 接近玩家后爆炸

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 25 | 生命值 |
| speed | 50 | 移动速度 |
| explosion_damage | 30 | 爆炸伤害 |
| explosion_radius | 80 | 爆炸范围 |
| fuse_time | 1.5 | 引爆时间 |
| trigger_distance | 40 | 触发爆炸距离 |
| xp_value | 10 | 掉落经验 |

**测试用例**:
- [ ] T3.6.13: Creeper script loads
- [ ] T3.6.14: Creeper scene loads
- [ ] T3.6.15: Creeper has correct health (25)
- [ ] T3.6.16: Creeper has explosion_damage property
- [ ] T3.6.17: Creeper has fuse_time property
- [ ] T3.6.18: Creeper starts fuse when near player
- [ ] T3.6.19: Creeper flashes when fuse active
- [ ] T3.6.20: Creeper is in "enemies" group

**节点结构**:
```
Creeper (CharacterBody2D)
├── Sprite2D (creeper.svg)
├── CollisionShape2D
├── HitBox (Area2D)
├── FuseTimer (Timer)
├── ExplosionArea (Area2D)
└── AudioStreamPlayer2D (hiss sound, optional)
```

#### 3.6.4 Spider (蜘蛛)

**描述**: 快速移动，可跳跃

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 12 | 生命值 |
| speed | 100 | 移动速度 (快) |
| damage | 8 | 接触伤害 |
| jump_distance | 150 | 跳跃距离 |
| jump_cooldown | 3.0 | 跳跃间隔 |
| xp_value | 6 | 掉落经验 |

**测试用例**:
- [ ] T3.6.21: Spider script loads
- [ ] T3.6.22: Spider scene loads
- [ ] T3.6.23: Spider has correct health (12)
- [ ] T3.6.24: Spider has correct speed (100)
- [ ] T3.6.25: Spider has jump method
- [ ] T3.6.26: Spider is in "enemies" group

**节点结构**:
```
Spider (CharacterBody2D)
├── Sprite2D (spider.svg)
├── CollisionShape2D
├── HitBox (Area2D)
└── JumpTimer (Timer)
```

---

## 实现顺序 (TDD)

### Step 1: XP Orb
```
1. 写测试 → tests/unit/test_xp_orb.gd
2. 实现 → scripts/pickups/xp_orb.gd, scenes/pickups/xp_orb.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 2: XP/Level System
```
1. 写测试 → 更新 tests/unit/test_player.gd
2. 实现 → 更新 scripts/player.gd
3. 运行测试 → ./run_tests.sh
```

### Step 3: XP Bar HUD
```
1. 写测试 → 更新 tests/unit/test_hud.gd
2. 实现 → 更新 scripts/ui/hud.gd, scenes/ui/hud.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 4: Zombie XP Drop
```
1. 写测试 → 更新 tests/unit/test_zombie.gd
2. 实现 → 更新 scripts/enemies/zombie.gd
3. 运行测试 → ./run_tests.sh
```

### Step 5: Upgrade System
```
1. 写测试 → tests/unit/test_upgrades.gd
2. 实现 → scripts/systems/upgrade_manager.gd, scripts/systems/upgrade.gd
3. 运行测试 → ./run_tests.sh
```

### Step 6: Upgrade UI
```
1. 写测试 → tests/unit/test_upgrade_ui.gd
2. 实现 → scripts/ui/upgrade_ui.gd, scenes/ui/upgrade_ui.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 7: Skeleton Enemy
```
1. 写测试 → tests/unit/test_skeleton.gd
2. 实现 → scripts/enemies/skeleton.gd, scenes/enemies/skeleton.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 8: Arrow Projectile
```
1. 写测试 → tests/unit/test_arrow.gd
2. 实现 → scripts/projectiles/arrow.gd, scenes/projectiles/arrow.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 9: Creeper Enemy
```
1. 写测试 → tests/unit/test_creeper.gd
2. 实现 → scripts/enemies/creeper.gd, scenes/enemies/creeper.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 10: Spider Enemy
```
1. 写测试 → tests/unit/test_spider.gd
2. 实现 → scripts/enemies/spider.gd, scenes/enemies/spider.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 11: Update Spawner
```
1. 写测试 → 更新 tests/unit/test_spawner.gd
2. 实现 → 更新 scripts/spawner.gd (spawn different enemy types)
3. 运行测试 → ./run_tests.sh
```

### Step 12: Integration
```
1. 写集成测试 → tests/integration/test_progression.gd
2. 集成所有组件
3. 运行所有测试 → ./run_tests.sh
```

---

## 文件结构 (Phase 3 完成后)

```
minecraft_survivors/
├── scripts/
│   ├── player.gd              # 更新: 添加 XP/Level
│   ├── spawner.gd             # 更新: 多种敌人
│   ├── pickups/
│   │   └── xp_orb.gd          # 新增
│   ├── enemies/
│   │   ├── zombie.gd          # 更新: 掉落 XP
│   │   ├── skeleton.gd        # 新增
│   │   ├── creeper.gd         # 新增
│   │   └── spider.gd          # 新增
│   ├── projectiles/
│   │   └── arrow.gd           # 新增
│   ├── systems/
│   │   ├── upgrade_manager.gd # 新增
│   │   └── upgrade.gd         # 新增
│   └── ui/
│       ├── hud.gd             # 更新: XP bar
│       └── upgrade_ui.gd      # 新增
├── scenes/
│   ├── pickups/
│   │   └── xp_orb.tscn        # 新增
│   ├── enemies/
│   │   ├── zombie.tscn
│   │   ├── skeleton.tscn      # 新增
│   │   ├── creeper.tscn       # 新增
│   │   └── spider.tscn        # 新增
│   ├── projectiles/
│   │   └── arrow.tscn         # 新增
│   └── ui/
│       ├── hud.tscn           # 更新
│       └── upgrade_ui.tscn    # 新增
└── tests/
    └── unit/
        ├── test_xp_orb.gd     # 新增
        ├── test_skeleton.gd   # 新增
        ├── test_creeper.gd    # 新增
        ├── test_spider.gd     # 新增
        ├── test_arrow.gd      # 新增
        ├── test_upgrades.gd   # 新增
        └── test_upgrade_ui.gd # 新增
```

---

## 验收标准

Phase 3 完成条件:
- [x] 所有测试通过 (117 tests)
- [x] 敌人死亡掉落 XP 球
- [x] XP 球自动飞向玩家
- [x] 收集 XP 球增加经验
- [x] 经验满升级
- [x] 升级时显示选择界面
- [x] 选择强化后应用效果
- [x] Skeleton 可以射箭
- [x] Creeper 接近后爆炸
- [x] Spider 快速移动
- [x] 游戏可以持续运行不崩溃

---

## 测试用例汇总

| 模块 | 测试数量 |
|------|----------|
| XP Orb | 7 |
| XP/Level System | 8 |
| XP Bar HUD | 4 |
| Upgrade System | 7 |
| Upgrade UI | 6 |
| Skeleton | 7 |
| Arrow | 5 |
| Creeper | 8 |
| Spider | 6 |
| **总计** | **58** |

Phase 3 预计新增 58 个测试用例。

---

## 更新日志

- **2026-01-23**: 创建 Phase 3 计划文档 (TDD 方法)
- **2026-01-23**: Phase 3 完成! 所有功能已实现并测试通过 (117 tests)
