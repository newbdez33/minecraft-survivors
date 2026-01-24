# Phase 5 视觉测试详细规格

本文档补充 `phase5_test_plan.md`，详细描述测试模式下的视觉元素和验证标准。

---

## 1. 测试模式 UI 布局

### 1.1 调试信息面板 (TestDebugOverlay)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [TEST MODE] v0.3.0-beta                                          FPS: 60   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─ GAME STATE ──────────────────┐  ┌─ PLAYER STATE ─────────────────────┐ │
│  │ Time: 125.5s                  │  │ HP: 78/100 [████████░░] 78%        │ │
│  │ Wave: 3                       │  │ Level: 5                           │ │
│  │ Kills: 47                     │  │ XP: 340/500 [██████░░░░] 68%       │ │
│  │ Day/Night: Night (75.5s)      │  │ Position: (245, -128)              │ │
│  │ Enemies: 23/60                │  │ Velocity: (150, 0)                 │ │
│  │ XP Orbs: 12                   │  │ Facing: Right                      │ │
│  └────────────────────────────────┘  └────────────────────────────────────┘ │
│                                                                             │
│  ┌─ STATUS EFFECTS ──────────────────────────────────────────────────────┐ │
│  │ [🧪 POISON] 3.5s remaining | 6/20 damage taken                        │ │
│  │ [⚡ NONE]                                                              │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─ COMBAT STATS ────────────────────────────────────────────────────────┐ │
│  │ DPS: 45.2 | Combo: 15 (+25% XP) | Crits: 12% | Damage Taken: 234      │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─ AUTO PLAYER ─────────────────────────────────────────────────────────┐ │
│  │ Strategy: SURVIVE | Target: Zombie@(300, 150) | Action: Evading       │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ EVENT LOG (最近10条)                                                        │
│ [125.5] Poison tick: -2 HP                                                  │
│ [125.0] Poison tick: -2 HP                                                  │
│ [124.2] Enemy killed: Zombie (+5 XP, +10 score)                            │
│ [123.8] Combo reached 15!                                                   │
│ [122.1] Witch spawned at (450, 200)                                         │
│ [120.0] Night started                                                       │
│ [118.5] Level up! 4 → 5                                                     │
│ [115.2] Poison applied (5.0s duration)                                      │
│ [110.0] Wave 3 started                                                      │
│ [105.3] Screenshot: wave_3_start.png                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 面板位置与样式

| 元素 | 位置 | 字体 | 颜色 | 透明度 |
|------|------|------|------|--------|
| 主面板 | 左上角 | Monospace 12px | 白色 | 80% 黑色背景 |
| 标题栏 | 面板顶部 | Monospace 14px Bold | 黄色 | - |
| 正常数值 | - | Monospace 12px | 白色 | - |
| 警告数值 | - | Monospace 12px | 橙色 | HP < 30% |
| 危险数值 | - | Monospace 12px | 红色 | HP < 15% |
| 正面效果 | - | Monospace 12px | 绿色 | 连击、升级 |
| 负面效果 | - | Monospace 12px | 紫色 | 中毒 |

### 1.3 快捷键 (测试模式专用)

| 按键 | 功能 |
|------|------|
| F1 | 切换调试面板显示/隐藏 |
| F2 | 手动截图 |
| F3 | 切换AutoPlayer策略 |
| F4 | 暂停/继续游戏 |
| F5 | 2倍速/正常速度 |
| F6 | 强制触发升级 |
| F7 | 强制触发中毒 |
| F8 | 强制触发游戏结束 |
| F9 | 重置游戏 |
| F10 | 输出当前状态到日志 |

---

## 2. 视觉元素验证规格

### 2.1 中毒效果视觉验证

#### 2.1.1 玩家中毒状态颜色

```gdscript
# 验证标准
const POISON_TINT = Color(0.5, 1.0, 0.5, 1.0)  # 绿色调
const NORMAL_TINT = Color(1.0, 1.0, 1.0, 1.0)  # 正常白色

func validate_poison_visual() -> bool:
    var player = get_player()
    var sprite = player.get_node("Sprite2D")

    if player.is_poisoned():
        # 中毒时应该是绿色
        return sprite.modulate.is_equal_approx(POISON_TINT)
    else:
        # 正常时应该是白色
        return sprite.modulate.is_equal_approx(NORMAL_TINT)
```

#### 2.1.2 中毒粒子效果

| 属性 | 值 | 描述 |
|------|-----|------|
| 粒子数量 | 20 | 同时存在的粒子数 |
| 发射速率 | 10/秒 | 每秒发射粒子数 |
| 粒子颜色 | #00FF00 → #008800 | 绿色渐变 |
| 粒子大小 | 4px → 2px | 逐渐缩小 |
| 运动方式 | 向上飘动 | 模拟毒气上升 |
| 生命周期 | 1.0秒 | 单个粒子存在时间 |
| 发射半径 | 玩家周围 30px | 粒子生成范围 |

#### 2.1.3 毒药水爆炸效果

| 属性 | 值 | 描述 |
|------|-----|------|
| 爆炸半径动画 | 0 → 100px | 0.3秒内扩散 |
| 爆炸颜色 | #00FF00 | 绿色 |
| 爆炸透明度 | 1.0 → 0.0 | 0.5秒内淡出 |
| 地面毒雾 | 半径100px | 持续3秒 |
| 毒雾颜色 | #00FF0040 | 半透明绿色 |

### 2.2 日夜循环视觉验证

#### 2.2.1 屏幕色调 (CanvasModulate)

| 阶段 | 时间范围 | 色调值 (RGB) | 描述 |
|------|----------|--------------|------|
| 黎明 | 0-5s | (1.0, 0.85, 0.7) | 温暖橙色 |
| 早晨 | 5-20s | (1.0, 0.95, 0.9) | 微暖 |
| 正午 | 20-40s | (1.0, 1.0, 1.0) | 正常 |
| 下午 | 40-55s | (1.0, 0.9, 0.8) | 温暖 |
| 黄昏 | 55-60s | (1.0, 0.7, 0.5) | 橙红 |
| 月升 | 60-75s | (0.7, 0.75, 0.9) | 冷色过渡 |
| 夜间 | 75-105s | (0.5, 0.55, 0.8) | 深蓝 |
| 深夜 | 105-115s | (0.4, 0.45, 0.7) | 更深蓝 |
| 月落 | 115-120s | (0.6, 0.65, 0.75) | 过渡到黎明 |

```gdscript
# 验证色调
func validate_day_night_tint(time: float) -> bool:
    var overlay = get_node("DayNightOverlay")
    var expected_color = _get_expected_tint(time)
    return overlay.color.is_equal_approx(expected_color)

func _get_expected_tint(time: float) -> Color:
    if time < 5:
        return Color(1.0, 0.85, 0.7)
    elif time < 20:
        return Color(1.0, 0.95, 0.9)
    # ... 等等
```

#### 2.2.2 HUD日夜图标

| 阶段 | 图标文件 | 图标大小 | 位置 |
|------|----------|----------|------|
| 黎明 | sun_dawn.svg | 32x32 | HUD右上角 |
| 早晨 | sun_morning.svg | 32x32 | HUD右上角 |
| 正午 | sun.svg | 32x32 | HUD右上角 |
| 下午 | sun_afternoon.svg | 32x32 | HUD右上角 |
| 黄昏 | sun_dusk.svg | 32x32 | HUD右上角 |
| 月升 | moon_rise.svg | 32x32 | HUD右上角 |
| 夜间 | moon.svg | 32x32 | HUD右上角 |
| 深夜 | moon_late.svg | 32x32 | HUD右上角 |
| 月落 | moon_set.svg | 32x32 | HUD右上角 |

### 2.3 连击系统视觉验证

#### 2.3.1 连击计数显示

| 连击数 | 字体大小 | 颜色 | 特效 |
|--------|----------|------|------|
| 1-9 | 24px | 白色 | 无 |
| 10-24 | 32px | 黄色 | 轻微脉冲 |
| 25-49 | 40px | 橙色 | 明显脉冲 |
| 50-99 | 48px | 红色 | 强烈脉冲+光晕 |
| 100+ | 56px | 紫色 | 彩虹色渐变+震动 |

#### 2.3.2 连击里程碑特效

| 里程碑 | 文字 | 音效 | 屏幕效果 |
|--------|------|------|----------|
| 10 | "不错!" | combo_10.wav | 边缘轻微闪光 |
| 25 | "很棒!" | combo_25.wav | 边缘中等闪光 |
| 50 | "疯狂!" | combo_50.wav | 全屏闪光 |
| 100 | "无敌!" | combo_100.wav | 全屏彩虹+震动 |
| 200 | "神级!" | combo_200.wav | 极致特效 |

### 2.4 伤害数字视觉验证

#### 2.4.1 伤害数字样式

| 类型 | 字体大小 | 颜色 | 动画 |
|------|----------|------|------|
| 普通伤害 | 16px | 白色 #FFFFFF | 向上飘动淡出 |
| 暴击伤害 | 24px | 黄色 #FFFF00 | 向上弹跳+震动 |
| 中毒伤害 | 14px | 紫色 #AA00FF | 向上飘动 |
| 治疗 | 18px | 绿色 #00FF00 | 向上飘动 |
| 连击加成 | 12px | 青色 #00FFFF | 跟随伤害数字 |

#### 2.4.2 伤害数字动画参数

```gdscript
const DAMAGE_NUMBER_CONFIG = {
    "normal": {
        "rise_speed": 50.0,      # 向上移动速度 px/s
        "rise_distance": 30.0,   # 总移动距离 px
        "fade_duration": 0.8,    # 淡出时间 秒
        "font_size": 16,
        "color": Color.WHITE
    },
    "critical": {
        "rise_speed": 80.0,
        "rise_distance": 50.0,
        "fade_duration": 1.0,
        "font_size": 24,
        "color": Color.YELLOW,
        "shake_intensity": 3.0,  # 震动强度
        "scale_pop": 1.5         # 初始放大倍数
    },
    "poison": {
        "rise_speed": 30.0,
        "rise_distance": 20.0,
        "fade_duration": 0.6,
        "font_size": 14,
        "color": Color(0.67, 0, 1.0)  # 紫色
    }
}
```

### 2.5 升级界面视觉验证

#### 2.5.1 升级界面布局

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           选择升级                                           │
│                         ⏱️ 4.2s                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                  │
│   │             │     │  ★ 选中 ★   │     │             │                  │
│   │   [图标]    │     │   [图标]    │     │   [图标]    │                  │
│   │             │     │             │     │             │                  │
│   │  Sharpness  │     │    弓箭     │     │ Protection  │                  │
│   │   Level 3   │     │   Level 1   │     │   Level 2   │                  │
│   │             │     │             │     │             │                  │
│   │ +10% 伤害   │     │ 远程攻击    │     │ -8% 受伤    │                  │
│   │             │     │             │     │             │                  │
│   └─────────────┘     └─────────────┘     └─────────────┘                  │
│        [A]                [W/S]               [D]                           │
│                                                                             │
│                    ◀ A/Left    选择    D/Right ▶                           │
│                         Enter/Space 确认                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 2.5.2 升级选项卡样式

| 状态 | 边框颜色 | 背景色 | 缩放 |
|------|----------|--------|------|
| 未选中 | #666666 | #333333 | 1.0x |
| 选中 | #FFD700 (金色) | #444444 | 1.1x |
| 悬停 | #AAAAAA | #3A3A3A | 1.05x |

#### 2.5.3 倒计时显示

| 剩余时间 | 颜色 | 大小 | 效果 |
|----------|------|------|------|
| 5-3秒 | 白色 | 24px | 正常 |
| 3-1秒 | 黄色 | 28px | 脉冲 |
| <1秒 | 红色 | 32px | 快速脉冲 |

### 2.6 游戏结束界面视觉验证

#### 2.6.1 游戏结束布局

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                            GAME OVER                                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                        🏆 SCORE: 15,420 🏆                                  │
│                           RANK: #3                                          │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ⏱️ 存活时间: 5:32        ⚔️ 击杀数: 247                                  │
│   📈 等级: 12              🌊 波数: 6                                       │
│                                                                             │
│   ───────────────────────────────────────────                               │
│                                                                             │
│   分数明细:                                                                  │
│   击杀: 247 × 10 = 2,470                                                    │
│   时间: 332 × 1 = 332                                                       │
│   等级: 12 × 50 = 600                                                       │
│   波数: 6 × 100 = 600                                                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│            [再来一局]              [排行榜]              [主菜单]            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.7 HUD状态图标验证

#### 2.7.1 状态图标规格

| 图标 | 文件 | 大小 | 位置 | 显示条件 |
|------|------|------|------|----------|
| 中毒 | status_poison.svg | 24x24 | HP条下方 | 中毒状态 |
| 燃烧 | status_burn.svg | 24x24 | HP条下方 | 燃烧状态 |
| 减速 | status_slow.svg | 24x24 | HP条下方 | 减速状态 |
| 力量 | status_strength.svg | 24x24 | HP条下方 | 力量加成 |
| 速度 | status_speed.svg | 24x24 | HP条下方 | 速度加成 |

#### 2.7.2 状态图标倒计时

```
┌──────┐
│ [🧪] │  ← 图标
│ 3.5s │  ← 剩余时间 (小字)
└──────┘
```

---

## 3. 自动截图触发点

### 3.1 必须截图的时刻

| 触发点 | 截图名称 | 验证内容 |
|--------|----------|----------|
| 游戏开始 | `game_start.png` | 初始UI、玩家位置 |
| 首次击杀 | `first_kill.png` | 伤害数字、XP掉落 |
| 首次升级 | `first_level_up.png` | 升级UI、选项显示 |
| 选择升级 | `upgrade_selected.png` | 高亮选项、倒计时 |
| 升级完成 | `upgrade_complete.png` | 属性变化、特效 |
| 波数变化 | `wave_X_start.png` | 波数提示、敌人生成 |
| 进入夜间 | `night_start.png` | 色调变化、图标变化 |
| 进入白天 | `day_start.png` | 色调恢复、图标变化 |
| 中毒触发 | `poison_applied.png` | 爆炸特效、玩家变色 |
| 中毒进行 | `poison_active.png` | 粒子效果、HUD图标 |
| 中毒解除 | `poison_cured.png` | 颜色恢复、图标消失 |
| 连击10 | `combo_10.png` | 连击数字、特效 |
| 连击50 | `combo_50.png` | 连击数字、屏幕效果 |
| 低血量 | `low_health.png` | HP条红色、警告效果 |
| 游戏结束 | `game_over.png` | 结束界面、分数显示 |

### 3.2 截图验证函数

```gdscript
# scripts/testing/screenshot_validator.gd
class_name ScreenshotValidator
extends RefCounted

## 验证截图内容是否符合预期

func validate_game_start(image: Image) -> Dictionary:
    var result = {
        "valid": true,
        "checks": []
    }

    # 检查玩家是否在屏幕中央
    var player_visible = _check_player_visible(image)
    result.checks.append({
        "name": "player_visible",
        "passed": player_visible,
        "message": "Player should be visible at center"
    })

    # 检查HUD是否存在
    var hud_visible = _check_hud_visible(image)
    result.checks.append({
        "name": "hud_visible",
        "passed": hud_visible,
        "message": "HUD should be visible"
    })

    result.valid = player_visible and hud_visible
    return result

func validate_poison_applied(image: Image) -> Dictionary:
    var result = {
        "valid": true,
        "checks": []
    }

    # 检查是否有绿色爆炸效果
    var green_explosion = _check_color_present(image, Color(0, 1, 0), 0.1)
    result.checks.append({
        "name": "green_explosion",
        "passed": green_explosion,
        "message": "Green explosion effect should be visible"
    })

    # 检查玩家是否变绿
    var player_green = _check_player_tint(image, Color(0.5, 1.0, 0.5))
    result.checks.append({
        "name": "player_green_tint",
        "passed": player_green,
        "message": "Player should have green tint"
    })

    result.valid = green_explosion and player_green
    return result

func _check_color_present(image: Image, target_color: Color, threshold: float) -> bool:
    # 检查图像中是否存在目标颜色
    var width = image.get_width()
    var height = image.get_height()
    var target_pixels = 0
    var total_pixels = width * height

    for x in range(width):
        for y in range(height):
            var pixel = image.get_pixel(x, y)
            if pixel.is_equal_approx(target_color):
                target_pixels += 1

    return float(target_pixels) / total_pixels >= threshold
```

---

## 4. 测试日志格式

### 4.1 标准日志输出

```
================================================================================
MINECRAFT SURVIVORS - TEST MODE LOG
================================================================================
Timestamp: 2026-01-24 10:46:32
Test Name: poison_visual_test
Strategy: TRIGGER_POISON
Duration: 30.0s
================================================================================

[00:00.0] TEST_START | Poison visual test initialized
[00:00.0] GAME_STATE | Wave: 1, Enemies: 0, Player HP: 100/100
[00:05.2] ENEMY_SPAWN | Witch spawned at (450, 200)
[00:08.5] AUTO_PLAYER | Strategy changed: approaching Witch
[00:12.3] DAMAGE_TAKEN | Player hit by Potion, -12 HP
[00:12.3] STATUS_EFFECT | Poison applied (duration: 5.0s)
[00:12.3] SCREENSHOT | poison_applied.png saved
[00:12.3] VISUAL_CHECK | Player green tint: PASS
[00:12.3] VISUAL_CHECK | Explosion effect: PASS
[00:12.8] POISON_TICK | -2 HP (remaining: 4.5s)
[00:13.3] POISON_TICK | -2 HP (remaining: 4.0s)
[00:13.8] POISON_TICK | -2 HP (remaining: 3.5s)
[00:14.3] POISON_TICK | -2 HP (remaining: 3.0s)
[00:14.8] POISON_TICK | -2 HP (remaining: 2.5s)
[00:15.0] SCREENSHOT | poison_active.png saved
[00:15.0] VISUAL_CHECK | Poison particles: PASS
[00:15.0] VISUAL_CHECK | HUD poison icon: PASS
[00:15.3] POISON_TICK | -2 HP (remaining: 2.0s)
[00:15.8] POISON_TICK | -2 HP (remaining: 1.5s)
[00:16.3] POISON_TICK | -2 HP (remaining: 1.0s)
[00:16.8] POISON_TICK | -2 HP (remaining: 0.5s)
[00:17.3] STATUS_EFFECT | Poison expired (total damage: 20)
[00:17.3] SCREENSHOT | poison_cured.png saved
[00:17.3] VISUAL_CHECK | Player normal tint: PASS
[00:17.3] VISUAL_CHECK | HUD icon removed: PASS
[00:30.0] TEST_END | Test completed successfully

================================================================================
TEST SUMMARY
================================================================================
Duration: 30.0s
Screenshots: 3
Visual Checks: 6 passed, 0 failed
Events Logged: 24

RESULT: PASS
================================================================================
```

### 4.2 JSON结果输出

```json
{
    "test_name": "poison_visual_test",
    "timestamp": "2026-01-24T10:46:32",
    "duration_seconds": 30.0,
    "strategy": "TRIGGER_POISON",
    "result": "PASS",
    "screenshots": [
        {
            "name": "poison_applied.png",
            "timestamp": 12.3,
            "validations": [
                {"check": "player_green_tint", "result": "PASS"},
                {"check": "explosion_effect", "result": "PASS"}
            ]
        },
        {
            "name": "poison_active.png",
            "timestamp": 15.0,
            "validations": [
                {"check": "poison_particles", "result": "PASS"},
                {"check": "hud_poison_icon", "result": "PASS"}
            ]
        },
        {
            "name": "poison_cured.png",
            "timestamp": 17.3,
            "validations": [
                {"check": "player_normal_tint", "result": "PASS"},
                {"check": "hud_icon_removed", "result": "PASS"}
            ]
        }
    ],
    "game_stats": {
        "survival_time": 30.0,
        "kills": 3,
        "level": 1,
        "wave": 1,
        "damage_taken": 32,
        "poison_damage": 20
    },
    "events": [
        {"time": 0.0, "type": "TEST_START", "data": {}},
        {"time": 12.3, "type": "STATUS_EFFECT", "data": {"effect": "POISON", "duration": 5.0}},
        {"time": 17.3, "type": "STATUS_EFFECT", "data": {"effect": "POISON", "action": "expired"}}
    ]
}
```

---

## 5. 测试覆盖检查清单

### 5.1 每个功能必须测试的内容

#### 中毒系统 ✓
- [ ] StatusEffect 类加载
- [ ] StatusEffectManager 信号发射
- [ ] 中毒伤害计算正确 (2伤害 × 10次 = 20总伤害)
- [ ] 中毒持续时间正确 (5秒)
- [ ] 中毒自动解除
- [ ] 重复中毒刷新时间
- [ ] 玩家变绿色 (视觉)
- [ ] 粒子效果显示 (视觉)
- [ ] HUD图标显示 (视觉)
- [ ] HUD倒计时显示 (视觉)
- [ ] 中毒解除后恢复正常 (视觉)

#### 排行榜系统 ✓
- [ ] 分数计算公式正确
- [ ] 击杀得分 (×10)
- [ ] 时间得分 (×1)
- [ ] 等级得分 (×50)
- [ ] 波数得分 (×100)
- [ ] 分数保存到文件
- [ ] 分数加载正确
- [ ] 限制10条记录
- [ ] 按分数排序
- [ ] 游戏结束显示分数 (视觉)
- [ ] 游戏结束显示排名 (视觉)
- [ ] 排行榜UI显示 (视觉)

#### 成就系统 ✓
- [ ] 首次击杀成就
- [ ] 百人斩成就
- [ ] 存活时间成就
- [ ] 等级成就
- [ ] 波数成就
- [ ] 特殊击杀成就
- [ ] 成就奖励发放
- [ ] 成就持久化
- [ ] 成就弹窗显示 (视觉)

#### 连击系统 ✓
- [ ] 连击计数正确
- [ ] 3秒超时重置
- [ ] 受伤重置
- [ ] XP加成计算
- [ ] 里程碑触发
- [ ] 连击显示更新 (视觉)
- [ ] 里程碑特效 (视觉)

#### 屏幕反馈 ✓
- [ ] 相机震动函数存在
- [ ] 攻击时震动触发
- [ ] 伤害数字生成
- [ ] 暴击数字样式
- [ ] 升级慢动作
- [ ] 屏幕闪光效果 (视觉)
