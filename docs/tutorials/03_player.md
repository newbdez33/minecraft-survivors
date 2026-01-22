# Tutorial 3: Player Character

The player is the most important part of our game. Let's understand every line of code and every node in detail.

## What the Player Needs

For a Vampire Survivors-like game, our player needs:

1. ✅ **Movement** - Walk in any direction
2. ✅ **Collision** - Bump into things (enemies, walls)
3. ✅ **Visual** - Something to see on screen
4. 🔜 **Health** - (Coming in Phase 2)
5. 🔜 **Weapons** - (Coming in Phase 2)

## Player Scene Structure

```
player.tscn
└── Player (CharacterBody2D)     ← Root: Handles physics
    ├── Sprite2D                  ← Child: What you see
    └── CollisionShape2D          ← Child: Physics hitbox
```

### Why CharacterBody2D?

Godot has several physics body types:

| Body Type | Use Case | Example |
|-----------|----------|---------|
| `StaticBody2D` | Never moves | Walls, floors |
| `RigidBody2D` | Physics-controlled | Falling rocks, balls |
| `CharacterBody2D` | Player-controlled | Player, enemies |
| `Area2D` | Detect overlaps only | Pickups, triggers |

We use `CharacterBody2D` because:
- We control movement directly (not physics simulation)
- Built-in `move_and_slide()` handles collisions smoothly
- Perfect for characters that walk around

## The Player Script - Line by Line

Let's examine `scripts/player.gd`:

```gdscript
extends CharacterBody2D
```
**Line 1:** Our script "becomes" a CharacterBody2D. This means we get:
- `velocity` property (built-in)
- `move_and_slide()` function
- All CharacterBody2D features

---

```gdscript
## Player character controller
## Handles 8-directional movement using WASD or Arrow keys
```
**Lines 2-3:** Documentation comments (##). These appear in Godot's help system.

---

```gdscript
# Movement speed in pixels per second
@export var speed: float = 200.0
```
**Lines 5-6:**
- `@export` - Makes this visible in the Inspector
- `var speed` - Variable named "speed"
- `: float` - Type hint (decimal number)
- `= 200.0` - Default value

**What does 200 mean?** At 200 pixels/second:
- Screen is 1280 pixels wide
- Takes 6.4 seconds to cross the screen
- Feel free to adjust! Try 150 (slow) or 300 (fast)

---

```gdscript
func _physics_process(_delta: float) -> void:
```
**Line 8:** Function that runs every physics frame.
- `_physics_process` - Special Godot function, runs 60 times/second
- `_delta` - Underscore means we don't use this parameter
- `: float` - Delta is a float (time since last frame)
- `-> void` - Function returns nothing

**Why `_physics_process` not `_process`?**
- `_process` - Variable frame rate, for visuals
- `_physics_process` - Fixed rate (60/sec), for physics

Movement is physics, so we use `_physics_process`.

---

```gdscript
    # Get input direction
    var input_direction = get_input_direction()
```
**Lines 9-10:** Call our helper function to get which direction the player is pressing.

---

```gdscript
    # Calculate velocity
    if input_direction != Vector2.ZERO:
        # Normalize to prevent faster diagonal movement
        velocity = input_direction.normalized() * speed
    else:
        velocity = Vector2.ZERO
```
**Lines 12-17:** Convert input to velocity.

Let's break this down:

**The Problem with Diagonal Movement:**
```
Pressing RIGHT only:
  direction = (1, 0)
  length = 1
  speed = 200

Pressing RIGHT + DOWN:
  direction = (1, 1)
  length = 1.414  ← √2, longer!
  speed = 282.8   ← Too fast!
```

**The Solution - Normalize:**
```gdscript
input_direction.normalized()
```
`normalized()` scales the vector to length 1:
```
(1, 1).normalized() = (0.707, 0.707)
length = 1  ← Now consistent!
```

Visual representation:
```
Without normalize:        With normalize:
       ↑                        ↑
       │ 1.0                    │ 1.0
       │                        │
 ──────┼──────→           ──────┼──────→
  1.0  │      1.0          1.0  │      1.0
       │                        │
       ↓                        ↓

  Diagonal = 1.41          Diagonal = 1.0 ✓
  (moves faster!)          (same speed)
```

---

```gdscript
    # Move the player
    move_and_slide()
```
**Lines 19-20:** The magic function!

`move_and_slide()`:
1. Takes the `velocity` we set
2. Moves the player
3. Handles collisions (slides along walls)
4. Updates position automatically

We don't need to write collision code - Godot handles it!

---

```gdscript
func get_input_direction() -> Vector2:
    var direction = Vector2.ZERO
```
**Lines 22-23:** Helper function to read input.
- `-> Vector2` - Returns a Vector2
- Start with zero (no movement)

---

```gdscript
    # Horizontal movement
    direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    # Vertical movement
    direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
```
**Lines 25-28:** Read input for each axis.

**How this works:**
```
get_action_strength() returns 0.0 to 1.0

Pressing RIGHT only:
  direction.x = 1.0 - 0.0 = 1.0  (move right)

Pressing LEFT only:
  direction.x = 0.0 - 1.0 = -1.0 (move left)

Pressing BOTH (or neither):
  direction.x = 1.0 - 1.0 = 0.0  (no horizontal movement)
  direction.x = 0.0 - 0.0 = 0.0  (no horizontal movement)
```

This technique handles:
- ✅ Keyboard input (0 or 1)
- ✅ Gamepad analog sticks (0.0 to 1.0)
- ✅ Conflicting inputs (both left+right)

---

```gdscript
    return direction
```
**Line 30:** Send the direction back to the caller.

## The Player Scene File

Let's examine `scenes/player.tscn`:

```
[gd_scene load_steps=4 format=3 uid="uid://player001"]
```
- Scene file header
- `load_steps=4` - How many resources to load
- `format=3` - Godot 4 format

```
[ext_resource type="Script" path="res://scripts/player.gd" id="1_player"]
```
- External resource (our script)
- `res://` means "project root"

```
[sub_resource type="RectangleShape2D" id="RectangleShape2D_player"]
size = Vector2(28, 28)
```
- Collision shape (28x28 pixel rectangle)
- Slightly smaller than sprite (32x32) for forgiving collisions

```
[sub_resource type="PlaceholderTexture2D" id="PlaceholderTexture2D_player"]
size = Vector2(32, 32)
```
- Temporary placeholder texture
- Replace with real sprite later!

```
[node name="Player" type="CharacterBody2D"]
collision_layer = 1
collision_mask = 2
script = ExtResource("1_player")
```
- Root node configuration
- `collision_layer = 1` - Player is on layer 1
- `collision_mask = 2` - Player detects layer 2 (enemies)

```
[node name="Sprite2D" type="Sprite2D" parent="."]
modulate = Color(0.3, 0.7, 1, 1)
texture = SubResource("PlaceholderTexture2D_player")
```
- Visual representation
- `modulate` - Tints the sprite blue
- `parent="."` - Child of root node

```
[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_player")
```
- Physics hitbox
- Must have a shape to collide!

## Visual Guide

```
┌─────────────────────────────────────────┐
│           Player Node Tree              │
├─────────────────────────────────────────┤
│                                         │
│  CharacterBody2D (Player)               │
│  ├─ position: controls where we are     │
│  ├─ velocity: how fast we're moving     │
│  ├─ collision_layer: what we ARE        │
│  └─ collision_mask: what we HIT         │
│       │                                 │
│       ├── Sprite2D                      │
│       │   └─ Just the visual, no logic  │
│       │                                 │
│       └── CollisionShape2D              │
│           └─ Invisible hitbox           │
│              (must match sprite size)   │
│                                         │
└─────────────────────────────────────────┘
```

## Common Modifications

### Change Player Speed
In Godot Inspector or in code:
```gdscript
@export var speed: float = 300.0  # Faster!
```

### Change Player Color
In the scene, modify Sprite2D's `modulate`:
```
modulate = Color(1, 0.3, 0.3, 1)  # Red player
```

### Add Acceleration (Smooth Start/Stop)
```gdscript
@export var acceleration: float = 800.0
@export var friction: float = 600.0

func _physics_process(delta: float) -> void:
    var input_direction = get_input_direction()

    if input_direction != Vector2.ZERO:
        # Accelerate toward input direction
        velocity = velocity.move_toward(
            input_direction.normalized() * speed,
            acceleration * delta
        )
    else:
        # Slow down when no input
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    move_and_slide()
```

## Testing Your Understanding

Try these exercises:

1. **Change the speed** to 400 and see how it feels
2. **Make the player red** by changing the modulate color
3. **Print the velocity** each frame: `print(velocity)`
4. **Make the hitbox bigger** (change RectangleShape2D size)

## Summary

| Component | Purpose |
|-----------|---------|
| `CharacterBody2D` | Physics-based movement |
| `Sprite2D` | Visual representation |
| `CollisionShape2D` | Physics hitbox |
| `velocity` | Built-in movement vector |
| `move_and_slide()` | Handles movement + collision |
| `normalized()` | Consistent speed in all directions |

---

**Previous:** [Tutorial 2: Godot Basics](./02_godot_basics.md)
**Next:** [Tutorial 4: Camera System](./04_camera.md)
