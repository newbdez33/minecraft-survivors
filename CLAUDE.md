# CLAUDE.md - AI Assistant Guide for Three Kingdoms Survivors

This document provides essential context for AI assistants working on the Three Kingdoms Survivors codebase.

## Project Overview

**Three Kingdoms Survivors** (三国幸存者) is a Vampire Survivors-like roguelike game built with **Godot 4.5** featuring Romance of the Three Kingdoms (三国演义) themed characters and enemies. Players control legendary generals (Guan Yu, Zhao Yun, Zhang Fei), survive waves of Cao Cao's forces using auto-attack combat, collect War Merits (战功), and select upgrades to become stronger.

- **Engine:** Godot 4.5
- **Language:** GDScript
- **Main Scene:** `res://scenes/main.tscn`
- **Resolution:** 1280x720

## Directory Structure

```
three-kingdoms-survivors/
├── assets/              # SVG pixel art assets
│   ├── characters/      # Player generals and enemy sprites
│   ├── effects/         # Visual effect sprites
│   ├── items/           # Collectibles (war_merit, heart, steamed_bun, immortal_peach)
│   ├── tiles/           # Ground tiles (grass, desert, snow, swamp)
│   ├── ui/              # UI icons (upgrades, day/night)
│   └── weapons/         # Weapon sprites (iron/steel/fine_steel blades, divine_weapon, bow, crossbow)
├── docs/                # Comprehensive documentation
│   ├── tutorials/       # Beginner learning guides
│   └── screenshots/     # Test verification images
├── localization/        # Translation files (CSV)
├── scenes/              # Godot scene files (.tscn)
│   ├── enemies/         # Enemy scenes
│   ├── effects/         # Effect scenes
│   ├── pickups/         # Collectible scenes
│   ├── projectiles/     # Arrow, poison dart scenes
│   ├── ui/              # UI scenes (HUD, upgrade, game over)
│   └── weapons/         # Weapon scenes
├── scripts/             # GDScript source files
│   ├── components/      # Reusable components (health, status effects, weapon slots)
│   ├── effects/         # Effect scripts
│   ├── enemies/         # Enemy AI scripts
│   ├── pickups/         # Pickup scripts
│   ├── projectiles/     # Projectile scripts
│   ├── systems/         # Global systems (upgrades, day/night, waves, localization)
│   ├── testing/         # Test mode automation (auto_player, test_mode, screenshots)
│   ├── ui/              # UI scripts
│   └── weapons/         # Weapon scripts
├── tests/               # Test suite
│   ├── unit/            # Unit tests
│   └── visual/          # Visual verification tests
├── .github/workflows/   # CI/CD pipelines
└── .claude/             # Claude Code settings
```

## Key Files

| File | Purpose |
|------|---------|
| `project.godot` | Godot project configuration, physics layers, input map |
| `export_presets.cfg` | Build presets for Windows/macOS/Linux |
| `run_tests.sh` | Test runner script |
| `scripts/game.gd` | Main game controller, signal hub |
| `scripts/player.gd` | Player movement, health, XP/level system |
| `scripts/spawner.gd` | Enemy spawning with wave scaling |
| `scripts/systems/upgrade_manager.gd` | Upgrade system (9 upgrades) |
| `scripts/systems/wave_manager.gd` | Wave-based difficulty scaling |
| `scripts/systems/day_night_cycle.gd` | 8-phase day/night visual system |
| `scripts/systems/health_pickup_spawner.gd` | Periodic health pickup spawning |
| `scripts/systems/audio_manager.gd` | Audio autoload: object pool, bus setup, SFX + music playback |
| `scripts/systems/sfx_generator.gd` | Procedural 8-bit sound generation (30 presets) |
| `scripts/systems/sfx_connector.gd` | Signal wiring for audio events |
| `scripts/systems/wave_scaler.gd` | Post-wave-30 infinite stat scaling |
| `scripts/systems/idle_controller.gd` | AI auto-play controller (kite, dodge, collect, weapon-first upgrades) |
| `scripts/systems/biome_manager.gd` | Biome zone math, tile selection, transition blending |
| `scripts/systems/music_generator.gd` | Procedural 12s ambient music loops per biome |
| `scripts/systems/music_player.gd` | Dual-player crossfade controller for biome music |
| `scripts/components/elite_modifier.gd` | Elite monster stat boosting and abilities |
| `scripts/components/health.gd` | Reusable health component |
| `scripts/components/status_effect_manager.gd` | Poison/buff stacking system |
| `scripts/components/weapon_slots.gd` | 4-slot weapon system |
| `scripts/weapons/sword_base.gd` | Sword evolution system (4 tiers) |
| `scripts/pickups/health_pickup.gd` | Immortal Peach (仙桃) healing pickup |
| `scripts/pickups/meat_pickup.gd` | Steamed Bun (馒头) drop from enemies |
| `scripts/systems/achievement_manager.gd` | Achievement tracking, persistence, 21 achievements |
| `scripts/systems/achievement.gd` | Achievement data class with icon_path |
| `scripts/ui/achievement_panel.gd` | Achievement grid panel (main menu + pause menu) |
| `scripts/ui/achievement_item.gd` | Individual achievement card with badge icon |
| `scripts/ui/achievement_notification.gd` | Toast popup on achievement unlock |
| `tests/test_runner.gd` | Central test orchestrator (1718 tests) |
| `scripts/testing/test_mode.gd` | Auto-play test mode with performance monitoring |
| `docs/GAME_DATA.md` | Comprehensive game data reference (bilingual) |

## Entity Reference

### Player Characters (Shu Han Generals)

| Character | Chinese | Script | Role |
|-----------|---------|--------|------|
| Guan Yu | 关羽 | `player.gd` | Balanced fighter, Green Dragon Blade |
| Zhao Yun | 赵云 | `player.gd` | Agile warrior, +20% speed, +50% pickup |
| Zhang Fei | 张飞 | `player.gd` | Tank/power: +20% HP, +10% dmg, -15% speed |

### Regular Enemies (Cao Cao's Troops - 兵种)

| Enemy | Chinese | Script | Behavior |
|-------|---------|--------|----------|
| Infantry | 步兵 | `infantry.gd` | Basic melee chaser |
| Archer | 弓兵 | `archer.gd` | Ranged arrows |
| Cavalry | 骑兵 | `cavalry.gd` | Fast, charge/leap attack |
| Fire Soldier | 火兵 | `fire_soldier.gd` | Explodes (fire attack) |
| Assassin | 刺客 | `assassin.gd` | Teleports when hit |
| Sorcerer | 术士 | `sorcerer.gd` | Throws poison darts |

### Boss Enemies (Cao Cao's Generals)

| Boss | Chinese | Wave | Script |
|------|---------|------|--------|
| Xiahou Dun | 夏侯惇 | 5 | `xiahou_dun.gd` |
| Xu Chu | 许褚 | 10 | `xu_chu.gd` |
| Zhang Liao | 张辽 | 15 | `zhang_liao.gd` |
| Dian Wei | 典韦 | 20 | `dian_wei.gd` |
| Sima Yi | 司马懿 | 25 | `sima_yi.gd` |
| Lv Bu | 吕布 | 30 | `lv_bu.gd` |

### Weapons

| Weapon | Chinese | Tier |
|--------|---------|------|
| Iron Blade | 铁刃 | T1 |
| Steel Blade | 钢刃 | T2 |
| Fine Steel Blade | 精钢刃 | T3 |
| Divine Weapon | 神兵 | T4 |
| Bow | 弓 | - |
| Repeating Crossbow | 连弩 | Bow evolution |
| War Lantern | 战灯 | - |

### Pickups & Items

| Item | Chinese | Description |
|------|---------|-------------|
| War Merit | 战功 | XP orb equivalent |
| Immortal Peach | 仙桃 | Heals 50% max HP |
| Steamed Bun | 馒头 | Heals 10 HP, drops from Archers |
| Copper Coin | 铜钱 | Currency pickup |
| Tiger Tally | 虎符 | Special item |

### Projectiles

| Projectile | Chinese | Used By |
|------------|---------|---------|
| Dark Flame | 暗火 | Sima Yi (homing) |
| Sky Halberd | 天戟 | Lv Bu (homing + dive) |
| Poison Dart | 毒针 | Sorcerer |
| Ground Spike | 地刺 | Xiahou Dun |

### Biomes

| Biome | Chinese | Direction |
|-------|---------|-----------|
| Central Plains | 中原 | Inner (<800px) |
| Western Regions | 西域 | East |
| Northern Frontier | 北疆 | North |
| Southern Marshes | 南蛮 | South-west |

## Development Commands

### Running the Game
```bash
# Run from command line
godot --path . scenes/main.tscn

# Or open project.godot in Godot editor and press F5
```

### Running Tests
```bash
# Run all tests (headless)
./run_tests.sh

# Or directly
godot --headless --script tests/test_runner.gd
```

Exit code 0 = all tests pass, 1 = failures.

### Creating a Release
Releases are triggered by pushing version tags:
```bash
git tag v2.0.0
git push origin v2.0.0
```
GitHub Actions automatically builds Windows/macOS executables.

## Code Conventions

### Naming
- **Classes:** PascalCase (`class_name Infantry`, `class_name UpgradeManager`)
- **Variables/Functions:** snake_case (`var move_speed`, `func take_damage()`)
- **Constants:** UPPER_SNAKE_CASE (`const MAX_HEALTH`, `const UPGRADE_DEFS`)
- **Signals:** snake_case (`signal health_changed`, `signal leveled_up`)
- **Private methods:** Prefix with underscore (`func _on_health_changed()`)

### Export Variables
```gdscript
@export var speed: float = 200.0
@export var max_health: int = 100
@export_group("Combat")
@export var damage: int = 10
```

### Signal Declarations
```gdscript
signal health_changed(current: int, maximum: int)
signal died()
signal xp_changed(current: int, required: int)
```

## Architecture Patterns

### Signal-Driven Architecture
The game uses signals for loose coupling:
- **Player** emits: `health_changed`, `died`, `xp_changed`, `leveled_up`, `facing_changed`
- **Game.gd** acts as central hub connecting signals
- **UI** responds to signals rather than polling

### Component-Based Design
Reusable components in `scripts/components/`:
- `health.gd` - Health management for any entity
- `status_effect_manager.gd` - Handles poison, buffs with stacking
- `weapon_slots.gd` - 4-position weapon system around player

### Physics Layers
Defined in `project.godot`:
- Layer 1: `player`
- Layer 2: `enemies`
- Layer 3: `pickups`
- Layer 4: `projectiles`

## Testing

### Test Structure
Tests are organized by development phase:
- **Phase 1:** Core Foundation (37 tests)
- **Phase 2:** Combat Basics (32 tests)
- **Phase 3:** Progression Loop (63 tests)
- **Phase 4:** Game Feel (145 tests)
- **Phase 5:** Game Enhancements (112 tests)
- **BDD Tests:** Boss Attacks (52), Elite Monsters (40), Wave Scaling (29), Idle Mode (27), Achievement UI (27)
- **System Tests:** Biome Manager (16), Music Generator (12)
- **External Suites:** Combat, pickups, enemies, animations, bosses (969+ tests)

**Total: 1718 tests** (1718 passed, 0 failures)

### Test Types
- **Unit tests** (`tests/unit/`) - Logic verification
- **Behavioral tests** (`tests/unit/behavioral/`) - BDD Given-When-Then tests
- **Visual tests** (`tests/visual/`) - Screenshot-based verification

### Writing Tests
Tests follow this pattern in `test_runner.gd`:
```gdscript
func test_player_takes_damage() -> void:
    var player = create_test_player()
    player.take_damage(10)
    assert_eq(player.health, 90, "Player should have 90 health after 10 damage")
```

## Localization

### Supported Languages
- `en` - English
- `ja` - Japanese (日本語)
- `zh` - Simplified Chinese (简体中文)

### Translation File
Located at `localization/translations.csv`:
```csv
keys,en,ja,zh
GAME_TITLE,Three Kingdoms Survivors,三国サバイバーズ,三国幸存者
YOU_DIED,You Died!,死亡した！,你死了！
```

### Using Translations
```gdscript
# In scripts
var text = tr("GAME_TITLE")

# Change language
LocalizationManager.set_language("ja")
```

### Real-time Language Switching
All UI components connect to `LocalizationManager.language_changed` signal to refresh when language changes:
- HUD (Level, Wave, Kills labels)
- Pause Menu
- Settings Panel
- Game Over UI

Key translation keys:
- `HUD_LEVEL`, `HUD_WAVE`, `HUD_KILLS` - Gameplay HUD
- `YOU_DIED`, `SURVIVAL_TIME`, `RESPAWN` - Game Over screen
- `PAUSED`, `RESUME`, `SETTINGS` - Pause Menu
- `ALL_MAXED` - Upgrade UI when weapons maxed

## CI/CD

### Release Workflow
Located at `.github/workflows/release.yml`:

1. **Trigger:** Git tags matching `v*` (e.g., `v2.0.0`)
2. **verify-main-branch:** Ensures tag is on main branch
3. **build-windows:** Builds Windows executable
4. **build-macos:** Builds macOS app bundle
5. **create-release:** Creates GitHub Release with artifacts

### Prerelease Detection
Tags containing "alpha", "beta", or "rc" are marked as prereleases.

### GitHub Pages Deployment
Located at `.github/workflows/deploy-web.yml`:

1. **Trigger:** Push to `main` branch (when develop is merged)
2. **build-web:** Builds Web/HTML5 version using Godot
3. **deploy:** Deploys to GitHub Pages with COOP/COEP headers

Play the game at: `https://<username>.github.io/<repo-name>/`

## Important Systems

### Weapon Evolution System
Swords use a 4-tier evolution system (`scripts/weapons/sword_base.gd`):

| Tier | Name | Chinese | Damage | Range | Cooldown | Kills to Evolve |
|------|------|---------|--------|-------|----------|-----------------|
| 1 | Iron Blade | 铁刃 | 5 | 60 | 1.2s | 50 |
| 2 | Steel Blade | 钢刃 | 8 | 70 | 1.0s | 150 |
| 3 | Fine Steel Blade | 精钢刃 | 12 | 80 | 0.9s | 400 |
| 4 | Divine Weapon | 神兵 | 15 | 90 | 0.8s | Max tier |

**Per-level upgrades:** +2 damage, +5 range, -5% cooldown
**Evolution bonuses:** Extra stats when evolving to next tier

### Upgrade System
9 upgrades managed by `UpgradeManager`:
- Sharpness / 锋利 (+5 damage per level)
- Protection / 铁甲 (-10% damage taken)
- Swiftness / 轻功 (+15% movement speed)
- Power Strike / 力拔 (+30 knockback force)
- Spoils / 缴获 (+20% XP gain)
- Sweep / 横扫 (+20 attack range)
- Swift Wind / 疾风 (-10% attack cooldown)

### Health Pickup System
Two types of health pickups:
- **Steamed Bun (馒头)** - Drops from Archers (12% chance), heals 10 HP. Elite enemies never drop.
- **Immortal Peach (仙桃)** - Spawns every 20s, heals 50% max HP

`HealthPickupSpawner` adjusts spawn rate based on player health:
- Health < 30%: Spawns at minimum interval (15s)
- Health < 50%: Spawns at half interval

### Wave System
`WaveManager` handles exponential difficulty scaling:
```gdscript
base_count = base_enemies_per_wave * pow(wave_scaling, wave - 1)
# Wave 1: 5 enemies → Wave 10: ~28 enemies
```

### Day/Night Cycle
8 visual phases with CanvasModulate tint overlay:
- Dawn → Morning → Midday → Afternoon → Dusk → Night → Midnight → Late Night

### Enemy Data
6 enemy types with unique behaviors:

| Enemy | Chinese | HP | Damage | Speed | XP | Drop | Special |
|-------|---------|-----|--------|-------|-----|------|---------|
| Infantry | 步兵 | 10 | 10 | 60 | 5 | 0% | Basic chaser |
| Archer | 弓兵 | 5 | 8 | 40 | 8 | 12% | Ranged arrows |
| Cavalry | 骑兵 | 6 | 8 | 100 | 6 | 0% | Charge attack |
| Fire Soldier | 火兵 | 12 | 30 | 50 | 10 | 0% | Explodes |
| Assassin | 刺客 | 20 | 15 | 70 | 15 | 0% | Teleports when hit |
| Sorcerer | 术士 | 10 | 12 | 35 | 12 | 0% | Throws poison darts |

**Anti-sticking:** All enemies have push-back when < 30px from player.

### Audio System
Procedural 8-bit sound effects with no external audio files required:
- `AudioManager` autoload singleton with object pool (8 global + 16 positional AudioStreamPlayers)
- `SfxGenerator` generates AudioStreamWAV at runtime with 30 presets (square, saw, noise waveforms)
- `SfxConnector` auto-wires signals from enemies, pickups, weapons, and player
- War Merit collection plays ascending C major scale (8 notes, resets after 0.5s gap)
- Audio buses: Master, SFX, Music (volume controlled via settings panel)
- Access pattern: `get_node_or_null("/root/AudioManager")` (never bare autoload name)

### Achievement System
21 achievements with pixel-art badge icons, localization (EN/JA/ZH), SFX, and notification popup:
- **Files:** `achievement_manager.gd` (tracking/persistence), `achievement.gd` (data class), `achievement_panel.gd` (grid UI), `achievement_item.gd` (card with badge), `achievement_notification.gd` (toast popup)
- **Badges:** 21 SVG pixel-art icons in `assets/ui/achievements/`, loaded via `ResourceLoader.exists()` + `load()`
- **Categories:** Kill (3), Survival (4), Level (3), Wave (3), Special (4), Unlock (3), Idle (1)
- **Integration:** Main menu (AchievementsButton + AchievementPanel + AchievementManagerMenu), Pause menu (button + panel, manager passed from game.gd)
- **Game.gd wiring:** ComboSystem (RefCounted), poison tracking, no-damage timer (1s throttle), notification popup + `achievement_unlock` SFX
- **Localization:** 50+ keys in `translations.csv` (ACH_*_NAME, ACH_*_DESC, ACH_PROGRESS, ACH_UNLOCKED, ACH_UNLOCKED_TITLE)
- **Note:** Two locale persistence systems: `LocalizationManager` (settings.cfg) and main_menu (settings.json). CSV must be reimported via Godot editor after edits.

### Boss Enemies
6 boss enemies spawn at specific waves with high HP. Bosses cycle after wave 30 with scaling.

| Boss | Chinese | Wave | HP | XP | Special |
|------|---------|------|-----|-----|---------|
| Xiahou Dun | 夏侯惇 | 5 | 400 | 200 | Summons ground spikes (地刺) |
| Xu Chu | 许褚 | 10 | 600 | 300 | Battle fatigue beam |
| Zhang Liao | 张辽 | 15 | 2400 | 400 | Charge (50 dmg) + Stomp (40 dmg AoE) |
| Dian Wei | 典韦 | 20 | 3000 | 600 | War cry (65 dmg) + Melee (55 dmg) + Ground Slam (45 dmg AoE) + Darkness Aura + Enrage at 50% HP |
| Sima Yi | 司马懿 | 25 | 3600 | 800 | Homing dark flames (暗火) |
| Lv Bu | 吕布 | 30 | 4500 | 1200 | Homing sky halberds (天戟) + dive |

All bosses have detailed pixel art SVG sprites located in `assets/characters/`.
Boss attacks use exaggerated multi-phase Tween animations with signal-based damage synchronization.

### Elite Monsters
Elite enemies are stat-boosted normal enemies with golden outline shader and unique abilities.
- **Stats:** 2.5x HP, 1.5x damage, 1.2x speed, 20x XP, 1.3x scale, no drops
- **Spawn:** Wave-based chance (0% at wave 1-3 → 25% at wave 20+), night +10%
- **Max cap:** 0 (wave 1-3) → 5 (wave 20+)
- **Abilities:** Infantry=War Cry (战吼), Archer=Volley (齐射), Cavalry=Poisoned Lance (毒矛), Fire Soldier=Inferno (烈焰), Assassin=Shadow Strike (暗杀), Sorcerer=Spell Storm (法术风暴)
- **Files:** `scripts/components/elite_modifier.gd`, `assets/shaders/elite_outline.gdshader`

### Wave Scaling (Post-Wave 30)
`WaveScaler` applies infinite stat scaling after wave 30.
- **Normal enemies:** +10% HP, +5% dmg, +2% speed (cap +50%), +10% XP per wave
- **Bosses:** +50% HP, +25% dmg, +10% speed (cap +100%) per 5-wave cycle
- **Elite scaling:** +1% chance/wave (cap 50%), +1 max elites per 5 waves
- **Safety caps:** HP 2^31, damage 100K, XP 1M
- **File:** `scripts/systems/wave_scaler.gd`

### Idle Mode (Auto-Play)
`IdleController` provides AI-controlled gameplay, unlocked via "Idle Master" achievement (wave 31+).
- **Toggle:** Tab key in `game.gd` `_input()` using `KEY_TAB`
- **AI priority:** Dodge projectiles > Kite enemies > Collect pickups > Engage enemies > Wander
- **Kiting system:** `_danger_distance=50` (flee), `_kite_distance=70` (strafe), `_safe_distance=200` (projectiles)
- **Weapon upgrades ALWAYS selected first** regardless of strategy; enchant strategies only for fallback
- **Upgrade strategies (enchant fallback):** WEAPON_FIRST (default), BALANCED, DEFENSIVE
- **Player integration:** `idle_mode: bool` flag in `player.gd`, skips input when true
- **Upgrade UI:** `idle_controller` reference, `_auto_select_upgrade()` on 5s timer, `PROCESS_MODE_ALWAYS` while paused
- **HUD:** `set_idle_mode()` / `set_idle_unlocked()` on `IdleModeLabel` in TopRightContainer
- **IDLE_TEST scenario:** `test_mode.gd` with god mode, fast progression, periodic screenshots every 15s
- **File:** `scripts/systems/idle_controller.gd`

### Biome Terrain System
Direction-based biome zones beyond 800px from spawn with procedural tile transitions:
- **4 Biomes:** Central Plains/中原 (inner <800px), Western Regions/西域 (east), Northern Frontier/北疆 (north), Southern Marshes/南蛮 (south-west)
- **Transition zone:** 800-1100px with probabilistic tile mixing (deterministic hash)
- **Tiles:** 12 SVG tiles (4 biomes x 3 variants: base, variant1, variant2)
- **Arena integration:** `arena.gd` uses `BiomeManager` for per-tile biome selection, emits `biome_changed` signal
- **Sector angles** (atan2 from +X, Y-down): Western Regions 330-90°, Southern Marshes 90-210°, Northern Frontier 210-330°
- **Files:** `scripts/systems/biome_manager.gd`, `assets/tiles/{desert,snow,swamp}*.svg`

### Procedural Background Music
Ambient music that crossfades between biome-specific tracks:
- **Generation:** 12-second looping AudioStreamWAV per biome (deterministic, no `randf`)
- **3 Layers:** Bass drone (triangle wave) + melody (triangle/square, pentatonic) + noise texture
- **Scales:** Central Plains=C major penta, Western Regions=D minor penta, Northern Frontier=E minor penta, Southern Marshes=A minor penta
- **Crossfade:** Dual AudioStreamPlayer, 2-second linear crossfade on biome change
- **Integration:** AudioManager caches tracks on first biome entry; `game.gd` connects `arena.biome_changed` → `audio.play_biome_music()`
- **Files:** `scripts/systems/music_generator.gd`, `scripts/systems/music_player.gd`

For complete game data, see `docs/GAME_DATA.md` (bilingual EN/ZH).

## Common Tasks

### Adding a New Enemy
1. Create sprite in `assets/characters/`
2. Create script in `scripts/enemies/` extending `CharacterBody2D`
3. Create scene in `scenes/enemies/` with sprite, collision, health component
4. Add to spawner's enemy pool

### Adding a New Upgrade
1. Add upgrade definition in `scripts/systems/upgrade_manager.gd`
2. Create icon in `assets/ui/`
3. Add localization keys to `localization/translations.csv`
4. Connect upgrade effects in relevant systems

### Adding a New Weapon
1. Create sprite in `assets/weapons/`
2. Create script in `scripts/weapons/` (extend `SwordBase` for melee weapons with evolution)
3. Create scene in `scenes/weapons/`
4. Integrate with `weapon_slots.gd` component

### Adding a New Pickup
1. Create sprite in `assets/items/`
2. Create script in `scripts/pickups/` with `collected` signal
3. Create scene in `scenes/pickups/`
4. For enemy drops: add drop logic to enemy scripts
5. For map spawns: integrate with `HealthPickupSpawner`

## Documentation

Detailed documentation is in `docs/`:
- `README.md` - Project overview
- `HANDOFF.md` - Current development status
- `TESTING.md` - Manual testing guide
- `GAME_DATA.md` - Complete game data reference (bilingual EN/ZH)
- `phase1-5_*.md` - Development phase guides
- `upgrade_system.md` - Upgrade mechanics
- `tutorials/` - Beginner learning guides

## Development Status

**Phase 4 (Game Feel):** Complete
**Phase 5 (Enhancements):** Complete
- Poison stacking with visual effects
- Weapon slots system (4 positions)
- Score/combo systems
- Main menu and settings
- Sword evolution system (Iron Blade → Steel Blade → Fine Steel Blade → Divine Weapon)
- Health pickups (Steamed Bun drops, Immortal Peach spawns)
- Enemy anti-sticking mechanism
- Bow weapon with Repeating Crossbow evolution
- Boss enemies (6 bosses with pixel art sprites)

**Phase 7 (Advanced Features):** Complete
- Procedural 8-bit audio system (30 SFX presets)
- Boss attack improvements (Zhang Liao & Dian Wei)
- Elite monsters (6 types with unique abilities, golden shader)
- Post-wave-30 infinite scaling (enemies, bosses, elites)
- Idle mode / auto-play (AI kiting controller, Tab toggle, weapon-first upgrades)
- Achievement system UI (21 achievements, badges, localization EN/JA/ZH, SFX, notification popup)
- Biome terrain system (4 biomes, 12 tile SVGs, direction-based zones, transition blending)
- Procedural background music (4 biome tracks, 12s loops, crossfade, pentatonic scales)

**Phase 8 (Three Kingdoms Re-theme):** Complete
- Full re-theme from Minecraft to Romance of the Three Kingdoms
- 3 playable generals: Guan Yu, Zhao Yun, Zhang Fei
- 6 enemy troops: Infantry, Archer, Cavalry, Fire Soldier, Assassin, Sorcerer
- 6 boss generals: Xiahou Dun, Xu Chu, Zhang Liao, Dian Wei, Sima Yi, Lv Bu
- All weapons, items, projectiles renamed with Chinese theme
- Full trilingual localization (EN/JA/ZH)
- All 1718 tests passing

## Git Workflow

- Main development on `develop` branch
- Feature branches: `claude/*` or `feature/*`
- Releases triggered by version tags (`v*`)
- All pushes verified by CI before release

## Performance Notes

- Use `godot --headless` for CI/testing (no rendering)
- Texture compression (ETC2/ASTC) enabled for mobile
- Knockback uses lerp decay for smooth physics
- Single CanvasModulate for day/night tint (efficient)

### Memory Management Patterns

The codebase follows strict memory management to prevent leaks:

**Pickup Collection Pattern:**
```gdscript
var _is_collecting: bool = false

func _on_body_entered(body: Node2D) -> void:
    if _is_collecting:
        return  # Prevent double collection
    _is_collecting = true
    # ... collection logic ...
    queue_free()
```

**Tween Cleanup Pattern:**
```gdscript
func queue_free() -> void:
    if _tween and _tween.is_running():
        _tween.kill()  # Stop tween before freeing
    super.queue_free()
```

**Timer Pattern (prefer SceneTreeTimer):**
```gdscript
# GOOD: SceneTreeTimer - auto-cleaned by scene tree
await get_tree().create_timer(1.0).timeout
queue_free()

# AVOID: Timer node - requires manual cleanup
var timer = Timer.new()  # Must track and free manually
```

**Signal Cleanup Pattern:**
```gdscript
func _exit_tree() -> void:
    for spawned_node in _active_nodes:
        if is_instance_valid(spawned_node):
            if spawned_node.died.is_connected(_on_node_died):
                spawned_node.died.disconnect(_on_node_died)
```

### Performance Monitoring (Test Mode)

Test mode includes built-in performance monitoring (`scripts/testing/test_mode.gd`):
- Logs objects, orphan nodes, FPS, memory every 10 seconds
- Warns if orphan node growth exceeds 100 (potential memory leak)
- Prints performance summary at test end

Run with: `godot res://scenes/main.tscn -- --test-mode --duration=180 --speed=2`

**Verified Stability:** Game runs 3+ minutes at 2x speed (80+ waves) with 0 orphan nodes, stable memory (~92-94MB), stable FPS (44-60).

## Workflow Rules

### Post-Testing Build
After all tests pass, always rebuild the game to ensure the Build directory has the latest version:

```bash
# Windows build
godot --headless --export-release "Windows Desktop" Build/game.exe

# Or run the export script if available
./export.sh
```

This ensures manual testing always uses the latest code.
