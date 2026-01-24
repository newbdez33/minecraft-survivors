# Localization Plan / 多言語対応計画 / 本地化方案

本文档详细说明游戏多语言支持的技术实现方案。

---

## 1. 概述

### 支持语言
| 代码 | 语言 | 备注 |
|------|------|------|
| en | English | 默认语言 |
| ja | 日本語 | Japanese |
| zh | 简体中文 | Simplified Chinese |

### Godot 本地化系统
Godot 提供内置的 `TranslationServer`，支持：
- CSV / PO / XLIFF 格式翻译文件
- 运行时语言切换
- `tr()` 函数自动翻译

---

## 2. 架构设计

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

## 3. 翻译文件结构

### 3.1 CSV 格式 (推荐)

**文件路径**: `localization/translations.csv`

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
DAY_N,Day %d,第%d日目,第 %d 天
SURVIVAL_TIME,Survival Time,生存時間,存活时间
SURVIVAL_TIME_N,Time: %s,時間: %s,时间: %s
LEVEL_UP,Level Up!,レベルアップ！,升级！
CHOOSE_UPGRADE,Choose an Upgrade,強化を選択してください,请选择一项强化
SHARPNESS,Sharpness,鋭さ,锋利
SHARPNESS_DESC,+5 damage per level,レベルごとに攻撃力+5,每级 +5 伤害
KNOCKBACK,Knockback,ノックバック,击退
KNOCKBACK_DESC,+30 knockback per level,レベルごとにノックバック+30,每级 +30 击退
LOOTING,Looting,ドロップ増加,抢夺
LOOTING_DESC,+20% XP gain per level,レベルごとにXP獲得+20%,每级 +20% 经验获取
PROTECTION,Protection,防護,保护
PROTECTION_DESC,-10% damage taken per level,レベルごとに被ダメージ-10%,每级 -10% 受到伤害
SWIFTNESS,Swiftness,俊敏,迅捷
SWIFTNESS_DESC,+15% move speed per level,レベルごとに移動速度+15%,每级 +15% 移动速度
SWEEPING,Sweeping Edge,範囲攻撃,横扫之刃
SWEEPING_DESC,+20 attack range per level,レベルごとに攻撃範囲+20,每级 +20 攻击范围
SETTINGS,Settings,設定,设置
LANGUAGE,Language,言語,语言
ENGLISH,English,English,English
JAPANESE,日本語,日本語,日本語
CHINESE,简体中文,简体中文,简体中文
PAUSED,Paused,ポーズ中,已暂停
RESUME,Resume,再開,继续
MAIN_MENU,Main Menu,メインメニュー,主菜单
```

### 3.2 Godot 项目设置

**project.godot** 添加:
```ini
[internationalization]
locale/translations=PackedStringArray("res://localization/translations.en.translation", "res://localization/translations.ja.translation", "res://localization/translations.zh.translation")
locale/fallback="en"
```

---

## 4. 代码实现

### 4.1 LocalizationManager (Autoload)

**文件**: `scripts/systems/localization_manager.gd`

```gdscript
extends Node
class_name LocalizationManager

## 多语言管理器
## Manages game localization and language switching

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

## 设置语言
func set_language(locale: String) -> void:
    if locale not in AVAILABLE_LANGUAGES:
        push_warning("Unknown locale: %s, falling back to 'en'" % locale)
        locale = "en"

    current_locale = locale
    TranslationServer.set_locale(locale)
    _save_language_preference()
    language_changed.emit(locale)

## 获取当前语言
func get_current_language() -> String:
    return current_locale

## 获取当前语言显示名称
func get_current_language_name() -> String:
    return AVAILABLE_LANGUAGES.get(current_locale, "English")

## 获取所有可用语言
func get_available_languages() -> Dictionary:
    return AVAILABLE_LANGUAGES.duplicate()

## 循环切换语言
func cycle_language() -> void:
    var locales = AVAILABLE_LANGUAGES.keys()
    var current_index = locales.find(current_locale)
    var next_index = (current_index + 1) % locales.size()
    set_language(locales[next_index])

## 检测系统语言并设置
func detect_system_language() -> void:
    var system_locale = OS.get_locale_language()
    if system_locale in AVAILABLE_LANGUAGES:
        set_language(system_locale)
    else:
        set_language("en")

## 保存语言设置
func _save_language_preference() -> void:
    var config = ConfigFile.new()
    config.set_value("settings", "language", current_locale)
    config.save(SAVE_PATH)

## 加载语言设置
func _load_language_preference() -> void:
    var config = ConfigFile.new()
    var err = config.load(SAVE_PATH)
    if err == OK:
        var saved_locale = config.get_value("settings", "language", "")
        if saved_locale in AVAILABLE_LANGUAGES:
            set_language(saved_locale)
            return
    # 如果没有保存的设置，检测系统语言
    detect_system_language()
```

### 4.2 注册为 Autoload

**project.godot**:
```ini
[autoload]
Localization="*res://scripts/systems/localization_manager.gd"
```

---

## 5. UI 组件更新

### 5.1 使用 tr() 函数

**Before (硬编码)**:
```gdscript
label.text = "You Died!"
```

**After (本地化)**:
```gdscript
label.text = tr("YOU_DIED")
```

### 5.2 带参数的翻译

**格式化字符串**:
```gdscript
# Wave 5
label.text = tr("WAVE_N") % [wave_number]

# Kills: 42
label.text = tr("KILLS_N") % [kill_count]

# Time: 05:30
label.text = tr("SURVIVAL_TIME_N") % [time_string]
```

### 5.3 动态更新 UI

当语言切换时，需要更新所有显示的文本：

```gdscript
extends CanvasLayer
class_name GameOverUI

@onready var title_label: Label = $VBox/TitleLabel
@onready var respawn_button: Button = $VBox/RespawnButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
    # 连接语言变更信号
    Localization.language_changed.connect(_on_language_changed)
    _update_texts()

func _on_language_changed(_locale: String) -> void:
    _update_texts()

func _update_texts() -> void:
    title_label.text = tr("YOU_DIED")
    respawn_button.text = tr("RESPAWN")
    quit_button.text = tr("QUIT")
```

---

## 6. 各 UI 组件修改清单

### 6.1 HUD (`scripts/ui/hud.gd`)

| 元素 | 翻译 Key | 示例 |
|------|----------|------|
| Level 显示 | LEVEL_N | "Lv.5" |
| Wave 显示 | WAVE_N | "Wave 3" |
| Kills 显示 | KILLS_N | "Kills: 42" |
| Time 显示 | DAY_N / NIGHT | "Day 2" |

### 6.2 Upgrade UI (`scripts/ui/upgrade_ui.gd`)

| 元素 | 翻译 Key |
|------|----------|
| 标题 | LEVEL_UP |
| 副标题 | CHOOSE_UPGRADE |
| Sharpness 名称 | SHARPNESS |
| Sharpness 描述 | SHARPNESS_DESC |
| ... | ... |

### 6.3 Game Over UI (`scripts/ui/game_over_ui.gd`)

| 元素 | 翻译 Key |
|------|----------|
| 标题 | YOU_DIED |
| 存活时间 | SURVIVAL_TIME_N |
| 击杀数 | KILLS_N |
| 等级 | LEVEL_N |
| 波次 | WAVE_N |
| 重生按钮 | RESPAWN |
| 退出按钮 | QUIT |

### 6.4 Settings UI (新增)

| 元素 | 翻译 Key |
|------|----------|
| 标题 | SETTINGS |
| 语言选项 | LANGUAGE |
| English | ENGLISH |
| 日本語 | JAPANESE |
| 简体中文 | CHINESE |

---

## 7. 语言切换 UI 设计

### 7.1 设置菜单方式

```
┌─────────────────────────────┐
│         Settings            │
├─────────────────────────────┤
│                             │
│  Language: [English    ▼]   │
│            ┌───────────┐    │
│            │ English   │    │
│            │ 日本語    │    │
│            │ 简体中文  │    │
│            └───────────┘    │
│                             │
│        [ OK ]  [Cancel]     │
└─────────────────────────────┘
```

### 7.2 快捷键方式

- 按 `L` 键循环切换语言 (开发/调试用)

```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_language"):
        Localization.cycle_language()
```

---

## 8. 字体支持

### 8.1 需要支持的字符集

| 语言 | 字符集 |
|------|--------|
| English | ASCII (A-Z, a-z, 0-9) |
| 日本語 | Hiragana, Katakana, Kanji |
| 中文 | CJK Unified Ideographs |

### 8.2 推荐字体

| 字体 | 支持 | 许可证 |
|------|------|--------|
| Noto Sans CJK | EN, JA, ZH | OFL |
| Source Han Sans | EN, JA, ZH | OFL |
| M PLUS 1p | EN, JA | OFL |

### 8.3 Godot 字体设置

**方式 1: 使用 DynamicFont**
```gdscript
# 在主题中设置支持 CJK 的字体
var font = load("res://assets/fonts/NotoSansCJK-Regular.ttf")
```

**方式 2: 字体回退链**
```gdscript
# project.godot
[gui]
theme/custom_font="res://assets/fonts/main_font.tres"
```

---

## 9. 测试计划

### 9.1 单元测试

```gdscript
# tests/unit/test_localization.gd

func test_localization_manager_loads():
    assert(Localization != null)

func test_set_language_english():
    Localization.set_language("en")
    assert(Localization.get_current_language() == "en")

func test_set_language_japanese():
    Localization.set_language("ja")
    assert(Localization.get_current_language() == "ja")

func test_set_language_chinese():
    Localization.set_language("zh")
    assert(Localization.get_current_language() == "zh")

func test_invalid_language_fallback():
    Localization.set_language("invalid")
    assert(Localization.get_current_language() == "en")

func test_translation_returns_text():
    Localization.set_language("en")
    assert(tr("YOU_DIED") == "You Died!")

func test_translation_japanese():
    Localization.set_language("ja")
    assert(tr("YOU_DIED") == "死亡した！")

func test_translation_chinese():
    Localization.set_language("zh")
    assert(tr("YOU_DIED") == "你死了！")
```

### 9.2 手动测试清单

- [ ] 游戏启动时检测系统语言
- [ ] 设置菜单可以切换语言
- [ ] 切换语言后所有 UI 立即更新
- [ ] 语言设置在重启后保持
- [ ] 所有翻译文本正确显示 (无乱码)
- [ ] CJK 字符正确渲染
- [ ] 格式化字符串 (%d, %s) 正常工作

### 9.3 Visual Test Plan (视觉测试)

自动截图测试，验证每种语言的 UI 显示正确。

**测试脚本**: `tests/visual/test_localization_visual.gd`

```gdscript
extends Node

## 本地化视觉测试
## 自动切换语言并截图保存到 docs/screenshots/localization/

const SCREENSHOT_DIR = "res://docs/screenshots/localization/"
const LANGUAGES = ["en", "ja", "zh"]

## 测试用例映射到截图文件
var tests_to_run = [
    {"test_id": "V4.7.1", "name": "hud", "wait": 2.0, "trigger": null},
    {"test_id": "V4.7.2", "name": "upgrade_ui", "wait": 1.0, "trigger": "level_up"},
    {"test_id": "V4.7.3", "name": "game_over", "wait": 1.0, "trigger": "die"},
]

func _ready() -> void:
    # 确保目录存在
    var dir = DirAccess.open("res://docs/screenshots/")
    if dir:
        dir.make_dir("localization")

    await _run_visual_tests()

    # 运行 CJK 渲染测试
    await _test_cjk_rendering()

    print("="*50)
    print("Visual tests complete!")
    print("Screenshots saved to: docs/screenshots/localization/")
    print("="*50)
    get_tree().quit()

func _run_visual_tests() -> void:
    for test in tests_to_run:
        for lang in LANGUAGES:
            Localization.set_language(lang)
            await get_tree().create_timer(0.3).timeout

            # 触发特定 UI
            if test.trigger == "level_up":
                _trigger_level_up()
            elif test.trigger == "die":
                _trigger_game_over()

            await get_tree().create_timer(test.wait).timeout
            await _capture_screenshot(test.test_id, test.name, lang)

            # 关闭 UI
            _close_all_ui()
            await get_tree().create_timer(0.3).timeout

func _capture_screenshot(test_id: String, name: String, lang: String) -> void:
    # 命名格式: V4.7.1_hud_en.png
    var filename = "%s_%s_%s.png" % [test_id, name, lang]
    var path = SCREENSHOT_DIR + filename

    var image = get_viewport().get_texture().get_image()
    image.save_png(ProjectSettings.globalize_path(path))
    print("[%s] Captured: %s" % [lang.to_upper(), filename])

func _test_cjk_rendering() -> void:
    ## V4.7.4: CJK 字符渲染测试
    ## 显示包含日文和中文的测试文本

    var test_label = Label.new()
    test_label.text = "CJK Test / CJK テスト / CJK 测试\n"
    test_label.text += "日本語: あいうえお カキクケコ 漢字\n"
    test_label.text += "中文: 你好世界 升级 击杀 经验"
    test_label.position = Vector2(100, 100)
    test_label.add_theme_font_size_override("font_size", 24)
    add_child(test_label)

    await get_tree().create_timer(1.0).timeout

    var image = get_viewport().get_texture().get_image()
    var path = SCREENSHOT_DIR + "V4.7.4_cjk_rendering.png"
    image.save_png(ProjectSettings.globalize_path(path))
    print("[CJK] Captured: V4.7.4_cjk_rendering.png")

    test_label.queue_free()

func _trigger_level_up() -> void:
    # 模拟升级触发 Upgrade UI
    var player = get_tree().get_first_node_in_group("player")
    if player and player.has_method("_level_up"):
        player._level_up()

func _trigger_game_over() -> void:
    # 模拟死亡触发 Game Over UI
    var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
    if game_over_ui and game_over_ui.has_method("show"):
        game_over_ui.show()

func _close_all_ui() -> void:
    var upgrade_ui = get_tree().get_first_node_in_group("upgrade_ui")
    if upgrade_ui and upgrade_ui.has_method("hide"):
        upgrade_ui.hide()

    var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
    if game_over_ui and game_over_ui.has_method("hide"):
        game_over_ui.hide()
```

**截图输出**:

所有视觉测试截图保存到 `docs/screenshots/localization/` 目录，并提交到版本库：

```
docs/screenshots/localization/
├── V4.7.1_hud_en.png           # V4.7.1 - English HUD
├── V4.7.1_hud_ja.png           # V4.7.1 - 日本語 HUD
├── V4.7.1_hud_zh.png           # V4.7.1 - 中文 HUD
├── V4.7.2_upgrade_ui_en.png    # V4.7.2 - English Upgrade Selection
├── V4.7.2_upgrade_ui_ja.png    # V4.7.2 - 日本語 Upgrade Selection
├── V4.7.2_upgrade_ui_zh.png    # V4.7.2 - 中文 Upgrade Selection
├── V4.7.3_game_over_en.png     # V4.7.3 - English Game Over
├── V4.7.3_game_over_ja.png     # V4.7.3 - 日本語 Game Over
├── V4.7.3_game_over_zh.png     # V4.7.3 - 中文 Game Over
└── V4.7.4_cjk_rendering.png    # V4.7.4 - CJK Font Test
```

**命名规则**: `V{test_id}_{ui_name}_{locale}.png`

**视觉测试检查项**:

| Test ID | Screenshot | 检查项 | EN | JA | ZH |
|---------|------------|--------|----|----|----|
| V4.7.1 | `V4.7.1_hud_en.png` | Level 显示 | Lv.1 | - | - |
| V4.7.1 | `V4.7.1_hud_ja.png` | Level 显示 | - | Lv.1 | - |
| V4.7.1 | `V4.7.1_hud_zh.png` | Level 显示 | - | - | 等级 1 |
| V4.7.1 | all | Wave 显示 | Wave 1 | ウェーブ 1 | 第 1 波 |
| V4.7.1 | all | Kills 显示 | Kills: 0 | 撃破数: 0 | 击杀: 0 |
| V4.7.2 | `V4.7.2_upgrade_ui_en.png` | 标题 | Level Up! | - | - |
| V4.7.2 | `V4.7.2_upgrade_ui_ja.png` | 标题 | - | レベルアップ！ | - |
| V4.7.2 | `V4.7.2_upgrade_ui_zh.png` | 标题 | - | - | 升级！ |
| V4.7.2 | all | 副标题 | Choose an Upgrade | 強化を選択 | 选择强化 |
| V4.7.2 | all | 卡片名称 | Sharpness | 鋭さ | 锋利 |
| V4.7.3 | `V4.7.3_game_over_en.png` | 标题 | You Died! | - | - |
| V4.7.3 | `V4.7.3_game_over_ja.png` | 标题 | - | 死亡した！ | - |
| V4.7.3 | `V4.7.3_game_over_zh.png` | 标题 | - | - | 你死了！ |
| V4.7.3 | all | 按钮 | Respawn | リスポーン | 重生 |
| V4.7.4 | `V4.7.4_cjk_rendering.png` | CJK 渲染 | - | あいうえお 漢字 | 你好世界 |

**截图验证 Checklist**:

```
docs/screenshots/localization/
├── [ ] V4.7.1_hud_en.png         ✓ "Lv.1" "Wave 1" "Kills: 0"
├── [ ] V4.7.1_hud_ja.png         ✓ "Lv.1" "ウェーブ 1" "撃破数: 0"
├── [ ] V4.7.1_hud_zh.png         ✓ "等级 1" "第 1 波" "击杀: 0"
├── [ ] V4.7.2_upgrade_ui_en.png  ✓ "Level Up!" "Sharpness"
├── [ ] V4.7.2_upgrade_ui_ja.png  ✓ "レベルアップ！" "鋭さ"
├── [ ] V4.7.2_upgrade_ui_zh.png  ✓ "升级！" "锋利"
├── [ ] V4.7.3_game_over_en.png   ✓ "You Died!" "Respawn"
├── [ ] V4.7.3_game_over_ja.png   ✓ "死亡した！" "リスポーン"
├── [ ] V4.7.3_game_over_zh.png   ✓ "你死了！" "重生"
└── [ ] V4.7.4_cjk_rendering.png  ✓ No tofu (□) characters
```

**运行视觉测试**:
```bash
# 方式 1: 命令行
godot --path . --script tests/visual/test_localization_visual.gd

# 方式 2: 添加到 run_tests.sh
./run_visual_tests.sh
```

**CI/CD 集成** (可选):
```yaml
# .github/workflows/visual-tests.yml
- name: Run Visual Tests
  run: |
    godot --headless --path . --script tests/visual/test_localization_visual.gd

- name: Upload Screenshots
  uses: actions/upload-artifact@v3
  with:
    name: localization-screenshots
    path: screenshots/localization/
```

---

## 10. 实现步骤

### Step 1: 创建翻译文件
```
1. 创建 localization/translations.csv
2. 添加所有翻译 key 和对应翻译
3. 在 Godot 中导入并生成 .translation 文件
```

### Step 2: 创建 LocalizationManager
```
1. 创建 scripts/systems/localization_manager.gd
2. 注册为 Autoload (project.godot)
3. 实现语言切换和持久化
```

### Step 3: 更新现有 UI
```
1. HUD - 使用 tr() 替换硬编码文本
2. Upgrade UI - 使用 tr() 替换硬编码文本
3. 连接 language_changed 信号
```

### Step 4: 创建 Game Over UI
```
1. 新建 scenes/ui/game_over_ui.tscn
2. 使用 tr() 实现所有文本
```

### Step 5: 添加设置 UI (可选)
```
1. 创建语言选择下拉菜单
2. 或添加快捷键切换
```

### Step 6: 添加 CJK 字体
```
1. 下载 Noto Sans CJK 字体
2. 配置 Godot 主题使用该字体
```

---

## 11. 文件清单

| 文件 | 类型 | 描述 |
|------|------|------|
| `localization/translations.csv` | 数据 | 翻译源文件 |
| `localization/translations.en.translation` | 数据 | English 编译文件 |
| `localization/translations.ja.translation` | 数据 | 日本語 编译文件 |
| `localization/translations.zh.translation` | 数据 | 中文 编译文件 |
| `scripts/systems/localization_manager.gd` | 脚本 | 语言管理器 |
| `assets/fonts/NotoSansCJK-Regular.ttf` | 资源 | CJK 字体 |
| `tests/unit/test_localization.gd` | 测试 | 本地化测试 |

---

## 12. 更新日志

- **2026-01-24**: HUD 实时语言切换 - 暂停菜单中切换语言时 HUD 自动刷新
- **2026-01-23**: 创建本地化技术方案文档
