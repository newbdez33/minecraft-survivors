extends Camera2D
## Smooth follow camera
## Follows a target node with configurable smoothing

# The node path to follow (usually the player)
@export var target: NodePath

# How quickly the camera catches up to the target (lower = smoother)
@export var smoothing_speed: float = 5.0

var _target_node: Node2D

func _ready() -> void:
	if target:
		_target_node = get_node_or_null(target) as Node2D
	# Start at target position immediately
	if _target_node:
		global_position = _target_node.global_position

func _physics_process(delta: float) -> void:
	if _target_node:
		# Smoothly interpolate camera position toward target
		global_position = global_position.lerp(_target_node.global_position, smoothing_speed * delta)
