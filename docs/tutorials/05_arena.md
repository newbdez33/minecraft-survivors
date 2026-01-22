# Tutorial 5: Arena Background

The arena is the game world where everything happens. In Vampire Survivors-style games, the arena often appears infinite - you can walk forever in any direction. Let's learn how we create this illusion!

## The "Infinite" Arena Illusion

We don't actually create an infinite world. Instead, we:
1. Only draw what the camera can see
2. Redraw based on camera position each frame
3. Use a simple repeating pattern (grid)

```
Actual game world:          What we draw:
┌───────────────────┐       ┌───────────────────┐
│                   │       │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                   │       │ ▓┼──┼──┼──┼──┼──┼▓ │
│    [viewport]     │  →    │ ▓│  │  │  │  │  │▓ │
│                   │       │ ▓┼──┼──[■]─┼──┼─┼▓ │ ← Player
│                   │       │ ▓│  │  │  │  │  │▓ │
│                   │       │ ▓┼──┼──┼──┼──┼──┼▓ │
└───────────────────┘       └───────────────────┘
                             Only draw visible area!
```

## Why Not Use a Huge Sprite?

You could create a massive background image, but:

| Approach | Problem |
|----------|---------|
| 10000x10000 sprite | Huge file, slow loading, memory issues |
| TileMap | Better, but still needs predefined size |
| **Custom draw** | Perfect! Draw only what's needed |

## The Arena Script - Line by Line

Let's examine `scripts/arena.gd`:

```gdscript
extends Node2D
```
**Line 1:** Arena is a simple Node2D because:
- We don't need physics
- We just need to draw things
- Node2D gives us `_draw()` function

---

```gdscript
## Arena/Ground manager
## Creates a simple tiled background that follows the camera
```
**Lines 2-3:** Documentation.

---

```gdscript
@export var tile_size: int = 64
@export var grid_color: Color = Color(0.15, 0.15, 0.2, 1.0)
@export var line_color: Color = Color(0.2, 0.2, 0.3, 1.0)
```
**Lines 5-7:** Configurable properties.

- `tile_size` - Size of each grid cell (64 pixels)
- `grid_color` - Dark background color
- `line_color` - Slightly lighter grid lines

**Understanding Color:**
```gdscript
Color(red, green, blue, alpha)
# Values from 0.0 to 1.0

Color(1, 0, 0, 1)      # Bright red
Color(0, 1, 0, 1)      # Bright green
Color(0, 0, 1, 1)      # Bright blue
Color(0.5, 0.5, 0.5, 1) # Gray
Color(0.15, 0.15, 0.2, 1) # Dark blue-gray (our grid)
```

---

```gdscript
var camera: Camera2D
```
**Line 9:** Variable to store camera reference.

---

```gdscript
func _ready() -> void:
    # Find the camera in the scene
    camera = get_viewport().get_camera_2d()
```
**Lines 11-13:** Find the camera when scene loads.

- `get_viewport()` - Gets the current viewport
- `.get_camera_2d()` - Gets the active 2D camera

**Why not use @export?**
We could export and assign manually, but this auto-finds the camera. Less setup!

---

```gdscript
func _draw() -> void:
```
**Line 15:** Special Godot function for custom drawing.

`_draw()`:
- Called when Godot needs to render this node
- You use draw_* functions to draw shapes
- Only redraws when you call `queue_redraw()`

---

```gdscript
    if not camera:
        camera = get_viewport().get_camera_2d()
        if not camera:
            return
```
**Lines 16-19:** Safety check.
- If camera isn't set, try to find it
- If still no camera, don't draw anything

---

```gdscript
    var viewport_size = get_viewport_rect().size
    var cam_pos = camera.global_position
```
**Lines 21-22:** Get what we need to calculate drawing area.

- `viewport_size` - Screen dimensions (1280x720)
- `cam_pos` - Where the camera is looking

---

```gdscript
    # Calculate the area to draw (larger than viewport for smooth scrolling)
    var draw_size = viewport_size * 1.5
    var start_x = cam_pos.x - draw_size.x / 2
    var start_y = cam_pos.y - draw_size.y / 2
```
**Lines 24-27:** Calculate drawing boundaries.

**Why 1.5x viewport size?**
```
If we only draw exact viewport:
┌─────────────┐
│  viewport   │  ← edges visible when moving
└─────────────┘

Drawing 1.5x size:
┌───────────────────┐
│ ┌─────────────┐   │
│ │  viewport   │   │  ← extra buffer around edges
│ └─────────────┘   │
└───────────────────┘
```

The extra 50% ensures grid is drawn slightly outside the view, preventing edges from being visible during fast movement.

---

```gdscript
    # Snap to grid
    start_x = floor(start_x / tile_size) * tile_size
    start_y = floor(start_y / tile_size) * tile_size
```
**Lines 29-31:** Align to grid lines.

**The snap calculation:**
```
start_x = 137  (arbitrary position)
tile_size = 64

floor(137 / 64) = floor(2.14) = 2
2 * 64 = 128  ← Snapped to nearest grid line!
```

This ensures grid lines don't "swim" as camera moves:
```
Without snap:           With snap:
  ┼───┼───┼               ┼───┼───┼
    ↑                     ↑
  Grid moves             Grid locked
  with camera            to 64px intervals
```

---

```gdscript
    # Draw background
    draw_rect(Rect2(start_x, start_y, draw_size.x + tile_size, draw_size.y + tile_size), grid_color)
```
**Lines 33-34:** Draw the background fill.

`draw_rect(rectangle, color)`:
- `Rect2(x, y, width, height)` - Rectangle definition
- We add an extra `tile_size` to width/height for buffer

---

```gdscript
    # Draw grid lines
    var x = start_x
    while x < start_x + draw_size.x + tile_size:
        draw_line(Vector2(x, start_y), Vector2(x, start_y + draw_size.y + tile_size), line_color, 1.0)
        x += tile_size
```
**Lines 36-40:** Draw vertical grid lines.

```
draw_line(from, to, color, width)

    start_y ──→ ┬─────┬─────┬─────┬
                │     │     │     │
                │     │     │     │
                │     │     │     │
    end_y ────→ ┴─────┴─────┴─────┴
                ↑     ↑     ↑     ↑
               x   x+64  x+128  x+192
```

The `while` loop:
1. Start at `start_x`
2. Draw a vertical line
3. Move right by `tile_size`
4. Repeat until past the draw area

---

```gdscript
    var y = start_y
    while y < start_y + draw_size.y + tile_size:
        draw_line(Vector2(start_x, y), Vector2(start_x + draw_size.x + tile_size, y), line_color, 1.0)
        y += tile_size
```
**Lines 42-45:** Draw horizontal grid lines (same logic, different direction).

---

```gdscript
func _process(_delta: float) -> void:
    # Redraw every frame to update with camera movement
    queue_redraw()
```
**Lines 47-49:** Request redraw every frame.

`queue_redraw()`:
- Tells Godot "_draw() needs to run again"
- Called in `_process` so it updates every frame
- Godot batches redraws efficiently

**Why every frame?**
Camera moves → we need to recalculate what to draw.

## Visual: How Drawing Works

```
Frame 1: Camera at (0, 0)
┌─────────────────────────────┐
│ ┼───┼───┼───┼───┼───┼───┼   │
│ │   │   │   │   │   │   │   │
│ ┼───┼───┼───┼───┼───┼───┼   │
│ │   │   │ ■ │   │   │   │   │  ← Player at center
│ ┼───┼───┼───┼───┼───┼───┼   │
│ │   │   │   │   │   │   │   │
│ ┼───┼───┼───┼───┼───┼───┼   │
└─────────────────────────────┘

Frame 50: Camera at (200, 100) - player moved!
          ┌─────────────────────────────┐
          │ ┼───┼───┼───┼───┼───┼───┼   │
          │ │   │   │   │   │   │   │   │
          │ ┼───┼───┼───┼───┼───┼───┼   │
          │ │   │   │ ■ │   │   │   │   │  ← Player still at center
          │ ┼───┼───┼───┼───┼───┼───┼   │     (camera followed)
          │ │   │   │   │   │   │   │   │
          │ ┼───┼───┼───┼───┼───┼───┼   │
          └─────────────────────────────┘

Grid redrawn around new camera position!
```

## The z_index Property

In `main.tscn`, Arena has:
```
z_index = -10
```

`z_index` controls draw order:
- Lower numbers = drawn first (behind)
- Higher numbers = drawn last (in front)

```
z_index: -10    0      10
         ↓     ↓       ↓
       Arena  Player  UI
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
              ■
            [Score: 0]
```

## Common Modifications

### Change Grid Size
```gdscript
@export var tile_size: int = 32  # Smaller grid
@export var tile_size: int = 128 # Larger grid
```

### Add Grid Dots Instead of Lines
```gdscript
func _draw() -> void:
    # ... (calculate boundaries same as before)

    # Draw background
    draw_rect(Rect2(start_x, start_y, draw_size.x + tile_size, draw_size.y + tile_size), grid_color)

    # Draw dots at intersections
    var x = start_x
    while x < start_x + draw_size.x + tile_size:
        var y = start_y
        while y < start_y + draw_size.y + tile_size:
            draw_circle(Vector2(x, y), 2, line_color)
            y += tile_size
        x += tile_size
```

### Add Alternating Tile Colors (Checkerboard)
```gdscript
@export var tile_color_a: Color = Color(0.12, 0.12, 0.18, 1)
@export var tile_color_b: Color = Color(0.15, 0.15, 0.22, 1)

func _draw() -> void:
    # ... (calculate boundaries)

    var x = start_x
    var col = 0
    while x < start_x + draw_size.x + tile_size:
        var y = start_y
        var row = 0
        while y < start_y + draw_size.y + tile_size:
            var color = tile_color_a if (col + row) % 2 == 0 else tile_color_b
            draw_rect(Rect2(x, y, tile_size, tile_size), color)
            y += tile_size
            row += 1
        x += tile_size
        col += 1
```

### Use a TileMap Instead (Alternative Approach)
For more complex arenas, you might use Godot's TileMap node:
1. Create a TileSet with your ground tiles
2. Add a TileMap node to the scene
3. Paint tiles in the editor

But for infinite arenas, custom drawing is more efficient!

## Performance Considerations

Our approach is efficient because:

1. **Only draw visible area** - Not the entire world
2. **Simple shapes** - Lines and rectangles are fast
3. **One draw call batched** - Godot optimizes multiple draw_* calls

For even better performance in complex games:
- Use a shader instead of _draw()
- Pre-render to a texture
- Use Godot's ParallaxBackground for layers

## Testing Your Understanding

1. **Change tile_size** to 32 and 128 - see the difference
2. **Change colors** to make a red/black grid
3. **Remove queue_redraw()** - watch what happens when you move
4. **Comment out the floor() snap** - see the grid "swim"

## Summary

| Concept | Purpose |
|---------|---------|
| `_draw()` | Custom drawing function |
| `queue_redraw()` | Request a redraw |
| `draw_rect()` | Draw a rectangle |
| `draw_line()` | Draw a line |
| `z_index` | Control draw order |
| Grid snapping | Prevent visual artifacts |

The arena creates the foundation of our game world. In future phases, we'll add obstacles and environmental variety!

---

**Previous:** [Tutorial 4: Camera System](./04_camera.md)
**Next:** [Tutorial 6: Scene Structure](./06_scene_structure.md)
