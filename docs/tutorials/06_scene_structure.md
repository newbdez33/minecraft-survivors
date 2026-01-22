# Tutorial 6: Scene Structure

Now that we understand each component, let's see how they all connect in the main scene. This tutorial explains the "big picture" of how Godot projects are organized.

## Project File Structure

```
zombies_survivors/
│
├── project.godot          ← Project configuration
│
├── scenes/                ← Scene files (.tscn)
│   ├── main.tscn          ← Main game scene (entry point)
│   └── player.tscn        ← Player character scene
│
├── scripts/               ← Code files (.gd)
│   ├── player.gd          ← Player behavior
│   ├── camera.gd          ← Camera behavior
│   └── arena.gd           ← Arena rendering
│
├── assets/                ← Art, sound, etc. (empty for now)
│
└── docs/                  ← Documentation
    └── tutorials/
```

## The project.godot File

This is the heart of your Godot project. Let's understand key sections:

### Project Identity
```ini
[application]
config/name="Zombie Survivors"
config/description="A Vampire Survivors-like roguelike game"
run/main_scene="res://scenes/main.tscn"
```
- `config/name` - Your game's name
- `run/main_scene` - Which scene runs when you press Play

### Display Settings
```ini
[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="viewport"
```
- `viewport_width/height` - Game resolution
- `stretch/mode="viewport"` - Scales game to window size

### Input Mappings
```ini
[input]
move_up={...}
move_down={...}
move_left={...}
move_right={...}
```

Each action maps to keys. Example structure:
```
move_up:
├── W key (keyboard)
└── Up Arrow (keyboard)
```

### Physics Layers
```ini
[layer_names]
2d_physics/layer_1="player"
2d_physics/layer_2="enemies"
2d_physics/layer_3="pickups"
2d_physics/layer_4="projectiles"
```

Named layers make collision setup clearer in the editor.

### Rendering
```ini
[rendering]
textures/canvas_textures/default_texture_filter=0
```
`filter=0` means "nearest neighbor" - keeps pixel art crisp instead of blurry.

## Main Scene Architecture

Let's examine how `main.tscn` assembles everything:

```
main.tscn
│
├── Main (Node2D)              ← Root node (container)
│   │
│   ├── Arena (Node2D)         ← Background layer
│   │   └── script: arena.gd
│   │   └── z_index: -10
│   │
│   ├── Player (instance)      ← Player scene instance
│   │   └── from: player.tscn
│   │   └── position: (640, 360)
│   │
│   └── Camera2D               ← Camera
│       └── script: camera.gd
│       └── target: Player
```

### Scene Instancing

Notice that Player isn't defined in main.tscn - it's **instanced** from player.tscn:

```
[ext_resource type="PackedScene" uid="uid://player001" path="res://scenes/player.tscn" id="1_player"]

[node name="Player" parent="." instance=ExtResource("1_player")]
position = Vector2(640, 360)
```

**Benefits of instancing:**
1. Edit player.tscn → all instances update
2. Reuse player in other scenes (menus, testing)
3. Spawn multiple players if needed

### Node Order Matters

Nodes are processed and drawn in tree order:

```
Processing order:       Draw order (without z_index):
1. Main                 1. Main (nothing visible)
2. Arena                2. Arena (background)
3. Player               3. Player (on top of arena)
4. Camera               4. Camera (doesn't draw)
```

But we use `z_index` for explicit control:
- Arena: z_index = -10 (always behind)
- Player: z_index = 0 (default, middle)
- (Future) UI: z_index = 100 (always on top)

## Scene Communication

How do our components talk to each other?

### Direct Reference (Export)
Camera needs to know about Player:
```gdscript
# In camera.gd
@export var target: Node2D  # Assigned in Inspector

func _physics_process(delta):
    position = position.lerp(target.position, ...)
```

### Finding Nodes (get_viewport)
Arena finds Camera automatically:
```gdscript
# In arena.gd
var camera = get_viewport().get_camera_2d()
```

### Signals (Future Use)
For loose coupling, Godot uses signals:
```gdscript
# In player.gd
signal health_changed(new_health)

func take_damage(amount):
    health -= amount
    health_changed.emit(health)  # Notify listeners

# In health_bar.gd
func _ready():
    player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health):
    update_display(new_health)
```

## Scene Lifecycle

When you press Play:

```
1. Godot loads main.tscn
   │
2. Creates node tree in memory
   │
   ├── Main node created
   ├── Arena node created
   │   └── arena.gd attached
   ├── Player instance loaded from player.tscn
   │   └── player.gd attached
   └── Camera node created
       └── camera.gd attached
   │
3. _ready() called (bottom-up)
   │
   ├── Player's children ready
   ├── Player._ready()
   ├── Arena._ready()         # Finds camera
   ├── Camera._ready()
   └── Main._ready()
   │
4. Game loop starts
   │
   └── Every frame:
       ├── _process() for each node
       ├── _physics_process() for each node
       └── _draw() for nodes that need it
```

## The res:// Path

In Godot, `res://` means "project root":

```
res://scenes/main.tscn    →  zombies_survivors/scenes/main.tscn
res://scripts/player.gd   →  zombies_survivors/scripts/player.gd
res://assets/player.png   →  zombies_survivors/assets/player.png
```

Always use `res://` in your code for portability.

## Node Paths

NodePath is how you reference other nodes:

```
Scene tree:
Main
├── Arena
├── Player
│   ├── Sprite2D
│   └── CollisionShape2D
└── Camera2D

From Camera2D, paths to other nodes:
"."                  → Camera2D itself
".."                 → Main (parent)
"../Player"          → Player (sibling)
"../Player/Sprite2D" → Sprite inside Player
"../Arena"           → Arena (sibling)
```

In scene files:
```
target = NodePath("../Player")
```

## Visual: Complete Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        project.godot                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • Project name & settings                                │   │
│  │ • Main scene: res://scenes/main.tscn                    │   │
│  │ • Input mappings (WASD, arrows)                         │   │
│  │ • Physics layers                                         │   │
│  │ • Display settings                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      main.tscn (Main Scene)                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                          Main                              │ │
│  │  ┌─────────────────┬────────────────┬─────────────────┐   │ │
│  │  │     Arena       │     Player     │    Camera2D     │   │ │
│  │  │                 │                │                 │   │ │
│  │  │  arena.gd       │  (instance)    │  camera.gd      │   │ │
│  │  │  • _draw()      │       │        │  • lerp follow  │   │ │
│  │  │  • grid render  │       │        │  • target ref   │   │ │
│  │  │                 │       ▼        │        │        │   │ │
│  │  └─────────────────┴───────┬────────┴────────┼────────┘   │ │
│  └────────────────────────────│─────────────────│────────────┘ │
└───────────────────────────────│─────────────────│──────────────┘
                                │                 │
                                ▼                 │ follows
┌───────────────────────────────────────────┐     │
│              player.tscn                  │ ←───┘
│  ┌─────────────────────────────────────┐ │
│  │            Player                    │ │
│  │  ┌────────────┬─────────────────┐   │ │
│  │  │  Sprite2D  │ CollisionShape  │   │ │
│  │  │  (visual)  │ (physics)       │   │ │
│  │  └────────────┴─────────────────┘   │ │
│  │                                      │ │
│  │  player.gd                          │ │
│  │  • get_input_direction()            │ │
│  │  • move_and_slide()                 │ │
│  └─────────────────────────────────────┘ │
└───────────────────────────────────────────┘
```

## Best Practices

### 1. One Script Per Behavior
Each script should do one thing:
- ✅ `player.gd` - Player movement
- ✅ `camera.gd` - Camera following
- ❌ `game.gd` - Everything (too complex!)

### 2. Use Scenes for Reusable Things
If you'll use something multiple times, make it a scene:
- Enemies → `enemy.tscn`
- Bullets → `projectile.tscn`
- Pickups → `experience_gem.tscn`

### 3. Keep Scene Trees Shallow
Deep nesting is hard to navigate:
```
❌ Main > World > Level > Area > Entities > Characters > Player
✅ Main > Player
```

### 4. Name Nodes Clearly
Future you will thank present you:
```
❌ Node2D3, Sprite2D, CharacterBody2D
✅ Player, PlayerSprite, PlayerCollision
```

## What We'll Add Next (Phase 2)

```
main.tscn (updated)
│
├── Main
│   ├── Arena
│   ├── Player
│   │   └── (NEW) WeaponManager
│   │       └── BasicProjectile
│   ├── (NEW) EnemyManager
│   │   └── Enemy (spawned instances)
│   ├── Camera2D
│   └── (NEW) UI
│       └── HealthBar
```

## Summary

| Concept | What It Is |
|---------|------------|
| `project.godot` | Central configuration |
| `res://` | Project root path |
| Scene instancing | Reuse scenes inside scenes |
| Node tree | Hierarchical organization |
| z_index | Draw order control |
| NodePath | Reference other nodes |
| Signals | Event-based communication |

Understanding scene structure is crucial as your game grows. A well-organized project is easier to debug, extend, and maintain!

---

**Previous:** [Tutorial 5: Arena Background](./05_arena.md)

**You've completed Phase 1 tutorials!** You now understand:
- How Godot works (nodes, scenes, scripts)
- Player movement and physics
- Camera following
- Background rendering
- Project organization

Ready for Phase 2? We'll add combat!
