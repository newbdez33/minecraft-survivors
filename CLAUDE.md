# CLAUDE.md - AI Assistant Guide for Minecraft Survivors

This document provides essential context for AI assistants working on the Minecraft Survivors codebase.

## Project Overview

**Minecraft Survivors** is a Vampire Survivors-like roguelike game built with **Godot 4.5** featuring Minecraft-themed characters and enemies. Players control Steve, survive waves of mobs using auto-attack combat, collect XP, and select upgrades to become stronger.

- **Engine:** Godot 4.5
- **Language:** GDScript
- **Main Scene:** `res://scenes/main.tscn`
- **Resolution:** 1280x720

## Directory Structure

```
minecraft-survivors/
├── assets/              # SVG pixel art assets
│   ├── characters/      # Player and enemy sprites
│   ├── effects/         # Visual effect sprites
│   ├── items/           # Collectibles (xp_orb, heart)
│   ├── tiles/           # Ground tiles (grass, dirt)
│   ├── ui/              # UI icons (upgrades, day/night)
│   └── weapons/         # Weapon sprites
├── docs/                # Comprehensive documentation
│   ├── tutorials/       # Beginner learning guides
│   └── screenshots/     # Test verification images
├── localization/        # Translation files (CSV)
├── scenes/              # Godot scene files (.tscn)
│   ├── enemies/         # Enemy scenes
│   ├── effects/         # Effect scenes
│   ├── pickups/         # Collectible scenes
│   ├── projectiles/     # Arrow, potion scenes
│   ├── ui/              # UI scenes (HUD, upgrade, game over)
│   └── weapons/         # Weapon scenes
├── scripts/             # GDScript source files
│   ├── components/      # Reusable components (health, status effects, weapon slots)
│   ├── effects/         # Effect scripts
│   ├── enemies/         # Enemy AI scripts
│   ├── pickups/         # Pickup scripts
│   ├── projectiles/     # Projectile scripts
│   ├── systems/         # Global systems (upgrades, day/night, waves, localization)
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
| `scripts/components/health.gd` | Reusable health component |
| `scripts/components/status_effect_manager.gd` | Poison/buff stacking system |
| `scripts/components/weapon_slots.gd` | 4-slot weapon system |
| `tests/test_runner.gd` | Central test orchestrator (389 tests) |

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
git tag v1.0.0
git push origin v1.0.0
```
GitHub Actions automatically builds Windows/macOS executables.

## Code Conventions

### Naming
- **Classes:** PascalCase (`class_name Zombie`, `class_name UpgradeManager`)
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

**Total: 389 tests**

### Test Types
- **Unit tests** (`tests/unit/`) - Logic verification
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
GAME_TITLE,Minecraft Survivors,マインクラフト サバイバーズ,我的世界 幸存者
YOU_DIED,You Died!,死亡した！,你死了！
```

### Using Translations
```gdscript
# In scripts
var text = tr("GAME_TITLE")

# Change language
LocalizationManager.set_language("ja")
```

## CI/CD

### GitHub Actions Workflow
Located at `.github/workflows/release.yml`:

1. **Trigger:** Git tags matching `v*` (e.g., `v1.0.0`)
2. **verify-main-branch:** Ensures tag is on main branch
3. **build-windows:** Builds Windows executable
4. **build-macos:** Builds macOS app bundle
5. **create-release:** Creates GitHub Release with artifacts

### Prerelease Detection
Tags containing "alpha", "beta", or "rc" are marked as prereleases.

## Important Systems

### Upgrade System
9 upgrades managed by `UpgradeManager`:
- Sharpness (damage)
- Protection (defense)
- Swiftness (speed)
- Knockback
- Looting (XP bonus)
- Sweeping (range)
- Haste (attack speed)
- And more...

### Wave System
`WaveManager` handles exponential difficulty scaling:
```gdscript
base_count = base_enemies_per_wave * pow(wave_scaling, wave - 1)
# Wave 1: 5 enemies → Wave 10: ~28 enemies
```

### Day/Night Cycle
8 visual phases with CanvasModulate tint overlay:
- Dawn → Morning → Midday → Afternoon → Dusk → Night → Midnight → Late Night

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
2. Create script in `scripts/weapons/`
3. Create scene in `scenes/weapons/`
4. Integrate with `weapon_slots.gd` component

## Documentation

Detailed documentation is in `docs/`:
- `README.md` - Project overview
- `HANDOFF.md` - Current development status
- `TESTING.md` - Manual testing guide
- `phase1-5_*.md` - Development phase guides
- `upgrade_system.md` - Upgrade mechanics
- `tutorials/` - Beginner learning guides

## Development Status

**Phase 4 (Game Feel):** Complete
**Phase 5 (Enhancements):** In Progress
- Poison stacking
- Weapon slots system
- Score/combo systems
- Main menu and settings
- [ ] Achievement system (pending)
- [ ] Boss enemies (pending)

## Git Workflow

- Main development on `main` branch
- Feature branches: `claude/*` or `feature/*`
- Releases triggered by version tags (`v*`)
- All pushes verified by CI before release

## Performance Notes

- Use `godot --headless` for CI/testing (no rendering)
- Texture compression (ETC2/ASTC) enabled for mobile
- Knockback uses lerp decay for smooth physics
- Single CanvasModulate for day/night tint (efficient)
