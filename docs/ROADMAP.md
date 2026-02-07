# Development Roadmap / 开发路线图

本文档整理了 Minecraft Survivors 的完整开发计划和进度。

---

## Overview / 项目概述

**Minecraft Survivors** 是一款 Vampire Survivors 风格的肉鸽生存游戏，采用 Minecraft 主题。

- **引擎**: Godot 4.5
- **语言**: GDScript
- **平台**: Windows, macOS, Web
- **支持语言**: English, 日本語, 中文

---

## Development Phases / 开发阶段

### ✅ Phase 1: Core Foundation / 核心基础
**Status: COMPLETE**

| Feature | Description |
|---------|-------------|
| Player Movement | WASD/Arrow keys, mouse click |
| Camera System | Smooth follow camera |
| Arena System | Procedural tile-based arena |
| Basic Assets | Player sprite, tiles |

📄 Details: [phase1_core_foundation.md](./phases/phase1_core_foundation.md)

---

### ✅ Phase 2: Combat Basics / 战斗基础
**Status: COMPLETE**

| Feature | Description |
|---------|-------------|
| Sword Weapon | Auto-attack melee weapon |
| Enemy: Zombie | Basic chaser enemy |
| Enemy: Skeleton | Ranged archer enemy |
| Enemy: Spider | Fast jumper enemy |
| Enemy: Creeper | Exploding enemy |
| Health System | Player/enemy health |
| XP Orbs | Experience collection |

📄 Details: [phase2_combat_basics.md](./phases/phase2_combat_basics.md)

---

### ✅ Phase 3: Progression Loop / 成长循环
**Status: COMPLETE**

| Feature | Description |
|---------|-------------|
| Level System | XP-based leveling |
| Upgrade UI | Selection interface |
| Enchantments | Sharpness, Protection, Swiftness, Knockback, Looting, Sweeping Edge |
| HUD | Health bar, XP bar, level display |

📄 Details: [phase3_progression_loop.md](./phases/phase3_progression_loop.md)

---

### ✅ Phase 4: Game Feel / 游戏体验
**Status: COMPLETE**

| Feature | Description |
|---------|-------------|
| Game Stats | Time, kills, damage tracking |
| Day/Night Cycle | 8-phase visual cycle |
| Wave Manager | Progressive difficulty |
| Game Over UI | Death screen with stats |
| Localization | EN, JA, ZH support |
| Enemy: Enderman | Teleporting elite |
| Enemy: Witch | Potion-throwing caster |
| Poison System | DOT with visual effects |

📄 Details: [phase4_game_feel.md](./phases/phase4_game_feel.md)

---

### ✅ Phase 5: Game Enhancements / 游戏增强
**Status: COMPLETE**

#### Completed Features

| Feature | Description | Doc |
|---------|-------------|-----|
| Poison Stacking | Multiple poison effects stack | [night_mechanics.md](./design/night_mechanics.md) |
| Weapon Slots | 4-position weapon system | - |
| Score System | High score tracking | - |
| Combo System | Kill streak XP bonus | - |
| Haste Upgrade | Attack speed boost | - |
| Bow Weapon | Ranged auto-attack (12 levels) | [GAME_DATA.md](./GAME_DATA.md) |
| Crossbow Evolution | Bow evolves at level 12 | [GAME_DATA.md](./GAME_DATA.md) |
| Sword Evolution | Wood → Stone → Iron → Diamond | [GAME_DATA.md](./GAME_DATA.md) |
| Main Menu | Start, Settings, Scoreboard | - |
| Settings Panel | Volume, language, screen shake | - |
| Lucky Drop | Rare item drops | - |
| Health Pickups | Meat drops, Golden Apple spawns | [GAME_DATA.md](./GAME_DATA.md) |
| Torch Weapon | Night visibility radius control | [night_mechanics.md](./design/night_mechanics.md) |
| Fog of War | Circular night visibility | [night_mechanics.md](./design/night_mechanics.md) |
| Enderman Dodge | Arrow dodge (random teleport) | [night_mechanics.md](./design/night_mechanics.md) |
| Poison Hearts | Green hearts when poisoned | [night_mechanics.md](./design/night_mechanics.md) |
| Enemy Animation System | Procedural Tween-based animations | - |
| Upgrade Visual Feedback | Color-coded effects and stat popups | - |
| Character Selection | Steve and Alex with unique stats | - |

📄 Details: [phase5_enhancements.md](./phases/phase5_enhancements.md)

---

### ✅ Phase 6: Boss System / Boss系统
**Status: COMPLETE**

#### Boss System

| Boss | Wave | HP | Special Ability | Status |
|------|------|-----|-----------------|--------|
| Evoker / 唤魔者 | 5 | 400 | Summons Vexes, Fang Attack | ✅ **DONE** |
| Elder Guardian / 远古守卫者 | 10 | 600 | Mining fatigue beam | ✅ **DONE** |
| Ravager / 劫掠兽 | 15 | 800 | Charge attack | ✅ **DONE** |
| Warden / 监守者 | 20 | 1000 | Sonic boom | ✅ **DONE** |
| Wither / 凋灵 | 25 | 1200 | Wither skulls | ✅ **DONE** |
| Ender Dragon / 末影龙 | 30 | 1500 | Dragon breath (FINAL BOSS) | ✅ **DONE** |

#### Implemented Features

| Feature | Description |
|---------|-------------|
| 6 Boss Enemies | Evoker, Elder Guardian, Ravager, Warden, Wither, Ender Dragon |
| Boss Health Bar | Top-screen health display with boss name |
| Boss Wave Detection | WaveManager.is_boss_wave() every 5 waves |
| Spawner Pause | pause_spawning()/resume_spawning() for boss fights |
| Boss Drops | Emerald (30), Totem (10% chance) |
| Boss Pixel Art | All 6 bosses have detailed SVG sprites |
| Boss Animations | Unique attack animations per boss |

📄 Details: [boss_enemies.md](./design/boss_enemies.md)

---

### 📋 Phase 7: Advanced Features / 高级功能 (BACKLOG)
**Status: PLANNING**

| Feature | Priority | Description |
|---------|----------|-------------|
| Achievement System | High | Milestones, unlocks |
| Elite Monsters | High | Enhanced versions of all enemies |
| Crafting System | Medium | Material collection, auto-craft |
| MC Dungeons Weapons | Medium | More weapon types (Glaive, Daggers, etc.) |
| Sound & Music | Medium | BGM, SFX |
| More Characters | Low | Zombie Steve, etc. |
| Daily Challenge | Low | Daily missions |
| Economy System | Low | Emeralds, meta progression |

📄 Details: [backlog.md](./phases/backlog.md)

---

### 📋 Phase 8: Platform Expansion / 平台扩展 (BACKLOG)
**Status: FUTURE**

| Platform | Priority | Status |
|----------|----------|--------|
| Windows | High | ✅ Released |
| macOS | High | ✅ Released |
| Web | High | ✅ Released |
| Android | Low | Planned |
| iOS | Low | Planned |
| Steam | Very Low | Future |

📄 Details: [backlog.md](./phases/backlog.md)

---

## Documentation Index / 文档索引

### Core Documentation / 核心文档

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | AI Assistant Guide |
| [HANDOFF.md](./HANDOFF.md) | Project Handoff Status |
| [GAME_DATA.md](./GAME_DATA.md) | Complete Game Data Reference |

### Feature Design / 功能设计 (`design/`)

| Document | Description |
|----------|-------------|
| [boss_enemies.md](./design/boss_enemies.md) | Boss enemies with JP/CN names |
| [elite_monsters.md](./design/elite_monsters.md) | Elite monster system |
| [night_mechanics.md](./design/night_mechanics.md) | Night fog, torch, Enderman dodge |
| [upgrade_system.md](./design/upgrade_system.md) | Upgrade/enchantment system |
| [localization.md](./design/localization.md) | Multi-language support |
| [art_style.md](./design/art_style.md) | Art style guide |

### Phase Documentation / 阶段文档 (`phases/`)

| Document | Phase |
|----------|-------|
| [phase1_core_foundation.md](./phases/phase1_core_foundation.md) | Phase 1 |
| [phase2_combat_basics.md](./phases/phase2_combat_basics.md) | Phase 2 |
| [phase3_progression_loop.md](./phases/phase3_progression_loop.md) | Phase 3 |
| [phase4_game_feel.md](./phases/phase4_game_feel.md) | Phase 4 |
| [phase5_enhancements.md](./phases/phase5_enhancements.md) | Phase 5 |
| [backlog.md](./phases/backlog.md) | Future Plans |

### Testing / 测试 (`testing/`)

| Document | Description |
|----------|-------------|
| [guide.md](./testing/guide.md) | Testing guide and checklist |
| [phase5_test_plan.md](./testing/phase5_test_plan.md) | Phase 5 test cases |

### Infrastructure / 基础设施 (`infrastructure/`)

| Document | Description |
|----------|-------------|
| [release.md](./infrastructure/release.md) | CI/CD Release Pipeline |
| [web_deploy.md](./infrastructure/web_deploy.md) | Web Deployment Guide |
| [assets.md](./infrastructure/assets.md) | Asset Planning |

---

## Test Status / 测试状态

**Total Tests: 517+**
- Unit Tests: 389 (all passing)
- Visual Tests: 128 (all passing)

```
Phase 1: Core Foundation    - 37 tests
Phase 2: Combat Basics      - 32 tests
Phase 3: Progression Loop   - 63 tests
Phase 4: Game Feel          - 145 tests
Phase 5: Game Enhancements  - 112 tests
Visual Tests                - 128 tests (animations, upgrades, enemies)
```

📄 Details: [testing/guide.md](./testing/guide.md)

---

## Quick Links / 快速链接

- 🎮 **[Play Online](https://newbdez33.github.io/minecraft-survivors/)**
- 📦 **[Releases](https://github.com/newbdez33/minecraft-survivors/releases)**
- 🐛 **[Issues](https://github.com/newbdez33/minecraft-survivors/issues)**

---

## Version History / 版本历史

| Version | Date | Highlights |
|---------|------|------------|
| v0.6.2 | 2026-02-01 | Enemy animations, upgrade visual feedback, Windows build fix |
| v0.6.0 | 2026-01-29 | **All 6 Bosses**, Evoker/Elder Guardian/Ravager/Warden/Wither/Ender Dragon |
| v0.5.0 | 2026-01-26 | Torch fog system, bow rebalance, elite/boss design |
| v0.4.0 | 2026-01-24 | Night mechanics, poison hearts, Enderman dodge |
| v0.3.0 | 2026-01-22 | Weapon evolution, health pickups |
| v0.2.0 | 2026-01-20 | Day/night cycle, localization |
| v0.1.0 | 2026-01-15 | Initial release |

---

## Contributing / 贡献

See [CLAUDE.md](../CLAUDE.md) for development guidelines and code conventions.

---

*Last Updated: 2026-02-01*
