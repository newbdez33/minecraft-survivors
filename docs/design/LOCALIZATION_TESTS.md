# 多语言系统测试用例 / Localization Test Cases

## 测试范围 / Test Scope

- LocalizationManager 功能测试
- UI 文本翻译测试
- 语言切换测试
- 持久化测试

---

## 1. LocalizationManager 单元测试

### T1.1 初始化测试
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T1.1.1 | Manager 启动时加载默认语言 | current_locale == "en" |
| T1.1.2 | TranslationServer 同步设置 | TranslationServer.get_locale() == "en" |

### T1.2 语言切换测试
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T1.2.1 | set_locale("zh") 切换中文 | current_locale == "zh" |
| T1.2.2 | set_locale("ja") 切换日文 | current_locale == "ja" |
| T1.2.3 | set_locale("en") 切换英文 | current_locale == "en" |
| T1.2.4 | set_locale("invalid") 无效语言 | current_locale 不变 |
| T1.2.5 | 切换语言触发 language_changed 信号 | signal emitted with locale |

### T1.3 持久化测试
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T1.3.1 | 切换语言后保存到配置文件 | settings.cfg 包含 locale=zh |
| T1.3.2 | 重启后加载保存的语言 | 读取 settings.cfg 中的 locale |

---

## 2. 翻译文件测试

### T2.1 CSV 文件完整性
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T2.1.1 | translations.csv 存在 | 文件存在 |
| T2.1.2 | 所有 key 有英文翻译 | en 列无空值 |
| T2.1.3 | 所有 key 有中文翻译 | zh 列无空值 |
| T2.1.4 | 所有 key 有日文翻译 | ja 列无空值 |

### T2.2 翻译内容测试
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T2.2.1 | tr("GAME_OVER") 英文 | "Game Over" |
| T2.2.2 | tr("GAME_OVER") 中文 | "游戏结束" |
| T2.2.3 | tr("GAME_OVER") 日文 | "ゲームオーバー" |
| T2.2.4 | tr("RESUME") 英文 | "Resume" |
| T2.2.5 | tr("RESUME") 中文 | "继续" |

---

## 3. UI 文本测试

### T3.1 暂停菜单 (pause_menu)
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T3.1.1 | 英文模式显示 "PAUSED" | title == "PAUSED" |
| T3.1.2 | 中文模式显示 "暂停" | title == "暂停" |
| T3.1.3 | Resume 按钮英文 | button.text == "Resume" |
| T3.1.4 | Resume 按钮中文 | button.text == "继续" |

### T3.2 游戏结束界面 (game_over_ui)
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T3.2.1 | 英文显示 "GAME OVER" | title == "GAME OVER" |
| T3.2.2 | 中文显示 "游戏结束" | title == "游戏结束" |
| T3.2.3 | Restart 按钮英文 | button.text == "Restart" |
| T3.2.4 | Restart 按钮中文 | button.text == "重新开始" |
| T3.2.5 | Survived 标签英文 | label contains "Survived" |
| T3.2.6 | Survived 标签中文 | label contains "存活时间" |

### T3.3 HUD
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T3.3.1 | Level 显示英文 | contains "Lv" or "Level" |
| T3.3.2 | Level 显示中文 | contains "等级" |
| T3.3.3 | Wave 显示英文 | contains "Wave" |
| T3.3.4 | Wave 显示中文 | contains "波次" |

### T3.4 升级界面 (upgrade_ui)
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T3.4.1 | Sword 名称英文 | "Sword" |
| T3.4.2 | Sword 名称中文 | "剑" |
| T3.4.3 | Sharpness 名称英文 | "Sharpness" |
| T3.4.4 | Sharpness 名称中文 | "锋利" |
| T3.4.5 | Evolution 标签英文 | "★ EVOLUTION ★" |
| T3.4.6 | Evolution 标签中文 | "★ 进化 ★" |

---

## 4. 动态切换测试

### T4.1 运行时切换
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T4.1.1 | 游戏中切换语言 | 所有UI立即更新 |
| T4.1.2 | 暂停菜单中切换 | 菜单文本立即更新 |
| T4.1.3 | 升级界面中切换 | 升级卡片文本更新 |

### T4.2 语言切换按钮
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T4.2.1 | 暂停菜单显示语言按钮 | [EN] [中] [日] 可见 |
| T4.2.2 | 点击 [中] 切换中文 | locale 变为 "zh" |
| T4.2.3 | 当前语言按钮高亮 | 选中语言按钮样式不同 |

---

## 5. 边界情况测试

### T5.1 缺失翻译
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T5.1.1 | 未定义的 key | 返回 key 本身 |
| T5.1.2 | 某语言缺失翻译 | fallback 到英文 |

### T5.2 特殊字符
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T5.2.1 | 包含 {value} 的翻译 | 占位符正确替换 |
| T5.2.2 | 包含 % 的翻译 | 显示正确 |
| T5.2.3 | 包含特殊符号 ★ | 显示正确 |

### T5.3 字体渲染
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T5.3.1 | 中文字符渲染 | 无乱码/方块 |
| T5.3.2 | 日文字符渲染 | 无乱码/方块 |
| T5.3.3 | 混合文本渲染 | "Lv 5 等级" 正确显示 |

---

## 6. 集成测试

### T6.1 完整流程
| ID | 测试项 | 预期结果 |
|----|--------|----------|
| T6.1.1 | 新游戏 → 升级 → 暂停 → 切换语言 → 继续 | 全程文本正确 |
| T6.1.2 | 中文模式 → 死亡 → 重新开始 | 游戏结束界面中文 |
| T6.1.3 | 切换语言 → 退出 → 重启游戏 | 保持上次语言设置 |

---

## 7. 测试代码示例

```gdscript
# tests/test_localization.gd

func test_locale_switch():
    # T1.2.1
    LocalizationManager.set_locale("zh")
    assert_equal(LocalizationManager.current_locale, "zh")
    assert_equal(TranslationServer.get_locale(), "zh")

func test_translation_content():
    # T2.2.1 - T2.2.2
    TranslationServer.set_locale("en")
    assert_equal(tr("GAME_OVER"), "Game Over")

    TranslationServer.set_locale("zh")
    assert_equal(tr("GAME_OVER"), "游戏结束")

func test_ui_update_on_switch():
    # T4.1.1
    var pause_menu = get_node("/root/Main/PauseMenu")

    LocalizationManager.set_locale("en")
    await get_tree().process_frame
    assert_equal(pause_menu.get_title_text(), "PAUSED")

    LocalizationManager.set_locale("zh")
    await get_tree().process_frame
    assert_equal(pause_menu.get_title_text(), "暂停")
```

---

## 8. 验收标准 / Acceptance Criteria

- [ ] 所有 T1.x 测试通过 (LocalizationManager)
- [ ] 所有 T2.x 测试通过 (翻译文件)
- [ ] 所有 T3.x 测试通过 (UI文本)
- [ ] 所有 T4.x 测试通过 (动态切换)
- [ ] 所有 T5.x 测试通过 (边界情况)
- [ ] 所有 T6.x 测试通过 (集成测试)
- [ ] 中日文字符无乱码
- [ ] 语言设置重启后保持

---

**文档版本**: 1.0
**创建日期**: 2026-01-24
**状态**: 待开发
