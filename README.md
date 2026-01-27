# Minecraft Survivors

[![Deploy to GitHub Pages](https://github.com/newbdez33/minecraft-survivors/actions/workflows/deploy-web.yml/badge.svg)](https://github.com/newbdez33/minecraft-survivors/actions/workflows/deploy-web.yml)

A Vampire Survivors-like roguelike game with Minecraft theme. Play as Steve and survive waves of mobs!

## Play Now

**[Play the game online](https://newbdez33.github.io/minecraft-survivors/)**

## Controls

- **WASD / Arrow Keys** - Move
- **Mouse Click** - Click to move to location
- **ESC** - Pause

## Features

- Auto-attack combat system
- XP and level-up progression
- Upgrade system with enchantments (Sharpness, Protection, Swiftness, etc.)
- Weapon evolution (Wood Sword → Stone → Iron → Diamond, Bow → Crossbow)
- Torch weapon with night fog visibility system
- Day/night cycle with spawn modifiers
- Multiple enemy types (Zombie, Skeleton, Spider, Creeper, Enderman, Witch)
- Multi-language support (English, Japanese, Chinese)

## Documentation

📋 **[Development Roadmap](docs/ROADMAP.md)** - Complete development plan and progress

| Document | Description |
|----------|-------------|
| [ROADMAP.md](docs/ROADMAP.md) | Development phases and future plans |
| [GAME_DATA.md](docs/GAME_DATA.md) | Complete game data reference |
| [BOSS_LIST.md](docs/BOSS_LIST.md) | Boss enemies (planned) |
| [ELITE_MONSTER_DESIGN.md](docs/ELITE_MONSTER_DESIGN.md) | Elite monster system (planned) |
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
```

### Current Status

- **Phase 5**: Game Enhancements (90% complete)
- **Phase 6**: Bosses & Elites (Design complete, implementation pending)

See [ROADMAP.md](docs/ROADMAP.md) for detailed progress.

## License

MIT
