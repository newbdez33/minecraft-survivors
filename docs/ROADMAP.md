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

📄 Details: [phase1_core_foundation.md](./phase1_core_foundation.md)

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

📄 Details: [phase2_combat_basics.md](./phase2_combat_basics.md)

---

### ✅ Phase 3: Progression Loop / 成长循环
**Status: COMPLETE**

| Feature | Description |
|---------|-------------|
| Level System | XP-based leveling |
| Upgrade UI | Selection interface |
| Enchantments | Sharpness, Protection, Swiftness, Knockback, Looting, Sweeping Edge |
| HUD | Health bar, XP bar, level display |

📄 Details: [phase3_progression_loop.md](./phase3_progression_loop.md)

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

📄 Details: [phase4_game_feel.md](./phase4_game_feel.md)

---

### 🔄 Phase 5: Game Enhancements / 游戏增强
**Status: IN PROGRESS (90%)**

#### ✅ Completed Features

| Feature | Description | Doc |
|---------|-------------|-----|
| Poison Stacking | Multiple poison effects stack | [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) |
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
| Torch Weapon | Night visibility radius control | [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) |
| Fog of War | Circular night visibility | [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) |
| Enderman Dodge | Arrow dodge (random teleport) | [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) |
| Poison Hearts | Green hearts when poisoned | [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) |

#### ⏳ Remaining Features

| Feature | Priority | Description |
|---------|----------|-------------|
| Achievement System | Medium | Milestones and unlocks |
| Boss Enemies | High | Wave bosses (Wither, Ender Dragon) |
| Elite Monsters | High | Enhanced versions of all enemies |

📄 Details: [phase5_enhancements.md](./phase5_enhancements.md)

---

### 🔄 Phase 6: Bosses & Elites / Boss与精英怪
**Status: IN PROGRESS (17%)**

#### Boss System

| Boss | Wave | HP | Special Ability | Status |
|------|------|-----|-----------------|--------|
| Evoker / 唤魔者 | 5 | 100 | Summons Vexes, Fang Attack | ✅ **DONE** |
| Elder Guardian / 远古守卫者 | 10 | 150 | Laser attack | ⏳ Planned |
| Ravager / 劫掠兽 | 15 | 200 | Charge attack | ⏳ Planned |
| Warden / 监守者 | 20 | 400 | Sonic boom | ⏳ Planned |
| Wither / 凋灵 | 25 | 500 | Wither skulls, summons skeletons | ⏳ Planned |
| Ender Dragon / 末影龙 | 30 | 800 | Dragon breath, flight (FINAL BOSS) | ⏳ Planned |

#### ✅ Implemented Features

| Feature | Description |
|---------|-------------|
| Evoker Boss | First boss at Wave 5, 100 HP, knockback/poison immune |
| Evoker Fang Attack | 5 fangs in line, 0.5s warning, 15 damage |
| Vex Summon | 3 flying minions, 15s lifetime, pass through walls |
| Boss Health Bar | Top-screen health display with boss name |
| Boss Wave Detection | WaveManager.is_boss_wave() |
| Spawner Pause | pause_spawning()/resume_spawning() for boss fights |
| Emerald Pickup | Boss currency drop (30 emeralds) |
| Totem Pickup | Rare drop (10% chance) |

📄 Details: [BOSS_LIST.md](./BOSS_LIST.md)

#### Elite Monster System

| Elite | HP | XP | Special Ability |
|-------|-----|-----|-----------------|
| Elite Zombie / 精英僵尸 | 50 | 25 | Summons 2 zombies on death |
| Elite Skeleton / 精英骷髅 | 38 | 40 | Multi-shot (3 arrows) |
| Elite Spider / 精英蜘蛛 | 30 | 30 | Venom attack (poison) |
| Elite Creeper / 精英苦力怕 | 63 | 50 | Chain lightning explosion |
| Elite Enderman / 精英末影人 | 100 | 75 | Double strike |
| Elite Witch / 精英女巫 | 50 | 60 | Potion storm (3 potions) |

**Spawn Rates:**
- Wave 1-3: 0%
- Wave 4-6: 5%
- Wave 7-9: 10%
- Wave 10-14: 15%
- Wave 15-19: 20%
- Wave 20+: 25%
- Night bonus: +10%

📄 Details: [ELITE_MONSTER_DESIGN.md](./ELITE_MONSTER_DESIGN.md)

---

### 📋 Phase 7: Advanced Features / 高级功能 (BACKLOG)
**Status: PLANNING**

| Feature | Priority | Description |
|---------|----------|-------------|
| Crafting System | High | Material collection, auto-craft |
| MC Dungeons Weapons | High | More weapon types (Glaive, Daggers, etc.) |
| Sound & Music | Medium | BGM, SFX |
| Achievement System | Medium | Milestones, unlocks |
| More Characters | Low | Alex, Zombie Steve, etc. |
| Daily Challenge | Low | Daily missions |
| Economy System | Low | Emeralds, meta progression |

📄 Details: [backlog.md](./backlog.md)

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

📄 Details: [backlog.md](./backlog.md)

---

## Documentation Index / 文档索引

### Core Documentation / 核心文档

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | AI Assistant Guide |
| [HANDOFF.md](./HANDOFF.md) | Project Handoff Status |
| [GAME_DATA.md](./GAME_DATA.md) | Complete Game Data Reference |
| [TESTING.md](./TESTING.md) | Testing Guide |

### Feature Design / 功能设计

| Document | Description |
|----------|-------------|
| [BOSS_LIST.md](./BOSS_LIST.md) | Boss enemies with JP/CN names |
| [ELITE_MONSTER_DESIGN.md](./ELITE_MONSTER_DESIGN.md) | Elite monster system |
| [FEATURE_DESIGN_NIGHT_MECHANICS.md](./FEATURE_DESIGN_NIGHT_MECHANICS.md) | Night fog, torch, Enderman dodge |
| [upgrade_system.md](./upgrade_system.md) | Upgrade/enchantment system |
| [localization_plan.md](./localization_plan.md) | Multi-language support |

### Phase Documentation / 阶段文档

| Document | Phase |
|----------|-------|
| [phase1_core_foundation.md](./phase1_core_foundation.md) | Phase 1 |
| [phase2_combat_basics.md](./phase2_combat_basics.md) | Phase 2 |
| [phase3_progression_loop.md](./phase3_progression_loop.md) | Phase 3 |
| [phase4_game_feel.md](./phase4_game_feel.md) | Phase 4 |
| [phase5_enhancements.md](./phase5_enhancements.md) | Phase 5 |
| [backlog.md](./backlog.md) | Future Plans |

### Infrastructure / 基础设施

| Document | Description |
|----------|-------------|
| [CI_RELEASE_PLAN.md](./CI_RELEASE_PLAN.md) | CI/CD Release Pipeline |
| [DEPLOY_WEB.md](./DEPLOY_WEB.md) | Web Deployment Guide |
| [ART_STYLE.md](./ART_STYLE.md) | Art Style Guide |
| [art_asset_plan.md](./art_asset_plan.md) | Asset Planning |

---

## Test Status / 测试状态

**Total Tests: 701**
- Passed: 659
- Failed: 42 (pre-existing issues)

```
Phase 1: Core Foundation    - 37 tests
Phase 2: Combat Basics      - 32 tests
Phase 3: Progression Loop   - 63 tests
Phase 4: Game Feel          - 145 tests
Phase 5: Game Enhancements  - 361 tests
Phase 6: Boss System        - 63 tests (NEW - all passing)
```

📄 Details: [test_plan.md](./test_plan.md)

---

## Quick Links / 快速链接

- 🎮 **[Play Online](https://newbdez33.github.io/minecraft-survivors/)**
- 📦 **[Releases](https://github.com/newbdez33/minecraft-survivors/releases)**
- 🐛 **[Issues](https://github.com/newbdez33/minecraft-survivors/issues)**

---

## Version History / 版本历史

| Version | Date | Highlights |
|---------|------|------------|
| v0.6.0 | 2026-01-29 | **Evoker Boss**, Vex minions, Fang attack, Boss health bar |
| v0.5.0 | 2026-01-26 | Torch fog system, bow rebalance, elite/boss design |
| v0.4.0 | 2026-01-24 | Night mechanics, poison hearts, Enderman dodge |
| v0.3.0 | 2026-01-22 | Weapon evolution, health pickups |
| v0.2.0 | 2026-01-20 | Day/night cycle, localization |
| v0.1.0 | 2026-01-15 | Initial release |

---

## Contributing / 贡献

See [CLAUDE.md](../CLAUDE.md) for development guidelines and code conventions.

---

*Last Updated: 2026-01-29*
