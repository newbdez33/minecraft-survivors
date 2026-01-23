# Project Handoff Document

**Last Updated:** 2024-01-23
**Project:** Minecraft Survivors
**Current Phase:** Phase 4 - Game Feel (In Progress)

---

## Project Overview

A Vampire Survivors-like roguelike game with Minecraft theme built in Godot 4.5. Player controls Steve and survives waves of mobs (Zombies, Skeletons, Spiders, Creepers).

## Completed Phases

### Phase 1: Core Foundation ✅
- Player movement (WASD/Arrow keys)
- Basic arena with boundaries
- Camera following player

### Phase 2: Combat Basics ✅
- Sword weapon with auto-attack
- Enemy types: Zombie, Skeleton, Spider, Creeper
- Health system and damage
- XP orbs and collection

### Phase 3: Progression Loop ✅
- Level-up system
- Upgrade selection UI
- 6 Minecraft-themed upgrades:
  - Sharpness (damage)
  - Protection (defense)
  - Swiftness (speed)
  - Knockback
  - Looting (XP bonus)
  - Sweeping Edge (range)
- HUD with health/XP bars

### Phase 4: Game Feel (In Progress) 🔄

#### Completed Steps (1-6):
| Step | System | Status | Tests |
|------|--------|--------|-------|
| 1 | GameStats | ✅ Done | Tracks survival time, kills, damage, XP |
| 2 | DayNightCycle | ✅ Done | DAWN→DAY→DUSK→NIGHT cycle |
| 3 | WaveManager | ✅ Done | Wave-based spawning with scaling |
| 4 | GameOverUI | ✅ Done | Death screen with stats |
| 5 | Localization | ✅ Done | EN, JA, ZH support |
| 6 | Integration | ✅ Done | Game.gd connects all systems |

#### Remaining Steps (7-12):
| Step | System | Status |
|------|--------|--------|
| 7 | New Assets | ⏳ Pending |
| 8 | Enderman Enemy | ⏳ Pending |
| 9 | Witch Enemy | ⏳ Pending |
| 10 | Potion Pickups | ⏳ Pending |
| 11 | Update Spawner | ⏳ Pending |
| 12 | Final Integration | ⏳ Pending |

---

## Test Status

**155 tests passing** (0 failures)

```
Phase 1: Core Foundation - 25 tests
Phase 2: Combat Basics - 52 tests
Phase 3: Progression Loop - 40 tests
Phase 4: Game Feel - 38 tests
```

Run tests with:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/test_runner.gd
```

---

## Key Files Structure

```
minecraft-survivors/
├── scenes/
│   ├── main.tscn              # Main game scene
│   ├── player.tscn            # Player (Steve)
│   ├── enemies/               # Zombie, Skeleton, Spider, Creeper
│   ├── weapons/               # Sword
│   ├── pickups/               # XP orbs
│   ├── ui/
│   │   ├── hud.tscn           # Health/XP bars
│   │   ├── upgrade_ui.tscn    # Level-up selection
│   │   └── game_over_ui.tscn  # Death screen
│   └── effects/               # Explosions, particles
├── scripts/
│   ├── player.gd
│   ├── game.gd                # Main game controller
│   ├── spawner.gd
│   ├── systems/
│   │   ├── game_stats.gd      # Statistics tracking
│   │   ├── day_night_cycle.gd # Time of day
│   │   ├── wave_manager.gd    # Wave spawning
│   │   ├── localization_manager.gd
│   │   └── upgrade_manager.gd
│   ├── enemies/
│   ├── weapons/
│   └── ui/
├── localization/
│   └── translations.csv       # EN, JA, ZH translations
├── tests/
│   ├── test_runner.gd         # Main test runner
│   └── visual/                # Visual test scenes
├── docs/
│   ├── README.md              # Project overview
│   ├── phase4_game_feel.md    # Phase 4 detailed plan
│   ├── localization_plan.md   # i18n implementation
│   └── screenshots/           # Visual test captures
└── assets/                    # Sprites, audio
```

---

## Visual Test Screenshots

Located in `docs/screenshots/`:

| File | Description |
|------|-------------|
| `phase4_gameplay_*.png` | Gameplay screenshots |
| `localization/V4.7.3_game_over_en.png` | Game Over - English |
| `localization/V4.7.3_game_over_ja.png` | Game Over - Japanese |
| `localization/V4.7.3_game_over_zh.png` | Game Over - Chinese |

---

## How to Continue Development

### 1. Setup
```bash
git clone <repo-url>
cd minecraft-survivors
```

### 2. Run the game
```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . scenes/main.tscn
# Or open in Godot Editor and press F5
```

### 3. Run tests
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/test_runner.gd
```

### 4. Next task
Continue Phase 4 Step 7: Create new enemy assets (Enderman, Witch) and potion pickup sprites.

---

## Architecture Notes

### Signal Flow
```
Player.died → Game._on_player_died → GameOverUI.show_game_over
Player.leveled_up → Game._on_player_leveled_up → UpgradeUI.show_upgrades
Enemy.died → Spawner → XPOrb spawned → Player collects → XP added
```

### TDD Workflow
All development follows Red→Green→Refactor:
1. Write failing tests in `tests/test_runner.gd`
2. Implement minimal code to pass
3. Refactor if needed
4. Verify all tests still pass

---

## Known Issues

- Translation system requires manual CSV import configuration in Godot
- Visual tests use direct label text setting (workaround for translation timing)

---

## Contact

This project was developed with Claude Code assistance. Resume conversation or start fresh with this handoff document as context.
