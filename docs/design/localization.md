# Localization System / 多语言系统

本文档详细说明游戏多语言支持的设计和实现方案。

---

## 1. Overview / 概述

### 1.1 Goals / 目标
- 支持多语言切换 (中文、英文、日文)
- 运行时动态切换语言
- 易于扩展新语言
- 使用 Godot 内置本地化系统

### 1.2 Supported Languages / 支持语言

| Code | Language | Priority |
|------|----------|----------|
| en | English | P0 (Default) |
| ja | 日本語 | P0 |
| zh | 简体中文 | P0 |

---

## 2. Architecture / 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                      Game UI                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │
│  │   HUD   │  │ Upgrade │  │ GameOver│  │Settings │    │
│  │         │  │   UI    │  │   UI    │  │   UI    │    │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘    │
│       │            │            │            │          │
│       └────────────┴─────┬──────┴────────────┘          │
│                          │                              │
│                          ▼                              │
│              ┌───────────────────────┐                  │
│              │  tr("TRANSLATION_KEY")│                  │
│              └───────────┬───────────┘                  │
│                          │                              │
└──────────────────────────┼──────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│                  TranslationServer                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │  LocalizationManager (Autoload Singleton)          │  │
│  │  - current_locale: String                          │  │
│  │  - set_language(locale: String)                    │  │
│  │  - get_current_language() -> String                │  │
│  │  - get_available_languages() -> Array              │  │
│  └────────────────────────────────────────────────────┘  │
│                          │                                │
│                          ▼                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │ en.translation│ │ ja.translation│ │ zh.translation│    │
│  │   (English)  │  │  (日本語)    │  │   (中文)     │      │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
└──────────────────────────────────────────────────────────┘
```

---

## 3. Translation Files / 翻译文件

### 3.1 File Structure

```
localization/
├── translations.csv           # Source file
├── translations.en.translation  # Compiled
├── translations.ja.translation
└── translations.zh.translation
```

### 3.2 CSV Format

**File**: `localization/translations.csv`

```csv
keys,en,ja,zh
GAME_TITLE,Minecraft Survivors,マインクラフト サバイバーズ,我的世界 幸存者
YOU_DIED,You Died!,死亡した！,你死了！
RESPAWN,Respawn,リスポーン,重生
QUIT,Quit,終了,退出
WAVE,Wave,ウェーブ,波次
WAVE_N,Wave %d,ウェーブ %d,第 %d 波
KILLS,Kills,撃破数,击杀
KILLS_N,Kills: %d,撃破数: %d,击杀: %d
LEVEL,Level,レベル,等级
LEVEL_N,Lv.%d,Lv.%d,等级 %d
DAY,Day,日目,白天
NIGHT,Night,夜,夜晚
SURVIVAL_TIME,Survival Time,生存時間,存活时间
LEVEL_UP,Level Up!,レベルアップ！,升级！
CHOOSE_UPGRADE,Choose an Upgrade,強化を選択してください,请选择一项强化
SHARPNESS,Sharpness,鋭さ,锋利
SHARPNESS_DESC,+5 damage per level,レベルごとに攻撃力+5,每级 +5 伤害
KNOCKBACK,Knockback,ノックバック,击退
LOOTING,Looting,ドロップ増加,抢夺
PROTECTION,Protection,防護,保护
SWIFTNESS,Swiftness,俊敏,迅捷
SWEEPING,Sweeping Edge,範囲攻撃,横扫之刃
HASTE,Haste,急迫,急迫
SETTINGS,Settings,設定,设置
LANGUAGE,Language,言語,语言
PAUSED,Paused,ポーズ中,已暂停
RESUME,Resume,再開,继续
MAIN_MENU,Main Menu,メインメニュー,主菜单
```

---

## 4. Implementation / 代码实现

### 4.1 LocalizationManager (Autoload)

**File**: `scripts/systems/localization_manager.gd`

```gdscript
extends Node
class_name LocalizationManager

signal language_changed(locale: String)

const SAVE_PATH = "user://settings.cfg"
const AVAILABLE_LANGUAGES = {
    "en": "English",
    "ja": "日本語",
    "zh": "简体中文"
}

var current_locale: String = "en"

func _ready() -> void:
    _load_language_preference()

func set_language(locale: String) -> void:
    if locale not in AVAILABLE_LANGUAGES:
        push_warning("Unknown locale: %s, falling back to 'en'" % locale)
        locale = "en"

    current_locale = locale
    TranslationServer.set_locale(locale)
    _save_language_preference()
    language_changed.emit(locale)

func get_current_language() -> String:
    return current_locale

func get_available_languages() -> Dictionary:
    return AVAILABLE_LANGUAGES.duplicate()

func cycle_language() -> void:
    var locales = AVAILABLE_LANGUAGES.keys()
    var current_index = locales.find(current_locale)
    var next_index = (current_index + 1) % locales.size()
    set_language(locales[next_index])

func _save_language_preference() -> void:
    var config = ConfigFile.new()
    config.set_value("settings", "language", current_locale)
    config.save(SAVE_PATH)

func _load_language_preference() -> void:
    var config = ConfigFile.new()
    if config.load(SAVE_PATH) == OK:
        var saved_locale = config.get_value("settings", "language", "")
        if saved_locale in AVAILABLE_LANGUAGES:
            set_language(saved_locale)
            return
    # Detect system language if no saved preference
    var system_locale = OS.get_locale_language()
    if system_locale in AVAILABLE_LANGUAGES:
        set_language(system_locale)
```

### 4.2 Usage in UI

**Using tr() function**:
```gdscript
# Before (hardcoded)
label.text = "You Died!"

# After (localized)
label.text = tr("YOU_DIED")
```

**With parameters**:
```gdscript
# Wave 5
label.text = tr("WAVE_N") % [wave_number]

# Kills: 42
label.text = tr("KILLS_N") % [kill_count]
```

**Dynamic update on language change**:
```gdscript
func _ready() -> void:
    Localization.language_changed.connect(_on_language_changed)
    _update_texts()

func _on_language_changed(_locale: String) -> void:
    _update_texts()

func _update_texts() -> void:
    title_label.text = tr("YOU_DIED")
    respawn_button.text = tr("RESPAWN")
```

---

## 5. UI Components / UI 组件修改

### 5.1 HUD (`scripts/ui/hud.gd`)

| Element | Translation Key | Example |
|---------|-----------------|---------|
| Level display | LEVEL_N | "Lv.5" |
| Wave display | WAVE_N | "Wave 3" |
| Kills display | KILLS_N | "Kills: 42" |

### 5.2 Upgrade UI (`scripts/ui/upgrade_ui.gd`)

| Element | Translation Key |
|---------|-----------------|
| Title | LEVEL_UP |
| Subtitle | CHOOSE_UPGRADE |
| Upgrade names | SHARPNESS, PROTECTION, etc. |
| Descriptions | SHARPNESS_DESC, etc. |

### 5.3 Game Over UI (`scripts/ui/game_over_ui.gd`)

| Element | Translation Key |
|---------|-----------------|
| Title | YOU_DIED |
| Survival time | SURVIVAL_TIME_N |
| Respawn button | RESPAWN |
| Quit button | QUIT |

---

## 6. Font Support / 字体支持

### 6.1 Required Character Sets

| Language | Character Set |
|----------|---------------|
| English | ASCII (A-Z, a-z, 0-9) |
| 日本語 | Hiragana, Katakana, Kanji |
| 中文 | CJK Unified Ideographs |

### 6.2 Recommended Fonts

| Font | Support | License |
|------|---------|---------|
| Noto Sans CJK | EN, JA, ZH | OFL |
| Source Han Sans | EN, JA, ZH | OFL |

---

## 7. Testing / 测试

### 7.1 Unit Tests

```gdscript
func test_localization_manager_loads():
    assert(Localization != null)

func test_set_language_english():
    Localization.set_language("en")
    assert(Localization.get_current_language() == "en")

func test_set_language_japanese():
    Localization.set_language("ja")
    assert(Localization.get_current_language() == "ja")

func test_invalid_language_fallback():
    Localization.set_language("invalid")
    assert(Localization.get_current_language() == "en")

func test_translation_returns_text():
    Localization.set_language("en")
    assert(tr("YOU_DIED") == "You Died!")

func test_translation_chinese():
    Localization.set_language("zh")
    assert(tr("YOU_DIED") == "你死了！")
```

### 7.2 Manual Test Checklist

- [ ] Game detects system language on first launch
- [ ] Settings menu can switch language
- [ ] All UI updates immediately on language change
- [ ] Language setting persists after restart
- [ ] All translations display correctly (no garbled text)
- [ ] CJK characters render correctly
- [ ] Format strings (%d, %s) work correctly

### 7.3 Visual Test Screenshots

Screenshots saved to `docs/screenshots/localization/`:

```
V4.7.1_hud_en.png, V4.7.1_hud_ja.png, V4.7.1_hud_zh.png
V4.7.2_upgrade_ui_en.png, V4.7.2_upgrade_ui_ja.png, V4.7.2_upgrade_ui_zh.png
V4.7.3_game_over_en.png, V4.7.3_game_over_ja.png, V4.7.3_game_over_zh.png
V4.7.4_cjk_rendering.png
```

---

## 8. Changelog / 更新日志

- **2026-01-24**: HUD real-time language switching
- **2026-01-23**: Initial localization system implementation
