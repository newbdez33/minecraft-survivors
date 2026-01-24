# Test Plan - Minecraft Survivors

本文档包含游戏的测试计划，包括自动化测试和手动测试清单。

---

## 运行自动化测试

```bash
# 运行所有测试
godot --headless --script tests/test_runner.gd

# 或使用快捷脚本
./run_tests.sh
```

### 最新测试结果 (2026-01-23)

```
============================================================
  TEST SUMMARY
============================================================
  Passed: 32
  Failed: 0
  Total:  32

  ✓ ALL TESTS PASSED!
============================================================
```

---

## TDD 工作流程

```
1. 编写测试 (Red)    → 测试失败 ✗
2. 实现功能 (Green)  → 测试通过 ✓
3. 重构代码 (Refactor) → 保持测试通过
```

## 自动化测试覆盖

### Phase 1: Core Foundation ✅

| 测试套件 | 测试数量 | 状态 |
|---------|---------|------|
| Player Tests | 7 | ✅ Pass |
| Camera Tests | 3 | ✅ Pass |
| Arena Tests | 3 | ✅ Pass |
| Asset Tests | 19 | ✅ Pass |

### Phase 2: Combat Basics (TDD)

| 测试套件 | 测试数量 | 状态 |
|---------|---------|------|
| Health Component Tests | 6 | ❌ Not Implemented |
| Zombie Tests | 8 | ❌ Not Implemented |
| Diamond Sword Tests | 6 | ❌ Not Implemented |
| Mob Spawner Tests | 5 | ❌ Not Implemented |
| HUD Tests | 4 | ❌ Not Implemented |

### 测试用例清单

#### Player Tests
- [x] Player script loads
- [x] Player scene loads
- [x] Player can be instantiated
- [x] Player has Sprite2D node
- [x] Player has CollisionShape2D node
- [x] Player has positive speed
- [x] Player is CharacterBody2D
- [x] Player collision layers correct
- [x] Player has sprite texture

#### Camera Tests
- [x] Camera script loads
- [x] Camera has target property
- [x] Camera has smoothing_speed property

#### Arena Tests
- [x] Arena script loads
- [x] Arena has tile_size property
- [x] Arena has background_color property
- [x] Tile variant distribution correct (~70/15/15)
- [x] Tile variant is deterministic

#### Asset Tests
- [x] Character SVGs exist (steve, zombie, skeleton, creeper, spider)
- [x] Tile SVGs exist (grass, variants, dirt)
- [x] Weapon SVGs exist (diamond_sword, bow, arrow)
- [x] Item SVGs exist (xp_orb, hearts)
- [x] Effect SVGs exist (hit, death, explosion)

---

## 手动测试清单

### Phase 1.5: 核心功能测试

#### 1. 游戏启动测试
- [ ] 游戏能正常启动
- [ ] 无报错信息
- [ ] 窗口大小正确 (1280x720)

#### 2. 玩家显示测试
- [ ] Steve 角色显示在屏幕中央
- [ ] Steve 使用正确的像素艺术贴图
- [ ] Steve 没有变形或拉伸

#### 3. 玩家移动测试
| 输入 | 预期结果 | 通过 |
|------|---------|------|
| W / ↑ | 玩家向上移动 | [ ] |
| S / ↓ | 玩家向下移动 | [ ] |
| A / ← | 玩家向左移动 | [ ] |
| D / → | 玩家向右移动 | [ ] |
| W+D | 玩家向右上对角移动 | [ ] |
| S+A | 玩家向左下对角移动 | [ ] |
| 无输入 | 玩家静止 | [ ] |

#### 4. 对角移动速度测试
- [ ] 对角移动速度与直线移动速度相同（已标准化）

#### 5. 摄像机测试
- [ ] 摄像机跟随玩家移动
- [ ] 摄像机移动平滑，无抖动
- [ ] 玩家始终在屏幕中央或附近

#### 6. 草地背景测试
- [ ] 草地瓷砖正确显示
- [ ] 草地有变体（普通草、花朵、草丛）
- [ ] 草地瓷砖无缝拼接
- [ ] 移动时背景正确滚动

#### 7. 性能测试
- [ ] 游戏运行流畅 (60 FPS)
- [ ] 长时间移动无内存泄漏
- [ ] 无明显卡顿

---

## 视觉检查清单

### 角色贴图
| 角色 | 文件 | 颜色正确 | 比例正确 | 像素清晰 |
|------|------|---------|---------|---------|
| Steve | steve.svg | [ ] | [ ] | [ ] |
| Zombie | zombie.svg | [ ] | [ ] | [ ] |
| Skeleton | skeleton.svg | [ ] | [ ] | [ ] |
| Creeper | creeper.svg | [ ] | [ ] | [ ] |
| Spider | spider.svg | [ ] | [ ] | [ ] |

### 地面瓷砖
| 瓷砖 | 文件 | 颜色正确 | 可平铺 | 像素清晰 |
|------|------|---------|--------|---------|
| Grass | grass.svg | [ ] | [ ] | [ ] |
| Grass+Flowers | grass_variant1.svg | [ ] | [ ] | [ ] |
| Grass+Tufts | grass_variant2.svg | [ ] | [ ] | [ ] |
| Dirt | dirt.svg | [ ] | [ ] | [ ] |

### 物品贴图
| 物品 | 文件 | 颜色正确 | 比例正确 |
|------|------|---------|---------|
| Diamond Sword | diamond_sword.svg | [ ] | [ ] |
| Bow | bow.svg | [ ] | [ ] |
| Arrow | arrow.svg | [ ] | [ ] |
| XP Orb | xp_orb.svg | [ ] | [ ] |
| Heart Full | heart_full.svg | [ ] | [ ] |
| Heart Half | heart_half.svg | [ ] | [ ] |
| Heart Empty | heart_empty.svg | [ ] | [ ] |

---

## 回归测试

每次代码修改后运行:

```bash
# 1. 运行自动化测试
godot --path . --headless -s tests/test_runner.gd

# 2. 启动游戏进行快速手动测试
godot --path .

# 3. 检查:
#    - 游戏启动正常
#    - 玩家显示正常
#    - 移动功能正常
#    - 背景显示正常
```

---

## 测试环境

- **引擎**: Godot 4.5.1
- **平台**: macOS (Apple Silicon)
- **分辨率**: 1280x720

---

## Bug 报告模板

```markdown
### Bug 描述
[简短描述问题]

### 重现步骤
1. [步骤1]
2. [步骤2]
3. [步骤3]

### 预期行为
[应该发生什么]

### 实际行为
[实际发生了什么]

### 截图/视频
[如有]

### 环境
- Godot 版本:
- 操作系统:
```

---

## 更新日志

- **2026-01-23**: 创建测试计划，添加自动化测试框架
