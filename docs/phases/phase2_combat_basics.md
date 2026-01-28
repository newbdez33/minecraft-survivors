# Phase 2: Combat Basics (TDD Approach)

本阶段实现战斗系统的基础功能，采用测试驱动开发 (TDD) 方法。

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

---

## 功能列表

### 2.1 Diamond Sword (钻石剑)

**描述**: Steve 周围自动挥舞的近战武器

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| damage | 10 | 每次攻击伤害 |
| attack_range | 64 | 攻击范围 (像素) |
| attack_cooldown | 1.0 | 攻击间隔 (秒) |
| knockback | 50 | 击退力度 |

**测试用例**:
- [ ] T2.1.1: Sword script loads
- [ ] T2.1.2: Sword scene loads
- [ ] T2.1.3: Sword has correct damage value
- [ ] T2.1.4: Sword has correct attack range
- [ ] T2.1.5: Sword has correct cooldown
- [ ] T2.1.6: Sword can detect enemies in range
- [ ] T2.1.7: Sword deals damage to enemies

**节点结构**:
```
DiamondSword (Area2D)
├── Sprite2D (diamond_sword.svg)
├── CollisionShape2D (CircleShape2D, radius=64)
├── AttackTimer (Timer, wait_time=1.0)
└── AnimationPlayer (optional)
```

---

### 2.2 Zombie (僵尸)

**描述**: 基础敌人，缓慢追踪 Steve

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 20 | 生命值 |
| speed | 60 | 移动速度 (像素/秒) |
| damage | 10 | 接触伤害 |
| xp_value | 5 | 死亡掉落经验 |

**测试用例**:
- [ ] T2.2.1: Zombie script loads
- [ ] T2.2.2: Zombie scene loads
- [ ] T2.2.3: Zombie has correct health
- [ ] T2.2.4: Zombie has correct speed
- [ ] T2.2.5: Zombie has correct damage
- [ ] T2.2.6: Zombie moves toward player
- [ ] T2.2.7: Zombie takes damage correctly
- [ ] T2.2.8: Zombie dies when health <= 0
- [ ] T2.2.9: Zombie drops XP on death

**节点结构**:
```
Zombie (CharacterBody2D)
├── Sprite2D (zombie.svg)
├── CollisionShape2D (RectangleShape2D)
├── HitBox (Area2D) - 检测与玩家碰撞
└── HealthComponent (Node)
```

---

### 2.3 Mob Spawner (怪物生成器)

**描述**: 在 Steve 周围生成敌人

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| spawn_radius_min | 400 | 最小生成距离 |
| spawn_radius_max | 600 | 最大生成距离 |
| spawn_interval | 2.0 | 生成间隔 (秒) |
| max_enemies | 50 | 最大敌人数量 |

**测试用例**:
- [ ] T2.3.1: Spawner script loads
- [ ] T2.3.2: Spawner has correct spawn radius
- [ ] T2.3.3: Spawner has correct spawn interval
- [ ] T2.3.4: Spawner respects max enemy limit
- [ ] T2.3.5: Spawner spawns enemies at correct distance
- [ ] T2.3.6: Spawner spawns enemies outside viewport

**节点结构**:
```
MobSpawner (Node)
├── SpawnTimer (Timer)
└── (manages enemy instances)
```

---

### 2.4 Health System (生命系统)

**描述**: Steve 和敌人的生命值管理

**Steve 规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| max_health | 100 | 最大生命值 (10颗心) |
| invincibility_time | 1.0 | 受伤后无敌时间 |

**测试用例**:
- [ ] T2.4.1: Player has health property
- [ ] T2.4.2: Player has max_health = 100
- [ ] T2.4.3: Player can take damage
- [ ] T2.4.4: Player health doesn't go below 0
- [ ] T2.4.5: Player has invincibility after damage
- [ ] T2.4.6: Player dies when health <= 0

**HUD 测试**:
- [ ] T2.4.7: HUD displays correct heart count
- [ ] T2.4.8: HUD updates when health changes
- [ ] T2.4.9: HUD shows half hearts correctly

---

### 2.5 Hit/Death Effects (打击/死亡特效)

**测试用例**:
- [ ] T2.5.1: Hit effect scene loads
- [ ] T2.5.2: Death effect scene loads
- [ ] T2.5.3: Effects auto-free after animation

---

## 实现顺序 (TDD)

按以下顺序实现，每步先写测试:

### Step 1: Health Component
```
1. 写测试 → tests/unit/test_health.gd
2. 实现 → scripts/components/health.gd
3. 运行测试 → ./run_tests.sh
```

### Step 2: Zombie Enemy
```
1. 写测试 → tests/unit/test_zombie.gd
2. 实现 → scripts/enemies/zombie.gd, scenes/enemies/zombie.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 3: Diamond Sword
```
1. 写测试 → tests/unit/test_sword.gd
2. 实现 → scripts/weapons/diamond_sword.gd, scenes/weapons/diamond_sword.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 4: Mob Spawner
```
1. 写测试 → tests/unit/test_spawner.gd
2. 实现 → scripts/spawner.gd
3. 运行测试 → ./run_tests.sh
```

### Step 5: HUD (Hearts Display)
```
1. 写测试 → tests/unit/test_hud.gd
2. 实现 → scripts/ui/hud.gd, scenes/ui/hud.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 6: Integration
```
1. 写集成测试 → tests/integration/test_combat.gd
2. 集成所有组件到 main.tscn
3. 运行所有测试 → ./run_tests.sh
```

---

## 文件结构 (Phase 2 完成后)

```
minecraft_survivors/
├── scripts/
│   ├── player.gd              # 更新: 添加 health
│   ├── camera.gd
│   ├── arena.gd
│   ├── spawner.gd             # 新增
│   ├── components/
│   │   └── health.gd          # 新增
│   ├── enemies/
│   │   └── zombie.gd          # 新增
│   ├── weapons/
│   │   └── diamond_sword.gd   # 新增
│   └── ui/
│       └── hud.gd             # 新增
├── scenes/
│   ├── main.tscn              # 更新
│   ├── player.tscn            # 更新
│   ├── enemies/
│   │   └── zombie.tscn        # 新增
│   ├── weapons/
│   │   └── diamond_sword.tscn # 新增
│   └── ui/
│       └── hud.tscn           # 新增
└── tests/
    ├── test_runner.gd         # 更新
    └── unit/
        ├── test_player.gd
        ├── test_arena.gd
        ├── test_health.gd     # 新增
        ├── test_zombie.gd     # 新增
        ├── test_sword.gd      # 新增
        ├── test_spawner.gd    # 新增
        └── test_hud.gd        # 新增
```

---

## 验收标准

Phase 2 完成条件:
- [x] 所有测试通过 (61 测试)
- [x] Steve 可以被 Zombie 攻击并扣血
- [x] Diamond Sword 自动攻击周围的 Zombie
- [x] Zombie 死亡时播放特效
- [x] HUD 正确显示 Steve 的生命值
- [x] 游戏可以持续运行不崩溃

---

## 更新日志

- **2026-01-23**: 创建 Phase 2 计划文档 (TDD 方法)
- **2026-01-23**: Phase 2 完成! 所有功能已实现并测试通过
