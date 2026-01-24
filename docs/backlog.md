# Backlog (待定功能)

低优先级功能，待未来版本实现。

---

## Phase 5.5: Sword Tier Evolution (剑进化系统)

**优先级**: 高
**状态**: 待实现

### Overview (概述)
玩家初始持有木剑，通过收集材料或达成条件进化到更高级别的剑。

```
🪵 Wood Sword → 🪨 Stone Sword → 🔩 Iron Sword → 💎 Diamond Sword
```

### Sword Tiers (剑等级)

**注意**: 当前钻石剑范围100px太大，需要缩小让战斗更有挑战性。

| 等级 | 名称 | 伤害 | 攻速 | 范围 | 颜色 |
|------|------|------|------|------|------|
| 1 | 木剑 (Wood) | 5 | 1.2s | 30 | 🟫 棕色 |
| 2 | 石剑 (Stone) | 8 | 1.0s | 35 | ⬜ 灰色 |
| 3 | 铁剑 (Iron) | 12 | 0.9s | 40 | 🔲 银色 |
| 4 | 钻石剑 (Diamond) | 15 | 0.8s | 45 | 🔷 蓝色 |

**Range Comparison (范围对比):**
- 当前: 100px (太大，敌人还没靠近就死了)
- 目标: 30-45px (近身肉搏战斗)

### Evolution Requirements (进化条件)

**方案 A: 材料收集** (推荐)

| 进化 | 所需材料 | 获取方式 |
|------|----------|----------|
| Wood → Stone | 圆石×5 | 击杀敌人掉落 |
| Stone → Iron | 铁锭×5 | 击杀敌人掉落 (稀有) |
| Iron → Diamond | 钻石×3 | Boss掉落 / 宝箱 |

**方案 B: 击杀数进化**

| 进化 | 击杀数 | 预计时间 |
|------|--------|----------|
| Wood → Stone | 50 kills | ~2分钟 |
| Stone → Iron | 150 kills | ~5分钟 |
| Iron → Diamond | 400 kills | ~10分钟 |

**方案 C: 等级进化**

| 进化 | 玩家等级 |
|------|----------|
| Wood → Stone | Level 5 |
| Stone → Iron | Level 10 |
| Iron → Diamond | Level 18 |

### Visual Design (视觉设计)

```
Wood Sword:     ╱▔╲    棕色木质纹理
                │  │
                └──┘

Stone Sword:    ╱▔╲    灰色石质纹理
                │▓▓│
                └──┘

Iron Sword:     ╱▔╲    银色金属光泽
                │░░│
                └──┘

Diamond Sword:  ╱▔╲    蓝色钻石光泽 + 闪光特效
                │◆◆│
                └──┘
```

### Evolution Effects (进化特效)
- 进化时播放升级动画
- 屏幕闪光效果
- 显示 "Sword Evolved!" 文字
- 音效 (叮~)

### Implementation Plan (实现计划)

1. **创建剑基类** `base_sword.gd`
   - 通用剑逻辑
   - 进化方法 `evolve()`
   - 等级属性 `tier`

2. **创建各等级剑资源**
   - `wood_sword.tscn` (初始)
   - `stone_sword.tscn`
   - `iron_sword.tscn`
   - `diamond_sword.tscn` (最终)

3. **创建剑管理器** `sword_manager.gd`
   - 追踪当前剑等级
   - 检查进化条件
   - 执行进化替换

4. **更新材料系统**
   - 添加圆石、铁锭掉落
   - 材料收集UI

5. **进化UI**
   - 进化进度条
   - 进化提示

### Assets Needed (所需资源)

| 资源 | 文件名 |
|------|--------|
| 木剑图标 | `wood_sword.svg` |
| 石剑图标 | `stone_sword.svg` |
| 铁剑图标 | `iron_sword.svg` |
| 钻石剑图标 | `diamond_sword.svg` (已有) |
| 圆石图标 | `cobblestone.svg` |
| 铁锭图标 | `iron_ingot.svg` |
| 钻石图标 | `diamond.svg` |
| 进化特效 | `evolution_effect.tscn` |

---

## Phase 6: Crafting System (合成系统)

**优先级**: 高
**状态**: 待实现

### Materials Collection (素材收集)
地图上生成可收集的素材，类似XP球自动吸收。

| 素材 | 图标 | 出现条件 | 稀有度 |
|------|------|----------|--------|
| 木棍 (Stick) | 🪵 | 随机生成 | 普通 |
| 煤炭 (Coal) | ⬛ | 随机生成 | 普通 |
| 铁块 (Iron) | 🔩 | 击杀敌人掉落 | 少见 |
| 金块 (Gold) | 🥇 | 击杀敌人掉落 | 稀有 |
| 红石粉 (Redstone) | 🔴 | 波数奖励 | 稀有 |
| 钻石 (Diamond) | 💎 | Boss掉落 | 极稀有 |

### Auto-Crafting Recipes (自动合成配方)
收集足够素材时自动合成道具。

| 道具 | 配方 | 效果 |
|------|------|------|
| **火把** | 煤炭×1 + 木棍×1 | 夜间照亮200px范围，持续60秒，范围内敌人+20%受伤 |
| **金苹果** | 金块×8 | 全额回血 + 5秒伤害提升 |
| **铁傀儡** | 铁块×4 + 红石×1 | 召唤临时战斗伙伴30秒 |
| **TNT** | 红石×1 + 煤炭×4 | 放置后3秒爆炸，范围伤害 |
| **附魔书** | 钻石×1 + 红石×1 | 随机升级一个被动技能 |

### Night Illumination (夜间照明)
- 火把创建光照区域 (半径200px)
- 光照区域内敌人受到额外伤害
- 可同时放置多个火把，光照叠加
- 白天自动消失

---

## Phase 7: Minecraft Dungeons Weapon System (MC地下城武器系统)

**优先级**: 高
**参考**: https://minecraft.fandom.com/wiki/Minecraft_Dungeons:Weapon

### Melee Weapons (近战武器)

| 武器 | 类型 | 攻速 | 特殊能力 |
|------|------|------|----------|
| 剑 (Sword) | 基础 | 中 | 平衡的速度与伤害 |
| 大剑 (Claymore) | 重型 | 慢 | 强力击退效果 |
| 双刃 (Daggers) | 双持 | 快 | 双持攻击，高攻速 |
| 斧头 (Axe) | 重型 | 慢 | 旋转攻击能力 |
| 长戟 (Glaive) | 长柄 | 中 | 攻击范围+50% |
| 战棍 (Battlestaff) | 连击 | 快 | 多段连击伤害递增 |
| 钉锤 (Mace) | 钝器 | 慢 | 10%眩晕几率 |
| 镰刀 (Sickles) | 双持 | 快 | 攻击回血 |
| 拳套 (Gauntlets) | 拳击 | 极快 | 连续快速打击 |
| 鞭子 (Whip) | 范围 | 中 | 直线穿透多个敌人 |

### Ranged Weapons (远程武器)

| 武器 | 类型 | 射速 | 特殊能力 |
|------|------|------|----------|
| 弓 (Bow) | 基础 | 中 | 标准远程攻击 |
| 长弓 (Longbow) | 重型 | 慢 | 高伤害，穿透 |
| 短弓 (Shortbow) | 轻型 | 快 | 快速射击 |
| 十字弓 (Crossbow) | 机械 | 中 | 穿透箭矢 |
| 灵魂弩 (Soul Crossbow) | 魔法 | 慢 | 灵魂伤害类型 |
| 竖琴弓 (Harp Crossbow) | 特殊 | 慢 | 扇形5箭齐发 |

### Weapon Tiers (武器品质)

| 品质 | 颜色 | 词缀数量 | 掉落率 |
|------|------|----------|--------|
| 普通 (Common) | 白色 | 0 | 60% |
| 优秀 (Uncommon) | 绿色 | 1 | 25% |
| 稀有 (Rare) | 蓝色 | 2 | 12% |
| 传说 (Unique) | 橙色 | 3 + 特殊能力 | 3% |

### Enchantment System (附魔系统)

每把武器最多3个附魔槽位，可选择不同附魔。

| 附魔 | 效果 | 最高等级 |
|------|------|----------|
| 锋利 (Sharpness) | +伤害 | III |
| 火焰附加 (Fire Aspect) | 燃烧DOT | II |
| 抢夺 (Looting) | +XP/掉落 | III |
| 连锁 (Chains) | 闪电链接附近敌人 | III |
| 光辉 (Radiance) | 攻击回血 | III |
| 漩涡 (Swirling) | 旋转攻击伤害 | III |
| 雷鸣 (Thundering) | 触发雷击 | III |
| 回响 (Echo) | 触发额外攻击 | III |

---

## More Characters (更多角色)

**优先级**: 低
**依赖**: Phase 5 角色系统完成后

**未来可解锁角色:**
| 角色 | 解锁条件 | 特殊能力 |
|------|----------|----------|
| Zombie | 击杀500僵尸 | +30%HP，-20%移速，撞击伤害 |
| Skeleton | 击杀300骷髅 | 初始携带弓箭，-20%HP |
| Creeper | 被苦力怕炸死10次 | 死亡时爆炸造成伤害 |
| Enderman | 击杀100末影人 | 受伤时有20%几率传送 |
| Herobrine | 达到30级 | +50%伤害，HP上限50 |
| Wither Skeleton | 击杀10个Boss | 攻击附带凋零效果 |
| Iron Golem | 购买(5000绿宝石) | +100%HP，-30%移速，范围攻击 |

---

## Daily Challenge (每日挑战)

**优先级**: 低
**依赖**: 需要网络时间同步或本地日期检测

**描述**: 每天生成不同的挑战条件，完成获得额外奖励。

**挑战类型**:
| 类型 | 示例 | 奖励 |
|------|------|------|
| 击杀挑战 | 击杀200个敌人 | 50绿宝石 |
| 存活挑战 | 存活8分钟 | 80绿宝石 |
| 特殊击杀 | 击杀20个末影人 | 60绿宝石 |
| 限制挑战 | 不升级Sharpness存活5分钟 | 100绿宝石 |
| 连击挑战 | 达成50连击 | 70绿宝石 |

**机制**:
- 每天0点UTC刷新
- 同时有3个挑战可完成
- 完成所有3个获得额外奖励
- 使用日期作为随机种子生成

---

## Boss Enemies (Boss敌人)

**优先级**: 中
**依赖**: 基础敌人系统完善后

**Boss列表**:
| Boss | 出现条件 | HP | 特殊技能 |
|------|----------|-----|----------|
| Wither | 第10波 | 500 | 凋零射击，召唤骷髅 |
| Ender Dragon | 第20波 | 1000 | 龙息攻击，飞行，召唤末影人 |
| Elder Guardian | 第15波 | 400 | 激光攻击，减速光环 |

---

## New Weapons (新武器)

**优先级**: 中
**依赖**: 多武器系统实现后 (Phase 5 只有钻石剑和弓箭)

**基础武器:**
| 武器 | 类型 | 获取方式 | 效果 |
|------|------|----------|------|
| 三叉戟 | 投掷 | Boss掉落/稀有宝箱 | 投掷后返回，可穿透 |
| 火焰弹 | 远程 | 稀有掉落 | 范围燃烧DOT |
| 末影珍珠 | 特殊 | 末影人掉落 | 传送+范围伤害 |

**进化武器 (需要基础武器5级 + 对应被动5级):**
| 进化武器 | 基础武器 | 需要被动 | 效果 |
|----------|----------|----------|------|
| 十字弓 | 弓箭 | Sharpness V | 穿透敌人+高伤害 |
| 火焰剑 | 钻石剑 | Sharpness V | 攻击附带燃烧DOT |
| 横扫剑 | 钻石剑 | Sweeping V | 360°范围攻击 |
| 荆棘之刃 | 任意武器 | Protection V | 受伤反弹伤害 |

---

## Multiplayer (多人模式)

**优先级**: 极低
**依赖**: 核心玩法完善后

**模式**:
- 本地双人合作
- 在线合作 (最多4人)
- PVP竞速模式

---

## Mobile Support (移动端支持)

**优先级**: 低
**依赖**: PC版本稳定后

**需要**:
- 虚拟摇杆
- 触屏UI适配
- 性能优化

---

## Sound & Music (音效与音乐)

**优先级**: 中
**状态**: 待设计

**需要**:
- 背景音乐 (日/夜不同)
- 攻击音效
- 受伤音效
- 升级音效
- UI音效
- Boss战音乐

---

## Endless Mode Variations (无尽模式变体)

**优先级**: 低

| 模式 | 描述 |
|------|------|
| 极速模式 | 一切加速2倍 |
| 困难模式 | 敌人HP/伤害×2 |
| 无升级模式 | 不能升级，考验操作 |
| Boss Rush | 连续Boss战 |

---

## Steam Integration (Steam集成)

**优先级**: 极低
**依赖**: 游戏完成后

- Steam成就
- 云存档
- 排行榜
- 卡牌/徽章

---

## iOS Release (iOS发布)

**优先级**: 低
**依赖**: PC版本稳定后

**要求**:
- Apple Developer账号 ($99/年)
- Xcode (macOS)
- App Store Connect配置

**发布清单**:
| 项目 | 说明 |
|------|------|
| Bundle ID | com.minecraftsurvivors.game |
| 图标 | 1024x1024 App Icon |
| 截图 | iPhone 6.5", iPad 12.9" |
| 隐私政策 | 必需 (即使不收集数据) |
| 年龄分级 | 9+ (偶尔/轻微卡通暴力) |

**Godot iOS导出配置**:
```ini
[preset.ios]
name="iOS"
platform="iOS"
bundle_identifier="com.minecraftsurvivors.game"
signature/apple_team_id="YOUR_TEAM_ID"
application/icon="res://assets/icon_ios.png"
```

**CI配置** (需要 macOS runner):
```yaml
build-ios:
  runs-on: macos-latest
  steps:
    - name: Build iOS
      run: godot --headless --export-release "iOS" build/ios/MinecraftSurvivors.ipa
    - name: Upload to App Store Connect
      uses: apple-actions/upload-testflight-build@v1
```

---

## Android Release (Android发布)

**优先级**: 低
**依赖**: PC版本稳定后

**要求**:
- Google Play Developer账号 ($25 一次性)
- Android SDK
- 签名密钥 (keystore)

**发布清单**:
| 项目 | 说明 |
|------|------|
| Package Name | com.minecraftsurvivors.game |
| 图标 | 512x512 圆角图标 |
| Feature Graphic | 1024x500 |
| 截图 | 手机/平板各尺寸 |
| 内容分级 | PEGI 7 / ESRB E10+ |
| 隐私政策 | 必需 |

**Godot Android导出配置**:
```ini
[preset.android]
name="Android"
platform="Android"
package/unique_name="com.minecraftsurvivors.game"
package/name="Minecraft Survivors"
version/code=1
version/name="1.0.0"
launcher_icons/main_192x192="res://assets/icon_android.png"
keystore/release="path/to/release.keystore"
keystore/release_user="alias"
keystore/release_password="password"
```

**CI配置**:
```yaml
build-android:
  runs-on: ubuntu-latest
  steps:
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3

    - name: Build Android APK
      run: godot --headless --export-release "Android" build/android/MinecraftSurvivors.apk

    - name: Build Android AAB (for Play Store)
      run: godot --headless --export-release "Android" build/android/MinecraftSurvivors.aab

    - name: Upload to Google Play
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
        packageName: com.minecraftsurvivors.game
        releaseFiles: build/android/MinecraftSurvivors.aab
        track: internal
```

**触控适配需求**:
- 虚拟摇杆 (左下角)
- 虚拟按钮 (可选，因为自动攻击)
- 触屏升级选择
- UI缩放适配不同屏幕

---

## Web Release (Web发布)

**优先级**: 极低
**依赖**: PC版本稳定后

**发布平台**:
- itch.io
- GitHub Pages
- 自建网站

**Godot Web导出配置**:
```ini
[preset.web]
name="Web"
platform="Web"
export_path="build/web/index.html"
```

**限制**:
- 需要 HTTPS
- 首次加载较慢 (~20MB)
- 不支持多线程
- 存档使用 IndexedDB

---

## Economy System (经济系统)

**优先级**: 低
**依赖**: 基础游戏完善后

**货币**: 绿宝石 (Emerald) - Minecraft标准货币

**获取方式**:
| 来源 | 数量 |
|------|------|
| 击杀普通敌人 | 1-3 |
| 击杀精英敌人 | 5-10 |
| 击杀Boss | 50-100 |
| 成就奖励 | 10-300 |
| 通过波数 | wave × 10 |

**用途**:
| 用途 | 描述 |
|------|------|
| 购买角色 | 部分角色需要绿宝石解锁 |
| 永久升级 | Meta Progression商店 |
| 复活 | 可选的游戏内复活 |

**存储**: `user://economy.json`

---

## Meta Progression (永久升级)

**优先级**: 低
**依赖**: 经济系统实现后

**描述**: 使用绿宝石购买永久加成，每局游戏都生效。

**永久升级列表**:
| 升级 | 效果 | 最大等级 | 费用 |
|------|------|----------|------|
| 💪 初始伤害 | +5% 基础伤害 | 10 | 100×等级 绿宝石 |
| ❤️ 初始生命 | +10 最大HP | 10 | 120×等级 绿宝石 |
| 👟 初始速度 | +3% 移速 | 10 | 80×等级 绿宝石 |
| 🧲 XP磁铁 | +10% 拾取范围 | 5 | 150×等级 绿宝石 |
| 💰 绿宝石加成 | +5% 绿宝石获取 | 10 | 200×等级 绿宝石 |
| ⭐ 幸运 | +1% 稀有掉落率 | 5 | 300×等级 绿宝石 |

**解锁条件**:
- 通过第5波解锁永久升级功能
- 每个升级需要前置等级达到才能继续购买

**UI设计**:
```
┌────────────────────────────────────────────────┐
│  永久升级                    💎 绿宝石: 1,234  │
├────────────────────────────────────────────────┤
│  💪 初始伤害 [■■■□□□□□□□] 3/10               │
│     +15% 基础伤害                              │
│     下一级: 400 绿宝石  [升级]                  │
│                                                │
│  ❤️ 初始生命 [■□□□□□□□□□] 1/10               │
│     +10 最大HP                                 │
│     下一级: 240 绿宝石  [升级]                  │
│                                                │
│  ...                                           │
└────────────────────────────────────────────────┘
```
