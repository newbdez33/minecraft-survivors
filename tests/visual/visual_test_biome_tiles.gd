extends Node2D
## Visual Test for Biome Tile System
## Displays all biome tile sets in a gallery + simulated transition zone
## Run: godot --path . tests/visual/visual_test_biome_tiles.tscn

const BiomeManagerClass = preload("res://scripts/systems/biome_manager.gd")

var _timer: float = 0.0
var _state: String = "loading"
var _screenshot_dir: String = "res://docs/screenshots"

const BIOME_COLORS: Dictionary = {
	0: Color(0.48, 0.74, 0.42),  # Plains - green
	1: Color(0.91, 0.84, 0.64),  # Desert - sand
	2: Color(0.91, 0.93, 0.94),  # Snow - white
	3: Color(0.29, 0.42, 0.23),  # Swamp - dark green
}

const BIOME_LABELS: Array = ["Plains", "Desert", "Snow", "Swamp"]


func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Biome Tile Gallery")
	print("=".repeat(50))

	# Ensure screenshot directory exists
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("docs/screenshots"):
		dir.make_dir_recursive("docs/screenshots")

	# Create dark background
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -100
	add_child(bg)

	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = "BIOME TILE GALLERY"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 10
	add_child(title)

	await get_tree().process_frame
	_display_tile_gallery()
	_display_transition_demo()
	_state = "ready"


func _display_tile_gallery() -> void:
	# Layout: 4 biomes across, each showing base + 2 variants
	var start_x: int = 60
	var start_y: int = 70
	var biome_spacing: int = 310
	var tile_display_size: int = 64  # Draw tiles at 2x for visibility
	var variant_spacing: int = 80

	for biome_idx in range(4):
		var bx: int = start_x + biome_idx * biome_spacing
		var paths: Array = BiomeManagerClass.TILE_PATHS[biome_idx]

		# Biome name label
		var name_label = Label.new()
		name_label.text = BIOME_LABELS[biome_idx]
		name_label.add_theme_font_size_override("font_size", 20)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.add_theme_constant_override("outline_size", 2)
		name_label.add_theme_color_override("font_outline_color", Color.BLACK)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(bx, start_y)
		name_label.custom_minimum_size = Vector2(250, 30)
		add_child(name_label)

		# Load and display 3 variants
		var variant_names: Array = ["Base", "Variant 1", "Variant 2"]
		for v in range(3):
			var vx: int = bx + v * variant_spacing + 10
			var vy: int = start_y + 40

			# Load texture
			if ResourceLoader.exists(paths[v]):
				var tex: Texture2D = load(paths[v])
				if tex:
					var sprite = Sprite2D.new()
					sprite.texture = tex
					sprite.scale = Vector2(2.0, 2.0)
					sprite.position = Vector2(vx + 32, vy + 32)
					add_child(sprite)

					# Color indicator square
					var indicator = ColorRect.new()
					indicator.color = BIOME_COLORS[biome_idx]
					indicator.size = Vector2(64, 4)
					indicator.position = Vector2(vx, vy + 68)
					add_child(indicator)

					print("  Loaded: %s [%s]" % [BIOME_LABELS[biome_idx], variant_names[v]])
			else:
				print("  MISSING: %s" % paths[v])

			# Variant label
			var vlabel = Label.new()
			vlabel.text = variant_names[v]
			vlabel.add_theme_font_size_override("font_size", 12)
			vlabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			vlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vlabel.position = Vector2(vx - 5, vy + 74)
			vlabel.custom_minimum_size = Vector2(74, 20)
			add_child(vlabel)


func _display_transition_demo() -> void:
	# Show a simulated cross-section from Plains through transition into Desert
	var demo_y: int = 260
	var tile_size: int = 16  # Smaller tiles for the demo strip
	var strip_start_x: int = 60
	var strip_width: int = 70  # number of tiles

	# Section label
	var section_label = Label.new()
	section_label.text = "TRANSITION DEMO  (Plains -> Desert, left to right)"
	section_label.add_theme_font_size_override("font_size", 18)
	section_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	section_label.position = Vector2(strip_start_x, demo_y)
	add_child(section_label)

	# Draw tile strip simulating player moving east from 600px to 1300px
	var sim_start_world_x: float = 600.0
	var sim_end_world_x: float = 1300.0
	var world_step: float = (sim_end_world_x - sim_start_world_x) / float(strip_width)

	for row in range(4):
		var ty: int = demo_y + 30 + row * tile_size
		for i in range(strip_width):
			var world_x: float = sim_start_world_x + i * world_step
			var tile_x: int = int(world_x / 32.0)
			var tile_y: int = row * 3 + 5  # Arbitrary y for hash variation

			var biome: int = BiomeManagerClass.get_tile_biome(tile_x, tile_y)
			var color: Color = BIOME_COLORS[biome]

			var rect = ColorRect.new()
			rect.color = color
			rect.size = Vector2(tile_size - 1, tile_size - 1)
			rect.position = Vector2(strip_start_x + i * tile_size, ty)
			add_child(rect)

	# Distance markers
	var marker_positions: Array = [
		{"x": 0, "label": "600px"},
		{"x": int(200.0 / world_step), "label": "800px (inner)"},
		{"x": int(500.0 / world_step), "label": "1100px (outer)"},
		{"x": strip_width - 1, "label": "1300px"},
	]
	for marker in marker_positions:
		var mx: int = strip_start_x + marker.x * tile_size
		var my: int = demo_y + 30 + 4 * tile_size + 4
		var mlabel = Label.new()
		mlabel.text = marker.label
		mlabel.add_theme_font_size_override("font_size", 11)
		mlabel.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		mlabel.position = Vector2(mx - 15, my)
		add_child(mlabel)

	# Show biome zone map (top-down circle diagram)
	_display_zone_map()


func _display_zone_map() -> void:
	var map_center := Vector2(640, 530)
	var map_radius: float = 140.0
	var label_title = Label.new()
	label_title.text = "BIOME ZONE MAP  (top-down, player at center)"
	label_title.add_theme_font_size_override("font_size", 18)
	label_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	label_title.position = Vector2(map_center.x - 200, map_center.y - map_radius - 40)
	add_child(label_title)

	# Draw colored sectors using small colored rects
	var grid_res: int = 60  # resolution of the grid
	var cell_size: float = map_radius * 2.0 / float(grid_res)

	for gx in range(grid_res):
		for gy in range(grid_res):
			var local_x: float = (gx - grid_res / 2.0) * cell_size
			var local_y: float = (gy - grid_res / 2.0) * cell_size
			var dist: float = Vector2(local_x, local_y).length()

			if dist > map_radius:
				continue

			# Map local position to world scale (map_radius = 1400 world px)
			var world_scale: float = 1400.0 / map_radius
			var world_pos := Vector2(local_x * world_scale, local_y * world_scale)
			var biome: int = BiomeManagerClass.get_primary_biome(world_pos)
			var color: Color = BIOME_COLORS[biome]

			# Darken transition zone slightly
			if dist * world_scale > BiomeManagerClass.INNER_RADIUS and dist * world_scale < BiomeManagerClass.OUTER_RADIUS:
				color = color.darkened(0.15)

			var rect = ColorRect.new()
			rect.color = color
			rect.size = Vector2(cell_size + 0.5, cell_size + 0.5)
			rect.position = Vector2(map_center.x + local_x - cell_size / 2, map_center.y + local_y - cell_size / 2)
			add_child(rect)

	# Center dot (spawn)
	var center_dot = ColorRect.new()
	center_dot.color = Color.WHITE
	center_dot.size = Vector2(6, 6)
	center_dot.position = map_center - Vector2(3, 3)
	add_child(center_dot)

	# Direction labels
	var dir_labels: Array = [
		{"text": "DESERT (East)", "pos": Vector2(map_radius + 10, -8)},
		{"text": "SNOW (North)", "pos": Vector2(-30, -(map_radius + 20))},
		{"text": "SWAMP (West/South)", "pos": Vector2(-(map_radius + 120), -8)},
	]
	for dl in dir_labels:
		var dlabel = Label.new()
		dlabel.text = dl.text
		dlabel.add_theme_font_size_override("font_size", 13)
		dlabel.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		dlabel.add_theme_constant_override("outline_size", 2)
		dlabel.add_theme_color_override("font_outline_color", Color.BLACK)
		dlabel.position = map_center + dl.pos
		add_child(dlabel)


func _process(delta: float) -> void:
	if _state == "ready":
		_timer += delta
		if _timer >= 0.5:
			_take_screenshots()
			_state = "done"


func _take_screenshots() -> void:
	print("\n  Taking screenshots...")

	# In headless mode, get_image() returns null (dummy renderer has no texture)
	var viewport = get_viewport()
	if not viewport:
		print("  SKIP: No viewport (headless mode)")
		_finish_test()
		return
	var image = viewport.get_texture().get_image() if viewport.get_texture() else null
	if image:
			var path = _screenshot_dir + "/biome_tile_gallery.png"
			var error = image.save_png(path)
			if error == OK:
				print("  Saved: %s" % path)
			else:
				print("  ERROR: Failed to save screenshot (error %d)" % error)
	else:
		print("  SKIP: No image available (headless mode)")

	_finish_test()


func _finish_test() -> void:
	print("\n" + "=".repeat(50))
	print("  BIOME TILE VISUAL TEST COMPLETE!")
	print("  Gallery: docs/screenshots/biome_tile_gallery.png")
	print("=".repeat(50) + "\n")

	var title = get_node_or_null("Title")
	if title:
		title.text = "BIOME TILE GALLERY - TEST COMPLETE"
		title.add_theme_color_override("font_color", Color.GREEN)

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
