extends Node2D
## Hit effect - flash/spark when damage is dealt

@export var lifetime: float = 0.2
@export var flash_scale: float = 1.3

func _ready() -> void:
	# Quick flash animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * flash_scale, lifetime * 0.5)
	tween.tween_property(self, "scale", Vector2.ZERO, lifetime * 0.5)

	# Auto-free after animation
	await get_tree().create_timer(lifetime).timeout
	queue_free()
