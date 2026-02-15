extends Node2D
## Arena/Ground manager
## Draws tiled background that follows the camera
## Supports biome transitions based on distance/direction from spawn

const BiomeManagerClass = preload("res://scripts/systems/biome_manager.gd")

@export var tile_size: int = 32
@export var background_color: Color = Color(0.48, 0.74, 0.42, 1.0)  # Grass green fallback

signal biome_changed(biome: int)

var camera: Camera2D
var textures_loaded: bool = false
var _current_biome: int = BiomeManagerClass.Biome.PLAINS
var _player: Node2D = null

# Texture cache: biome enum -> [base, variant1, variant2]
var _biome_textures: Dictionary = {}


func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	_load_textures()


func _load_textures() -> void:
	var any_loaded: bool = false
	for biome in BiomeManagerClass.TILE_PATHS:
		var paths: Array = BiomeManagerClass.TILE_PATHS[biome]
		var textures: Array = [null, null, null]
		for i in range(paths.size()):
			if ResourceLoader.exists(paths[i]):
				textures[i] = load(paths[i])
				if i == 0:
					any_loaded = true
		_biome_textures[biome] = textures

	textures_loaded = any_loaded


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

	# Draw tiles with biome support
	var x = start_x
	while x < start_x + draw_size.x + tile_size:
		var y = start_y
		while y < start_y + draw_size.y + tile_size:
			var tile_x = int(x / tile_size)
			var tile_y = int(y / tile_size)

			# Get biome and variant for this tile
			var biome: int = BiomeManagerClass.get_tile_biome(tile_x, tile_y, tile_size)
			var variant: int = BiomeManagerClass.get_tile_variant(tile_x, tile_y)

			# Get texture from cache
			var tex: Texture2D = _get_biome_texture(biome, variant)

			if tex:
				draw_texture(tex, Vector2(x, y))
			y += tile_size
		x += tile_size


func _process(_delta: float) -> void:
	# Redraw every frame to update with camera movement
	queue_redraw()

	# Check for biome change based on player position
	_update_current_biome()


func _get_biome_texture(biome: int, variant: int) -> Texture2D:
	if biome not in _biome_textures:
		return null
	var textures: Array = _biome_textures[biome]
	if variant > 0 and variant < textures.size() and textures[variant] != null:
		return textures[variant]
	return textures[0]


func _update_current_biome() -> void:
	# Find player if not cached
	if not _player:
		_player = get_node_or_null("../Player")
		if not _player:
			return

	var new_biome: int = BiomeManagerClass.get_primary_biome(_player.global_position)
	if new_biome != _current_biome:
		_current_biome = new_biome
		biome_changed.emit(new_biome)


## Get the current biome the player is in
func get_current_biome() -> int:
	return _current_biome
