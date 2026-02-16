extends Node2D
## Visual Test for Boss Artwork
## Displays all bosses and takes screenshots

var _bosses: Array = []
var _timer: float = 0.0
var _state: String = "loading"
var _screenshot_dir: String = "res://docs/screenshots"

# Boss data: [scene_path, name, wave, hp]
const BOSS_DATA: Array = [
	["res://scenes/enemies/xiahou_dun.tscn", "Xiahou Dun", 5, 400],
	["res://scenes/enemies/xu_chu.tscn", "Xu Chu", 10, 600],
	["res://scenes/enemies/zhang_liao.tscn", "Zhang Liao", 15, 800],
	["res://scenes/enemies/dian_wei.tscn", "Dian Wei", 20, 1000],
	["res://scenes/enemies/sima_yi.tscn", "Sima Yi", 25, 1200],
	["res://scenes/enemies/lv_bu.tscn", "Lv Bu", 30, 1500],
]

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Boss Artwork")
	print("=".repeat(50))

	# Ensure screenshot directory exists
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("docs/screenshots"):
		dir.make_dir_recursive("docs/screenshots")

	# Create dark background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -100
	add_child(bg)

	# Create title
	var title = Label.new()
	title.name = "Title"
	title.text = "BOSS GALLERY"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 20
	add_child(title)

	# Load and display all bosses
	await get_tree().process_frame
	_display_all_bosses()

func _display_all_bosses() -> void:
	# Layout: 3 columns x 2 rows
	var cols = 3
	var start_x = 180
	var start_y = 150
	var spacing_x = 380
	var spacing_y = 280

	for i in range(BOSS_DATA.size()):
		var data = BOSS_DATA[i]
		var scene_path = data[0]
		var boss_name = data[1]
		var wave = data[2]
		var hp = data[3]

		var col = i % cols
		var row = i / cols
		var pos_x = start_x + col * spacing_x
		var pos_y = start_y + row * spacing_y

		# Create container for each boss
		var container = Node2D.new()
		container.name = "BossContainer_%d" % i
		container.position = Vector2(pos_x, pos_y)
		add_child(container)

		# Try to load boss scene
		if ResourceLoader.exists(scene_path):
			var scene = load(scene_path)
			if scene:
				var boss = scene.instantiate()
				boss.scale = Vector2(3.5, 3.5)  # Scale up for visibility
				boss.position = Vector2.ZERO

				# Disable all processing
				boss.set_physics_process(false)
				boss.set_process(false)
				if boss.has_method("set_process_input"):
					boss.set_process_input(false)

				container.add_child(boss)
				_bosses.append({"node": boss, "name": boss_name, "wave": wave, "hp": hp})
				print("  Loaded: %s" % boss_name)
		else:
			print("  ERROR: Scene not found - %s" % scene_path)

		# Create name label (above boss)
		var name_label = Label.new()
		name_label.text = boss_name
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.add_theme_constant_override("outline_size", 3)
		name_label.add_theme_color_override("font_outline_color", Color.BLACK)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(-80, -90)
		name_label.custom_minimum_size = Vector2(160, 30)
		container.add_child(name_label)

		# Create info label (below boss)
		var info_label = Label.new()
		info_label.text = "Wave %d | HP: %d" % [wave, hp]
		info_label.add_theme_font_size_override("font_size", 16)
		info_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
		info_label.add_theme_constant_override("outline_size", 2)
		info_label.add_theme_color_override("font_outline_color", Color.BLACK)
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info_label.position = Vector2(-80, 75)
		info_label.custom_minimum_size = Vector2(160, 25)
		container.add_child(info_label)

	print("\n  Total bosses loaded: %d" % _bosses.size())
	_state = "ready"

func _process(delta: float) -> void:
	if _state == "ready":
		_timer += delta
		if _timer >= 0.5:
			_take_all_screenshots()
			_state = "done"

func _take_all_screenshots() -> void:
	print("\n  Taking screenshots...")

	# Take main gallery screenshot
	var image = get_viewport().get_texture().get_image()
	var gallery_path = _screenshot_dir + "/boss_gallery.png"
	var error = image.save_png(gallery_path)
	if error == OK:
		print("  Saved: %s" % gallery_path)
	else:
		print("  ERROR: Failed to save gallery screenshot")

	# Take individual boss screenshots
	for i in range(_bosses.size()):
		var boss_data = _bosses[i]
		var boss_name = boss_data["name"].to_lower().replace(" ", "_")
		var wave = boss_data["wave"]

		# Create individual screenshot by cropping
		var crop_x = 180 + (i % 3) * 380 - 100
		var crop_y = 150 + (i / 3) * 280 - 100
		var crop_w = 200
		var crop_h = 200

		# Get fresh image
		var full_image = get_viewport().get_texture().get_image()
		var cropped = full_image.get_region(Rect2i(crop_x, crop_y, crop_w, crop_h))

		var individual_path = "%s/boss_%s_wave%02d.png" % [_screenshot_dir, boss_name, wave]
		error = cropped.save_png(individual_path)
		if error == OK:
			print("  Saved: %s" % individual_path)

	_finish_test()

func _finish_test() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST COMPLETE!")
	print("  Gallery: docs/screenshots/boss_gallery.png")
	print("  Individual: docs/screenshots/boss_*.png")
	print("=".repeat(50) + "\n")

	# Update title to show completion
	var title = get_node_or_null("Title")
	if title:
		title.text = "BOSS GALLERY - TEST COMPLETE"
		title.add_theme_color_override("font_color", Color.GREEN)

	# Wait then quit
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
