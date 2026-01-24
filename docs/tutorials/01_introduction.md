# Tutorial 1: Introduction to Minecraft Survivors

Welcome! This tutorial series will guide you through understanding every part of our Vampire Survivors-like game with a Minecraft theme. By the end, you'll understand how each piece works and why we built it that way.

## What is a Vampire Survivors-like Game?

Vampire Survivors is a popular "bullet hell" roguelike game with these core mechanics:

1. **Auto-combat**: Your character attacks automatically - you just move
2. **Swarm enemies**: Hordes of enemies constantly approach you
3. **Survival**: Stay alive as long as possible
4. **Progression**: Kill enemies → collect XP → level up → choose upgrades
5. **Escalation**: The game gets harder over time

## Our Minecraft Theme

We're combining Vampire Survivors gameplay with Minecraft's beloved characters:

| Game Element | Our Version |
|--------------|-------------|
| Player | **Steve** |
| Basic Enemy | **Zombie** (slow, melee) |
| Ranged Enemy | **Skeleton** (shoots arrows) |
| Explosive Enemy | **Creeper** (explodes) |
| Fast Enemy | **Spider** (quick, jumps) |
| Experience | **XP Orbs** (green orbs) |
| Weapons | Diamond Sword, Bow, Enchantments |
| Arena | Grass field (like Minecraft plains) |

## What We're Building

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│     Zombie ──→  🧟                                      │
│                    🧟 ──→  [STEVE]  ←── 🧟              │
│                              ↑                          │
│     Skeleton ──→  💀        │                          │
│                         Diamond Sword                   │
│                         auto-attacks                    │
│                                                         │
│   [XP Orb] [XP Orb]    [XP Orb]                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Why Godot?

Godot is a free, open-source game engine that's great for beginners because:

- **GDScript**: Python-like language, easy to learn
- **Scene system**: Build games like LEGO blocks
- **2D-focused**: Excellent 2D game support
- **Lightweight**: Small download, runs on most computers
- **No cost**: Completely free, even for commercial games

## Project Architecture Overview

Our game is organized into **scenes** and **scripts**:

```
┌─────────────────────────────────────────────────────────┐
│                     MAIN SCENE                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Arena (grass background)                        │   │
│  │  ┌─────────────────────────────────────────┐    │   │
│  │  │  Steve (you control this)               │    │   │
│  │  │  ┌─────────────────────────────────┐    │    │   │
│  │  │  │  Sprite (Steve's look)          │    │    │   │
│  │  │  │  CollisionShape (hitbox)        │    │    │   │
│  │  │  └─────────────────────────────────┘    │    │   │
│  │  └─────────────────────────────────────────┘    │   │
│  │  Camera (follows Steve)                         │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Files We Created

| File | Purpose |
|------|---------|
| `project.godot` | Project settings, input mappings |
| `scenes/main.tscn` | The main game scene |
| `scenes/player.tscn` | Steve character (reusable) |
| `scripts/player.gd` | Steve movement code |
| `scripts/camera.gd` | Camera follow code |
| `scripts/arena.gd` | Background grid code |

## How to Read These Tutorials

Each tutorial will explain:

1. **What** - What the component does
2. **Why** - Why we need it
3. **How** - Line-by-line code explanation
4. **Concepts** - Godot/game dev concepts involved

## Tutorial Order

1. **Introduction** (you are here)
2. **Godot Basics** - Essential Godot concepts
3. **Player Character** - Steve's movement and physics
4. **Camera System** - Following Steve
5. **Arena Background** - Creating the game world
6. **Scene Structure** - How it all connects

## Future Content (Coming Soon)

| Phase | What We'll Add |
|-------|----------------|
| Phase 2 | Diamond Sword, Zombies, Health (hearts) |
| Phase 3 | XP Orbs, Level up, Enchantment upgrades |
| Phase 4 | More mobs, Day/Night cycle, Boss fights |

Let's start with Godot basics in the next tutorial!

---

**Next:** [Tutorial 2: Godot Basics](./02_godot_basics.md)
