# Phase 4: Game Feel (TDD Approach)

本阶段实现游戏体验增强功能：日夜循环、怪物波次、游戏结束画面，以及新敌人。

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

---

## 功能列表

### 4.1 Day/Night Cycle (日夜循环)

**描述**: 游戏时间系统，影响怪物生成和视觉效果

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| day_duration | 60.0 | 白天时长 (秒) |
| night_duration | 60.0 | 夜晚时长 (秒) |
| transition_time | 5.0 | 过渡时间 (秒) |
| night_tint | Color(0.2, 0.2, 0.4, 0.5) | 夜晚色调 |

**时间阶段**:
| 阶段 | 时间范围 | 效果 |
|------|----------|------|
| Dawn (黎明) | 0:00-0:05 | 夜→日过渡 |
| Day (白天) | 0:05-1:00 | 正常生成 |
| Dusk (黄昏) | 1:00-1:05 | 日→夜过渡 |
| Night (夜晚) | 1:05-2:00 | 加速生成，更强敌人 |

**测试用例**:
- [ ] T4.1.1: DayNightCycle script loads
- [ ] T4.1.2: DayNightCycle has current_time property
- [ ] T4.1.3: DayNightCycle has day_duration property
- [ ] T4.1.4: DayNightCycle has night_duration property
- [ ] T4.1.5: DayNightCycle has is_night method
- [ ] T4.1.6: DayNightCycle has get_time_of_day method
- [ ] T4.1.7: DayNightCycle emits time_changed signal
- [ ] T4.1.8: DayNightCycle emits night_started signal
- [ ] T4.1.9: DayNightCycle emits day_started signal

**节点结构**:
```
DayNightCycle (Node)
├── DayTimer (Timer)
└── CanvasModulate (visual tint)
```

---

### 4.2 Wave System (波次系统)

**描述**: 按波次生成敌人，夜晚波次更强

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| wave_interval | 30.0 | 波次间隔 (秒) |
| base_enemies_per_wave | 5 | 基础每波敌人数 |
| wave_scaling | 1.2 | 每波敌人数增长倍率 |
| night_multiplier | 2.0 | 夜晚敌人数倍率 |

**波次公式**:
```
enemies = base_enemies * (wave_scaling ^ (wave - 1)) * night_multiplier
```

**敌人配比 (按波次)**:
| 波次 | Zombie | Skeleton | Creeper | Spider |
|------|--------|----------|---------|--------|
| 1-3  | 100%   | 0%       | 0%      | 0%     |
| 4-6  | 60%    | 30%      | 0%      | 10%    |
| 7-9  | 40%    | 30%      | 15%     | 15%    |
| 10+  | 30%    | 25%      | 20%     | 25%    |

**测试用例**:
- [ ] T4.2.1: WaveManager script loads
- [ ] T4.2.2: WaveManager has current_wave property
- [ ] T4.2.3: WaveManager has wave_interval property
- [ ] T4.2.4: WaveManager has start_wave method
- [ ] T4.2.5: WaveManager has get_enemies_for_wave method
- [ ] T4.2.6: WaveManager emits wave_started signal
- [ ] T4.2.7: WaveManager emits wave_completed signal
- [ ] T4.2.8: WaveManager scales enemies per wave

**节点结构**:
```
WaveManager (Node)
├── WaveTimer (Timer)
└── (integrates with MobSpawner)
```

---

### 4.3 Game Over Screen (游戏结束画面)

**描述**: Steve 死亡时显示游戏结束界面

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| show_stats | true | 显示统计数据 |
| restart_delay | 1.0 | 显示重开按钮延迟 |

**显示内容**:
- "You Died!" 标题 (Minecraft 风格)
- 存活时间
- 击杀数量
- 达到等级
- 达到波次
- "Respawn" 按钮 (重新开始)
- "Quit" 按钮 (退出游戏)

**测试用例**:
- [ ] T4.3.1: GameOverUI script loads
- [ ] T4.3.2: GameOverUI scene loads
- [ ] T4.3.3: GameOverUI has show method
- [ ] T4.3.4: GameOverUI has set_stats method
- [ ] T4.3.5: GameOverUI pauses game when shown
- [ ] T4.3.6: GameOverUI emits restart_pressed signal
- [ ] T4.3.7: GameOverUI emits quit_pressed signal
- [ ] T4.3.8: GameOverUI is CanvasLayer

**节点结构**:
```
GameOverUI (CanvasLayer)
├── ColorRect (dark overlay)
├── VBoxContainer
│   ├── Label ("You Died!")
│   ├── StatsContainer
│   │   ├── Label (survival time)
│   │   ├── Label (kills)
│   │   ├── Label (level)
│   │   └── Label (wave)
│   ├── RespawnButton
│   └── QuitButton
```

---

### 4.4 Game Stats Tracker (游戏统计)

**描述**: 跟踪游戏统计数据

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| survival_time | 0.0 | 存活时间 |
| kills | 0 | 击杀数 |
| damage_dealt | 0 | 造成伤害 |
| damage_taken | 0 | 受到伤害 |
| xp_collected | 0 | 收集经验 |

**测试用例**:
- [ ] T4.4.1: GameStats script loads
- [ ] T4.4.2: GameStats has survival_time property
- [ ] T4.4.3: GameStats has kills property
- [ ] T4.4.4: GameStats has add_kill method
- [ ] T4.4.5: GameStats has reset method
- [ ] T4.4.6: GameStats has get_stats method

**节点结构**:
```
GameStats (Node - Autoload/Singleton)
```

---

### 4.5 HUD Enhancements (HUD 增强)

**描述**: 增强 HUD 显示更多信息

**新增显示**:
| 元素 | 位置 | 描述 |
|------|------|------|
| Wave Counter | 右上 | "Wave 1" |
| Kill Counter | 右上 | "Kills: 0" |
| Time Display | 顶部中央 | "Day 1 - 00:30" |
| Day/Night Icon | 时间旁 | 太阳/月亮图标 |

**测试用例**:
- [ ] T4.5.1: HUD has set_wave method
- [ ] T4.5.2: HUD has set_kills method
- [ ] T4.5.3: HUD has set_time method
- [ ] T4.5.4: HUD has WaveLabel node
- [ ] T4.5.5: HUD has KillsLabel node
- [ ] T4.5.6: HUD has TimeLabel node

---

### 4.6 New Enemies (新敌人)

#### 4.6.1 Enderman (末影人)

**描述**: 会传送的敌人，受到攻击时传送

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 40 | 生命值 |
| speed | 70 | 移动速度 |
| damage | 15 | 接触伤害 |
| teleport_cooldown | 3.0 | 传送冷却 |
| teleport_range | 200 | 传送距离 |
| teleport_on_hit | true | 受击时传送 |
| xp_value | 15 | 掉落经验 |

**测试用例**:
- [ ] T4.6.1: Enderman script loads
- [ ] T4.6.2: Enderman scene loads
- [ ] T4.6.3: Enderman has health property (40)
- [ ] T4.6.4: Enderman has speed property (70)
- [ ] T4.6.5: Enderman has teleport method
- [ ] T4.6.6: Enderman has teleport_cooldown property
- [ ] T4.6.7: Enderman teleports when hit
- [ ] T4.6.8: Enderman is in "enemies" group

**节点结构**:
```
Enderman (CharacterBody2D)
├── Sprite2D (enderman.svg)
├── CollisionShape2D
├── HitBox (Area2D)
├── TeleportTimer (Timer)
└── TeleportEffect (Particles2D)
```

#### 4.6.2 Witch (女巫)

**描述**: 远程敌人，投掷药水造成范围伤害

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| health | 20 | 生命值 |
| speed | 35 | 移动速度 (慢) |
| potion_damage | 12 | 药水伤害 |
| potion_radius | 60 | 药水范围 |
| attack_range | 250 | 攻击距离 |
| attack_cooldown | 3.0 | 攻击间隔 |
| xp_value | 12 | 掉落经验 |

**测试用例**:
- [ ] T4.6.9: Witch script loads
- [ ] T4.6.10: Witch scene loads
- [ ] T4.6.11: Witch has health property (20)
- [ ] T4.6.12: Witch has speed property (35)
- [ ] T4.6.13: Witch has throw_potion method
- [ ] T4.6.14: Witch has attack_range property
- [ ] T4.6.15: Witch keeps distance from player
- [ ] T4.6.16: Witch is in "enemies" group

**节点结构**:
```
Witch (CharacterBody2D)
├── Sprite2D (witch.svg)
├── CollisionShape2D
├── HitBox (Area2D)
├── AttackTimer (Timer)
└── PotionSpawnPoint (Marker2D)
```

#### 4.6.3 Potion (药水)

**描述**: 女巫投掷的投射物，落地后造成范围伤害

**规格**:
| 属性 | 值 | 描述 |
|------|-----|------|
| speed | 200 | 飞行速度 |
| damage | 12 | 伤害 |
| splash_radius | 60 | 溅射范围 |
| lifetime | 2.0 | 飞行时间 |

**测试用例**:
- [ ] T4.6.17: Potion script loads
- [ ] T4.6.18: Potion scene loads
- [ ] T4.6.19: Potion has speed property
- [ ] T4.6.20: Potion has damage property
- [ ] T4.6.21: Potion has splash_radius property
- [ ] T4.6.22: Potion is Area2D

**节点结构**:
```
Potion (Area2D)
├── Sprite2D (potion.svg)
├── CollisionShape2D
├── LifetimeTimer (Timer)
└── SplashArea (Area2D)
```

---

### 4.7 Localization / 多言語対応 / 多语言支持 (i18n)

**描述**: 支持英语、日语、中文三种语言

**支持语言**:
| 语言 | 代码 | 名称 |
|------|------|------|
| English | en | English |
| 日本語 | ja | 日本語 |
| 中文 | zh | 简体中文 |

**需要翻译的文本**:
| Key | English | 日本語 | 中文 |
|-----|---------|--------|------|
| GAME_TITLE | Minecraft Survivors | マインクラフト サバイバーズ | 我的世界 幸存者 |
| YOU_DIED | You Died! | 死亡した！ | 你死了！ |
| RESPAWN | Respawn | リスポーン | 重生 |
| QUIT | Quit | 終了 | 退出 |
| WAVE | Wave | ウェーブ | 波次 |
| KILLS | Kills | 撃破数 | 击杀 |
| LEVEL | Level | レベル | 等级 |
| DAY | Day | 日目 | 第 天 |
| NIGHT | Night | 夜 | 夜晚 |
| SURVIVAL_TIME | Survival Time | 生存時間 | 存活时间 |
| LEVEL_UP | Level Up! | レベルアップ！ | 升级！ |
| CHOOSE_UPGRADE | Choose an Upgrade | 強化を選択 | 选择强化 |
| SHARPNESS | Sharpness | 鋭さ | 锋利 |
| KNOCKBACK | Knockback | ノックバック | 击退 |
| LOOTING | Looting | ドロップ増加 | 抢夺 |
| PROTECTION | Protection | 防護 | 保护 |
| SWIFTNESS | Swiftness | 俊敏 | 迅捷 |
| SWEEPING | Sweeping Edge | 範囲攻撃 | 横扫之刃 |
| SETTINGS | Settings | 設定 | 设置 |
| LANGUAGE | Language | 言語 | 语言 |

**Godot 本地化实现**:
- 使用 Godot 内置的 `TranslationServer`
- CSV 格式翻译文件
- 自动检测系统语言
- 支持运行时切换语言

**测试用例**:
- [ ] T4.7.1: Localization script loads
- [ ] T4.7.2: Translation CSV files exist (en, ja, zh)
- [ ] T4.7.3: LocalizationManager has get_text method
- [ ] T4.7.4: LocalizationManager has set_language method
- [ ] T4.7.5: LocalizationManager has get_current_language method
- [ ] T4.7.6: LocalizationManager has get_available_languages method
- [ ] T4.7.7: All UI text uses tr() function
- [ ] T4.7.8: Language persists after restart

**视觉测试** (详见 [localization_plan.md](./localization_plan.md#93-visual-test-plan-视觉测试)):
- [ ] V4.7.1: HUD 截图验证 (EN/JA/ZH)
- [ ] V4.7.2: Upgrade UI 截图验证 (EN/JA/ZH)
- [ ] V4.7.3: Game Over 截图验证 (EN/JA/ZH)
- [ ] V4.7.4: CJK 字符渲染正确 (无豆腐块)

**文件结构**:
```
localization/
├── translations.en.csv    # English
├── translations.ja.csv    # 日本語
└── translations.zh.csv    # 中文
```

**CSV 格式**:
```csv
key,en,ja,zh
GAME_TITLE,Minecraft Survivors,マインクラフト サバイバーズ,我的世界 幸存者
YOU_DIED,You Died!,死亡した！,你死了！
...
```

**节点结构**:
```
LocalizationManager (Node - Autoload/Singleton)
└── (manages TranslationServer)
```

---

### 4.8 New Art Assets (新美术资源)

**需要创建的 SVG**:
| 资源 | 路径 | 描述 |
|------|------|------|
| enderman.svg | assets/characters/ | 末影人 |
| witch.svg | assets/characters/ | 女巫 |
| potion.svg | assets/weapons/ | 药水瓶 |
| sun.svg | assets/ui/ | 太阳图标 |
| moon.svg | assets/ui/ | 月亮图标 |

**测试用例**:
- [ ] T4.8.1: Asset: enderman.svg
- [ ] T4.8.2: Asset: witch.svg
- [ ] T4.8.3: Asset: potion.svg
- [ ] T4.8.4: Asset: sun.svg
- [ ] T4.8.5: Asset: moon.svg

---

## 实现顺序 (TDD)

### Step 1: Game Stats
```
1. 写测试 → tests/unit/test_game_stats.gd
2. 实现 → scripts/systems/game_stats.gd
3. 运行测试 → ./run_tests.sh
```

### Step 2: Day/Night Cycle
```
1. 写测试 → tests/unit/test_day_night.gd
2. 实现 → scripts/systems/day_night_cycle.gd
3. 运行测试 → ./run_tests.sh
```

### Step 3: Wave Manager
```
1. 写测试 → tests/unit/test_wave_manager.gd
2. 实现 → scripts/systems/wave_manager.gd
3. 运行测试 → ./run_tests.sh
```

### Step 4: HUD Enhancements
```
1. 写测试 → 更新 tests/unit/test_hud.gd
2. 实现 → 更新 scripts/ui/hud.gd, scenes/ui/hud.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 5: Game Over UI
```
1. 写测试 → tests/unit/test_game_over.gd
2. 实现 → scripts/ui/game_over_ui.gd, scenes/ui/game_over_ui.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 6: Localization (i18n)
```
1. 写测试 → tests/unit/test_localization.gd
2. 创建翻译文件 → localization/translations.*.csv
3. 实现 → scripts/systems/localization_manager.gd
4. 更新所有 UI 使用 tr() 函数
5. 运行测试 → ./run_tests.sh
```

### Step 7: New Assets
```
1. 写测试 → 更新 tests/unit/test_assets.gd
2. 创建 SVG → assets/characters/, assets/ui/
3. 运行测试 → ./run_tests.sh
```

### Step 8: Enderman Enemy
```
1. 写测试 → tests/unit/test_enderman.gd
2. 实现 → scripts/enemies/enderman.gd, scenes/enemies/enderman.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 9: Witch Enemy
```
1. 写测试 → tests/unit/test_witch.gd
2. 实现 → scripts/enemies/witch.gd, scenes/enemies/witch.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 10: Potion Projectile
```
1. 写测试 → tests/unit/test_potion.gd
2. 实现 → scripts/projectiles/potion.gd, scenes/projectiles/potion.tscn
3. 运行测试 → ./run_tests.sh
```

### Step 11: Update Spawner
```
1. 写测试 → 更新 tests/unit/test_spawner.gd
2. 实现 → 更新 scripts/spawner.gd (spawn Enderman, Witch)
3. 运行测试 → ./run_tests.sh
```

### Step 12: Integration
```
1. 写集成测试 → tests/integration/test_game_feel.gd
2. 集成所有组件到 main.tscn
3. 运行所有测试 → ./run_tests.sh
```

---

## 文件结构 (Phase 4 完成后)

```
minecraft_survivors/
├── scripts/
│   ├── systems/
│   │   ├── upgrade_manager.gd
│   │   ├── upgrade.gd
│   │   ├── game_stats.gd            # 新增
│   │   ├── day_night_cycle.gd       # 新增
│   │   ├── wave_manager.gd          # 新增
│   │   └── localization_manager.gd  # 新增 (i18n)
│   ├── enemies/
│   │   ├── zombie.gd
│   │   ├── skeleton.gd
│   │   ├── creeper.gd
│   │   ├── spider.gd
│   │   ├── enderman.gd              # 新增
│   │   └── witch.gd                 # 新增
│   ├── projectiles/
│   │   ├── arrow.gd
│   │   └── potion.gd                # 新增
│   └── ui/
│       ├── hud.gd                   # 更新 (i18n)
│       ├── upgrade_ui.gd            # 更新 (i18n)
│       └── game_over_ui.gd          # 新增 (i18n)
├── scenes/
│   ├── enemies/
│   │   ├── enderman.tscn            # 新增
│   │   └── witch.tscn               # 新增
│   ├── projectiles/
│   │   └── potion.tscn              # 新增
│   └── ui/
│       └── game_over_ui.tscn        # 新增
├── localization/                     # 新增 (i18n)
│   ├── translations.csv             # 主翻译文件
│   ├── translations.en.translation  # English (compiled)
│   ├── translations.ja.translation  # 日本語 (compiled)
│   └── translations.zh.translation  # 中文 (compiled)
├── assets/
│   ├── characters/
│   │   ├── enderman.svg             # 新增
│   │   └── witch.svg                # 新增
│   ├── weapons/
│   │   └── potion.svg               # 新增
│   └── ui/
│       ├── sun.svg                  # 新增
│       └── moon.svg                 # 新增
└── tests/
    └── unit/
        ├── test_game_stats.gd       # 新增
        ├── test_day_night.gd        # 新增
        ├── test_wave_manager.gd     # 新增
        ├── test_game_over.gd        # 新增
        ├── test_localization.gd     # 新增 (i18n)
        ├── test_enderman.gd         # 新增
        ├── test_witch.gd            # 新增
        └── test_potion.gd           # 新增
```

---

## 验收标准

Phase 4 完成条件:
- [ ] 所有测试通过 (预计 180+ tests)
- [ ] 日夜循环正常工作
- [ ] 夜晚时怪物生成加快
- [ ] 波次系统正常工作
- [ ] HUD 显示波次、击杀、时间
- [ ] Steve 死亡时显示游戏结束界面
- [ ] 可以重新开始游戏
- [ ] Enderman 可以传送
- [ ] Witch 可以投掷药水
- [ ] 支持英语、日语、中文切换
- [ ] 语言设置保存并持久化
- [ ] 所有 UI 文本正确显示翻译
- [ ] 游戏可以持续运行不崩溃

---

## 测试用例汇总

| 模块 | 测试数量 |
|------|----------|
| Day/Night Cycle | 9 |
| Wave Manager | 8 |
| Game Over UI | 8 |
| Game Stats | 6 |
| HUD Enhancements | 6 |
| Localization (i18n) | 8 |
| Enderman | 8 |
| Witch | 8 |
| Potion | 6 |
| New Assets | 5 |
| **总计** | **72** |

Phase 4 预计新增 72 个测试用例。

---

## 更新日志

- **2026-01-23**: 添加多语言支持 (English, 日本語, 中文)
- **2026-01-23**: 创建 Phase 4 计划文档 (TDD 方法)
