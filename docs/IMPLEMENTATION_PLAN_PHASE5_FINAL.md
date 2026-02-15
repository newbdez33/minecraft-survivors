# Phase 5 最终实施计划 - TDD 方法

**创建日期**: 2026-02-01
**目标**: 完成 Phase 5 剩余功能，保持 100% 测试覆盖率

---

## 概览

| 序号 | 功能 | 预计测试数 | 依赖 |
|------|------|------------|------|
| 1 | Achievement System 成就系统 | 20 | 无 |
| 2 | Unlockable Characters 可解锁角色 | 12 | Achievement |
| 3 | Boss: Elder Guardian 远古守卫者 | 25 | 无 |
| 4 | Boss: Ravager 劫掠兽 | 25 | 无 |
| 5 | Boss: Warden 监守者 | 30 | 无 |
| 6 | Boss: Wither 凋灵 | 35 | 无 |
| 7 | Boss: Ender Dragon 末影龙 | 40 | 无 |

**总计**: ~187 个新测试

---

## 1. Achievement System 成就系统

### 1.1 文件结构

```
scripts/systems/
├── achievement.gd          # 单个成就数据类 ✅ 已存在
├── achievement_manager.gd  # 成就管理器 ✅ 已存在
└── achievement_ui.gd       # 成就UI (新建)

scenes/ui/
├── achievement_panel.tscn  # 成就面板 (新建)
└── achievement_popup.tscn  # 成就解锁弹窗 (新建)

assets/ui/achievements/
├── first_kill.svg          # 成就图标 (新建)
├── hundred_kills.svg
├── survive_5min.svg
├── survive_15min.svg
└── ...
```

### 1.2 成就列表

| ID | 成就名 | 条件 | 奖励 | 解锁内容 |
|----|--------|------|------|----------|
| first_kill | 初次击杀 | 击杀1个敌人 | 10 绿宝石 | - |
| hundred_kills | 百人斩 | 单局击杀100敌人 | 50 绿宝石 | - |
| thousand_kills | 千人斩 | 单局击杀1000敌人 | 200 绿宝石 | - |
| survive_5min | 存活5分钟 | 存活300秒 | 30 绿宝石 | - |
| survive_10min | 存活10分钟 | 存活600秒 | 100 绿宝石 | - |
| survive_15min | 存活15分钟 | 存活900秒 | 150 绿宝石 | **解锁 Alex** |
| reach_level_10 | 达到10级 | 单局达到10级 | 50 绿宝石 | - |
| reach_level_20 | 达到20级 | 单局达到20级 | 150 绿宝石 | - |
| beat_wave_5 | 通过第5波 | 击败 Evoker | 40 绿宝石 | - |
| beat_wave_10 | 通过第10波 | 击败 Elder Guardian | 100 绿宝石 | - |
| beat_wave_30 | 通关游戏 | 击败 Ender Dragon | 500 绿宝石 | - |
| enderman_hunter | 末影猎人 | 累计击杀50末影人 | 100 绿宝石 | - |
| witch_slayer | 女巫克星 | 累计击杀30女巫 | 80 绿宝石 | - |
| explosion_victim | 爆炸受害者 | 被苦力怕炸死5次 | 20 绿宝石 | - |
| no_damage_60s | 完美主义 | 60秒不受伤 | 150 绿宝石 | - |

### 1.3 测试用例 (20个)

```
T5.ACH.1: Achievement script loads
T5.ACH.2: Achievement has id property
T5.ACH.3: Achievement has name_key property
T5.ACH.4: Achievement has condition property
T5.ACH.5: Achievement has unlocked property (default false)

T5.ACH.6: AchievementManager loads
T5.ACH.7: AchievementManager has check_achievements method
T5.ACH.8: AchievementManager has unlock_achievement method
T5.ACH.9: AchievementManager has get_achievement method
T5.ACH.10: AchievementManager has is_unlocked method
T5.ACH.11: AchievementManager emits achievement_unlocked signal
T5.ACH.12: AchievementManager persists to user://achievements.json

T5.ACH.13: First kill achievement unlocks correctly
T5.ACH.14: Hundred kills achievement unlocks correctly
T5.ACH.15: Survive 5min achievement unlocks correctly
T5.ACH.16: Survive 15min unlocks Alex character
T5.ACH.17: Beat wave 5 achievement unlocks correctly

T5.ACH.18: AchievementUI scene loads
T5.ACH.19: AchievementUI shows unlock popup
T5.ACH.20: AchievementPanel shows all achievements with status
```

---

## 2. Unlockable Characters 可解锁角色

### 2.1 文件结构

```
scripts/systems/
├── character.gd            # 角色数据类 ✅ 已存在
├── character_manager.gd    # 角色管理器 ✅ 已存在
└── character_select_ui.gd  # 角色选择UI (新建)

scenes/ui/
└── character_select.tscn   # 角色选择界面 (新建)

assets/characters/
├── steve.svg               # ✅ 已存在
└── alex.svg                # Alex 角色 (新建)
```

### 2.2 角色属性

| 角色 | 解锁条件 | HP | 移速 | 伤害 | 特殊能力 |
|------|----------|-----|------|------|----------|
| Steve | 默认 | 100 | 200 | 100% | 无 |
| Alex | 存活15分钟 | 90 | 240 (+20%) | 100% | 拾取范围+50% |

### 2.3 测试用例 (12个)

```
T5.CHAR.1: Character script loads
T5.CHAR.2: Character has id property
T5.CHAR.3: Character has stats (hp, speed, damage_mult, pickup_range)
T5.CHAR.4: Character has unlock_condition property
T5.CHAR.5: Character has is_unlocked method

T5.CHAR.6: CharacterManager loads
T5.CHAR.7: CharacterManager has Steve by default
T5.CHAR.8: CharacterManager has Alex (locked initially)
T5.CHAR.9: CharacterManager unlock_character works
T5.CHAR.10: CharacterManager persists to user://characters.json

T5.CHAR.11: CharacterSelectUI shows available characters
T5.CHAR.12: Player stats change based on selected character
```

---

## 3. Boss: Elder Guardian 远古守卫者 (Wave 10)

### 3.1 属性

| 属性 | 数值 |
|------|------|
| HP | 150 |
| 移动速度 | 30 |
| 碰撞伤害 | 10 |
| 尺寸 | 32×32 |
| 荆棘反伤 | 5 |

### 3.2 技能

| 技能 | 伤害 | 冷却 | 描述 |
|------|------|------|------|
| 激光攻击 | 25 | 4s | 2s蓄力，红线预警 |
| 疲劳诅咒 | - | 12s | -30%移速，-20%攻速，5s |
| 荆棘防御 | 5 | 被动 | 近战攻击时反伤 |

### 3.3 测试用例 (25个)

```
T5.EG.1: ElderGuardian script loads
T5.EG.2: ElderGuardian scene loads
T5.EG.3: ElderGuardian has correct HP (150)
T5.EG.4: ElderGuardian has correct speed (30)
T5.EG.5: ElderGuardian has collision_damage (10)
T5.EG.6: ElderGuardian has spike_damage (5)

T5.EG.7: ElderGuardian has laser_attack method
T5.EG.8: Laser has charge_time (2.0s)
T5.EG.9: Laser deals 25 damage
T5.EG.10: Laser shows warning line during charge
T5.EG.11: Laser tracks player during charge

T5.EG.12: ElderGuardian has mining_fatigue_curse method
T5.EG.13: Curse reduces player speed by 30%
T5.EG.14: Curse reduces player attack speed by 20%
T5.EG.15: Curse lasts 5 seconds
T5.EG.16: Curse cooldown is 12 seconds

T5.EG.17: Spike defense triggers on melee hit
T5.EG.18: Spike reflects 5 damage to attacker

T5.EG.19: ElderGuardian enters rage at HP < 50%
T5.EG.20: Rage reduces laser cooldown to 3s
T5.EG.21: Rage reduces charge time to 1.5s

T5.EG.22: ElderGuardian drops 80 XP
T5.EG.23: ElderGuardian drops 50 emeralds
T5.EG.24: ElderGuardian has 15% Ocean Heart drop
T5.EG.25: BossHealthBar shows during fight
```

---

## 4. Boss: Ravager 劫掠兽 (Wave 15)

### 4.1 属性

| 属性 | 数值 |
|------|------|
| HP | 200 |
| 移动速度 | 50 (冲锋350) |
| 碰撞伤害 | 15 |
| 尺寸 | 32×32 |

### 4.2 技能

| 技能 | 伤害 | 冷却 | 描述 |
|------|------|------|------|
| 狂暴冲锋 | 25 | 5s | 1s蓄力，300px距离 |
| 践踏 | 20 | 4s | 80px范围，0.5s击晕 |
| 咆哮 | 0 | 8s | 120px范围，击退+50%减速2s |

### 4.3 测试用例 (25个)

```
T5.RAV.1: Ravager script loads
T5.RAV.2: Ravager scene loads
T5.RAV.3: Ravager has correct HP (200)
T5.RAV.4: Ravager has correct speed (50)
T5.RAV.5: Ravager has collision_damage (15)

T5.RAV.6: Ravager has charge_attack method
T5.RAV.7: Charge has 1s windup
T5.RAV.8: Charge speed is 350
T5.RAV.9: Charge deals 25 damage
T5.RAV.10: Charge has 200 knockback
T5.RAV.11: Charge shows direction arrow

T5.RAV.12: Ravager has stomp method
T5.RAV.13: Stomp deals 20 damage
T5.RAV.14: Stomp has 80px radius
T5.RAV.15: Stomp stuns for 0.5s
T5.RAV.16: Stomp cooldown is 4s

T5.RAV.17: Ravager has roar method
T5.RAV.18: Roar has 120px radius
T5.RAV.19: Roar applies 150 knockback
T5.RAV.20: Roar applies 50% slow for 2s

T5.RAV.21: Ravager enters rage at HP < 40%
T5.RAV.22: Rage increases speed to 70
T5.RAV.23: Rage reduces charge cooldown to 3.5s

T5.RAV.24: Ravager drops 100 XP
T5.RAV.25: Ravager drops 70 emeralds
```

---

## 5. Boss: Warden 监守者 (Wave 20)

### 5.1 属性

| 属性 | 数值 |
|------|------|
| HP | 400 |
| 移动速度 | 60 |
| 碰撞伤害 | 20 |
| 尺寸 | 24×48 |

### 5.2 技能

| 技能 | 伤害 | 冷却 | 描述 |
|------|------|------|------|
| 音波攻击 | 40 (无视护甲) | 6s | 1.5s蓄力，300px射程 |
| 黑暗笼罩 | 0 | 15s | 6s内视野缩小到150px |
| 重击 | 30 | 2s | 90度扇形，70px半径 |

### 5.3 阶段

- **HP > 50%**: 正常模式
- **HP < 50%**: 狂怒 - 移速80，音波冷却4s
- **HP < 25%**: 暴走 - 音波360度，永久黑暗

### 5.4 测试用例 (30个)

```
T5.WAR.1: Warden script loads
T5.WAR.2: Warden scene loads
T5.WAR.3: Warden has correct HP (400)
T5.WAR.4: Warden has correct speed (60)
T5.WAR.5: Warden has collision_damage (20)

T5.WAR.6: Warden has sonic_boom method
T5.WAR.7: Sonic boom has 1.5s charge
T5.WAR.8: Sonic boom deals 40 damage
T5.WAR.9: Sonic boom ignores armor
T5.WAR.10: Sonic boom has 300px range
T5.WAR.11: Sonic boom shows chest glow during charge

T5.WAR.12: Warden has darkness method
T5.WAR.13: Darkness reduces vision to 150px
T5.WAR.14: Darkness lasts 6 seconds
T5.WAR.15: Darkness cooldown is 15s
T5.WAR.16: Warden speed +30% during darkness

T5.WAR.17: Warden has melee_slam method
T5.WAR.18: Slam deals 30 damage
T5.WAR.19: Slam has 90 degree arc
T5.WAR.20: Slam has 70px radius
T5.WAR.21: Slam has 180 knockback

T5.WAR.22: Warden enters rage at HP < 50%
T5.WAR.23: Rage increases speed to 80
T5.WAR.24: Rage reduces sonic cooldown to 4s

T5.WAR.25: Warden enters rampage at HP < 25%
T5.WAR.26: Rampage makes sonic 360 degree
T5.WAR.27: Rampage makes darkness permanent

T5.WAR.28: Warden drops 150 XP
T5.WAR.29: Warden drops 100 emeralds
T5.WAR.30: Warden has 25% Sculk Fragment drop
```

---

## 6. Boss: Wither 凋灵 (Wave 25)

### 6.1 属性

| 属性 | 数值 |
|------|------|
| HP | 500 |
| 移动速度 | 45 (飞行) |
| 碰撞伤害 | 15 |
| 尺寸 | 48×48 |

### 6.2 技能

| 技能 | 伤害 | 冷却 | 描述 |
|------|------|------|------|
| 凋灵头颅 | 15 + 凋零(5 DPS, 4s) | 1.5s | 轻微追踪 |
| 蓝色头颅 | 25 + 100px爆炸 | 8s | 强追踪，慢速 |
| 召唤骷髅 | - | 12s | 4个凋灵骷髅 |
| 生命汲取 | - | 被动 | 击杀回血2HP |

### 6.3 阶段

- **HP > 50%**: 正常模式
- **HP < 50%**: 护盾 - 免疫远程，只受近战伤害

### 6.4 测试用例 (35个)

```
T5.WIT.1: Wither script loads
T5.WIT.2: Wither scene loads
T5.WIT.3: Wither has correct HP (500)
T5.WIT.4: Wither has correct speed (45)
T5.WIT.5: Wither has is_flying = true
T5.WIT.6: Wither has collision_damage (15)

T5.WIT.7: Wither has skull_attack method
T5.WIT.8: Skull deals 15 damage
T5.WIT.9: Skull applies wither effect (5 DPS, 4s)
T5.WIT.10: Skull has light tracking
T5.WIT.11: Skull fires every 1.5s

T5.WIT.12: Wither has blue_skull method
T5.WIT.13: Blue skull deals 25 damage
T5.WIT.14: Blue skull has 100px explosion radius
T5.WIT.15: Blue skull has strong tracking
T5.WIT.16: Blue skull cooldown is 8s

T5.WIT.17: Wither has summon_skeletons method
T5.WIT.18: Summon spawns 4 wither skeletons
T5.WIT.19: Wither skeleton has 20 HP
T5.WIT.20: Wither skeleton has wither attack
T5.WIT.21: Summon cooldown is 12s

T5.WIT.22: Wither has life_drain passive
T5.WIT.23: Life drain heals 2 HP per kill
T5.WIT.24: Wither has natural regen 1 HP/5s

T5.WIT.25: Wither enters shield at HP < 50%
T5.WIT.26: Shield blocks ranged damage
T5.WIT.27: Shield allows melee damage
T5.WIT.28: Shield has blue visual effect

T5.WIT.29: WitherEffect script loads
T5.WIT.30: WitherEffect turns hearts black
T5.WIT.31: WitherEffect deals damage over time

T5.WIT.32: Wither drops 200 XP
T5.WIT.33: Wither drops 150 emeralds
T5.WIT.34: Wither has 30% Nether Star drop
T5.WIT.35: WitherSkeleton script and scene load
```

---

## 7. Boss: Ender Dragon 末影龙 (Wave 30 - FINAL)

### 7.1 属性

| 属性 | 数值 |
|------|------|
| HP | 800 |
| 移动速度 | 80 (飞行) |
| 碰撞伤害 | 25 |
| 尺寸 | 64×48 |
| 免疫 | 所有状态效果 |

### 7.2 技能

| 技能 | 伤害 | 冷却 | 描述 |
|------|------|------|------|
| 龙息 | 10 DPS, 5s | 8s | 100px毒云 |
| 俯冲攻击 | 35 | 10s | 1.5s蓄力，400速度 |
| 召唤末影人 | - | 15s | 3个末影人 |
| 末影水晶 | - | 20s | 阶段2专属，回血5HP/s |
| 末影风暴 | 8 DPS | 25s | 阶段3专属，全屏(中央安全) |

### 7.3 阶段

- **HP > 60%**: 天空之王 - 龙息、俯冲、召唤
- **HP 30-60%**: 水晶守护 - 召唤水晶，受伤减半
- **HP < 30%**: 终末之怒 - 解锁风暴，连续俯冲

### 7.4 测试用例 (40个)

```
T5.ED.1: EnderDragon script loads
T5.ED.2: EnderDragon scene loads
T5.ED.3: EnderDragon has correct HP (800)
T5.ED.4: EnderDragon has correct speed (80)
T5.ED.5: EnderDragon has is_flying = true
T5.ED.6: EnderDragon has collision_damage (25)
T5.ED.7: EnderDragon is immune to status effects

T5.ED.8: EnderDragon has dragon_breath method
T5.ED.9: Dragon breath creates poison cloud
T5.ED.10: Dragon breath deals 10 DPS
T5.ED.11: Dragon breath lasts 5 seconds
T5.ED.12: Dragon breath has 100px radius

T5.ED.13: EnderDragon has dive_attack method
T5.ED.14: Dive has 1.5s charge
T5.ED.15: Dive deals 35 damage
T5.ED.16: Dive speed is 400
T5.ED.17: Dive has 250 knockback
T5.ED.18: Dive shows red path warning

T5.ED.19: EnderDragon has summon_endermen method
T5.ED.20: Summon spawns 3 endermen
T5.ED.21: Summon cooldown is 15s

T5.ED.22: EnderDragon enters phase 2 at HP < 60%
T5.ED.23: Phase 2 spawns end crystals
T5.ED.24: End crystal has 30 HP
T5.ED.25: End crystal heals dragon 5 HP/s
T5.ED.26: Dragon takes 50% damage with crystals
T5.ED.27: Crystal explodes on death (50px, 20 dmg)

T5.ED.28: EnderDragon enters phase 3 at HP < 30%
T5.ED.29: Phase 3 unlocks ender storm
T5.ED.30: Ender storm deals 8 DPS
T5.ED.31: Ender storm has safe zone in center (80px)
T5.ED.32: Ender storm lasts 6 seconds
T5.ED.33: Phase 3 enables double dive

T5.ED.34: EnderDragon drops 500 XP
T5.ED.35: EnderDragon drops 300 emeralds
T5.ED.36: EnderDragon drops Dragon Egg (100%)

T5.ED.37: EndCrystal script loads
T5.ED.38: EndCrystal scene loads
T5.ED.39: DragonBreathCloud script loads
T5.ED.40: Victory screen shows on defeat
```

---

## 实施顺序

### 第一阶段: 基础系统 (成就 + 角色)

```
1. 完善 Achievement System
   - 添加成就解锁UI弹窗
   - 添加成就面板到主菜单
   - 实现成就检查逻辑

2. 完善 Character System
   - 创建 Alex 角色资源
   - 添加角色选择UI
   - 实现角色属性应用
```

### 第二阶段: Boss 敌人 (按波次顺序)

```
3. Elder Guardian (Wave 10)
   - 激光攻击系统
   - 疲劳诅咒效果
   - 荆棘反伤

4. Ravager (Wave 15)
   - 冲锋攻击系统
   - 践踏和咆哮

5. Warden (Wave 20)
   - 音波攻击 (无视护甲)
   - 黑暗效果 (视野限制)
   - 多阶段AI

6. Wither (Wave 25)
   - 头颅投射物
   - 凋零状态效果
   - 护盾阶段

7. Ender Dragon (Wave 30)
   - 飞行AI
   - 三阶段战斗
   - 末影水晶机制
   - 胜利画面
```

---

## TDD 工作流程

每个功能遵循：

```
1. 写测试 (RED)
   - 在 tests/test_runner.gd 添加测试用例
   - 运行测试，确认失败

2. 实现功能 (GREEN)
   - 编写最小代码使测试通过
   - 运行测试，确认通过

3. 重构 (REFACTOR)
   - 优化代码结构
   - 运行测试，确认仍然通过

4. 验证覆盖率
   - 运行完整测试套件
   - 确保 100% 覆盖率
```

---

## 资源清单

### 需要创建的资源

| 类型 | 文件 | 描述 |
|------|------|------|
| 角色 | `assets/characters/alex.svg` | Alex 角色精灵 |
| Boss | `assets/characters/elder_guardian.svg` | 远古守卫者 |
| Boss | `assets/characters/ravager.svg` | 劫掠兽 |
| Boss | `assets/characters/warden.svg` | 监守者 |
| Boss | `assets/characters/wither.svg` | 凋灵 |
| Boss | `assets/characters/ender_dragon.svg` | 末影龙 |
| 小怪 | `assets/characters/wither_skeleton.svg` | 凋灵骷髅 |
| 效果 | `assets/effects/laser_beam.svg` | 激光 |
| 效果 | `assets/effects/sonic_boom.svg` | 音波 |
| 效果 | `assets/effects/wither_skull.svg` | 凋灵头颅 |
| 效果 | `assets/effects/dragon_breath.svg` | 龙息 |
| 效果 | `assets/effects/end_crystal.svg` | 末影水晶 |
| UI | `assets/ui/achievements/*.svg` | 成就图标 (15个) |

---

## 验收标准

1. **测试通过**: 所有 ~187 个新测试通过
2. **覆盖率**: 保持 100% 函数覆盖率
3. **游戏流程**:
   - 可以从 Wave 1 打到 Wave 30
   - 击败 Ender Dragon 显示胜利画面
4. **成就系统**:
   - 成就正确解锁
   - 存活15分钟解锁 Alex
5. **角色系统**:
   - Alex 可选择并有正确属性

---

## 时间估算

| 阶段 | 功能 | 复杂度 |
|------|------|--------|
| 1 | Achievement System | 中 |
| 1 | Character System | 低 |
| 2 | Elder Guardian | 中 |
| 2 | Ravager | 中 |
| 2 | Warden | 高 |
| 2 | Wither | 高 |
| 2 | Ender Dragon | 很高 |

---

## 参考文档

- `docs/BOSS_DETAILED_DESIGN.md` - Boss 详细设计
- `docs/design/boss_enemies.md` - Boss 列表
- `docs/phases/phase5_enhancements.md` - Phase 5 完整规划
- `scripts/enemies/evoker.gd` - 已实现的 Boss 参考
