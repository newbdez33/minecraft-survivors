# Zombie Survivors

A Vampire Survivors-like roguelike game built with Godot 4.

## Game Overview

Zombie Survivors is an action roguelike where you:
- Control a character that auto-attacks
- Survive waves of enemies
- Collect experience to level up
- Choose upgrades to become more powerful

## Getting Started

1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this folder and select `project.godot`
4. Press F5 to run the game
5. Use **WASD** or **Arrow keys** to move

## Development Phases

### Phase 1: Core Foundation ✅
- [x] Player character with 8-direction movement
- [x] Smooth follow camera
- [x] Infinite scrolling arena

### Phase 2: Combat Basics (Planned)
- [ ] Auto-attack weapon
- [ ] Basic enemy AI
- [ ] Enemy spawner
- [ ] Health system

### Phase 3: Progression Loop (Planned)
- [ ] Experience gems
- [ ] Level up system
- [ ] Upgrade selection UI

### Phase 4: Game Feel (Planned)
- [ ] Game timer
- [ ] Enemy waves
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
zombies_survivors/
├── project.godot           # Project configuration
├── scenes/
│   ├── main.tscn           # Main game scene
│   └── player.tscn         # Player character
├── scripts/
│   ├── player.gd           # Player movement
│   ├── camera.gd           # Camera follow
│   └── arena.gd            # Background grid
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
| 3 | [Player Character](./tutorials/03_player.md) | Movement, physics, CharacterBody2D |
| 4 | [Camera System](./tutorials/04_camera.md) | Smooth following, lerp interpolation |
| 5 | [Arena Background](./tutorials/05_arena.md) | Custom drawing, infinite scrolling |
| 6 | [Scene Structure](./tutorials/06_scene_structure.md) | Project organization, node trees |

**Recommended reading order:** 1 → 2 → 3 → 4 → 5 → 6

## Requirements

- Godot 4.2 or higher
- No external dependencies

## License

This is a learning project. Feel free to use and modify!
