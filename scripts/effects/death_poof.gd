extends Node2D
## Death poof effect - smoke cloud when enemy dies

@export var lifetime: float = 0.4
@export var expand_scale: float = 1.5

func _ready() -> void:
	# Expand and fade animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE * expand_scale, lifetime)
	tween.tween_property(self, "modulate:a", 0.0, lifetime)

	# Auto-free after animation
	await get_tree().create_timer(lifetime).timeout
	queue_free()
