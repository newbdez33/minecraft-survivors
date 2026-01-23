extends Node2D
class_name Explosion
## Explosion visual effect

@export var lifetime: float = 0.5
@export var expand_scale: float = 2.0

func _ready() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(expand_scale, expand_scale), lifetime)
		tween.tween_property(sprite, "modulate:a", 0.0, lifetime)
		tween.chain().tween_callback(queue_free)
	else:
		await get_tree().create_timer(lifetime).timeout
		queue_free()
