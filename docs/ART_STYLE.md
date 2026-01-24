# Art Style Guide

**Project:** Minecraft Survivors
**Style:** Minecraft-inspired Pixel Art

---

## Core Requirements

All artwork MUST follow these rules:

### 1. Pixel Art Format
- **Grid Size:** 16x16 pixels
- **Pixel Size:** 2x2 pixel blocks (using `<rect>` elements)
- **Rendering:** `shape-rendering="crispEdges"` for sharp pixels
- **Format:** SVG with `viewBox="0 0 16 16"`

### 2. SVG Template
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" shape-rendering="crispEdges">
  <!-- Pixel Art Content -->
  <rect x="0" y="0" width="2" height="2" fill="#COLOR"/>
</svg>
```

### 3. Color Palette (Minecraft Authentic)

#### Sword Materials
| Material | Base Color | Highlight | Dark |
|----------|-----------|-----------|------|
| Wood | `#866526` | `#B8945F` | `#6B4F12` |
| Stone | `#8B8B8B` | `#A9A9A9` | `#6D6D6D` |
| Iron | `#D8D8D8` | `#ECECEC` | `#A8A8A8` |
| Diamond | `#2DCDB0` | `#62E8D6` | `#1FA890` |

#### Common Colors
| Element | Color | Hex |
|---------|-------|-----|
| Wood Handle | Brown | `#8B5A2B` |
| Wood Handle Dark | Dark Brown | `#6B4423` |
| Guard | Gray | `#888888` |
| Guard Dark | Dark Gray | `#666666` |
| String | Light Gray | `#CCCCCC` |
| Arrow Shaft | Gray | `#666666` |
| Arrow Tip | Silver | `#AAAAAA` |

---

## Weapon Orientations

### Swords
- **Orientation:** 45° diagonal (handle bottom-left, blade tip top-right)
- **Structure:** Tip → Blade → Guard → Handle → Pommel
- **Style:** Matches Minecraft inventory sprite exactly

### Bows
- **Orientation:** Vertical curve with string on right side
- **Structure:** Curved wood body + string

### Crossbows
- **Orientation:** Horizontal, bolt pointing right
- **Structure:** Stock + Limbs + String + Mechanism + Bolt

---

## File Naming
- Use lowercase with underscores: `wood_sword.svg`
- Include material/type in name: `diamond_sword.svg`, `stone_sword.svg`

---

## Examples

### Sword Pixel Structure
```
     Tip:    [  ][  ]        (2 pixels)
    Blade:   [  ][  ]        (6 pixels height)
    Guard:   [  ][  ][  ]    (6 pixels width)
   Handle:   [  ][  ]        (4 pixels height)
   Pommel:   [  ][  ]        (4 pixels width)
```

---

## Checklist for New Artwork

- [ ] Uses 16x16 grid
- [ ] Uses 2x2 pixel blocks
- [ ] Has `shape-rendering="crispEdges"`
- [ ] Uses Minecraft-authentic colors
- [ ] Follows correct orientation for weapon type
- [ ] File named correctly (lowercase, underscores)
- [ ] SVG format with proper viewBox
