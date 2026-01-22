# Tutorial 4: Camera System

The camera controls what the player sees. Without a camera following the player, they'd walk off-screen! Let's understand how our smooth-follow camera works.

## Why Do We Need a Camera?

```
Without Camera (player walks off screen):
┌─────────────────────────────────────┐
│ Viewport (what you see)             │
│                                     │
│    [Player starts here]             │
│              ↓                      │
│              ■───────────────────────→ Player walks away
│                                     │     (can't see them!)
│                                     │
└─────────────────────────────────────┘

With Camera (follows player):
          ┌─────────────────────────────────────┐
          │ Viewport (what you see)             │
          │                                     │
          │              ■ ← Player always      │
          │                  in view            │
          │                                     │
          └─────────────────────────────────────┘
                        ↑
                    Camera follows
```

## Camera Behavior Options

There are several ways to make a camera follow:

### 1. Direct Attach (Simple)
Make camera a child of player:
```
Player
└── Camera2D
```
- ✅ Simplest approach
- ❌ Camera moves instantly (jarring)
- ❌ Can't have camera effects easily

### 2. Position Snapping (Our Current Approach)
Smoothly interpolate camera position:
```gdscript
camera.position = camera.position.lerp(target.position, speed * delta)
```
- ✅ Smooth, professional feel
- ✅ Camera is independent node
- ✅ Easy to add effects later

### 3. Godot's Built-in Smoothing
Camera2D has built-in options:
```
Camera2D
├── position_smoothing_enabled = true
└── position_smoothing_speed = 5.0
```
- ✅ No code needed
- ❌ Less control over behavior

We use approach #2 for learning purposes and flexibility.

## The Camera Script - Line by Line

Let's examine `scripts/camera.gd`:

```gdscript
extends Camera2D
```
**Line 1:** Our script becomes a Camera2D, gaining:
- Viewport control
- Zoom capabilities
- Limit boundaries
- Built-in smoothing options

---

```gdscript
## Smooth follow camera
## Follows a target node with configurable smoothing
```
**Lines 2-3:** Documentation comments.

---

```gdscript
# The node to follow (usually the player)
@export var target: Node2D
```
**Lines 5-6:**
- `@export` - Visible in Inspector, can drag-and-drop node
- `var target` - Variable to store reference
- `: Node2D` - Must be a 2D node (has position)

In the Godot editor, you can:
1. Select the Camera2D
2. Find "Target" in Inspector
3. Drag the Player node to assign it

---

```gdscript
# How quickly the camera catches up to the target (lower = smoother)
@export var smoothing_speed: float = 5.0
```
**Lines 8-9:**
- Controls how fast camera follows
- Higher = snappier, lower = floatier

**Recommended values:**
| Value | Feel |
|-------|------|
| 2.0 | Very floaty, cinematic |
| 5.0 | Smooth, balanced |
| 8.0 | Quick, responsive |
| 15.0 | Almost instant |

---

```gdscript
func _physics_process(delta: float) -> void:
```
**Line 11:** Physics process for consistent movement.

**Why `_physics_process`?**
- Player moves in `_physics_process`
- Camera should match for smooth following
- Prevents camera "jitter"

---

```gdscript
    if target:
```
**Line 12:** Safety check - make sure target exists.

Without this, if target is null, we'd get an error:
```
Invalid get index 'global_position' (on base: 'null instance')
```

---

```gdscript
        # Smoothly interpolate camera position toward target
        global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
```
**Lines 13-14:** The core smoothing logic.

### Understanding `lerp` (Linear Interpolation)

`lerp` blends between two values:

```gdscript
a.lerp(b, t)
# Returns a point between a and b
# t = 0.0 → returns a
# t = 0.5 → returns midpoint
# t = 1.0 → returns b
```

Visual example:
```
t = 0.0     t = 0.25    t = 0.5     t = 0.75    t = 1.0
[A]─────────────────────────────────────────────[B]
 ↑           ↑           ↑           ↑           ↑
result     result      result     result      result
```

### How Our Smooth Follow Works

Each frame:
1. Camera is at position A
2. Target (player) is at position B
3. We move camera 5*delta (≈0.083) of the way toward B
4. Next frame, repeat from new position

```
Frame 1:  Camera ────────────────────────── Player
                        (far apart)

Frame 2:  Camera ──────────────────── Player
                    (moved 8% closer)

Frame 3:  Camera ────────────────── Player
                  (moved 8% of remaining)

Frame 10: Camera ─────── Player
              (getting close)

Frame 20: Camera ── Player
            (almost there)
```

This creates an "easing" effect:
- Camera moves fast when far from player
- Camera slows down as it gets closer
- Creates smooth, natural-feeling movement

### Why `smoothing_speed * delta`?

```gdscript
smoothing_speed * delta
# 5.0 * 0.0167 ≈ 0.083 (at 60 FPS)
```

Multiplying by delta ensures:
- Consistent smoothing regardless of frame rate
- 30 FPS and 60 FPS feel the same

## Global vs Local Position

```gdscript
global_position = ...lerp(target.global_position, ...)
```

- `position` - Relative to parent node
- `global_position` - Absolute world position

**Why global?**

```
Main Scene
├── Player (position: 500, 300)    ← global = (500, 300)
│   └── Sprite (position: 0, 0)    ← global = (500, 300)
└── Camera (position: 500, 300)    ← We want this!
```

If player is child of another node:
```
Main Scene
├── PlayArea (position: 100, 100)
│   └── Player (position: 400, 200)  ← local = (400, 200)
│                                       global = (500, 300)
└── Camera
```

Using `global_position` ensures camera goes to the right place regardless of scene structure.

## Camera in the Scene

In `main.tscn`, the camera is configured:

```
[node name="Camera2D" type="Camera2D" parent="."]
script = ExtResource("2_camera")
target = NodePath("../Player")
smoothing_speed = 8.0
```

- `target = NodePath("../Player")` - Points to sibling node "Player"
- `../` means "go up to parent, then..."
- `smoothing_speed = 8.0` - We use 8 for responsive feel

## Visual Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Game World                           │
│                                                         │
│    ┌─────────────────────┐                              │
│    │   Viewport          │←── Camera controls          │
│    │   (What you see)    │    what's visible           │
│    │                     │                              │
│    │      [Player]       │                              │
│    │         ↑           │                              │
│    │     Camera          │                              │
│    │     follows         │                              │
│    └─────────────────────┘                              │
│                                                         │
│    Enemies, items, etc. exist outside viewport          │
│    but are revealed as player/camera moves              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Common Modifications

### Add Camera Zoom

```gdscript
@export var target_zoom: float = 1.0

func _ready() -> void:
    zoom = Vector2(target_zoom, target_zoom)
```
- `zoom = 0.5` - Zoomed out (see more)
- `zoom = 1.0` - Normal
- `zoom = 2.0` - Zoomed in (see less)

### Add Camera Shake

```gdscript
var shake_amount: float = 0.0

func shake(amount: float, duration: float) -> void:
    shake_amount = amount
    # Create a timer to reduce shake
    var tween = create_tween()
    tween.tween_property(self, "shake_amount", 0.0, duration)

func _physics_process(delta: float) -> void:
    if target:
        var target_pos = target.global_position
        # Add random shake offset
        target_pos += Vector2(
            randf_range(-shake_amount, shake_amount),
            randf_range(-shake_amount, shake_amount)
        )
        global_position = global_position.lerp(target_pos, smoothing_speed * delta)
```

Call `camera.shake(10, 0.3)` when player gets hit!

### Add Camera Boundaries

```gdscript
@export var limit_left: float = -1000
@export var limit_right: float = 1000
@export var limit_top: float = -1000
@export var limit_bottom: float = 1000

func _physics_process(delta: float) -> void:
    if target:
        var target_pos = target.global_position
        # Clamp to boundaries
        target_pos.x = clamp(target_pos.x, limit_left, limit_right)
        target_pos.y = clamp(target_pos.y, limit_top, limit_bottom)
        global_position = global_position.lerp(target_pos, smoothing_speed * delta)
```

## Testing Your Understanding

1. **Change smoothing_speed** to 2.0 - notice the floaty feel
2. **Change smoothing_speed** to 20.0 - notice the snappy feel
3. **Remove the if check** - see what error you get
4. **Try making camera a child of Player** - compare the feel

## Summary

| Concept | What It Does |
|---------|--------------|
| `Camera2D` | Controls viewport |
| `target` | Node to follow |
| `lerp()` | Smooth interpolation |
| `global_position` | World coordinates |
| `smoothing_speed * delta` | Frame-rate independent smoothing |

The camera is simple but essential. A good camera makes the game feel polished; a bad camera makes it feel amateur!

---

**Previous:** [Tutorial 3: Player Character](./03_player.md)
**Next:** [Tutorial 5: Arena Background](./05_arena.md)
