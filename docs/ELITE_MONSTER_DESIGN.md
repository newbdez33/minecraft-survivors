# Elite Monster System Design / 精英怪物系统设计

本文档详细描述精英怪物系统的设计方案。

---

## Overview / 概述

精英怪物是普通怪物的强化版本，拥有更高的属性、特殊视觉效果和额外能力。

**设计目标:**
- 增加游戏中后期挑战性
- 提供更高的奖励激励
- 丰富战斗体验
- 不改变核心玩法

---

## Elite Monster Stats / 精英怪物属性

### Stat Multipliers / 属性倍率

| Attribute | Elite Multiplier | Description |
|-----------|------------------|-------------|
| HP / 生命值 | **2.5x** | 更持久的战斗 |
| Damage / 伤害 | **1.5x** | 更高威胁 |
| Speed / 移速 | **1.2x** | 稍快但不过分 |
| XP Value / 经验值 | **5x** | 高额奖励 |
| Size / 体型 | **1.3x** | 视觉区分 |
| Meat Drop / 肉掉落 | **100%** | 必定掉落 |

---

## Elite Enemies / 精英敌人列表

### Elite Zombie / 精英僵尸

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Zombie | Elite Zombie |
| Japanese Name | ゾンビ | エリートゾンビ |
| Chinese Name | 僵尸 | 精英僵尸 |
| HP | 20 | **50** |
| Damage | 10 | **15** |
| Speed | 60 | **72** |
| XP Value | 5 | **25** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效 (Golden outline glow)
- 红色眼睛 (Red glowing eyes)
- 头戴铁头盔 (Iron helmet)

**Special Ability / 特殊能力:**
- **亡灵召唤 (Undead Rally)**: 死亡时有50%几率召唤2只普通僵尸

---

### Elite Skeleton / 精英骷髅

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Skeleton | Elite Skeleton |
| Japanese Name | スケルトン | エリートスケルトン |
| Chinese Name | 骷髅 | 精英骷髅 |
| HP | 15 | **38** |
| Damage | 8 | **12** |
| Speed | 40 | **48** |
| XP Value | 8 | **40** |
| Attack Cooldown | 2.0s | **1.5s** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效
- 穿戴锁子甲 (Chainmail armor)
- 持有附魔弓 (Enchanted bow glow)

**Special Ability / 特殊能力:**
- **多重射击 (Multi-Shot)**: 每次攻击发射3支箭 (扇形分布)

---

### Elite Spider / 精英蜘蛛

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Spider | Elite Spider |
| Japanese Name | クモ | エリートクモ |
| Chinese Name | 蜘蛛 | 精英蜘蛛 |
| HP | 12 | **30** |
| Damage | 8 | **12** |
| Speed | 100 | **120** |
| XP Value | 6 | **30** |
| Jump Cooldown | 3.0s | **2.0s** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效
- 深紫色身体 (Dark purple body) - 洞穴蜘蛛风格
- 毒液滴落特效 (Dripping venom effect)

**Special Ability / 特殊能力:**
- **毒液攻击 (Venom Strike)**: 攻击附带3秒中毒效果 (2伤害/0.5秒)

---

### Elite Creeper / 精英苦力怕

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Creeper | Elite Creeper |
| Japanese Name | クリーパー | エリートクリーパー |
| Chinese Name | 苦力怕 | 精英苦力怕 |
| HP | 25 | **63** |
| Explosion Damage | 30 | **45** |
| Speed | 50 | **60** |
| XP Value | 10 | **50** |
| Explosion Radius | 80 | **120** |
| Fuse Time | 1.5s | **1.2s** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效
- 闪电纹理 (Lightning pattern) - 高压苦力怕风格
- 蓝色电弧特效 (Blue electric sparks)

**Special Ability / 特殊能力:**
- **闪电爆炸 (Charged Explosion)**: 爆炸时产生闪电链，对120像素内所有敌人造成额外15点伤害

---

### Elite Enderman / 精英末影人

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Enderman | Elite Enderman |
| Japanese Name | エンダーマン | エリートエンダーマン |
| Chinese Name | 末影人 | 精英末影人 |
| HP | 40 | **100** |
| Damage | 15 | **23** |
| Speed | 70 | **84** |
| XP Value | 15 | **75** |
| Teleport Cooldown | 3.0s | **2.0s** |
| Dodge Chance | 80% | **95%** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效
- 白色眼睛 (White glowing eyes) - 更亮
- 紫色粒子更密集 (Dense purple particles)
- 手持末地水晶 (Holding End crystal)

**Special Ability / 特殊能力:**
- **虚空打击 (Void Strike)**: 攻击后立即传送到玩家背后再次攻击 (双重打击)

---

### Elite Witch / 精英女巫

| Attribute | Normal | Elite |
|-----------|--------|-------|
| English Name | Witch | Elite Witch |
| Japanese Name | ウィッチ | エリートウィッチ |
| Chinese Name | 女巫 | 精英女巫 |
| HP | 20 | **50** |
| Potion Damage | 12 | **18** |
| Speed | 35 | **42** |
| XP Value | 12 | **60** |
| Attack Cooldown | 3.0s | **2.0s** |

**Visual Differences / 视觉差异:**
- 体型增大 1.3x
- 金色轮廓光效
- 紫色长袍 (Purple robe) - 替代黑色
- 魔法光环 (Magic aura around)
- 手持附魔书 (Holding enchanted book)

**Special Ability / 特殊能力:**
- **药水风暴 (Potion Storm)**: 同时投掷3瓶药水 (扇形分布)，毒云持续时间+2秒

---

## Spawn System / 生成系统

### Spawn Conditions / 生成条件

| Condition | Elite Spawn Chance |
|-----------|-------------------|
| Wave 1-3 | 0% (无精英) |
| Wave 4-6 | 5% |
| Wave 7-9 | 10% |
| Wave 10-14 | 15% |
| Wave 15-19 | 20% |
| Wave 20+ | 25% |
| Night Time | +10% (额外加成) |

### Spawn Rules / 生成规则

```gdscript
# 精英生成逻辑
func _should_spawn_elite() -> bool:
    var base_chance = _get_elite_chance_for_wave(current_wave)

    # 夜间额外加成
    if is_night:
        base_chance += 0.10

    # 最大25%几率
    base_chance = min(base_chance, 0.25)

    return randf() < base_chance

func _get_elite_chance_for_wave(wave: int) -> float:
    if wave <= 3:
        return 0.0
    elif wave <= 6:
        return 0.05
    elif wave <= 9:
        return 0.10
    elif wave <= 14:
        return 0.15
    elif wave <= 19:
        return 0.20
    else:
        return 0.25
```

### Maximum Elite Count / 最大精英数量

| Wave Range | Max Elites on Screen |
|------------|---------------------|
| Wave 4-9 | 2 |
| Wave 10-14 | 3 |
| Wave 15-19 | 4 |
| Wave 20+ | 5 |

---

## Visual Design / 视觉设计

### Elite Indicator / 精英标识

所有精英怪物共享以下视觉特征:

1. **金色轮廓 (Golden Outline)**
   - 2像素金色描边
   - 颜色: #FFD700 (Gold)
   - 轻微脉动效果 (0.5秒周期)

2. **体型增大 (Size Increase)**
   - 1.3x 缩放
   - 保持像素完美

3. **精英图标 (Elite Icon)**
   - 头顶显示 ⭐ 星星图标
   - 或皇冠图标 👑

4. **特殊粒子 (Special Particles)**
   - 金色闪光粒子环绕
   - 每秒3-5个粒子

### Color Palette / 颜色方案

| Element | Color | Hex |
|---------|-------|-----|
| Elite Outline | Gold | #FFD700 |
| Elite Glow | Light Gold | #FFECB3 |
| Elite Star | Yellow | #FFFF00 |
| Elite Particle | Gold Sparkle | #FFC107 |

### Shader Implementation / 着色器实现

```glsl
// elite_outline.gdshader
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.84, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (tex.a < 0.5) {
        // Check neighboring pixels for outline
        float outline = 0.0;
        for (float x = -outline_width; x <= outline_width; x += 1.0) {
            for (float y = -outline_width; y <= outline_width; y += 1.0) {
                vec2 offset = vec2(x, y) / vec2(textureSize(TEXTURE, 0));
                if (texture(TEXTURE, UV + offset).a > 0.5) {
                    outline = 1.0;
                }
            }
        }

        if (outline > 0.0) {
            float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
            COLOR = outline_color * (0.7 + pulse * 0.3);
        } else {
            COLOR = tex;
        }
    } else {
        COLOR = tex;
    }
}
```

---

## Implementation Plan / 实现计划

### Phase 1: Core System / 核心系统

1. **创建 EliteEnemy 基类**
   ```
   scripts/enemies/elite_enemy_base.gd
   ```
   - 继承自普通敌人
   - 应用属性倍率
   - 添加精英视觉效果

2. **修改 Spawner**
   ```
   scripts/spawner.gd
   ```
   - 添加精英生成判定
   - 精英数量限制
   - 波次相关几率

3. **创建精英着色器**
   ```
   assets/shaders/elite_outline.gdshader
   ```
   - 金色轮廓效果
   - 脉动动画

### Phase 2: Individual Elites / 单独精英

为每个敌人创建精英版本:

| Enemy | Elite Script | Elite Scene |
|-------|--------------|-------------|
| Zombie | elite_zombie.gd | elite_zombie.tscn |
| Skeleton | elite_skeleton.gd | elite_skeleton.tscn |
| Spider | elite_spider.gd | elite_spider.tscn |
| Creeper | elite_creeper.gd | elite_creeper.tscn |
| Enderman | elite_enderman.gd | elite_enderman.tscn |
| Witch | elite_witch.gd | elite_witch.tscn |

### Phase 3: Special Abilities / 特殊能力

实现每个精英的独特能力:

| Elite | Ability | Implementation |
|-------|---------|----------------|
| Zombie | Undead Rally | 死亡时 spawn 2 zombies |
| Skeleton | Multi-Shot | 修改箭矢发射为3发 |
| Spider | Venom Strike | 攻击添加毒效果 |
| Creeper | Charged Explosion | 爆炸添加连锁伤害 |
| Enderman | Void Strike | 攻击后传送+二次攻击 |
| Witch | Potion Storm | 投掷3瓶药水 |

### Phase 4: Polish / 完善

1. 精英死亡特效 (更大的爆炸)
2. 精英出现音效
3. HUD 精英击杀计数
4. 成就系统集成

---

## Balance Considerations / 平衡性考虑

### Difficulty Curve / 难度曲线

```
Wave 1-3:   无精英，学习阶段
Wave 4-6:   5%几率，初见精英
Wave 7-9:   10%几率，适应精英
Wave 10-14: 15%几率，中期挑战
Wave 15-19: 20%几率，后期压力
Wave 20+:   25%几率，生存挑战
```

### Risk vs Reward / 风险与回报

| Elite Type | Risk Level | XP Reward | Worth It? |
|------------|------------|-----------|-----------|
| Elite Zombie | Low | 25 | ✅ Easy farm |
| Elite Skeleton | Medium | 40 | ✅ Good if ranged |
| Elite Spider | Medium | 30 | ⚠️ Poison danger |
| Elite Creeper | High | 50 | ⚠️ Explosion risk |
| Elite Enderman | High | 75 | ⚠️ Hard to hit |
| Elite Witch | Medium | 60 | ✅ Predictable |

### Counter Strategies / 应对策略

| Elite | Recommended Upgrades |
|-------|---------------------|
| Elite Zombie | Knockback, Swiftness |
| Elite Skeleton | Protection, Swiftness |
| Elite Spider | Protection (poison resist) |
| Elite Creeper | Swiftness, Knockback |
| Elite Enderman | Haste (fast attacks) |
| Elite Witch | Swiftness (dodge potions) |

---

## Test Cases / 测试用例

### Unit Tests

```gdscript
func _test_elite_system() -> void:
    # T6.E.1: Elite base class exists
    var elite_script = load("res://scripts/enemies/elite_enemy_base.gd")
    _assert_not_null(elite_script, "T6.E.1: Elite base class exists")

    # T6.E.2: Elite has stat multipliers
    _assert_true("HP_MULTIPLIER" in elite_script, "T6.E.2: Has HP_MULTIPLIER")
    _assert_true("DAMAGE_MULTIPLIER" in elite_script, "T6.E.3: Has DAMAGE_MULTIPLIER")
    _assert_true("SPEED_MULTIPLIER" in elite_script, "T6.E.4: Has SPEED_MULTIPLIER")
    _assert_true("XP_MULTIPLIER" in elite_script, "T6.E.5: Has XP_MULTIPLIER")

    # T6.E.6: Elite Zombie exists
    var elite_zombie = load("res://scenes/enemies/elite_zombie.tscn")
    _assert_not_null(elite_zombie, "T6.E.6: Elite Zombie scene exists")

    # T6.E.7-12: All elite scenes exist
    # ... similar for other elites

    # T6.E.13: Spawner has elite spawn logic
    var spawner = load("res://scripts/spawner.gd")
    _assert_true(spawner.has_method("_should_spawn_elite"), "T6.E.13: Spawner has elite logic")

    # T6.E.14: Elite outline shader exists
    var shader = load("res://assets/shaders/elite_outline.gdshader")
    _assert_not_null(shader, "T6.E.14: Elite shader exists")
```

### Integration Tests

1. **精英生成测试**: Wave 4+ 确认精英可以生成
2. **属性倍率测试**: 精英HP/伤害/速度正确
3. **特殊能力测试**: 每个精英能力正常触发
4. **视觉效果测试**: 金色轮廓正确显示
5. **掉落测试**: 精英必定掉落肉

---

## Localization / 本地化

### Translation Keys

```csv
keys,en,ja,zh
ELITE_PREFIX,Elite,エリート,精英
ELITE_ZOMBIE,Elite Zombie,エリートゾンビ,精英僵尸
ELITE_SKELETON,Elite Skeleton,エリートスケルトン,精英骷髅
ELITE_SPIDER,Elite Spider,エリートクモ,精英蜘蛛
ELITE_CREEPER,Elite Creeper,エリートクリーパー,精英苦力怕
ELITE_ENDERMAN,Elite Enderman,エリートエンダーマン,精英末影人
ELITE_WITCH,Elite Witch,エリートウィッチ,精英女巫
ELITE_KILLED,Elite Killed!,エリート撃破！,击杀精英！
```

---

## Summary Table / 总结表

| Enemy | JP Name | CN Name | HP | DMG | SPD | XP | Special Ability |
|-------|---------|---------|-----|-----|-----|-----|-----------------|
| Elite Zombie | エリートゾンビ | 精英僵尸 | 50 | 15 | 72 | 25 | 死亡召唤2只僵尸 |
| Elite Skeleton | エリートスケルトン | 精英骷髅 | 38 | 12 | 48 | 40 | 3箭齐发 |
| Elite Spider | エリートクモ | 精英蜘蛛 | 30 | 12 | 120 | 30 | 攻击附带中毒 |
| Elite Creeper | エリートクリーパー | 精英苦力怕 | 63 | 45 | 60 | 50 | 闪电连锁爆炸 |
| Elite Enderman | エリートエンダーマン | 精英末影人 | 100 | 23 | 84 | 75 | 双重打击 |
| Elite Witch | エリートウィッチ | 精英女巫 | 50 | 18 | 42 | 60 | 3药水风暴 |

---

## Version Info

- Document Version: 1.0
- Created: 2026-01-26
- Status: Design Phase
- Target Implementation: Phase 6
