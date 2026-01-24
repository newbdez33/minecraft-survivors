extends Area2D
class_name LuckyDropPickup
## Pickup item that applies a lucky drop effect

const LuckyDropClass = preload("res://scripts/systems/lucky_drop.gd")

@export var drop_type: int = 0  # LuckyDrop.DropType
@export var attract_speed: float = 300.0
@export var pickup_radius: float = 20.0

var _is_attracted: bool = false
var _target: Node2D = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1  # Player

	body_entered.connect(_on_body_entered)

	# Visual setup based on drop type
	_setup_visual()

	# Bob animation
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 5, 0.5)
	tween.tween_property(self, "position:y", position.y + 5, 0.5)

func _setup_visual() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)

	# Color based on rarity
	match drop_type:
		1:  # Diamond
			sprite.modulate = Color.CYAN
		2:  # Golden Apple
			sprite.modulate = Color.GOLD
		3:  # XP Bottle
			sprite.modulate = Color.LIME_GREEN
		4:  # Strength
			sprite.modulate = Color.RED
		5:  # Speed
			sprite.modulate = Color.SKY_BLUE
		6:  # Totem
			sprite.modulate = Color.YELLOW
		7:  # Chest
			sprite.modulate = Color.ORANGE

func _physics_process(delta: float) -> void:
	if _is_attracted and _target and is_instance_valid(_target):
		var direction = (_target.global_position - global_position).normalized()
		global_position += direction * attract_speed * delta

		# Check if close enough to collect
		if global_position.distance_to(_target.global_position) < pickup_radius:
			_collect()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_is_attracted = true
		_target = body

func _collect() -> void:
	if _target:
		LuckyDropClass.apply_drop(_target, drop_type)

		# Spawn collection effect
		_spawn_collect_effect()

	queue_free()

func _spawn_collect_effect() -> void:
	var effect_scene = load("res://scenes/effects/hit_effect.tscn")
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.global_position = global_position
		effect.modulate = Color.GOLD
		effect.scale = Vector2(1.5, 1.5)
		get_tree().current_scene.add_child(effect)
