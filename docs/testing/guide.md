# Testing Guide / 测试指南

本文档包含游戏的测试计划、自动化测试和手动测试清单。

---

## 1. Running Tests / 运行测试

### Automated Tests

```bash
# Run all tests (headless)
./run_tests.sh

# Or directly
godot --headless --script tests/test_runner.gd
```

Exit code 0 = all tests pass, 1 = failures.

### Visual Tests

```bash
# Run full visual test suite with screenshots
godot --path . tests/visual/full_test_runner.tscn

# Run auto visual test (60 seconds)
godot res://scenes/main.tscn -- --test-mode --duration=60

# Fast test with all features (recommended)
godot res://scenes/main.tscn -- --test-mode --duration=60 --fast-all
```

### Test Mode Options

| Flag | Description |
|------|-------------|
| `--test-mode` | Enable automated testing |
| `--duration=N` | Test duration in seconds (default: 120) |
| `--speed=N` | Game speed multiplier (default: 1.0) |
| `--no-screenshots` | Disable automatic screenshots |
| `--god-mode` | Player invincibility |
| `--fast-progression` | 10x XP gain for faster level-ups |
| `--fast-sword` | Sword evolves at 5/10/15 kills |
| `--fast-all` | Enable all fast options |

---

## 2. Test Coverage / 测试覆盖

### Test Summary by Phase

| Phase | Test Count | Status |
|-------|------------|--------|
| Phase 1: Core Foundation | 37 | ✅ Pass |
| Phase 2: Combat Basics | 32 | ✅ Pass |
| Phase 3: Progression Loop | 63 | ✅ Pass |
| Phase 4: Game Feel | 145 | ✅ Pass |
| Phase 5: Game Enhancements | 112+ | ✅ Pass |
| **Total** | **389+** | ✅ |

### Test Categories

#### Player Tests
- [x] Player script loads
- [x] Player scene loads
- [x] Player movement (WASD/Arrow keys)
- [x] Player has positive speed
- [x] Player collision layers correct

#### Combat Tests
- [x] Sword damage and range
- [x] Sword follows player facing direction
- [x] Attack range visual circle
- [x] Knockback mechanics
- [x] Enemy AI chases player

#### Upgrade Tests
- [x] Sharpness (+5 damage per level)
- [x] Knockback (+30 per level)
- [x] Looting (+20% XP per level)
- [x] Protection (-10% damage per level)
- [x] Swiftness (+15% speed per level)
- [x] Sweeping Edge (+20 range per level)
- [x] Haste (-10% cooldown per level)

#### System Tests
- [x] Day/Night cycle (8 phases)
- [x] Wave system
- [x] XP collection and leveling
- [x] Game over screen
- [x] Localization (EN, JA, ZH)

---

## 3. TDD Workflow / TDD 工作流程

```
1. Write Test (Red)    → Test fails ✗
2. Implement (Green)   → Test passes ✓
3. Refactor           → Keep tests passing
```

All development follows Red→Green→Refactor:
1. Write failing tests in `tests/test_runner.gd`
2. Implement minimal code to pass
3. Refactor if needed
4. Verify all tests still pass

---

## 4. Manual Testing Checklist / 手动测试清单

### 4.1 Game Launch
- [ ] Game starts without errors
- [ ] Window size correct (1280x720)
- [ ] Player (Steve) visible at center

### 4.2 Player Movement
| Input | Expected | Pass |
|-------|----------|------|
| W / ↑ | Move up | [ ] |
| S / ↓ | Move down | [ ] |
| A / ← | Move left | [ ] |
| D / → | Move right | [ ] |
| Diagonal | Normalized speed | [ ] |

### 4.3 Combat
- [ ] Sword auto-attacks nearby enemies
- [ ] Enemies die and drop XP orbs
- [ ] XP orbs are collected on touch
- [ ] Level up triggers upgrade UI

### 4.4 Upgrades
- [ ] 3 random upgrades shown
- [ ] Upgrades can be selected
- [ ] Effects apply correctly
- [ ] "All Maxed" shown when applicable

### 4.5 Game Systems
- [ ] Day/night cycle changes visuals
- [ ] Wave counter increments
- [ ] Enemies spawn in waves
- [ ] Game over on death

### 4.6 Localization
- [ ] Language can be changed in settings
- [ ] All UI text updates on change
- [ ] CJK characters render correctly
- [ ] Setting persists after restart

---

## 5. Visual Test Screenshots / 视觉测试截图

Screenshots are saved to `docs/screenshots/`:

| Directory | Content |
|-----------|---------|
| `testing/` | Manual test screenshots |
| `localization/` | Language UI screenshots |
| `day_night_icons/` | Day/night cycle phases |

---

## 6. Bug Report Template / Bug 报告模板

```markdown
### Bug Description
[Brief description]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happened]

### Screenshots/Video
[If applicable]

### Environment
- Godot version:
- OS:
```

---

## 7. Post-Coding Verification / 编码后验证

**ALWAYS run tests after finishing any coding task:**

```bash
# 1. Run unit tests
./run_tests.sh

# 2. Run visual test
godot res://scenes/main.tscn -- --test-mode --duration=60 --fast-all

# 3. Quick manual check
godot --path . scenes/main.tscn
```

### What the visual test verifies:
1. Automated gameplay runs
2. Screenshots captured at key moments
3. Tracks: kills, level, wave, sword tier
4. Tests sword evolution
5. Verifies systems work together

---

## 8. Test Environment / 测试环境

- **Engine**: Godot 4.5
- **Platform**: macOS / Windows / Linux
- **Resolution**: 1280x720
