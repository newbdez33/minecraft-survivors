# Minecraft Survivors

A Vampire Survivors-like roguelike game with a Minecraft theme, built with Godot 4.5.

## Game Overview

Minecraft Survivors is an action roguelike where you:
- Play as **Steve**, surviving endless waves of mobs
- Auto-attack with Minecraft weapons (swords, bows)
- Fight **Zombies, Skeletons, Creepers, Spiders, Enderman, Witch**
- Collect XP orbs to level up
- Choose upgrades to become stronger

## Quick Start

```bash
# Run the game
godot --path . scenes/main.tscn

# Run tests
./run_tests.sh
```

## Controls

| Input | Action |
|-------|--------|
| W / ↑ | Move up |
| S / ↓ | Move down |
| A / ← | Move left |
| D / → | Move right |
| Mouse Left Click | Move to clicked position |
| Mouse Left Hold + Drag | Follow mouse position |
| ESC | Pause |

**Note:** Keyboard input takes priority over mouse input.

## Documentation Index

### Core Documentation
| Document | Description |
|----------|-------------|
| [HANDOFF.md](./HANDOFF.md) | Current development status |
| [GAME_DATA.md](./GAME_DATA.md) | Complete game data reference |
| [ROADMAP.md](./ROADMAP.md) | Development roadmap |

### Feature Design (`design/`)
| Document | Description |
|----------|-------------|
| [upgrade_system.md](./design/upgrade_system.md) | Upgrade/enchantment system |
| [boss_enemies.md](./design/boss_enemies.md) | Boss enemy designs |
| [elite_monsters.md](./design/elite_monsters.md) | Elite monster system |
| [night_mechanics.md](./design/night_mechanics.md) | Night fog and torch system |
| [localization.md](./design/localization.md) | Multi-language support |
| [art_style.md](./design/art_style.md) | Art style guide |

### Development Phases (`phases/`)
| Document | Description |
|----------|-------------|
| [phase1_core_foundation.md](./phases/phase1_core_foundation.md) | Core systems |
| [phase2_combat_basics.md](./phases/phase2_combat_basics.md) | Combat mechanics |
| [phase3_progression_loop.md](./phases/phase3_progression_loop.md) | XP and upgrades |
| [phase4_game_feel.md](./phases/phase4_game_feel.md) | Polish and systems |
| [phase5_enhancements.md](./phases/phase5_enhancements.md) | Current phase |
| [backlog.md](./phases/backlog.md) | Future features |

### Testing (`testing/`)
| Document | Description |
|----------|-------------|
| [guide.md](./testing/guide.md) | Testing guide and checklist |
| [phase5_test_plan.md](./testing/phase5_test_plan.md) | Phase 5 test cases |

### Infrastructure (`infrastructure/`)
| Document | Description |
|----------|-------------|
| [release.md](./infrastructure/release.md) | CI/CD and release process |
| [web_deploy.md](./infrastructure/web_deploy.md) | Web deployment guide |
| [assets.md](./infrastructure/assets.md) | Asset pipeline |

### Tutorials (`tutorials/`)
Beginner guides for learning game development with this project.

## Requirements

- Godot 4.5 or higher
- No external dependencies

## Disclaimer

This is a fan-made learning project. Minecraft is a trademark of Mojang Studios. This project is not affiliated with or endorsed by Mojang or Microsoft.
