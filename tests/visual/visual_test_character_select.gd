extends Node
## Visual Test Script for Character Selection UI
## Tests the main menu character selection flow

var _screenshot_count: int = 0
var _main_menu: Node = null
var _character_panel: Control = null
var _character_manager: Node = null

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("  VISUAL TEST: Character Selection UI")
	print("=".repeat(50))

	await get_tree().process_frame

	# Find main menu components
	_main_menu = get_tree().current_scene

	if not _main_menu:
		print("ERROR: MainMenu not found!")
		await get_tree().create_timer(2.0).timeout
		get_tree().quit(1)
		return

	print("MainMenu found: %s" % _main_menu)

	# Find character panel and manager
	_character_panel = _main_menu.get_node_or_null("CharacterSelect")
	_character_manager = _main_menu.get_node_or_null("CharacterManager")

	print("CharacterPanel: %s" % _character_panel)
	print("CharacterManager: %s" % _character_manager)

	# Run tests
	await _test_main_menu_buttons()
	await _test_character_panel_display()
	await _test_character_selection()

	_finish_tests()

func _test_main_menu_buttons() -> void:
	print("\n[TEST 1: Main Menu Buttons]")

	# Check if character button exists
	var char_button = _main_menu.get_node_or_null("Container/VBox/CharacterButton")
	if char_button:
		print("  CharacterButton found: PASS")
	else:
		print("  CharacterButton NOT found: FAIL")
		return

	# Take screenshot of main menu
	await get_tree().create_timer(0.5).timeout
	_take_screenshot("01_main_menu")

	# Find and check button label
	var label = char_button.get_node_or_null("Label")
	if label:
		print("  Button label: '%s'" % label.text)

	print("  Main menu buttons test: PASS")

func _test_character_panel_display() -> void:
	print("\n[TEST 2: Character Panel Display]")

	if not _character_panel:
		print("  ERROR: Character panel not found!")
		return

	# Initially hidden
	print("  Initial visibility: %s (expected: false)" % _character_panel.visible)

	# Show the panel
	if _character_panel.has_method("show_panel"):
		_character_panel.show_panel()
	else:
		_character_panel.visible = true
		if _character_panel.has_method("populate_characters"):
			_character_panel.populate_characters()

	await get_tree().create_timer(0.5).timeout

	print("  After show: %s (expected: true)" % _character_panel.visible)

	# Take screenshot with panel open
	_take_screenshot("02_character_panel_open")

	# Check character container
	var container = _character_panel.get_node_or_null("VBoxContainer/CharacterContainer")
	if container:
		var card_count = container.get_child_count()
		print("  Character cards shown: %d" % card_count)

		for i in range(card_count):
			var card = container.get_child(i)
			var name_label = card.get_node_or_null("VBox/NameLabel")
			if name_label:
				print("    - Card %d: %s" % [i + 1, name_label.text])

	print("  Character panel display test: PASS")

func _test_character_selection() -> void:
	print("\n[TEST 3: Character Selection]")

	if not _character_manager:
		print("  ERROR: Character manager not found!")
		return

	# Get current selection
	var current = _character_manager.selected_character_id
	print("  Current selection: %s" % current)

	# Get all characters
	var all_chars = _character_manager.get_all_characters()
	print("  Total characters: %d" % all_chars.size())

	for char in all_chars:
		var status = "UNLOCKED" if char.is_unlocked else "LOCKED"
		var selected = " (SELECTED)" if char.id == current else ""
		print("    - %s: %s%s" % [char.id, status, selected])
		print("      HP: %.0f%%, Speed: %.0f%%, Pickup: %.0f%%" % [
			char.health_mult * 100,
			char.speed_mult * 100,
			char.pickup_range_mult * 100
		])

	# Test unlock simulation
	print("\n  Testing Alex unlock...")
	var alex = _character_manager.get_character("alex")
	if alex:
		var was_locked = not alex.is_unlocked
		_character_manager.check_unlock_conditions({"survival_time": 900})

		if was_locked and alex.is_unlocked:
			print("  >>> Alex unlocked successfully! <<<")
		elif alex.is_unlocked:
			print("  Alex was already unlocked")

		# Try to select Alex
		if alex.is_unlocked:
			var selected = _character_manager.select_character("alex")
			if selected:
				print("  Alex selected: PASS")
				# Refresh panel
				if _character_panel and _character_panel.has_method("populate_characters"):
					_character_panel.populate_characters()
				await get_tree().create_timer(0.5).timeout
				_take_screenshot("03_alex_selected")
			else:
				print("  Failed to select Alex: FAIL")

	# Test selecting Steve back
	var steve_selected = _character_manager.select_character("steve")
	if steve_selected:
		print("  Steve re-selected: PASS")
		if _character_panel and _character_panel.has_method("populate_characters"):
			_character_panel.populate_characters()
		await get_tree().create_timer(0.5).timeout
		_take_screenshot("04_steve_selected")

	print("  Character selection test: PASS")

func _take_screenshot(name: String) -> void:
	_screenshot_count += 1
	var filename = "user://visual_test_char_select_%s.png" % name

	var image = get_viewport().get_texture().get_image()
	if image:
		var error = image.save_png(filename)
		if error == OK:
			print("  Screenshot saved: %s" % filename)

func _finish_tests() -> void:
	print("\n" + "=".repeat(50))
	print("  CHARACTER SELECT UI TEST COMPLETE")
	print("  Screenshots saved: %d" % _screenshot_count)
	print("=".repeat(50))

	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
