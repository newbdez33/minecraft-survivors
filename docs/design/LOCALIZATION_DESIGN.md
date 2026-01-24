# 多语言系统设计文档 / Localization System Design

## 1. 概述 / Overview

### 1.1 目标 / Goals
- 支持多语言切换 (中文、英文、日文等)
- 运行时动态切换语言
- 易于扩展新语言
- 使用 Godot 内置本地化系统

### 1.2 支持语言 / Supported Languages
| 语言代码 | 语言名称 | 优先级 |
|----------|----------|--------|
| en | English | P0 (默认) |
| zh | 简体中文 | P0 |
| ja | 日本語 | P1 |

---

## 2. 技术方案 / Technical Approach

### 2.1 使用 Godot TranslationServer
```gdscript
# 切换语言
TranslationServer.set_locale("zh")

# 获取翻译文本
var text = tr("GAME_OVER")
```

### 2.2 翻译文件格式
使用 CSV 格式，便于编辑和版本控制：

```
keys,en,zh,ja
GAME_OVER,Game Over,游戏结束,ゲームオーバー
RESUME,Resume,继续,再開
QUIT,Quit,退出,終了
```

### 2.3 文件结构
```
localization/
├── translations.csv       # 主翻译文件
├── translations.en.translation  # 编译后的翻译文件
├── translations.zh.translation
└── translations.ja.translation
```

---

## 3. 需要翻译的内容 / Content to Translate

### 3.1 UI 文本 / UI Text
| Key | EN | ZH | 位置 |
|-----|----|----|------|
| PAUSED | PAUSED | 暂停 | pause_menu |
| RESUME | Resume | 继续 | pause_menu |
| QUIT | Quit | 退出 | pause_menu, game_over |
| GAME_OVER | GAME OVER | 游戏结束 | game_over_ui |
| RESTART | Restart | 重新开始 | game_over_ui |
| SURVIVED | Survived | 存活时间 | game_over_ui |
| KILLS | Kills | 击杀数 | game_over_ui |
| LEVEL | Level | 等级 | hud |
| WAVE | Wave | 波次 | hud |

### 3.2 升级/武器名称 / Upgrade Names
| Key | EN | ZH |
|-----|----|----|
| UPGRADE_SWORD | Sword | 剑 |
| UPGRADE_BOW | Bow | 弓 |
| UPGRADE_CROSSBOW | Crossbow | 弩 |
| UPGRADE_SHARPNESS | Sharpness | 锋利 |
| UPGRADE_KNOCKBACK | Knockback | 击退 |
| UPGRADE_LOOTING | Looting | 抢夺 |
| UPGRADE_PROTECTION | Protection | 保护 |
| UPGRADE_SWIFTNESS | Swiftness | 迅捷 |
| UPGRADE_SWEEPING | Sweeping Edge | 横扫之刃 |
| UPGRADE_HASTE | Haste | 急迫 |

### 3.3 升级描述 / Upgrade Descriptions
| Key | EN | ZH |
|-----|----|----|
| DESC_SWORD | +2 damage, +5 range | +2伤害, +5范围 |
| DESC_BOW | +3 DMG, +25 range | +3伤害, +25范围 |
| DESC_SHARPNESS | +{value} damage | +{value}伤害 |
| DESC_KNOCKBACK | +{value} knockback | +{value}击退 |
| DESC_LOOTING | +{value}% XP gain | +{value}%经验获取 |
| DESC_PROTECTION | -{value}% damage taken | -{value}%受到伤害 |
| DESC_SWIFTNESS | +{value}% move speed | +{value}%移动速度 |
| DESC_SWEEPING | +{value} attack range | +{value}攻击范围 |
| DESC_HASTE | -{value}% attack cooldown | -{value}%攻击冷却 |

### 3.4 进化文本 / Evolution Text
| Key | EN | ZH |
|-----|----|----|
| EVOLUTION | ★ EVOLUTION ★ | ★ 进化 ★ |
| BONUS | BONUS | 奖励 |
| WOOD_SWORD | Wood Sword | 木剑 |
| STONE_SWORD | Stone Sword | 石剑 |
| IRON_SWORD | Iron Sword | 铁剑 |
| DIAMOND_SWORD | Diamond Sword | 钻石剑 |

---

## 4. 实现步骤 / Implementation Steps

### Phase 1: 基础设施
1. 创建 `localization/translations.csv`
2. 配置 project.godot 启用本地化
3. 创建 `LocalizationManager` 单例

### Phase 2: UI 适配
4. 修改 pause_menu.gd 使用 tr()
5. 修改 game_over_ui.gd 使用 tr()
6. 修改 hud.gd 使用 tr()
7. 修改 upgrade_ui.gd 使用 tr()

### Phase 3: 数据适配
8. 修改 upgrade_manager.gd 支持翻译
9. 修改 upgrade.gd 支持翻译

### Phase 4: 设置界面
10. 在 pause_menu 添加语言选择按钮
11. 保存语言偏好到 ConfigFile

---

## 5. LocalizationManager 设计

```gdscript
# scripts/systems/localization_manager.gd
extends Node
class_name LocalizationManager

signal language_changed(locale: String)

const SUPPORTED_LOCALES = ["en", "zh", "ja"]
const CONFIG_PATH = "user://settings.cfg"

var current_locale: String = "en"

func _ready() -> void:
    _load_saved_locale()

func set_locale(locale: String) -> void:
    if locale in SUPPORTED_LOCALES:
        current_locale = locale
        TranslationServer.set_locale(locale)
        _save_locale()
        language_changed.emit(locale)

func get_locale() -> String:
    return current_locale

func _load_saved_locale() -> void:
    var config = ConfigFile.new()
    if config.load(CONFIG_PATH) == OK:
        current_locale = config.get_value("settings", "locale", "en")
        TranslationServer.set_locale(current_locale)

func _save_locale() -> void:
    var config = ConfigFile.new()
    config.load(CONFIG_PATH)
    config.set_value("settings", "locale", current_locale)
    config.save(CONFIG_PATH)
```

---

## 6. UI 修改示例

### pause_menu.gd 修改前:
```gdscript
resume_button.text = "Resume"
```

### pause_menu.gd 修改后:
```gdscript
resume_button.text = tr("RESUME")
```

---

## 7. 语言切换 UI

在 pause_menu 中添加语言按钮：
```
[EN] [中] [日]
```

点击后调用:
```gdscript
LocalizationManager.set_locale("zh")
```

---

## 8. 注意事项 / Notes

1. **字体支持**: 确保字体支持中日文字符
2. **文本长度**: 中文通常比英文短，日文可能更长
3. **动态文本**: 使用 `{value}` 占位符处理动态数值
4. **热重载**: 语言切换后需要刷新所有UI文本

---

## 9. 待确认问题 / Questions

1. 是否需要支持更多语言？(韩语、繁体中文等)
2. 语言选择放在暂停菜单还是单独设置界面？
3. 是否需要自动检测系统语言作为默认值？

---

## 10. 时间估算 / Time Estimate

| 阶段 | 工作量 |
|------|--------|
| Phase 1: 基础设施 | 1h |
| Phase 2: UI 适配 | 2h |
| Phase 3: 数据适配 | 1h |
| Phase 4: 设置界面 | 1h |
| 测试 & 修复 | 1h |
| **总计** | **6h** |

---

**文档版本**: 1.0
**创建日期**: 2026-01-24
**状态**: 待确认
