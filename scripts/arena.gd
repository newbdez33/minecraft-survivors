extends Node2D
## Arena/Ground manager
## Draws tiled grass background that follows the camera

@export var tile_size: int = 32
@export var background_color: Color = Color(0.48, 0.74, 0.42, 1.0)  # Grass green fallback

var camera: Camera2D
var grass_texture: Texture2D
var grass_variant1_texture: Texture2D
var grass_variant2_texture: Texture2D
var textures_loaded: bool = false

# Pseudo-random pattern for tile variants (seeded by position)
func _get_tile_variant(tile_x: int, tile_y: int) -> int:
	var hash_val = (tile_x * 374761393 + tile_y * 668265263) % 100
	if hash_val < 70:
		return 0  # 70% normal grass
	elif hash_val < 85:
		return 1  # 15% flowers
	else:
		return 2  # 15% grass tufts

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	_load_textures()

func _load_textures() -> void:
	# Try to load grass textures
	if ResourceLoader.exists("res://assets/tiles/grass.svg"):
		grass_texture = load("res://assets/tiles/grass.svg")
	if ResourceLoader.exists("res://assets/tiles/grass_variant1.svg"):
		grass_variant1_texture = load("res://assets/tiles/grass_variant1.svg")
	if ResourceLoader.exists("res://assets/tiles/grass_variant2.svg"):
		grass_variant2_texture = load("res://assets/tiles/grass_variant2.svg")

	textures_loaded = grass_texture != null

func _draw() -> void:
	if not camera:
		camera = get_viewport().get_camera_2d()
		if not camera:
			return

	var viewport_size = get_viewport_rect().size
	var cam_pos = camera.global_position

	# Calculate the area to draw (larger than viewport for smooth scrolling)
	var draw_size = viewport_size * 1.5
	var start_x = floor((cam_pos.x - draw_size.x / 2) / tile_size) * tile_size
	var start_y = floor((cam_pos.y - draw_size.y / 2) / tile_size) * tile_size

	# If textures not loaded, draw colored background
	if not textures_loaded:
		draw_rect(Rect2(start_x, start_y, draw_size.x + tile_size, draw_size.y + tile_size), background_color)
		# Draw grid lines for visual feedback
		var line_color = Color(0.35, 0.6, 0.3, 1.0)
		var x = start_x
		while x < start_x + draw_size.x + tile_size:
			draw_line(Vector2(x, start_y), Vector2(x, start_y + draw_size.y + tile_size), line_color, 1.0)
			x += tile_size
		var y = start_y
		while y < start_y + draw_size.y + tile_size:
			draw_line(Vector2(start_x, y), Vector2(start_x + draw_size.x + tile_size, y), line_color, 1.0)
			y += tile_size
		return

	# Draw grass tiles
	var x = start_x
	while x < start_x + draw_size.x + tile_size:
		var y = start_y
		while y < start_y + draw_size.y + tile_size:
			var tile_x = int(x / tile_size)
			var tile_y = int(y / tile_size)
			var variant = _get_tile_variant(tile_x, tile_y)

			var tex: Texture2D = grass_texture
			match variant:
				1:
					if grass_variant1_texture:
						tex = grass_variant1_texture
				2:
					if grass_variant2_texture:
						tex = grass_variant2_texture

			if tex:
				draw_texture(tex, Vector2(x, y))
			y += tile_size
		x += tile_size

func _process(_delta: float) -> void:
	# Redraw every frame to update with camera movement
	queue_redraw()
