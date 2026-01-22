# Tutorial 1: Introduction to Zombie Survivors

Welcome! This tutorial series will guide you through understanding every part of our Vampire Survivors-like game. By the end, you'll understand how each piece works and why we built it that way.

## What is a Vampire Survivors-like Game?

Vampire Survivors is a popular "bullet hell" roguelike game with these core mechanics:

1. **Auto-combat**: Your character attacks automatically - you just move
2. **Swarm enemies**: Hordes of enemies constantly approach you
3. **Survival**: Stay alive as long as possible
4. **Progression**: Kill enemies → collect XP → level up → choose upgrades
5. **Escalation**: The game gets harder over time

## What We're Building

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│     Enemy ──→  ☠                                        │
│                    ☠ ──→  [PLAYER]  ←── ☠              │
│                              ↑                          │
│     Enemy ──→  ☠            │                          │
│                         Auto-attack                     │
│                         projectiles                     │
│                                                         │
│   [XP Gem] [XP Gem]    [XP Gem]                        │
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
│  │  Arena (background)                              │   │
│  │  ┌─────────────────────────────────────────┐    │   │
│  │  │  Player (you control this)              │    │   │
│  │  │  ┌─────────────────────────────────┐    │    │   │
│  │  │  │  Sprite (visual)                │    │    │   │
│  │  │  │  CollisionShape (physics)       │    │    │   │
│  │  │  └─────────────────────────────────┘    │    │   │
│  │  └─────────────────────────────────────────┘    │   │
│  │  Camera (follows player)                        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Files We Created

| File | Purpose |
|------|---------|
| `project.godot` | Project settings, input mappings |
| `scenes/main.tscn` | The main game scene |
| `scenes/player.tscn` | Player character (reusable) |
| `scripts/player.gd` | Player movement code |
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
3. **Player Character** - Movement and physics
4. **Camera System** - Following the player
5. **Arena Background** - Creating the game world
6. **Scene Structure** - How it all connects

Let's start with Godot basics in the next tutorial!

---

**Next:** [Tutorial 2: Godot Basics](./02_godot_basics.md)
