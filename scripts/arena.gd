extends Node2D
## Arena/Ground manager
## Creates a simple tiled background that follows the camera

@export var tile_size: int = 64
@export var grid_color: Color = Color(0.15, 0.15, 0.2, 1.0)
@export var line_color: Color = Color(0.2, 0.2, 0.3, 1.0)

var camera: Camera2D

func _ready() -> void:
	# Find the camera in the scene
	camera = get_viewport().get_camera_2d()

func _draw() -> void:
	if not camera:
		camera = get_viewport().get_camera_2d()
		if not camera:
			return

	var viewport_size = get_viewport_rect().size
	var cam_pos = camera.global_position

	# Calculate the area to draw (larger than viewport for smooth scrolling)
	var draw_size = viewport_size * 1.5
	var start_x = cam_pos.x - draw_size.x / 2
	var start_y = cam_pos.y - draw_size.y / 2

	# Snap to grid
	start_x = floor(start_x / tile_size) * tile_size
	start_y = floor(start_y / tile_size) * tile_size

	# Draw background
	draw_rect(Rect2(start_x, start_y, draw_size.x + tile_size, draw_size.y + tile_size), grid_color)

	# Draw grid lines
	var x = start_x
	while x < start_x + draw_size.x + tile_size:
		draw_line(Vector2(x, start_y), Vector2(x, start_y + draw_size.y + tile_size), line_color, 1.0)
		x += tile_size

	var y = start_y
	while y < start_y + draw_size.y + tile_size:
		draw_line(Vector2(start_x, y), Vector2(start_x + draw_size.x + tile_size, y), line_color, 1.0)
		y += tile_size

func _process(_delta: float) -> void:
	# Redraw every frame to update with camera movement
	queue_redraw()
