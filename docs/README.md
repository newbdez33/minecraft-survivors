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

## Development Phases

### Phase 1: Core Foundation ✅
- [x] Steve (player) with 8-direction movement
- [x] Smooth follow camera
- [x] Infinite scrolling arena (grass field)

### Phase 2: Combat Basics (Planned)
- [ ] Auto-attack weapon (Diamond Sword)
- [ ] Zombie AI (basic enemy)
- [ ] Mob spawner
- [ ] Health system (hearts)

### Phase 3: Progression Loop (Planned)
- [ ] XP Orbs (experience)
- [ ] Level up system
- [ ] Upgrade selection UI (enchantments)

### Phase 4: Game Feel (Planned)
- [ ] Day/Night timer
- [ ] Mob waves (night = more mobs)
- [ ] Game over screen

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
├── project.godot           # Project configuration
├── scenes/
│   ├── main.tscn           # Main game scene
│   └── player.tscn         # Steve character
├── scripts/
│   ├── player.gd           # Steve movement
│   ├── camera.gd           # Camera follow
│   └── arena.gd            # Background (grass field)
├── assets/                 # Art & sound (empty)
└── docs/
    ├── README.md           # This file
    ├── phase1_core_foundation.md
    └── tutorials/          # Learning guides
```

## Documentation

### Technical Reference
- [Phase 1: Core Foundation](./phase1_core_foundation.md) - Component specifications

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

## Future Mobs

| Mob | Behavior | Phase |
|-----|----------|-------|
| Zombie | Slow, walks toward Steve | 2 |
| Skeleton | Ranged, shoots arrows | 3 |
| Creeper | Explodes near Steve | 3 |
| Spider | Fast, jumps | 3 |
| Enderman | Teleports | 4 |
| Witch | Throws potions | 4 |

## Requirements

- Godot 4.2 or higher
- No external dependencies

## Disclaimer

This is a fan-made learning project. Minecraft is a trademark of Mojang Studios. This project is not affiliated with or endorsed by Mojang or Microsoft.

## License

This is a learning project. Feel free to use and modify!
