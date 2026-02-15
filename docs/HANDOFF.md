# Project Handoff Document

**Last Updated:** 2026-02-11
**Project:** Minecraft Survivors
**Version:** v0.7.3-alpha
**Current Phase:** Phase 5 & 6 Complete ✅ | Phase 7 In Progress

---

## Project Overview

A Vampire Survivors-like roguelike game with Minecraft theme built in Godot 4.5. Player controls Steve and survives waves of mobs (Zombies, Skeletons, Spiders, Creepers).

## Completed Phases

### Phase 1: Core Foundation ✅
- Player movement (WASD/Arrow keys + Mouse click/drag)
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

**1663 tests total** (1663 passed, 0 failures)

```
Phase 1: Core Foundation - 37 tests
Phase 2: Combat Basics - 32 tests
Phase 3: Progression Loop - 63 tests
Phase 4: Game Feel - 145 tests
Phase 5: Game Enhancements - 112 tests
Visual Tests - 128 tests (enemy animations, upgrade effects, all enemies)
Behavioral BDD Tests - 148 tests (boss attacks 52, elite monsters 40, wave scaling 29, idle mode 27)
External Test Suites - 969+ tests (combat, pickups, enemies, animations, bosses)
```

Run tests with:
```bash
"C:\Users\newbd\Godot\Godot_v4.5.1-stable_win64.exe" --headless --script tests/test_runner.gd --path .
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
│   ├── HANDOFF.md             # This file - development status
│   ├── GAME_DATA.md           # Game data reference
│   ├── ROADMAP.md             # Development roadmap
│   ├── design/                # Feature design docs
│   ├── phases/                # Development phase docs
│   ├── testing/               # Test documentation
│   ├── infrastructure/        # CI/CD and deployment
│   ├── tutorials/             # Learning guides
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
Phase 5 IN PROGRESS - Game Enhancements.

See [phase5_enhancements.md](./phases/phase5_enhancements.md) for detailed plan.

**Phase 5 Features Completed:**
- [x] **Poison System**: Witch potion causes DOT (damage over time)
  - Square pixel-style poison cloud (80x80 Minecraft style)
  - 5 second cloud duration with fade-out
  - Poison stacking: multiple poisons stack damage (+2 per stack)
  - Player visual: pulsing green tint + floating pixel particles
  - StatusEffectManager component with stacking support
- [x] **Upgrade UI Enhancements**:
  - Left side: Enchantments (random selection)
  - Right side: Weapons (1 random owned weapon)
  - Dynamic weapon icons (sword shows wood/stone/iron/diamond based on tier)
  - "All Weapons Maxed Out!" placeholder when fully upgraded
- [x] **Weapon Slots System**: 4 fixed positions around player
  - Weapons don't rotate with player movement
  - Bow fires from visual sprite position
- [x] **Score System**: High score tracking
  - Score formula: kills×10 + time + level×50 + wave×100
  - Top 10 local storage (user://scores.json)
  - ScoreCalculator and ScoreStorage classes
- [x] **Combo System**: Kill streaks for XP bonus
  - 3 second timeout
  - Milestones at 10/25/50/100 kills
  - XP bonuses up to +50%
- [x] **Haste Upgrade**: Attack speed boost
- [x] **Bow Weapon**: Ranged auto-attack
  - PlayerArrow projectile
  - Upgrade levels 1-5
- [x] **Screen Feedback**: Damage numbers, screen shake
- [x] **Status Icons**: HUD status effect display
- [x] **Main Menu**: Start, Settings, Scoreboard buttons
- [x] **Settings Panel**: Volume, language, screen shake toggles
- [x] **Lucky Drop System**: Rare item drops from enemies
- [x] **Auto Test Mode**: Automatic gameplay testing with screenshots
- [x] **HUD Localization**: Level/Wave/Kills labels translated with real-time refresh

**Phase 5 New Features (Latest):**
- [x] **Enemy Animation System**: Procedural Tween-based animations for all 12 enemies
  - Walk animations (bob, tilt, squash effects)
  - Attack animations (windup → strike → recovery)
  - Hit reactions (flash + shake)
  - Special animations for bosses (breath, laser, sonic boom)
- [x] **Upgrade Visual Feedback**: Color-coded effects and floating stat popups
- [x] **Character Selection UI**: Steve and Alex with localized stats
- [x] **Enhancement Bonus Tracking**: Separated from weapon level bonuses
- [x] **Anti-sticking Fix**: Enemies no longer stick to player

**Phase 7 (In Progress):**
- [x] Procedural 8-bit Audio System (SFX)
- [x] Elite Monsters (6 enemy types with unique abilities, golden outline shader)
- [x] Post-Wave-30 Infinite Scaling (HP, damage, speed, XP scale infinitely)
- [x] Idle Mode / Auto-Play (AI kiting, dodge, weapon-first upgrades)
- [x] Fixed elite spider venom bug (Dictionary instead of StatusEffect)
- [x] Fixed all 86 pre-existing test failures (1663/1663 pass)
- [ ] Achievement System UI

**Audio System (COMPLETE):**
- [x] AudioManager autoload singleton with object pool (8 global + 16 positional players)
- [x] SfxGenerator with 30 procedural 8-bit sound presets (no .ogg files needed)
- [x] SfxConnector signal wiring for enemies, pickups, weapons, player
- [x] XP orb ascending C major scale (8 notes, resets after 0.5s gap)
- [x] Audio bus setup (Master, SFX, Music) with volume control
- [x] Integrated with settings panel volume slider

**Boss System (COMPLETE + IMPROVED):**
- [x] Evoker (Wave 5, 400 HP) - Summons fangs
- [x] Elder Guardian (Wave 10, 600 HP) - Mining fatigue beam
- [x] Ravager (Wave 15, 2400 HP) - Charge + stomp attacks (improved animations & damage)
- [x] Warden (Wave 20, 3000 HP) - Sonic boom + melee + ground slam + darkness aura + enrage phase
- [x] Wither (Wave 25, 3600 HP) - Homing wither skulls (2.5 rad/s tracking)
- [x] Ender Dragon (Wave 30, 4500 HP) - Homing dragon fireballs (1.8 rad/s tracking) + dive
- [x] All bosses have detailed pixel art SVG sprites with proper textures
- [x] Boss attack improvements: exaggerated multi-phase animations, increased damage, fixed melee deadlock

**Infrastructure:**
- [x] GitHub CI Release (Windows + macOS) - See [infrastructure/release.md](./infrastructure/release.md)
  - `.github/workflows/release.yml` triggers on `v*` tags
  - Builds Windows (.exe) and macOS (.app) via chickensoft-games/setup-godot
  - Creates GitHub Release with zip files automatically
- [x] GitHub Pages Deployment (Web)
  - `.github/workflows/deploy-web.yml` triggers on push to main
  - Builds Web/HTML5 version automatically
  - Deploys to GitHub Pages with COOP/COEP headers for SharedArrayBuffer

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

## Recent Updates

### v0.7.3-alpha (2026-02-11) - Latest

**Idle Mode / Auto-Play System:**
- New `IdleController` AI with **kiting behavior**: maintains attack range distance from enemies
- Kiting distances: `_danger_distance=50` (flee), `_kite_distance=70` (strafe), `_safe_distance=200` (projectiles)
- AI priority: dodge projectiles > kite enemies > collect pickups > engage enemies > wander
- **Weapons ALWAYS selected first** regardless of strategy (enchant strategies only for fallback)
- Unlocked via "Idle Master" achievement (survive past wave 30, target=31)
- Toggle with **Tab** key during gameplay
- HUD shows cyan "IDLE MODE" indicator when active, subtle "Tab: Idle Mode" hint when unlocked
- Localized in EN/ZH/JA (IDLE_MODE, IDLE_MODE_ACTIVE, IDLE_MODE_LOCKED keys)
- 27 BDD tests in `tests/unit/behavioral/test_idle_mode_behavior.gd`
- Files: `scripts/systems/idle_controller.gd` (new), modified `game.gd`, `player.gd`, `hud.gd`, `upgrade_ui.gd`

**Bug Fixes:**
- Fixed elite spider venom passing Dictionary instead of StatusEffect (caused `remaining_time` errors and FPS drops to 4-7)
- Fixed all 86 pre-existing test failures across 23 test files (outdated values, missing scenes, wrong API, infrastructure)
- Test suite now: **1663 passed, 0 failures**

**Visual Test Results (IDLE_TEST, 120s @ 2x speed):**
- 233 kills, wave 7, level 12, Stone Sword (Tier 2)
- 60 FPS stable, 0 orphan nodes, ~97 MB memory
- 11/11 upgrades were weapon upgrades (weapon-first verified)

### v0.7.2-alpha (2026-02-10)

**Warden Boss Improvements:**
- Darkness Aura: reduces player visibility by 40% when within 350px (signal-based fog shader control)
- Ground Slam AoE: 45 damage in 150px radius, 6s cooldown, reuses boss stomp animation
- Enrage Phase: at 50% HP, 1.5x speed, 40% faster attacks, permanent red tint, max anger
- Faster Anger Buildup: anger_per_sound 15→25, damage anger 20→35, sonic threshold 30→20, tracking threshold 80→50, anger decay 30→15
- game.gd connects `darkness_aura_changed` signal, restores fog on boss defeat

### v0.7.1-alpha (2026-02-09)

**Elite Monsters System:**
- EliteModifier static component: 2.5x HP, 1.5x damage, 1.2x speed, 20x XP, 1.3x scale
- Golden outline shader (`elite_outline.gdshader`) with pulsing effect
- Wave-based spawn chance (0% wave 1-3 → 25% wave 20+), night +10% bonus
- Max elite cap (0 → 5 based on wave)
- 6 unique elite abilities: Undead Rally, Multi-Shot, Venom, Charged, Void Strike, Potion Storm
- Elite monsters don't drop meat
- 40 BDD tests in `tests/unit/behavioral/test_elite_monsters.gd`

**Homing Boss Projectiles:**
- Wither skulls now track the player (2.5 rad/s turn rate, smooth curve)
- Dragon fireballs now track the player (1.8 rad/s turn rate, gentler curve)
- Both use `angle_difference` + clamped turn for dodgeable but persistent tracking

**Post-Wave-30 Infinite Scaling:**
- WaveScaler static component (`scripts/systems/wave_scaler.gd`)
- Normal enemies: +10% HP, +5% damage, +2% speed (cap +50%), +10% XP per wave past 30
- Boss enemies: +50% HP, +25% damage, +10% speed (cap +100%) per 5-wave cycle
- Elite scaling: +1% chance/wave (cap 50%), +1 max elites per 5 waves
- Safety caps: HP 2^31, damage 100K, XP 1M
- 29 BDD tests in `tests/unit/behavioral/test_wave_scaling.gd`

### v0.7.0-alpha (2026-02-08)

**Procedural Audio System:**
- AudioManager autoload with object pool (8 global + 16 positional AudioStreamPlayers)
- SfxGenerator: 30 procedural 8-bit sound presets generating AudioStreamWAV at runtime
- SfxConnector: Auto-wires signals from enemies, pickups, weapons, player to AudioManager
- XP orb collection plays ascending C major scale (8 notes, resets after 0.5s silence)
- Audio bus setup (Master/SFX/Music), integrated with settings panel volume slider
- Files: `scripts/systems/audio_manager.gd`, `sfx_generator.gd`, `sfx_connector.gd`

**Boss Attack Improvements (Ravager & Warden):**
- New exaggerated multi-phase boss animations: `play_boss_stomp()`, `play_boss_charge()`, `play_boss_melee()`
- Enhanced `play_sonic_boom()` with scale pulsing, cyan tint flash, 16-frame shake
- Ravager: charge damage 35→50, stomp damage 25→40, contact 20→30, wider charge hitbox (50px)
- Warden: sonic boom damage 45→65, melee damage 40→55, contact 30→40
- Fixed Warden melee deadlock (melee range 50→80px, beyond 50px anti-sticking distance)
- Fixed Warden sonic boom triggers (anger threshold 50→30, cooldown 6→4s, anger_per_sound 10→15)
- Added charge single-hit guard (`_charge_hit` flag) preventing multi-frame damage
- Added `CHARGE_WINDUP` sub-state so Ravager holds still during 0.4s windup
- Warden sonic boom uses `await _animator.attack_hit_frame` signal for frame-perfect damage sync

**BDD Tests:**
- 52 new behavioral tests in `tests/unit/behavioral/test_boss_attack_behavior.gd`
- 7 feature groups: Ravager charge/stomp/contact, Warden sonic/melee/contact, animator methods, boss immunities
- Given-When-Then naming convention with `_extract_function()` source analysis helper

### v0.6.2-alpha (2026-02-01)

**Enemy Animation System:**
- Added EnemyAnimator component with procedural Tween-based animations
- Walk, attack, hit reaction animations for all 12 enemies
- Special boss animations (dragon breath, warden sonic boom, etc.)

**Upgrade Visual Feedback:**
- Color-coded upgrade effects (green for damage, blue for speed, etc.)
- Floating stat popups showing upgrade values
- Ring expansion and flash effects

**Bug Fixes:**
- Fixed main menu buttons not working
- Fixed enhancement overwrite when weapon upgrades
- Fixed enemies sticking to player's head
- Fixed Windows build in CI/CD pipeline

**UI Improvements:**
- Character selection localization
- Character card styling with proper padding
- Thicker Minecraft-style title logo

### Memory Leak Fixes & Performance Monitoring
Comprehensive memory leak fixes across pickups, enemies, and projectiles:

**Pickup Scripts (double-collection prevention):**
- `scripts/pickups/xp_orb.gd` - Added `_is_collecting` flag, tween callback queue_free
- `scripts/pickups/health_pickup.gd` - Added `_is_collecting` flag
- `scripts/pickups/meat_pickup.gd` - Added `_is_collecting` flag
- `scripts/pickups/emerald_pickup.gd` - Added `_is_collecting` flag
- `scripts/pickups/totem_pickup.gd` - Added `_is_collecting` flag
- `scripts/pickups/lucky_drop_pickup.gd` - Kill looping tween before queue_free

**Enemy Scripts (signal cleanup):**
- `scripts/enemies/evoker.gd` - Track active vexes, cleanup signals on exit

**Projectile Scripts (timer pattern):**
- `scripts/projectiles/dragon_fireball.gd` - Use SceneTreeTimer instead of Timer node
- `scripts/projectiles/wither_skull.gd` - Use SceneTreeTimer instead of Timer node

**Performance Monitoring in Test Mode:**
- Logs objects, orphan nodes, FPS, memory every 10 seconds
- Warns if orphan node growth exceeds 100 (potential leak)
- Prints performance summary at test end

**Verified Stability:**
- Game ran 3+ minutes at 2x speed (80+ waves) with 0 orphan nodes
- Memory stable at ~92-94MB
- FPS stable at 44-60

### HUD Localization
- HUD labels (Level, Wave, Kills) now fully localized
- Real-time language switching: Changing language in pause menu immediately updates all UI
- HUD connects to `LocalizationManager.language_changed` signal for automatic refresh
- Translation keys: `HUD_LEVEL`, `HUD_WAVE`, `HUD_KILLS`, `ALL_MAXED`

---

## Contact

This project was developed with Claude Code assistance. Resume conversation or start fresh with this handoff document as context.
