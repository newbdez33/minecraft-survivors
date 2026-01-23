# Minecraft Survivors

A Vampire Survivors-like roguelike game with a Minecraft theme, built with Godot 4.

## Game Overview

Minecraft Survivors is an action roguelike where you:
- Play as **Steve**, surviving endless waves of mobs
- Auto-attack with Minecraft weapons (swords, bows, magic)
- Fight against **Zombies, Skeletons, Creepers, Spiders** and more
- Collect experience orbs to level up
- Choose upgrades to become more powerful

## Theme

| Element | Minecraft Version |
|---------|-------------------|
| Player | Steve |
| Basic Enemy | Zombie |
| Ranged Enemy | Skeleton |
| Explosive Enemy | Creeper |
| Fast Enemy | Spider |
| Experience | XP Orbs |
| Weapons | Diamond Sword, Bow, Enchantments |

## Getting Started

1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this folder and select `project.godot`
4. Press F5 to run the game
5. Use **WASD** or **Arrow keys** to move Steve

## Development Approach: TDD (Test-Driven Development)

每个功能遵循 TDD 工作流:
```
1. 编写测试 (Red)    → 测试失败
2. 实现功能 (Green)  → 测试通过
3. 重构代码 (Refactor) → 保持测试通过
```

运行测试: `./run_tests.sh`

## Development Phases

### Phase 1: Core Foundation ✅
- [x] Steve (player) with 8-direction movement
- [x] Smooth follow camera
- [x] Infinite scrolling arena (grass field)
- [x] All art assets (19 SVGs)
- [x] Test framework (32 tests passing)

### Phase 2: Combat Basics ✅
See [phase2_combat_basics.md](./phase2_combat_basics.md) for details.
- [x] Health Component (reusable)
- [x] Zombie AI (chases player)
- [x] Diamond Sword (auto-attack)
- [x] Mob Spawner (spawns zombies)
- [x] HUD (hearts display)
- [x] 61 tests passing

### Phase 3: Progression Loop ✅
See [phase3_progression_loop.md](./phase3_progression_loop.md) for details.
- [x] XP Orbs (experience)
- [x] Level up system
- [x] Upgrade selection UI (enchantments)
- [x] Skeleton (ranged enemy)
- [x] Creeper (explosive enemy)
- [x] Spider (fast enemy)
- [x] 117 tests passing

### Phase 4: Game Feel ✅
See [phase4_game_feel.md](./phase4_game_feel.md) for details.
- [x] Day/Night cycle (8-phase with visual tint + HUD icons)
- [x] Wave system (scaling difficulty per wave)
- [x] Game over screen with stats
- [x] Game stats tracking (time, kills, level, wave)
- [x] HUD enhancements (wave, kills, time, day/night icon)
- [x] Localization (English, 日本語, 中文)
- [x] Enderman (teleports when hit)
- [x] Witch (throws potions)
- [x] Upgrade UI with 5s auto-select timer
- [x] 277 tests passing

## Controls

| Key | Action |
|-----|--------|
| W / Up Arrow | Move up |
| S / Down Arrow | Move down |
| A / Left Arrow | Move left |
| D / Right Arrow | Move right |

## Project Structure

```
minecraft_survivors/
├── project.godot              # Project configuration
├── scenes/
│   ├── main.tscn              # Main game scene
│   ├── player.tscn            # Steve character
│   ├── enemies/               # Enemy scenes
│   │   ├── zombie.tscn
│   │   ├── skeleton.tscn
│   │   ├── creeper.tscn
│   │   └── spider.tscn
│   ├── weapons/
│   │   └── diamond_sword.tscn
│   ├── pickups/
│   │   └── xp_orb.tscn
│   ├── projectiles/
│   │   └── arrow.tscn
│   └── ui/
│       ├── hud.tscn
│       └── upgrade_ui.tscn
├── scripts/
│   ├── player.gd              # Steve movement + XP/Level
│   ├── camera.gd              # Camera follow
│   ├── arena.gd               # Background (grass field)
│   ├── spawner.gd             # Mob spawner
│   ├── game.gd                # Game manager
│   ├── components/
│   │   └── health.gd          # Reusable health component
│   ├── enemies/
│   │   ├── zombie.gd
│   │   ├── skeleton.gd
│   │   ├── creeper.gd
│   │   └── spider.gd
│   ├── weapons/
│   │   └── diamond_sword.gd
│   ├── pickups/
│   │   └── xp_orb.gd
│   ├── projectiles/
│   │   └── arrow.gd
│   ├── systems/
│   │   ├── upgrade_manager.gd
│   │   └── upgrade.gd
│   └── ui/
│       ├── hud.gd
│       └── upgrade_ui.gd
├── assets/
│   ├── characters/            # Steve, Zombie, etc.
│   ├── tiles/                 # Grass, dirt
│   ├── weapons/               # Sword, bow, arrow
│   ├── items/                 # XP orb, hearts
│   ├── effects/               # Hit, death, explosion
│   └── ui/upgrades/           # Upgrade icons
├── tests/
│   └── unit/                  # 117 unit tests
└── docs/
    ├── README.md              # This file
    ├── phase1_core_foundation.md
    ├── phase2_combat_basics.md
    ├── phase3_progression_loop.md
    ├── phase4_game_feel.md
    ├── screenshots/           # Gameplay screenshots
    └── tutorials/             # Learning guides
```

## Documentation

### Technical Reference
- [Phase 1: Core Foundation](./phase1_core_foundation.md) - Player, camera, arena specs
- [Phase 2: Combat Basics](./phase2_combat_basics.md) - Health, zombie, sword, spawner
- [Phase 3: Progression Loop](./phase3_progression_loop.md) - XP, upgrades, new enemies
- [Phase 4: Game Feel](./phase4_game_feel.md) - Day/night, waves, game over

### Beginner Tutorials
If you're new to game development, start here:

| # | Tutorial | What You'll Learn |
|---|----------|-------------------|
| 1 | [Introduction](./tutorials/01_introduction.md) | Project overview, what we're building |
| 2 | [Godot Basics](./tutorials/02_godot_basics.md) | Nodes, scenes, scripts, vectors, input |
| 3 | [Player Character](./tutorials/03_player.md) | Steve movement, physics, CharacterBody2D |
| 4 | [Camera System](./tutorials/04_camera.md) | Smooth following, lerp interpolation |
| 5 | [Arena Background](./tutorials/05_arena.md) | Custom drawing, infinite scrolling |
| 6 | [Scene Structure](./tutorials/06_scene_structure.md) | Project organization, node trees |

**Recommended reading order:** 1 → 2 → 3 → 4 → 5 → 6

## Mobs

| Mob | Behavior | Phase | Status |
|-----|----------|-------|--------|
| Zombie | Slow, walks toward Steve | 2 | ✅ |
| Skeleton | Ranged, shoots arrows | 3 | ✅ |
| Creeper | Explodes near Steve | 3 | ✅ |
| Spider | Fast, jumps | 3 | ✅ |
| Enderman | Teleports when hit (40 HP, 15 dmg) | 4 | ✅ |
| Witch | Throws potions (20 HP, 12 dmg) | 4 | ✅ |

## Requirements

- Godot 4.2 or higher
- No external dependencies

## Disclaimer

This is a fan-made learning project. Minecraft is a trademark of Mojang Studios. This project is not affiliated with or endorsed by Mojang or Microsoft.

## License

This is a learning project. Feel free to use and modify!
