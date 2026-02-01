class_name UpgradeEffect
extends RefCounted

## Upgrade visual effect manager - handles various upgrade visual feedback

const StatPopupClass = preload("res://scripts/effects/stat_popup.gd")

# Upgrade color themes
const UPGRADE_COLORS = {
	"sharpness": Color(1.0, 0.3, 0.3),     # Red - damage
	"protection": Color(0.3, 0.5, 1.0),    # Blue - defense
	"swiftness": Color(0.3, 1.0, 0.5),     # Green - speed
	"knockback": Color(1.0, 0.6, 0.2),     # Orange - force
	"looting": Color(1.0, 0.85, 0.0),      # Gold - rewards
	"sweeping": Color(0.8, 0.4, 1.0),      # Purple - range
	"haste": Color(0.6, 0.3, 1.0),         # Violet - cooldown
	"sword": Color(0.7, 0.7, 0.75),        # Silver - weapon
	"bow": Color(0.6, 0.4, 0.2),           # Brown - weapon
	"torch": Color(1.0, 0.5, 0.0),         # Orange - light
}


static func get_upgrade_color(upgrade_id: String) -> Color:
	"""Get the theme color for an upgrade"""
	return UPGRADE_COLORS.get(upgrade_id, Color.WHITE)


static func play_upgrade_effect(target: Node2D, upgrade_id: String, level: int) -> void:
	"""Play upgrade visual effect on target"""
	if target == null or not is_instance_valid(target):
		return

	var color = get_upgrade_color(upgrade_id)

	# Create upgrade flash effect
	_spawn_upgrade_flash(target, color)

	# Create expanding ring effect
	_spawn_upgrade_ring(target, color)

	# Screen flash for higher levels
	if level >= 3:
		_do_screen_flash(target, color)


static func play_evolution_effect(target: Node2D, from_tier: int, to_tier: int) -> void:
	"""Play weapon evolution effect (more dramatic)"""
	if target == null or not is_instance_valid(target):
		return

	# Tier colors
	var tier_colors = {
		2: Color(0.6, 0.6, 0.65),  # Stone - gray
		3: Color(0.8, 0.8, 0.85),  # Iron - silver
		4: Color(0.3, 0.8, 1.0),   # Diamond - cyan
	}

	var color = tier_colors.get(to_tier, Color.WHITE)

	# Dramatic multi-burst effect
	for i in range(3):
		_spawn_upgrade_flash(target, color)
		_spawn_upgrade_ring(target, color)
		await target.get_tree().create_timer(0.15).timeout

	# Screen shake and flash
	_do_screen_flash(target, color)
	_do_screen_shake(target)

	# Particle burst
	_spawn_particle_burst(target, color, 12)


static func spawn_stat_popup(target: Node2D, text: String, color: Color) -> void:
	"""Spawn floating stat text above target"""
	if target == null or not is_instance_valid(target):
		return

	if not target.get_tree() or not target.get_tree().current_scene:
		return

	var popup = StatPopupClass.new()
	popup.global_position = target.global_position + Vector2(0, -30)
	popup.show_stat(text, color)

	target.get_tree().current_scene.call_deferred("add_child", popup)


static func _spawn_upgrade_flash(target: Node2D, color: Color) -> void:
	"""Spawn a flash effect at target position"""
	if not target.get_tree() or not target.get_tree().current_scene:
		return

	# Try to use hit_effect.tscn as base
	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if hit_scene:
		var flash = hit_scene.instantiate()
		flash.global_position = target.global_position
		flash.modulate = color
		flash.scale = Vector2(2.0, 2.0)
		target.get_tree().current_scene.call_deferred("add_child", flash)


static func _spawn_upgrade_ring(target: Node2D, color: Color) -> void:
	"""Spawn an expanding ring effect"""
	if not target.get_tree() or not target.get_tree().current_scene:
		return

	# Create a simple ring using CanvasItem
	var ring = _UpgradeRing.new()
	ring.global_position = target.global_position
	ring.ring_color = color
	target.get_tree().current_scene.call_deferred("add_child", ring)


static func _spawn_particle_burst(target: Node2D, color: Color, count: int) -> void:
	"""Spawn multiple particles in a burst pattern"""
	if not target.get_tree() or not target.get_tree().current_scene:
		return

	var hit_scene = load("res://scenes/effects/hit_effect.tscn")
	if not hit_scene:
		return

	for i in range(count):
		var particle = hit_scene.instantiate()
		var angle = TAU * i / count
		var offset = Vector2(cos(angle), sin(angle)) * 20.0

		particle.global_position = target.global_position + offset
		particle.modulate = color
		particle.scale = Vector2(0.6, 0.6)

		target.get_tree().current_scene.call_deferred("add_child", particle)


static func _do_screen_flash(target: Node2D, color: Color) -> void:
	"""Flash the screen briefly with a color overlay"""
	if not target.get_tree():
		return

	var canvas = target.get_tree().current_scene
	if canvas == null:
		return

	# Create a temporary color rect for flash
	var flash_rect = ColorRect.new()
	flash_rect.color = Color(color.r, color.g, color.b, 0.3)
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.add_child(flash_rect)
	canvas.call_deferred("add_child", canvas_layer)

	# Fade out
	var tween = canvas.create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, 0.3)
	tween.tween_callback(func(): canvas_layer.queue_free())


static func _do_screen_shake(target: Node2D) -> void:
	"""Shake the camera briefly"""
	var camera = target.get_viewport().get_camera_2d()
	if camera == null:
		return

	var original_offset = camera.offset
	var shake_tween = camera.create_tween()

	# Quick shake
	for i in range(5):
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		shake_tween.tween_property(camera, "offset", original_offset + shake_offset, 0.03)

	shake_tween.tween_property(camera, "offset", original_offset, 0.05)


# Internal helper class for ring effect
class _UpgradeRing extends Node2D:
	var ring_color: Color = Color.WHITE
	var ring_radius: float = 10.0
	var ring_width: float = 3.0
	var _tween: Tween = null

	func _ready() -> void:
		# Animate expansion and fade
		_tween = create_tween()
		_tween.set_parallel(true)
		_tween.tween_property(self, "ring_radius", 80.0, 0.4).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
		_tween.chain().tween_callback(queue_free)

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 32, ring_color, ring_width, true)
