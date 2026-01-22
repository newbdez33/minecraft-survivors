# Art Asset Plan - Minecraft Survivors

本文档详细列出游戏所需的所有美术资源。

## 美术风格

- **风格**: Minecraft 像素风格 (16x16 或 32x32 像素)
- **视角**: 俯视角 (Top-down) - 不是 Minecraft 原版的侧视角
- **调色板**: 使用 Minecraft 的经典配色

```
俯视角示例:
    ┌───┐
    │ @ │  ← 从上往下看 Steve
    └───┘
```

---

## 一、角色贴图 (Characters)

### 1. Steve (玩家)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `steve_idle.png` | 32x32 | Steve 站立 |
| `steve_walk_down.png` | 32x32 x 4帧 | Steve 向下走动画 |
| `steve_walk_up.png` | 32x32 x 4帧 | Steve 向上走动画 |
| `steve_walk_left.png` | 32x32 x 4帧 | Steve 向左走动画 |
| `steve_walk_right.png` | 32x32 x 4帧 | Steve 向右走动画 |

**简化版** (如果不想做动画):
| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `steve.png` | 32x32 | Steve 单帧 (俯视角) |

**Steve 俯视角参考**:
```
    ┌──────┐
    │ 棕棕 │  ← 头发 (棕色)
    │ 肤肤 │  ← 脸 (肤色)
    │ 蓝蓝 │  ← 衣服 (青色/蓝色)
    │ 蓝蓝 │
    └──────┘
```

颜色参考:
- 头发: `#4A3728` (深棕色)
- 皮肤: `#B87D56` (肤色)
- 衣服: `#00AAAA` (青色)
- 裤子: `#3C3C64` (深蓝色)

---

### 2. Zombie (僵尸) - 基础敌人

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `zombie.png` | 32x32 | Zombie 单帧 |
| `zombie_walk.png` | 32x32 x 4帧 | (可选) 走路动画 |

**Zombie 俯视角参考**:
```
    ┌──────┐
    │ 绿绿 │  ← 头 (绿色)
    │ 绿绿 │  ← 脸 (深绿色)
    │ 青青 │  ← 衣服 (青色，破烂)
    │ 蓝蓝 │  ← 裤子 (蓝色)
    └──────┘
```

颜色参考:
- 皮肤: `#7BC45C` (僵尸绿)
- 深色: `#597D35` (阴影绿)
- 衣服: `#49A5A5` (破烂青色)
- 裤子: `#3C3C8C` (蓝色)

---

### 3. Skeleton (骷髅) - 远程敌人

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `skeleton.png` | 32x32 | Skeleton 单帧 |

**颜色参考**:
- 骨头: `#C8C8C8` (浅灰色)
- 阴影: `#8B8B8B` (深灰色)
- 眼睛: `#1A1A1A` (黑色)

---

### 4. Creeper (苦力怕) - 爆炸敌人

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `creeper.png` | 32x32 | Creeper 单帧 |
| `creeper_flash.png` | 32x32 | (可选) 爆炸前闪烁 (白色) |

**Creeper 俯视角参考**:
```
    ┌──────┐
    │ ▓░▓░ │  ← 绿色迷彩
    │ █  █ │  ← 眼睛 (黑色)
    │ ▓░▓░ │
    │ ░▓░▓ │
    └──────┘
```

颜色参考:
- 浅绿: `#6AAB4E`
- 深绿: `#4E8B3A`
- 眼睛/嘴: `#000000` (黑色)

---

### 5. Spider (蜘蛛) - 快速敌人

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `spider.png` | 48x32 | Spider (稍宽，因为有腿) |

颜色参考:
- 身体: `#4A4040` (深灰棕)
- 眼睛: `#CC0000` (红色)

---

## 二、武器贴图 (Weapons)

### 1. Diamond Sword (钻石剑)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `diamond_sword.png` | 16x16 | 钻石剑图标 |
| `sword_slash.png` | 64x64 x 4帧 | (可选) 挥剑特效 |

颜色参考:
- 剑刃: `#33EBCB` (钻石青色)
- 剑柄: `#8B5A2B` (棕色)

---

### 2. Bow & Arrow (弓箭) - Phase 3

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `bow.png` | 16x16 | 弓图标 |
| `arrow.png` | 16x8 | 箭矢 |

---

## 三、物品贴图 (Items)

### 1. XP Orb (经验球)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `xp_orb.png` | 16x16 | 经验球 (绿色发光) |
| `xp_orb_anim.png` | 16x16 x 4帧 | (可选) 动画版本 |

颜色参考:
- 核心: `#AEFF00` (亮黄绿)
- 外圈: `#5EFF00` (绿色)
- 发光: `#CCFF00` (黄绿色)

---

### 2. Heart (爱心/生命值)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `heart_full.png` | 16x16 | 满心 |
| `heart_half.png` | 16x16 | 半心 |
| `heart_empty.png` | 16x16 | 空心 |

颜色参考:
- 红色: `#FF0000`
- 深红: `#AA0000`
- 空心: `#555555`

---

## 四、场景贴图 (Environment)

### 1. 地面 (Ground Tiles)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `grass.png` | 32x32 | 草地 |
| `grass_variant1.png` | 32x32 | 草地变体1 (小花) |
| `grass_variant2.png` | 32x32 | 草地变体2 (小草) |
| `dirt.png` | 32x32 | 泥土 |
| `stone.png` | 32x32 | (可选) 石头 |

**草地俯视角参考**:
```
┌────────────────┐
│ ░░▒░░░▒░░░░▒░░ │  深浅不一的绿色
│ ░░░░▒░░░▒░░░░░ │  偶尔有小花/草
│ ░▒░░░░░░░░▒░░░ │
│ ░░░░░▒░░░░░░▒░ │
└────────────────┘
```

颜色参考:
- 草地浅: `#7CBD6B`
- 草地深: `#5A9C4A`
- 泥土: `#8B6B47`

---

## 五、UI 贴图 (User Interface)

### 1. 血条 / HUD

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `hotbar_bg.png` | 182x22 | (可选) 快捷栏背景 |
| `ui_frame.png` | 可变 | UI 边框 |

---

## 六、特效贴图 (Effects)

| 文件名 | 尺寸 | 描述 |
|--------|------|------|
| `hit_effect.png` | 32x32 x 4帧 | 击中特效 |
| `death_poof.png` | 32x32 x 5帧 | 死亡烟雾 |
| `explosion.png` | 64x64 x 6帧 | Creeper 爆炸 |

---

## 资源获取方式

### 方案 A: 自己绘制 (推荐学习)
- 使用免费像素画工具:
  - **Aseprite** (付费，但很专业)
  - **Piskel** (免费，在线) - https://www.piskelapp.com/
  - **LibreSprite** (免费，Aseprite 开源版)
  - **Pixilart** (免费，在线) - https://www.pixilart.com/

### 方案 B: 使用免费素材
- **OpenGameArt** - https://opengameart.org/
  - 搜索 "top down rpg" 或 "pixel art characters"
- **Itch.io** - https://itch.io/game-assets/free
  - 很多免费像素素材包
- **Kenney** - https://kenney.nl/assets
  - 高质量免费素材

### 方案 C: 使用 AI 生成
- 使用 AI 图片生成工具生成基础图，再用像素画工具调整

### 方案 D: 委托/购买
- Fiverr, 淘宝等平台找人绘制
- 购买现成的 Minecraft 风格素材包

---

## 文件夹结构

```
assets/
├── characters/
│   ├── steve.png
│   ├── zombie.png
│   ├── skeleton.png
│   ├── creeper.png
│   └── spider.png
├── weapons/
│   ├── diamond_sword.png
│   ├── bow.png
│   └── arrow.png
├── items/
│   ├── xp_orb.png
│   ├── heart_full.png
│   ├── heart_half.png
│   └── heart_empty.png
├── tiles/
│   ├── grass.png
│   ├── grass_variant1.png
│   ├── grass_variant2.png
│   └── dirt.png
├── effects/
│   ├── hit_effect.png
│   ├── death_poof.png
│   └── explosion.png
└── ui/
    └── (UI elements)
```

---

## 优先级

### Phase 1.5 (现在做)
1. ⭐ `steve.png` - 玩家角色
2. ⭐ `grass.png` - 地面
3. ⭐ `grass_variant1.png` - 地面变体

### Phase 2 需要
4. `zombie.png` - 基础敌人
5. `diamond_sword.png` - 武器
6. `xp_orb.png` - 经验球
7. `heart_full.png` / `heart_half.png` / `heart_empty.png` - 生命值

### Phase 3 需要
8. `skeleton.png`
9. `creeper.png`
10. `spider.png`
11. `bow.png` / `arrow.png`

---

## 技术规格总结

| 类型 | 建议尺寸 | 格式 |
|------|----------|------|
| 角色 | 32x32 px | PNG (透明背景) |
| 地面 | 32x32 px | PNG |
| 物品 | 16x16 px | PNG (透明背景) |
| 特效 | 32x32 或 64x64 px | PNG (透明背景) |
| UI | 根据需要 | PNG (透明背景) |

**重要**: 所有贴图使用 **PNG 格式**，角色和物品需要**透明背景**。

---

## 下一步

1. 确定使用哪种方案获取资源
2. 先制作/获取最优先的 3 个贴图:
   - Steve
   - 草地
   - 草地变体
3. 在 Godot 中替换 placeholder
4. 测试效果

需要我帮你做什么？
- 创建资源文件夹结构？
- 寻找免费素材？
- 制作简单的 placeholder 贴图？
