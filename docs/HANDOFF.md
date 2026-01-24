# Project Handoff Document

**Last Updated:** 2026-01-24
**Project:** Minecraft Survivors
**Current Phase:** Phase 4 - Game Feel (COMPLETE ✅)

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

### Phase 4: Game Feel ✅ COMPLETE

#### All Steps Complete (1-15):
| Step | System | Status | Description |
|------|--------|--------|-------------|
| 1 | GameStats | ✅ | Tracks survival time, kills, damage, XP |
| 2 | DayNightCycle | ✅ | 8-phase cycle with visual tint |
| 3 | WaveManager | ✅ | Wave-based spawning with scaling |
| 4 | GameOverUI | ✅ | Death screen with stats |
| 5 | Localization | ✅ | EN, JA, ZH support |
| 6 | Integration | ✅ | Game.gd connects all systems |
| 7 | New Assets | ✅ | Enderman, Witch, Potion, 8 Sun/Moon phase icons |
| 8 | Enderman Enemy | ✅ | Teleports when hit (40 HP, 15 dmg) |
| 9 | Witch Enemy | ✅ | Ranged, throws potions (20 HP, 12 dmg) |
| 10 | Potion Projectile | ✅ | 200 speed, 60 splash radius |
| 11 | Update Spawner | ✅ | Enderman@120s, Witch@150s |
| 12 | Final Integration | ✅ | HUD shows Wave/Kills/Time, all signals connected |
| 13 | Day/Night Visuals | ✅ | CanvasModulate tint + 8-phase HUD icons |
| 14 | Upgrade UI Timer | ✅ | 5s auto-select, A/D navigation, middle default |
| 15 | Visual Tests | ✅ | Auto-running screenshot tests for day/night cycle |

#### Day/Night 8-Phase Icons:
| Phase | Time | Icon |
|-------|------|------|
| Dawn | 0-5s | sun_dawn.svg |
| Morning | 5-20s | sun_morning.svg |
| Midday | 20-40s | sun.svg |
| Afternoon | 40-55s | sun_afternoon.svg |
| Dusk | 55-60s | sun_dusk.svg |
| Moon Rise | 60-75s | moon_rise.svg |
| Night | 75-105s | moon.svg |
| Late Night | 105-115s | moon_late.svg |
| Moon Set | 115-120s | moon_set.svg |

---

## Test Status

**277 tests passing** (0 failures)

```
Phase 1: Core Foundation - 37 tests
Phase 2: Combat Basics - 32 tests
Phase 3: Progression Loop - 63 tests (incl. Upgrade UI timer tests)
Phase 4: Game Feel - 145 tests (incl. Enderman, Witch, Potion, Integration, Day/Night)
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

| Folder | Description |
|--------|-------------|
| `phase4_gameplay_*.png` | Gameplay screenshots |
| `localization/` | Game Over screens in EN, JA, ZH |
| `day_night_icons/` | 9 screenshots of day/night icon phases |

### Day/Night Icon Screenshots:
```
01_dawn.png, 02_morning.png, 03_midday.png, 04_afternoon.png,
05_dusk.png, 06_moon_rise.png, 07_night.png, 08_late_night.png, 09_moon_set.png
```

Run visual test: `godot --path . tests/visual/test_day_night_icons.tscn`

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
Phase 4 is COMPLETE! Starting Phase 5 - Game Enhancements.

See [phase5_enhancements.md](./phase5_enhancements.md) for detailed plan.

**Phase 5 Features (Planned):**
- [ ] **Poison System**: Witch potion causes DOT (damage over time)
  - Large explosion radius (100px)
  - 5 second poison duration
  - 2 damage every 0.5 seconds
  - Visual effects (green tint, particles)
  - HUD status indicator
- [ ] **Scoreboard**: High score tracking and leaderboard
  - Score formula: kills×10 + time + level×50 + wave×100
  - Top 10 local storage (user://scores.json)
  - Game Over shows score + rank
  - Dedicated scoreboard UI
- [ ] Boss enemies (Wither, Ender Dragon)
- [ ] New weapons (Bow, Trident)
- [ ] Settings menu (volume, controls)

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
