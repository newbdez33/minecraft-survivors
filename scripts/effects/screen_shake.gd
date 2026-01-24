extends Node
class_name ScreenShake
## Adds screen shake effect to camera

signal shake_started
signal shake_ended

var _camera: Camera2D
var _original_offset: Vector2
var _shake_amount: float = 0.0
var _shake_duration: float = 0.0
var _shake_elapsed: float = 0.0
var _is_shaking: bool = false

func _ready() -> void:
	# Find camera in parent or scene
	_camera = get_parent() as Camera2D
	if not _camera:
		_camera = get_tree().get_first_node_in_group("camera") as Camera2D
	if not _camera:
		var viewport = get_viewport()
		if viewport:
			_camera = viewport.get_camera_2d()

func _process(delta: float) -> void:
	if not _is_shaking or not _camera:
		return

	_shake_elapsed += delta

	if _shake_elapsed >= _shake_duration:
		_stop_shake()
		return

	# Calculate shake with decay
	var progress = _shake_elapsed / _shake_duration
	var current_amount = _shake_amount * (1.0 - progress)

	# Random offset
	var offset = Vector2(
		randf_range(-current_amount, current_amount),
		randf_range(-current_amount, current_amount)
	)

	_camera.offset = _original_offset + offset

func shake(amount: float = 5.0, duration: float = 0.2) -> void:
	if not _camera:
		return

	if not _is_shaking:
		_original_offset = _camera.offset

	# Use stronger shake if called multiple times
	_shake_amount = max(_shake_amount, amount)
	_shake_duration = max(_shake_duration - _shake_elapsed, duration)
	_shake_elapsed = 0.0

	if not _is_shaking:
		_is_shaking = true
		shake_started.emit()

func _stop_shake() -> void:
	_is_shaking = false
	_shake_elapsed = 0.0
	_shake_amount = 0.0
	_shake_duration = 0.0

	if _camera:
		_camera.offset = _original_offset

	shake_ended.emit()

# Convenience methods
func shake_light() -> void:
	shake(3.0, 0.1)

func shake_medium() -> void:
	shake(6.0, 0.2)

func shake_heavy() -> void:
	shake(12.0, 0.3)

func shake_explosion() -> void:
	shake(20.0, 0.4)
