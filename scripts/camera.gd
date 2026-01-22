extends Camera2D
## Smooth follow camera
## Follows a target node with configurable smoothing

# The node to follow (usually the player)
@export var target: Node2D

# How quickly the camera catches up to the target (lower = smoother)
@export var smoothing_speed: float = 5.0

func _physics_process(delta: float) -> void:
	if target:
		# Smoothly interpolate camera position toward target
		global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
