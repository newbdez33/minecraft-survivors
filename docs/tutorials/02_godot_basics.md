# Tutorial 2: Godot Basics

Before diving into our game code, let's understand the fundamental Godot concepts we'll use throughout.

## Nodes: The Building Blocks

Everything in Godot is a **Node**. Think of nodes as LEGO bricks - each does one thing, and you combine them to build complex things.

```
Node (base - does almost nothing)
├── Node2D (adds 2D position, rotation, scale)
│   ├── Sprite2D (displays an image)
│   ├── Camera2D (controls what you see)
│   └── CharacterBody2D (physics-enabled character)
├── Control (for UI elements)
└── Node3D (for 3D games)
```

### Common Node Types We Use

| Node Type | What It Does | We Use It For |
|-----------|--------------|---------------|
| `Node2D` | Base for 2D objects | Arena background |
| `CharacterBody2D` | Physics body you control | Player character |
| `Sprite2D` | Displays an image | Player visual |
| `CollisionShape2D` | Defines collision area | Player hitbox |
| `Camera2D` | Controls the viewport | Following player |

## Scenes: Reusable Node Trees

A **Scene** is a saved group of nodes. Scenes are:

- **Reusable**: Create once, use many times
- **Modular**: Each scene is self-contained
- **Nestable**: Scenes can contain other scenes

### Example: Our Player Scene

```
player.tscn (scene file)
└── Player (CharacterBody2D)      ← Root node
    ├── Sprite2D                   ← Child node
    └── CollisionShape2D           ← Child node
```

We save this as a scene so we can:
- Edit the player in one place
- Reuse it in different levels
- Spawn multiple players if needed

## Scripts: Adding Behavior

Nodes are dumb by default. **Scripts** give them behavior.

```gdscript
# This script is attached to a node
extends CharacterBody2D  # "I am a CharacterBody2D"

func _ready():
    # Runs once when node enters the scene
    print("I'm alive!")

func _process(delta):
    # Runs every frame (60 times per second)
    pass
```

### Script Lifecycle Functions

| Function | When It Runs | Use For |
|----------|--------------|---------|
| `_ready()` | Once, when node is added to scene | Initialization |
| `_process(delta)` | Every frame | Visual updates, UI |
| `_physics_process(delta)` | Fixed interval (60/sec) | Physics, movement |
| `_input(event)` | When input occurs | Handling key presses |

### What is `delta`?

`delta` is the time since the last frame in seconds.

**Why use it?** Computers run at different speeds. Without delta:
- Fast computer: Player moves 60 pixels/second
- Slow computer: Player moves 30 pixels/second

With delta:
```gdscript
# WRONG: Speed depends on frame rate
position.x += 5

# RIGHT: Consistent speed regardless of frame rate
position.x += 5 * delta
```

## The `extends` Keyword

Every script starts with `extends`. This means "I am this type of node."

```gdscript
extends CharacterBody2D
# This script IS a CharacterBody2D
# It has all CharacterBody2D abilities + our custom code
```

Think of it like inheritance:
```
CharacterBody2D (parent - has move_and_slide())
    └── Our player.gd (child - inherits move_and_slide, adds custom movement)
```

## Variables and Exports

### Regular Variables
```gdscript
var speed = 200  # Only accessible in code
```

### Exported Variables
```gdscript
@export var speed: float = 200.0
```

The `@export` decorator:
- Shows the variable in Godot's Inspector panel
- Lets you tweak values without editing code
- Great for game designers and testing

```
┌─────────────────────────────┐
│ Inspector                   │
├─────────────────────────────┤
│ Player                      │
│ ├── Speed: [====200====]    │  ← You can drag this slider!
│ └── ...                     │
└─────────────────────────────┘
```

## Vectors: Position and Direction

A **Vector2** holds two numbers (x, y). Used for:

- **Position**: Where something is
- **Direction**: Which way something faces
- **Velocity**: How fast and which direction

```gdscript
var position = Vector2(100, 200)  # x=100, y=200

#    (0,0) ────────────→ X+
#      │
#      │    Player at (100, 200)
#      │         ↓
#      ↓        [■]
#     Y+
```

### Useful Vector2 Constants

```gdscript
Vector2.ZERO   # (0, 0)   - No movement
Vector2.ONE    # (1, 1)   - Diagonal
Vector2.UP     # (0, -1)  - Up (Y is inverted in 2D!)
Vector2.DOWN   # (0, 1)   - Down
Vector2.LEFT   # (-1, 0)  - Left
Vector2.RIGHT  # (1, 0)   - Right
```

**Important:** In Godot 2D, Y increases downward!

```
      (0,0)
        ┌──────────→ X+ (right)
        │
        │
        ↓
       Y+ (down)
```

## Input System

Godot uses **Input Actions** - named inputs that can have multiple keys.

### Defining Actions (in project.godot)
```
Action: "move_up"
├── W key
└── Up Arrow
```

### Reading Actions (in code)
```gdscript
# Is the key currently held down?
if Input.is_action_pressed("move_up"):
    velocity.y = -speed

# How hard is it pressed? (0.0 to 1.0)
# Useful for analog sticks
var strength = Input.get_action_strength("move_up")
```

## Physics Layers and Masks

Physics layers control what collides with what.

```
Layer 1: Player      ■
Layer 2: Enemies     ☠ ☠ ☠
Layer 3: Pickups     ◆ ◆
Layer 4: Projectiles  • • •
```

### Layer vs Mask

- **Layer**: "I exist on this layer"
- **Mask**: "I detect collisions with these layers"

```
Player:
  Layer: 1 (I am a player)
  Mask: 2 (I collide with enemies)

Enemy:
  Layer: 2 (I am an enemy)
  Mask: 1, 4 (I collide with player and projectiles)
```

## File Types

| Extension | What It Is |
|-----------|------------|
| `.tscn` | Scene file (text format) |
| `.gd` | GDScript file |
| `.tres` | Resource file (text) |
| `.godot` | Project settings |

## The `$` Shorthand

`$` is shorthand for `get_node()`:

```gdscript
# These are the same:
var sprite = get_node("Sprite2D")
var sprite = $Sprite2D

# Access nested nodes with /
var collision = $Player/CollisionShape2D
```

## Summary

| Concept | What It Is | Example |
|---------|------------|---------|
| Node | Building block | `CharacterBody2D` |
| Scene | Saved node tree | `player.tscn` |
| Script | Node behavior | `player.gd` |
| Export | Editable variable | `@export var speed` |
| Vector2 | 2D coordinate | `Vector2(100, 200)` |
| Delta | Frame time | `position += velocity * delta` |
| Input Action | Named input | `"move_up"` |

---

**Previous:** [Tutorial 1: Introduction](./01_introduction.md)
**Next:** [Tutorial 3: Player Character](./03_player.md)
