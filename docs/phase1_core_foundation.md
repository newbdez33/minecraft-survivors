# Phase 1: Core Foundation

This document describes the initial setup for the Zombie Survivors game - a Vampire Survivors-like roguelike built with Godot 4.

## Project Structure

```
zombies_survivors/
├── project.godot          # Godot project configuration
├── scenes/
│   ├── main.tscn          # Main game scene
│   └── player.tscn        # Player character scene
├── scripts/
│   ├── player.gd          # Player movement controller
│   ├── camera.gd          # Smooth follow camera
│   └── arena.gd           # Background grid renderer
├── assets/                # (Empty) For future sprites/sounds
└── docs/
    └── phase1_core_foundation.md
```

---

## Components

### 1. Player (`scripts/player.gd`)

**Node Type:** `CharacterBody2D`

The player character handles 8-directional movement using input actions.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `speed` | float | 200.0 | Movement speed in pixels/second |

**Key Features:**
- Uses `CharacterBody2D` for physics-based movement
- Normalizes diagonal movement to prevent faster diagonal speed
- Reads from input actions: `move_up`, `move_down`, `move_left`, `move_right`

**Code Overview:**
```gdscript
func _physics_process(_delta: float) -> void:
    var input_direction = get_input_direction()
    if input_direction != Vector2.ZERO:
        velocity = input_direction.normalized() * speed
    else:
        velocity = Vector2.ZERO
    move_and_slide()
```

---

### 2. Camera (`scripts/camera.gd`)

**Node Type:** `Camera2D`

A smooth-follow camera that tracks the player.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `target` | Node2D | null | The node to follow |
| `smoothing_speed` | float | 5.0 | Interpolation speed (higher = snappier) |

**Key Features:**
- Uses linear interpolation (`lerp`) for smooth movement
- Configurable smoothing speed via export variable
- Target is set in the scene (defaults to Player)

---

### 3. Arena (`scripts/arena.gd`)

**Node Type:** `Node2D`

Renders an infinite-scrolling grid background.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `tile_size` | int | 64 | Grid cell size in pixels |
| `grid_color` | Color | Dark gray | Background fill color |
| `line_color` | Color | Lighter gray | Grid line color |

**Key Features:**
- Dynamically draws grid based on camera position
- Creates illusion of infinite arena
- Uses `_draw()` for efficient custom rendering
- Redraws every frame to follow camera

---

## Scenes

### Main Scene (`scenes/main.tscn`)

The root game scene that assembles all components.

**Node Hierarchy:**
```
Main (Node2D)
├── Arena (Node2D) - z_index: -10
├── Player (CharacterBody2D)
└── Camera2D
```

**Configuration:**
- Arena is placed behind everything (z_index: -10)
- Camera targets the Player node
- Player starts at center of viewport (640, 360)

---

### Player Scene (`scenes/player.tscn`)

A reusable player character scene.

**Node Hierarchy:**
```
Player (CharacterBody2D)
├── Sprite2D - Blue placeholder texture
└── CollisionShape2D - 28x28 rectangle
```

**Collision Setup:**
- Layer 1: "player"
- Mask 2: "enemies" (for future enemy collisions)

---

## Input Configuration

Defined in `project.godot`:

| Action | Keys |
|--------|------|
| `move_up` | W, Up Arrow |
| `move_down` | S, Down Arrow |
| `move_left` | A, Left Arrow |
| `move_right` | D, Right Arrow |

---

## Physics Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | player | Player collision |
| 2 | enemies | Enemy collision |
| 3 | pickups | Experience gems, items |
| 4 | projectiles | Weapon projectiles |

---

## How to Run

1. Open Godot 4.x
2. Import the project by selecting the `project.godot` file
3. Press F5 or click the Play button
4. Use WASD or Arrow keys to move the player

---

## What's Next (Phase 2)

- Auto-attacking weapon system
- Basic enemy that follows the player
- Enemy spawner
- Health system for player and enemies
