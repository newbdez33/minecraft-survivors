extends RefCounted
## BiomeManager - Zone math and biome tile selection
## Determines which biome to render based on world position relative to spawn (0,0)
##
## Biome Layout (direction from spawn, Godot screen coords):
##   East  (330-90 deg)  = DESERT
##   South-West (90-210 deg) = SWAMP (includes west at 180°)
##   North (210-330 deg) = SNOW (includes screen-up at 270°)
##   Inner (<800px)      = PLAINS
##
## Transition zone: 800-1100px (probabilistic tile mixing)

enum Biome { PLAINS, DESERT, SNOW, SWAMP }

const INNER_RADIUS: float = 800.0
const TRANSITION_WIDTH: float = 300.0
const OUTER_RADIUS: float = INNER_RADIUS + TRANSITION_WIDTH  # 1100.0

# Direction sectors (in degrees, atan2 from positive X, Y-down):
# Desert: 330-90 deg (east, wraps around 0)
# Swamp: 90-210 deg (south-west, includes west at 180)
# Snow: 210-330 deg (north-west, includes screen-up at 270)

# Tile texture paths per biome (base + 2 variants)
const TILE_PATHS: Dictionary = {
	Biome.PLAINS: [
		"res://assets/tiles/grass.svg",
		"res://assets/tiles/grass_variant1.svg",
		"res://assets/tiles/grass_variant2.svg",
	],
	Biome.DESERT: [
		"res://assets/tiles/desert.svg",
		"res://assets/tiles/desert_variant1.svg",
		"res://assets/tiles/desert_variant2.svg",
	],
	Biome.SNOW: [
		"res://assets/tiles/snow.svg",
		"res://assets/tiles/snow_variant1.svg",
		"res://assets/tiles/snow_variant2.svg",
	],
	Biome.SWAMP: [
		"res://assets/tiles/swamp.svg",
		"res://assets/tiles/swamp_variant1.svg",
		"res://assets/tiles/swamp_variant2.svg",
	],
}


## Get the primary biome for a world position (ignores transition blending)
static func get_primary_biome(world_pos: Vector2) -> int:
	var dist: float = world_pos.length()
	if dist < INNER_RADIUS:
		return Biome.PLAINS

	return _direction_to_biome(world_pos)


## Get the biome for a specific tile, accounting for transition zone blending
## Returns the biome enum value to use for rendering this tile
static func get_tile_biome(tile_x: int, tile_y: int, tile_size: int = 32) -> int:
	var world_pos: Vector2 = Vector2(tile_x * tile_size + tile_size / 2, tile_y * tile_size + tile_size / 2)
	var dist: float = world_pos.length()

	# Pure plains in inner radius
	if dist < INNER_RADIUS:
		return Biome.PLAINS

	# Pure target biome beyond outer radius
	var target_biome: int = _direction_to_biome(world_pos)
	if dist >= OUTER_RADIUS:
		return target_biome

	# Transition zone: probabilistic mixing based on distance
	var blend: float = (dist - INNER_RADIUS) / TRANSITION_WIDTH  # 0.0 to 1.0
	var hash_val: int = _tile_hash(tile_x, tile_y) % 100
	var threshold: int = int(blend * 100.0)

	if hash_val < threshold:
		return target_biome
	else:
		return Biome.PLAINS


## Get the tile variant index (0=base, 1=variant1, 2=variant2)
## Deterministic based on tile position
static func get_tile_variant(tile_x: int, tile_y: int) -> int:
	var hash_val: int = _tile_hash(tile_x, tile_y) % 100
	if hash_val < 70:
		return 0  # 70% base
	elif hash_val < 85:
		return 1  # 15% variant 1
	else:
		return 2  # 15% variant 2


## Get the biome name as a string
static func biome_name(biome: int) -> String:
	match biome:
		Biome.PLAINS: return "Central Plains"
		Biome.DESERT: return "Western Regions"
		Biome.SNOW: return "Northern Frontier"
		Biome.SWAMP: return "Southern Marshes"
		_: return "Unknown"


## Determine biome from direction angle
static func _direction_to_biome(world_pos: Vector2) -> int:
	# atan2 returns angle in radians; convert to degrees
	# Godot: atan2(y, x), where right=0, down=+90 in screen coords
	var angle_deg: float = rad_to_deg(atan2(world_pos.y, world_pos.x))
	# Normalize to 0-360 range
	if angle_deg < 0:
		angle_deg += 360.0

	# Desert: 330-360 and 0-90 (east, wraps around 0)
	if angle_deg >= 330.0 or angle_deg < 90.0:
		return Biome.DESERT
	# Swamp: 90-210 (south-west, includes west at 180°)
	elif angle_deg >= 90.0 and angle_deg < 210.0:
		return Biome.SWAMP
	# Snow: 210-330 (north-west, includes screen-up/north at 270°)
	else:
		return Biome.SNOW


## Deterministic hash for tile position (same as arena.gd original)
static func _tile_hash(tile_x: int, tile_y: int) -> int:
	var h: int = (tile_x * 374761393 + tile_y * 668265263)
	if h < 0:
		h = -h
	return h
