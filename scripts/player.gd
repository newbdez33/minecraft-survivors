extends CharacterBody2D
## Player character controller
## Handles 8-directional movement using WASD or Arrow keys

# Movement speed in pixels per second
@export var speed: float = 200.0

func _physics_process(_delta: float) -> void:
	# Get input direction
	var input_direction = get_input_direction()

	# Calculate velocity
	if input_direction != Vector2.ZERO:
		# Normalize to prevent faster diagonal movement
		velocity = input_direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	# Move the player
	move_and_slide()

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO

	# Horizontal movement
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# Vertical movement
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	return direction
