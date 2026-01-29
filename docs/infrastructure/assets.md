# Art Asset Plan - Minecraft Survivors

本文档详细列出游戏所需的所有美术资源。

## 美术风格

- **风格**: Minecraft 像素风格 (16x16 或 32x32 像素)
- **视角**: 俯视角 (Top-down) - 不是 Minecraft 原版的侧视角
- **调色板**: 使用 Minecraft 的经典配色
- **格式**: SVG (可缩放矢量图形)

```
俯视角示例:
    ┌───┐
    │ @ │  ← 从上往下看 Steve
    └───┘
```

---

## 资源完成状态

### 已完成 ✅

| 文件 | 尺寸 | 路径 | 状态 |
|------|------|------|------|
| steve.svg | 32x32 | assets/characters/ | ✅ 已集成 |
| zombie.svg | 32x32 | assets/characters/ | ✅ 完成 |
| skeleton.svg | 32x32 | assets/characters/ | ✅ 完成 |
| creeper.svg | 32x32 | assets/characters/ | ✅ 完成 |
| spider.svg | 48x32 | assets/characters/ | ✅ 完成 |
| grass.svg | 32x32 | assets/tiles/ | ✅ 已集成 |
| grass_variant1.svg | 32x32 | assets/tiles/ | ✅ 已集成 |
| grass_variant2.svg | 32x32 | assets/tiles/ | ✅ 已集成 |
| dirt.svg | 32x32 | assets/tiles/ | ✅ 完成 |
| diamond_sword.svg | 16x16 | assets/weapons/ | ✅ 完成 |
| bow.svg | 16x16 | assets/weapons/ | ✅ 完成 |
| arrow.svg | 16x8 | assets/weapons/ | ✅ 完成 |
| xp_orb.svg | 16x16 | assets/items/ | ✅ 完成 |
| heart_full.svg | 16x16 | assets/items/ | ✅ 完成 |
| heart_half.svg | 16x16 | assets/items/ | ✅ 完成 |
| heart_empty.svg | 16x16 | assets/items/ | ✅ 完成 |
| hit_effect.svg | 128x32 (4帧) | assets/effects/ | ✅ 完成 |
| death_poof.svg | 160x32 (5帧) | assets/effects/ | ✅ 完成 |
| explosion.svg | 384x64 (6帧) | assets/effects/ | ✅ 完成 |

---

## 一、角色贴图 (Characters)

### 1. Steve (玩家) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `steve.svg` | 32x32 | Steve 俯视角 | ✅ 已集成到 player.tscn |

颜色参考:
- 头发: `#4A3728` (深棕色)
- 皮肤: `#B87D56` (肤色)
- 衣服: `#00AAAA` (青色)
- 裤子: `#3C3C64` (深蓝色)

---

### 2. Zombie (僵尸) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `zombie.svg` | 32x32 | Zombie 俯视角 | ✅ 完成 |

颜色参考:
- 皮肤: `#7BC45C` (僵尸绿)
- 深色: `#597D35` (阴影绿)
- 衣服: `#49A5A5` (破烂青色)
- 裤子: `#3C3C8C` (蓝色)

---

### 3. Skeleton (骷髅) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `skeleton.svg` | 32x32 | Skeleton 俯视角 | ✅ 完成 |

颜色参考:
- 骨头: `#C8C8C8` (浅灰色)
- 阴影: `#8B8B8B` (深灰色)
- 眼睛: `#1A1A1A` (黑色)

---

### 4. Creeper (苦力怕) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `creeper.svg` | 32x32 | Creeper 俯视角 | ✅ 完成 |

颜色参考:
- 浅绿: `#6AAB4E`
- 深绿: `#4E8B3A`
- 眼睛/嘴: `#000000` (黑色)

---

### 5. Spider (蜘蛛) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `spider.svg` | 48x32 | Spider 俯视角 (宽) | ✅ 完成 |

颜色参考:
- 身体: `#4A4040` (深灰棕)
- 眼睛: `#CC0000` (红色)

---

## 二、武器贴图 (Weapons) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `diamond_sword.svg` | 16x16 | 钻石剑图标 | ✅ 完成 |
| `bow.svg` | 16x16 | 弓图标 | ✅ 完成 |
| `arrow.svg` | 16x8 | 箭矢 | ✅ 完成 |

颜色参考:
- 剑刃: `#33EBCB` (钻石青色)
- 剑柄: `#8B5A2B` (棕色)

---

## 三、物品贴图 (Items) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `xp_orb.svg` | 16x16 | 经验球 (绿色发光) | ✅ 完成 |
| `heart_full.svg` | 16x16 | 满心 | ✅ 完成 |
| `heart_half.svg` | 16x16 | 半心 | ✅ 完成 |
| `heart_empty.svg` | 16x16 | 空心 | ✅ 完成 |

颜色参考:
- XP核心: `#AEFF00` (亮黄绿)
- 红心: `#FF0000` / `#AA0000`
- 空心: `#555555`

---

## 四、场景贴图 (Environment) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `grass.svg` | 32x32 | 草地 | ✅ 已集成到 arena.gd |
| `grass_variant1.svg` | 32x32 | 草地变体 (小花) | ✅ 已集成到 arena.gd |
| `grass_variant2.svg` | 32x32 | 草地变体 (草丛) | ✅ 已集成到 arena.gd |
| `dirt.svg` | 32x32 | 泥土 | ✅ 完成 |

颜色参考:
- 草地浅: `#7CBD6B`
- 草地深: `#5A9C4A`
- 泥土: `#8B6B47`

---

## 五、特效贴图 (Effects) ✅

| 文件名 | 尺寸 | 描述 | 状态 |
|--------|------|------|------|
| `hit_effect.svg` | 128x32 | 击中特效 (4帧 spritesheet) | ✅ 完成 |
| `death_poof.svg` | 160x32 | 死亡烟雾 (5帧 spritesheet) | ✅ 完成 |
| `explosion.svg` | 384x64 | Creeper 爆炸 (6帧 spritesheet) | ✅ 完成 |

---

## 文件夹结构

```
assets/
├── characters/
│   ├── steve.svg      ✅
│   ├── zombie.svg     ✅
│   ├── skeleton.svg   ✅
│   ├── creeper.svg    ✅
│   └── spider.svg     ✅
├── weapons/
│   ├── diamond_sword.svg  ✅
│   ├── bow.svg            ✅
│   └── arrow.svg          ✅
├── items/
│   ├── xp_orb.svg         ✅
│   ├── heart_full.svg     ✅
│   ├── heart_half.svg     ✅
│   └── heart_empty.svg    ✅
├── tiles/
│   ├── grass.svg          ✅
│   ├── grass_variant1.svg ✅
│   ├── grass_variant2.svg ✅
│   └── dirt.svg           ✅
├── effects/
│   ├── hit_effect.svg     ✅
│   ├── death_poof.svg     ✅
│   └── explosion.svg      ✅
└── ui/
    └── (待添加)
```

---

## 集成状态

### Phase 1.5 ✅ 完成
- [x] `steve.svg` - 已集成到 `scenes/player.tscn`
- [x] `grass.svg` - 已集成到 `scripts/arena.gd`
- [x] `grass_variant1.svg` - 已集成到 `scripts/arena.gd`
- [x] `grass_variant2.svg` - 已集成到 `scripts/arena.gd`

### Phase 2 待集成
- [ ] `zombie.svg` - 需要创建敌人系统
- [ ] `diamond_sword.svg` - 需要创建武器系统
- [ ] `xp_orb.svg` - 需要创建拾取系统
- [ ] `heart_*.svg` - 需要创建 HUD 系统

### Phase 3 待集成
- [ ] `skeleton.svg` - 远程敌人
- [ ] `creeper.svg` - 爆炸敌人
- [ ] `spider.svg` - 快速敌人
- [ ] `bow.svg` / `arrow.svg` - 远程武器
- [ ] `hit_effect.svg` - 击中特效
- [ ] `death_poof.svg` - 死亡特效
- [ ] `explosion.svg` - 爆炸特效

---

## 技术规格

| 类型 | 尺寸 | 格式 |
|------|------|------|
| 角色 | 32x32 px | SVG |
| 地面 | 32x32 px | SVG |
| 物品 | 16x16 px | SVG |
| 武器 | 16x16 或 16x8 px | SVG |
| 特效 | Spritesheet | SVG |

**注意**:
- 所有 SVG 使用 `shape-rendering="crispEdges"` 保持像素锐利
- Godot 导入时会自动光栅化 SVG
- 可根据需要调整导入设置中的缩放比例

---

## 应用图标 (App Icons)

游戏图标使用 Steve 头像的像素风格设计。

### 源文件
| 文件 | 路径 | 说明 |
|------|------|------|
| icon.svg | assets/ui/icon.svg | 16x16 SVG 源文件 |

### 生成的图标
| 文件 | 尺寸 | 用途 |
|------|------|------|
| icon.png | 256x256 | Godot 项目图标 |
| icon.ico | 16/32/48/256 | Windows 可执行文件图标 |
| favicon.png | 32x32 | Web 网页图标 |
| icons/icon_144.png | 144x144 | PWA 图标 |
| icons/icon_180.png | 180x180 | PWA 图标 (iOS) |
| icons/icon_512.png | 512x512 | PWA 图标 (大) |

### 图标生成脚本
运行以下命令从 SVG 生成所有图标格式：
```bash
python3 scripts/utils/generate_icons.py
```

### 配置位置
| 平台 | 配置文件 | 设置项 |
|------|----------|--------|
| Godot | project.godot | config/icon |
| Windows | export_presets.cfg | application/icon |
| macOS | export_presets.cfg | application/icon |
| Web/PWA | export_presets.cfg | progressive_web_app/icon_* |

---

## 更新日志

- **2026-01-28**: 添加应用图标系统，从 icon.svg 生成多平台图标
- **2026-01-23**: 创建所有 19 个 SVG 资源，集成 Steve 和草地瓷砖到游戏中
