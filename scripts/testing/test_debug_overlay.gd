extends CanvasLayer
class_name TestDebugOverlay
## Displays real-time debug information during test mode

var _panel: PanelContainer
var _vbox: VBoxContainer
var _labels: Dictionary = {}

# Colors for different states
const COLOR_NORMAL = Color.WHITE
const COLOR_WARNING = Color.YELLOW
const COLOR_DANGER = Color.RED
const COLOR_GOOD = Color.GREEN
const COLOR_POISON = Color(0.5, 1.0, 0.5)

func _ready() -> void:
	layer = 100  # Always on top
	_create_ui()

func _create_ui() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_left = 0
	_panel.anchor_top = 0
	_panel.offset_left = 10
	_panel.offset_top = 10

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(10)
	_panel.add_theme_stylebox_override("panel", style)

	_vbox = VBoxContainer.new()
	_panel.add_child(_vbox)

	# Title
	var title = Label.new()
	title.text = "=== TEST MODE ==="
	title.add_theme_color_override("font_color", Color.CYAN)
	_vbox.add_child(title)

	# Add separator
	var sep = HSeparator.new()
	_vbox.add_child(sep)

	# Create labels for each stat
	_add_label("time", "Time: 0.0s")
	_add_label("fps", "FPS: 0")
	_add_label("strategy", "Strategy: SURVIVE")
	_add_separator()
	_add_label("health", "Health: 100/100")
	_add_label("level", "Level: 1")
	_add_label("xp", "XP: 0/10")
	_add_label("kills", "Kills: 0")
	_add_label("wave", "Wave: 1")
	_add_separator()
	_add_label("status", "Status: Normal")
	_add_label("poison", "Poison: None")
	_add_label("combo", "Combo: 0")
	_add_separator()
	_add_label("enemies", "Enemies: 0")
	_add_label("orbs", "XP Orbs: 0")
	_add_label("day_night", "Time of Day: Day")
	_add_separator()
	_add_label("screenshots", "Screenshots: 0")
	_add_label("events", "Last Event: -")

	add_child(_panel)

func _add_label(key: String, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	_labels[key] = label
	_vbox.add_child(label)

func _add_separator() -> void:
	var sep = HSeparator.new()
	sep.modulate.a = 0.3
	_vbox.add_child(sep)

func _process(_delta: float) -> void:
	_update_stats()

func _update_stats() -> void:
	# FPS
	_set_label("fps", "FPS: %d" % Engine.get_frames_per_second())

	# Player stats
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health_pct = float(player.current_health) / float(player.max_health)
		var health_color = COLOR_GOOD if health_pct > 0.5 else (COLOR_WARNING if health_pct > 0.25 else COLOR_DANGER)
		_set_label("health", "Health: %d/%d" % [player.current_health, player.max_health], health_color)
		_set_label("level", "Level: %d" % player.current_level)
		_set_label("xp", "XP: %d/%d" % [player.current_xp, player.xp_to_next_level])

		# Check for poison status
		var status_manager = player.get_node_or_null("StatusEffectManager")
		if status_manager and status_manager.active_effects.size() > 0:
			var poison_effect = null
			for effect in status_manager.active_effects:
				if effect.type == 0:  # POISON
					poison_effect = effect
					break

			if poison_effect:
				_set_label("status", "Status: POISONED", COLOR_POISON)
				_set_label("poison", "Poison: %.1fs remaining" % poison_effect.remaining_time, COLOR_POISON)
			else:
				_set_label("status", "Status: Normal", COLOR_NORMAL)
				_set_label("poison", "Poison: None", COLOR_NORMAL)
		else:
			_set_label("status", "Status: Normal", COLOR_NORMAL)
			_set_label("poison", "Poison: None", COLOR_NORMAL)

	# Game stats
	var game_stats = get_tree().get_first_node_in_group("game_stats")
	if not game_stats:
		var main = get_tree().current_scene
		if main:
			game_stats = main.get_node_or_null("GameStats")

	if game_stats:
		_set_label("time", "Time: %.1fs" % game_stats.survival_time)
		_set_label("kills", "Kills: %d" % game_stats.kills)
		_set_label("wave", "Wave: %d" % game_stats.highest_wave)

	# Enemy count
	var enemies = get_tree().get_nodes_in_group("enemies")
	_set_label("enemies", "Enemies: %d" % enemies.size())

	# XP orbs count
	var orbs = get_tree().get_nodes_in_group("xp_orbs")
	_set_label("orbs", "XP Orbs: %d" % orbs.size())

	# Day/Night cycle
	var day_night = get_tree().get_first_node_in_group("day_night_cycle")
	if not day_night:
		var main = get_tree().current_scene
		if main:
			day_night = main.get_node_or_null("DayNightCycle")

	if day_night and "current_phase_name" in day_night:
		_set_label("day_night", "Time of Day: %s" % day_night.current_phase_name)

func _set_label(key: String, text: String, color: Color = COLOR_NORMAL) -> void:
	if key in _labels:
		_labels[key].text = text
		_labels[key].add_theme_color_override("font_color", color)

func set_strategy(strategy_name: String) -> void:
	_set_label("strategy", "Strategy: %s" % strategy_name, Color.CYAN)

func set_screenshot_count(count: int) -> void:
	_set_label("screenshots", "Screenshots: %d" % count)

func set_last_event(event: String) -> void:
	_set_label("events", "Last Event: %s" % event, Color.YELLOW)

func set_combo(combo: int) -> void:
	var color = COLOR_NORMAL
	if combo >= 100:
		color = Color.GOLD
	elif combo >= 50:
		color = Color.ORANGE
	elif combo >= 25:
		color = COLOR_WARNING
	elif combo >= 10:
		color = COLOR_GOOD
	_set_label("combo", "Combo: %d" % combo, color)
