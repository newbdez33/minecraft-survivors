extends Node2D
class_name EffectBase
## Base class for visual effects that play once and auto-free

@export var lifetime: float = 0.5
@export var fade_out: bool = true

func _ready() -> void:
	# Auto-free after lifetime
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_end)

	# Fade out animation
	if fade_out:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, lifetime)

func _on_lifetime_end() -> void:
	queue_free()
