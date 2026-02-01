# Minecraft Survivors

[![Deploy to GitHub Pages](https://github.com/newbdez33/minecraft-survivors/actions/workflows/deploy-web.yml/badge.svg)](https://github.com/newbdez33/minecraft-survivors/actions/workflows/deploy-web.yml)
[![Build and Release](https://github.com/newbdez33/minecraft-survivors/actions/workflows/release.yml/badge.svg)](https://github.com/newbdez33/minecraft-survivors/actions/workflows/release.yml)
[![Version](https://img.shields.io/badge/version-v0.6.2--alpha-blue)](https://github.com/newbdez33/minecraft-survivors/releases/latest)

A Vampire Survivors-like roguelike game with Minecraft theme. Play as Steve and survive waves of mobs!

## Play Now

**[Play the game online](https://newbdez33.github.io/minecraft-survivors/)**

## Download

- [Windows](https://github.com/newbdez33/minecraft-survivors/releases/latest/download/MinecraftSurvivors-Windows-v0.6.2-alpha.zip)
- [macOS](https://github.com/newbdez33/minecraft-survivors/releases/latest/download/MinecraftSurvivors-macOS-v0.6.2-alpha.zip)

## Controls

- **WASD / Arrow Keys** - Move
- **Mouse Click** - Click to move to location
- **ESC** - Pause

## Features

- Auto-attack combat system with procedural enemy animations
- XP and level-up progression with visual feedback
- Upgrade system with enchantments (Sharpness, Protection, Swiftness, etc.)
- Weapon evolution (Wood Sword → Stone → Iron → Diamond, Bow → Crossbow)
- Torch weapon with night fog visibility system
- Day/night cycle with spawn modifiers
- 6 regular enemies (Zombie, Skeleton, Spider, Creeper, Enderman, Witch)
- 6 boss enemies at waves 5, 10, 15, 20, 25, 30 (Evoker, Elder Guardian, Ravager, Warden, Wither, Ender Dragon)
- Health pickups (Meat drops, Golden Apple spawns)
- Character selection (Steve, Alex)
- Multi-language support (English, Japanese, Chinese)

## Documentation

📋 **[Development Roadmap](docs/ROADMAP.md)** - Complete development plan and progress

| Document | Description |
|----------|-------------|
| [ROADMAP.md](docs/ROADMAP.md) | Development phases and future plans |
| [GAME_DATA.md](docs/GAME_DATA.md) | Complete game data reference (EN/ZH) |
| [CHANGELOG.md](docs/CHANGELOG.md) | Version history and changes |
| [BOSS_LIST.md](docs/BOSS_LIST.md) | Boss enemies with unique mechanics |
| [CLAUDE.md](CLAUDE.md) | AI assistant development guide |

## Development

Built with **Godot 4.5** using GDScript.

### Run Locally

```bash
godot --path . scenes/main.tscn
```

### Run Tests

```bash
./run_tests.sh
# 389+ unit tests, 128 visual tests
```

### Current Status

- **Phase 5**: Game Enhancements ✅ Complete
  - Enemy animation system
  - Upgrade visual feedback
  - Boss system (6 bosses)
  - Bow/Crossbow weapon
  - Health pickups
- **Phase 6**: Achievement System (Planned)

See [ROADMAP.md](docs/ROADMAP.md) for detailed progress.

## License

MIT
