# 游戏数据文档 / Game Data Documentation

## 敌人数据 / Enemy Data

### 敌人总览 / Enemy Overview

| 敌人 | 生命值 | 伤害 | 移动速度 | 经验值 | 肉掉落 | 特殊能力 |
|------|--------|------|----------|--------|--------|----------|
| Zombie 僵尸 | 10 | 10 | 60 | 5 | 0% | 无 |
| Skeleton 骷髅 | 5 | 8 | 40 | 8 | 12% | 远程射箭 |
| Spider 蜘蛛 | 6 | 8 | 100 | 6 | 0% | 跳跃攻击 |
| Creeper 苦力怕 | 12 | 30 | 50 | 10 | 0% | 自爆 |
| Enderman 末影人 | 20 | 15 | 70 | 15 | 0% | 受击瞬移 |
| Witch 女巫 | 10 | 12 | 35 | 12 | 0% | 投掷药水 |

**通用行为 (All Enemies):**
- 所有敌人具有防粘连机制: 当距离玩家 < 30像素时，会受到推开力，防止敌人粘在玩家身上移动
- 精英怪不掉落肉 (Elite monsters do not drop meat)

---

### Zombie 僵尸

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 10 |
| 伤害 (Damage) | 10 |
| 移动速度 (Speed) | 60 |
| 经验值 (XP) | 5 |
| 肉掉落 (Meat Drop) | 0% |

**行为特征:**
- 基础近战敌人
- 直线追踪玩家
- 接触造成伤害
- 可被击退 (knockback_decay: 10.0)
- 防粘连机制: 距离玩家 < 30像素时会被推开

---

### Skeleton 骷髅

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 5 |
| 伤害 (Damage) | 8 |
| 移动速度 (Speed) | 40 |
| 经验值 (XP) | 8 |
| 肉掉落 (Meat Drop) | 12% |
| 攻击范围 (Attack Range) | 300 |
| 攻击冷却 (Attack Cooldown) | 2.0s |
| 首选距离 (Preferred Distance) | 200 |

**行为特征:**
- 远程射箭攻击
- 保持与玩家的距离 (200像素)
- 太近时会后退
- 太远时会靠近
- 在攻击范围内时射箭

---

### Spider 蜘蛛

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 6 |
| 伤害 (Damage) | 8 |
| 移动速度 (Speed) | 100 |
| 经验值 (XP) | 6 |
| 肉掉落 (Meat Drop) | 0% |
| 跳跃距离 (Jump Distance) | 150 |
| 跳跃冷却 (Jump Cooldown) | 3.0s |
| 跳跃速度 (Jump Speed) | 400 |

**行为特征:**
- 高速移动
- 可以向玩家跳跃
- 跳跃时不受击退影响
- 跳跃持续0.2秒

---

### Creeper 苦力怕

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 12 |
| 爆炸伤害 (Explosion Damage) | 30 |
| 移动速度 (Speed) | 50 |
| 经验值 (XP) | 10 |
| 肉掉落 (Meat Drop) | 0% |
| 爆炸半径 (Explosion Radius) | 80 |
| 引信时间 (Fuse Time) | 1.5s |
| 触发距离 (Trigger Distance) | 40 |

**行为特征:**
- 接近玩家时开始倒计时
- 倒计时期间闪烁红白色
- 闪烁频率随时间加快
- 倒计时期间不受击退
- 被击杀不会爆炸
- 爆炸对范围内玩家造成伤害

---

### Enderman 末影人

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 20 |
| 伤害 (Damage) | 15 |
| 移动速度 (Speed) | 70 |
| 经验值 (XP) | 15 |
| 肉掉落 (Meat Drop) | 0% |
| 瞬移冷却 (Teleport Cooldown) | 3.0s |
| 瞬移范围 (Teleport Range) | 200 |
| 箭矢感知半径 (Arrow Detection) | 120 |
| 闪避成功率 (Dodge Chance) | 80% |

**行为特征:**
- 高生命值精英怪
- 受到攻击时瞬移
- **可以主动躲避弓箭** (80%成功率)
- 闪避方向为随机方向 (80-150像素)
- 瞬移到随机位置 (100-200像素范围内)
- 瞬移有3秒冷却时间
- 瞬移产生紫色特效

---

### Witch 女巫

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 10 |
| 药水伤害 (Potion Damage) | 12 |
| 接触伤害 (Contact Damage) | 5 |
| 移动速度 (Speed) | 35 |
| 经验值 (XP) | 12 |
| 攻击范围 (Attack Range) | 250 |
| 攻击冷却 (Attack Cooldown) | 3.0s |
| 首选距离 (Preferred Distance) | 180 |

**行为特征:**
- 远程投掷药水
- 保持与玩家距离
- 药水有轻微随机偏移 (±30像素)
- 接触伤害很低 (5点)
- 死亡产生绿色特效

**毒云数据 (Poison Cloud):**
| 属性 | 数值 |
|------|------|
| 持续时间 (Duration) | 5.0 秒 |
| 直径 (Diameter) | 80 像素 |
| 形状 (Shape) | 圆形 (像素风格) |
| 初始伤害 (Cloud Damage) | 5 |
| 中毒持续 (Poison Duration) | 3.0 秒 |
| 中毒伤害 (Poison Damage) | 2 每跳 |
| 伤害间隔 (Tick Interval) | 0.5 秒 |

**毒云视觉:**
- 圆形像素风格 (非平滑圆形)
- 8x8 像素块组成
- 绿色渐变 (深绿底色 + 亮绿变化)
- 6个浮动粒子动画
- 结束前1秒渐隐

---

## 武器数据 / Weapon Data

### 武器总览 / Weapon Overview

| 武器 | 基础伤害 | 攻击速度 | 范围 | 最大等级 | 特殊能力 |
|------|----------|----------|------|----------|----------|
| Sword 剑 | 5-15 | 0.8-1.2s | 60-90 | 12 | 4阶进化 |
| Bow 弓 | 6 | 0.5/s | 250 | 12 | 进化为弩 |
| Crossbow 弩 | 20 | 3.33/s | 400 | ∞ | 穿透3敌人 |
| Torch 火把 | - | - | - | 3 | 增加夜间可见范围 |

---

### Sword 剑 (4阶进化系统)

**阶段配置:**

| 阶段 | 名称 | 等级范围 | 伤害 | 范围 | 冷却 | 进化击杀数 |
|------|------|----------|------|------|------|------------|
| 1 | Wood Sword 木剑 | 1-3 | 5 | 60 | 1.2s | 50 |
| 2 | Stone Sword 石剑 | 4-6 | 8 | 70 | 1.0s | 150 |
| 3 | Iron Sword 铁剑 | 7-9 | 12 | 80 | 0.9s | 400 |
| 4 | Diamond Sword 钻石剑 | 10-12 | 15 | 90 | 0.8s | - |

**每级升级加成:**
| 属性 | 每级加成 |
|------|----------|
| 伤害 (Damage) | +2 |
| 范围 (Range) | +5 |
| 冷却减少 (Cooldown Reduction) | -5% |

**进化奖励:**

| 进化 | 伤害加成 | 范围加成 | 冷却减少 |
|------|----------|----------|----------|
| Wood → Stone | +5 | +15 | -10% |
| Stone → Iron | +8 | +20 | -15% |
| Iron → Diamond | +12 | +25 | -20% |

**行为特征:**
- 自动攻击范围内所有敌人
- 360度旋转攻击动画
- 可附加击退效果
- 显示攻击范围指示器

---

### Bow 弓

**基础数据:**
| 属性 | 数值 |
|------|------|
| 基础伤害 (Base Damage) | 6 |
| 攻击速度 (Attack Speed) | 0.5 箭/秒 (每2秒1箭) |
| 攻击范围 (Range) | 250 |
| 箭矢速度 (Arrow Speed) | 350 |
| 最大等级 (Max Level) | 12 |

**每级升级加成:**
| 属性 | 每级加成 |
|------|----------|
| 伤害 (Damage) | +2 |
| 攻击速度 (Attack Speed) | +1.0/s |
| 范围 (Range) | +20 |

**等级数据示例:**
| 等级 | 伤害 | 攻击速度 | 范围 |
|------|------|----------|------|
| 1 | 6 | 0.5/s | 250 |
| 6 | 16 | 5.5/s | 350 |
| 11 | 26 | 10.5/s | 450 |
| 12 | 进化为弩 | - | - |

**行为特征:**
- 自动瞄准最近敌人
- 发射单体箭矢
- 等级12时进化为弩

---

### Crossbow 弩 (弓的进化形态)

**基础数据:**
| 属性 | 数值 |
|------|------|
| 基础伤害 (Base Damage) | 20 |
| 攻击速度 (Attack Speed) | 3.33 箭/秒 (~0.3s冷却) |
| 攻击范围 (Range) | 400 |
| 箭矢速度 (Bolt Speed) | 600 |
| 穿透数量 (Pierce Count) | 3 |

**每级升级加成:**
| 属性 | 每级加成 |
|------|----------|
| 伤害 (Damage) | +5 |
| 穿透 (Pierce) | +1 |
| 范围 (Range) | +30 |

**进化奖励 (弓→弩):**
| 属性 | 奖励 |
|------|------|
| 伤害 | +12 |
| 范围 | +100 |
| 穿透 | 3 |

**行为特征:**
- 高速射击 (约0.3秒一发)
- 穿透多个敌人
- 更快的箭矢速度

---

### Torch 火把 (夜间可见范围)

**基础数据:**
| 属性 | 数值 |
|------|------|
| 最大等级 (Max Level) | 3 |
| 基础可见半径 (Base Visibility) | 0.25 (屏幕比例) |
| 位置 | 玩家左侧 |
| 解锁条件 | 第一个夜晚后 |

**等级效果:**
| 等级 | 可见半径 | 效果描述 |
|------|----------|----------|
| 0 (无火把) | 0.25 | 小范围可见，渐变黑暗 |
| 1 | 0.40 | 中等可见范围，圈内清晰 |
| 2 | 0.55 | 较大可见范围，圈内清晰 |
| 3 | 0.85 | 接近全屏可见 |

**特殊机制:**
- 拥有火把时，可见圈内**完全清晰**（无渐变黑暗）
- 拥有火把时，夜间整体变暗效果**被禁用**
- 只有迷雾圈效果保留

---

## 升级/附魔数据 / Upgrade/Enchantment Data

| 附魔 | 描述 | 最大等级 | 每级效果 |
|------|------|----------|----------|
| Sharpness 锋利 | 增加伤害 | 5 | +5 伤害 |
| Knockback 击退 | 增加击退 | 3 | +30 击退力 |
| Looting 抢夺 | 增加经验 | 3 | +20% 经验获取 |
| Protection 保护 | 减少伤害 | 4 | -10% 受到伤害 |
| Swiftness 迅捷 | 增加移速 | 3 | +15% 移动速度 |
| Sweeping Edge 横扫 | 增加剑范围 | 3 | +20 攻击范围 |
| Haste 急迫 | 减少冷却 | 3 | -10% 攻击冷却 |

---

## 物品数据 / Item Data

### 拾取物总览 / Pickup Overview

| 物品 | 效果 | 获取方式 | 概率/间隔 |
|------|------|----------|-----------|
| XP Orb 经验球 | +5 经验 | 击杀敌人 | 100% |
| Meat 肉 | +10 生命 (1心) | 击杀敌人掉落 | 10-25% |
| Golden Apple 金苹果 | +50% 最大生命 | 地图刷新 | 每20秒 |

---

### Meat 肉 (敌人掉落)

**基础数据:**
| 属性 | 数值 |
|------|------|
| 治疗量 (Heal Amount) | 10 HP (1心) |
| 吸引半径 (Attract Radius) | 100 像素 |
| 吸引速度 (Attract Speed) | 300 |
| 消失时间 (Despawn Time) | 15 秒 |

**掉落概率 (按敌人):**
| 敌人 | 掉落概率 |
|------|----------|
| Zombie 僵尸 | 0% |
| Skeleton 骷髅 | 12% |
| Spider 蜘蛛 | 0% |
| Creeper 苦力怕 | 0% |
| Witch 女巫 | 0% |
| Enderman 末影人 | 0% |
| Elite 精英怪 | 0% (强制) |

> 注: 目前仅骷髅掉落肉。精英怪的肉掉落概率被强制设为0。
> Note: Currently only Skeletons drop meat. Elite monsters have meat drop forced to 0%.

---

### Golden Apple 金苹果 (地图刷新)

**基础数据:**
| 属性 | 数值 |
|------|------|
| 治疗量 (Heal Amount) | 50% 最大生命 |
| 吸引半径 (Attract Radius) | 120 像素 |
| 吸引速度 (Attract Speed) | 250 |
| 消失时间 (Despawn Time) | 30 秒 |

**刷新机制:**
| 属性 | 数值 |
|------|------|
| 刷新间隔 (Spawn Interval) | 20 秒 |
| 最短间隔 (Min Interval) | 15 秒 |
| 最大数量 (Max Pickups) | 3 个 |
| 初始延迟 (Initial Delay) | 30 秒 |
| 刷新范围 (Spawn Radius) | 200-500 像素 |

**动态调整:**
- 玩家血量 < 30%: 刷新间隔降至最短 (15秒)
- 玩家血量 < 50%: 刷新间隔减半

---

### XP Orb 经验球

**基础数据:**
| 属性 | 数值 |
|------|------|
| 基础经验值 (Base XP) | 5 |
| 吸引半径 (Attract Radius) | 100 像素 |
| 拾取半径 (Pickup Radius) | 20 像素 |
| 缩放 (Scale) | 0.6 |

---

## Boss数据 / Boss Data

### Boss总览 / Boss Overview

Boss敌人在特定波次出现，具有高生命值和独特能力。所有Boss都有详细的像素风格SVG贴图。

Boss enemies appear at specific waves with high HP and unique abilities. All bosses have detailed pixel art SVG sprites.

| Boss | 波次 Wave | 生命值 HP | 经验值 XP | 特殊能力 Special |
|------|-----------|-----------|-----------|------------------|
| Evoker 唤魔者 | 5 | 400 | 200 | 召唤尖牙 Summons fangs |
| Elder Guardian 远古守卫者 | 10 | 600 | 300 | 挖掘疲劳光束 Mining fatigue beam |
| Ravager 劫掠兽 | 15 | 2400 | 400 | 冲撞+践踏 Charge + Stomp |
| Warden 监守者 | 20 | 3000 | 600 | 音波+近战+地震+黑暗光环+狂暴 Sonic boom + Melee + Ground Slam + Darkness Aura + Enrage |
| Wither 凋灵 | 25 | 3600 | 800 | 追踪凋灵骷髅头 Homing wither skulls |
| Ender Dragon 末影龙 | 30 | 4500 | 1200 | 追踪龙息火球+俯冲 Homing fireballs + dive |

> Boss在波次30后循环出现 (波次35=唤魔者, 40=远古守卫者...)，并按周期缩放属性。
> Bosses cycle after wave 30 (wave 35=Evoker, 40=Elder Guardian...) with scaling applied per cycle.

---

### Evoker 唤魔者

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 400 |
| 出现波次 (Spawn Wave) | 5 |

**行为特征:**
- 远程魔法攻击者
- 召唤尖牙从地面攻击玩家

---

### Elder Guardian 远古守卫者

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 600 |
| 出现波次 (Spawn Wave) | 10 |

**行为特征:**
- 发射挖掘疲劳光束
- 减缓玩家攻击速度

---

### Ravager 劫掠兽

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 2400 |
| 出现波次 (Spawn Wave) | 15 |

**行为特征:**
- 强力近战Boss
- 冲撞攻击造成大量伤害

---

### Warden 监守者

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 3000 |
| 出现波次 (Spawn Wave) | 20 |
| 接触伤害 (Contact Damage) | 40 |
| 移动速度 (Speed) | 35 |
| 经验值 (XP) | 600 |
| 伤害减免 (Damage Reduction) | 30% |
| 击退免疫 (Knockback Immune) | 是 Yes |

**攻击技能 / Attacks:**

| 技能 | 伤害 | 范围 | 冷却 | 说明 |
|------|------|------|------|------|
| Sonic Boom 音波 | 65 | 400px | 4.0s | 怒气≥20时触发 Fires when anger ≥ 20 |
| Melee 近战 | 55 | 80px | 1.5s | 近距离重击 Close-range heavy hit |
| Ground Slam 地震 | 45 | 150px | 6.0s | 玩家≤200px时触发 AoE when player ≤ 200px |

**黑暗光环 / Darkness Aura:**
- 玩家在350px范围内时，迷雾可见半径减少40%
- When player is within 350px, fog visibility radius reduced by 40%
- 监守者死亡时自动恢复 Auto-restores on Warden death

**狂暴阶段 / Enrage Phase (< 50% HP):**
| 属性 | 效果 |
|------|------|
| 速度 (Speed) | x1.5 |
| 攻击冷却 (Cooldowns) | x0.6 (40%更快 40% faster) |
| 怒气 (Anger) | 永久满值 Permanently maxed |
| 视觉 (Visual) | 红色染色 Red tint |

**怒气系统 / Anger System:**
| 触发 | 怒气增量 |
|------|----------|
| 玩家移动 (Player movement) | +25/tick |
| 受到伤害 (Taking damage) | +35 |
| 音波后衰减 (Post sonic boom) | -15 |
| 追踪阈值 (Tracking threshold) | 50 |
| 音波阈值 (Sonic boom threshold) | 20 |

**行为特征:**
- 高生命值近战Boss
- 音波攻击远程伤害
- 地震践踏AoE伤害
- 黑暗光环限制玩家视野
- 低血量狂暴加速攻击

---

### Wither 凋灵

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 3600 |
| 出现波次 (Spawn Wave) | 25 |

**行为特征:**
- 三头Boss敌人
- 发射追踪凋灵骷髅头 (追踪转速 2.5 rad/s)
- 骷髅头造成凋零(中毒)效果
- Fires homing wither skulls (2.5 rad/s turn rate) that apply wither/poison

---

### Ender Dragon 末影龙

**基础数据:**
| 属性 | 数值 |
|------|------|
| 生命值 (Health) | 4500 |
| 出现波次 (Spawn Wave) | 30 |

**行为特征:**
- 最终Boss
- 发射追踪龙息火球 (追踪转速 1.8 rad/s) + 俯冲攻击
- Fires homing dragon fireballs (1.8 rad/s turn rate) + dive attack

---

## 精英怪系统 / Elite Monster System

精英怪是普通敌人的强化版本，带有金色轮廓和特殊能力。
Elite monsters are enhanced versions of normal enemies with golden outline and special abilities.

### 精英属性倍率 / Elite Stat Multipliers

| 属性 | 倍率 |
|------|------|
| 生命值 (HP) | 2.5x |
| 伤害 (Damage) | 1.5x |
| 速度 (Speed) | 1.2x |
| 经验值 (XP) | 20x |
| 体型 (Scale) | 1.3x |
| 肉掉落 (Meat) | 0% (强制) |

### 精英出现概率 / Elite Spawn Chance (Waves 1-30)

| 波次 | 概率 | 最大数量 |
|------|------|----------|
| 1-3 | 0% | 0 |
| 4-6 | 5% | 2 |
| 7-9 | 10% | 2 |
| 10-14 | 15% | 3 |
| 15-19 | 20% | 4 |
| 20-30 | 25% | 5 |

- 夜间额外 +10% 出现概率 (Night bonus: +10%)

### 精英特殊能力 / Elite Special Abilities

| 敌人 | 精英能力 |
|------|----------|
| Zombie 僵尸 | Undead Rally 亡灵集结 (召唤2只普通僵尸) |
| Skeleton 骷髅 | Multi-Shot 多重射击 (3方向射箭) |
| Spider 蜘蛛 | Venom 毒液 (造成中毒效果) |
| Creeper 苦力怕 | Charged 充能 (更大爆炸范围) |
| Enderman 末影人 | Void Strike 虚空打击 (传送至玩家身后攻击) |
| Witch 女巫 | Potion Storm 药水风暴 (投掷3瓶药水) |

---

## 波次缩放系统 / Wave Scaling System (Post-Wave 30)

波次30后敌人属性无限缩放，为无尽玩法提供挑战。
After wave 30, enemy stats scale infinitely for endless endgame challenge.

### 普通敌人缩放 / Normal Enemy Scaling (per wave past 30)

| 属性 | 每波增长 | 示例 (波次40) | 示例 (波次50) |
|------|----------|---------------|---------------|
| 生命值 (HP) | +10% | 2.0x | 3.0x |
| 伤害 (Damage) | +5% | 1.5x | 2.0x |
| 速度 (Speed) | +2% (上限+50%) | 1.2x | 1.4x |
| 经验值 (XP) | +10% | 2.0x | 3.0x |

### Boss缩放 / Boss Scaling (per 5-wave cycle past 30)

| 属性 | 每周期增长 | 示例 (波次35) | 示例 (波次50) |
|------|------------|---------------|---------------|
| 生命值 (HP) | +50% | 1.5x | 3.0x |
| 伤害 (Damage) | +25% | 1.25x | 2.0x |
| 速度 (Speed) | +10% (上限+100%) | 1.1x | 1.4x |
| 经验值 (XP) | 与HP相同 | 1.5x | 3.0x |

### 精英缩放 / Elite Scaling (post-wave 30)

| 属性 | 缩放规则 |
|------|----------|
| 出现概率 | 25% + 1%/波, 上限50% |
| 最大数量 | 5 + 1/每5波 |
| 夜间加成 | +10% (不变) |

**示例 / Examples:**
- 波次35: 概率30%, 最大6只
- 波次50: 概率45%, 最大8只
- 波次80: 概率50%(上限), 最大15只

### 安全上限 / Safety Caps

| 属性 | 上限 |
|------|------|
| 生命值 (HP) | 2,147,483,647 (2^31-1) |
| 伤害 (Damage) | 100,000 |
| 经验值 (XP) | 1,000,000 |

---

## 放置模式 / Idle Mode (Auto-Play)

放置模式让AI自动控制玩家角色，自动闪避攻击、收集物品和选择升级。
Idle mode lets AI automatically control the player: dodge attacks, collect items, and select upgrades.

### 解锁条件 / Unlock Requirement

| 条件 | 详情 |
|------|------|
| 成就 (Achievement) | Idle Master / 放置大师 |
| 目标 (Target) | 存活超过30波 (wave 31+) |
| 切换键 (Toggle Key) | Tab |

### AI行为优先级 / AI Behavior Priority

| 优先级 | 行为 | 描述 |
|--------|------|------|
| 1 | 闪避投射物 (Dodge projectiles) | 垂直于投射物方向闪避 |
| 2 | 逃离敌人 (Flee enemies) | 距离 < 100像素时逃离，按距离加权 |
| 3 | 收集拾取物 (Collect pickups) | 150像素内收集XP和血量道具 |
| 4 | 闲逛 (Wander) | 缓慢环绕移动，避免站立不动 |

### 升级策略 / Upgrade Strategies

| 策略 | 优先顺序 |
|------|----------|
| WEAPON_FIRST (默认) | 武器升级 > Sharpness/Haste > Sweeping Edge > 其他 |
| BALANCED | 随机选择武器和附魔 |
| DEFENSIVE | Protection/Swiftness > 武器升级 > 其他 |

### 参数 / Parameters

| 参数 | 数值 |
|------|------|
| 逃离距离 (Flee distance) | 100 像素 |
| 安全距离 (Safe distance) | 200 像素 |
| 拾取半径 (Pickup radius) | 150 像素 |
| 自动选择超时 (Auto-select timeout) | 5 秒 |

---

## 版本信息 / Version Info

- 文档版本: 2.2
- 游戏版本: Phase 7
- 更新日期: 2026-02-11

### 更新记录 / Changelog
- v2.2: 添加放置模式/自动玩法系统 (Idle Mode auto-play system)
- v2.1: 更新Warden详细数据 (黑暗光环、地震践踏、狂暴阶段、加速怒气系统)
- v2.0: 添加精英怪系统、波次缩放系统、修正敌人HP/肉掉落数据、Boss XP值
- v1.5: 添加Boss数据 (Evoker, Elder Guardian, Ravager, Warden, Wither, Ender Dragon)
- v1.4: 弓每级升级攻速改为+1.0/s (原+0.1/s)
- v1.3: 更新弓数据(伤害6,攻速0.5,12级进化)、添加火把武器数据、Enderman闪避机制
- v1.2: 添加毒云详细数据、敌人防粘连机制说明
- v1.1: 添加物品掉落数据
- v1.0: 初始文档
