extends CanvasLayer
class_name HUD
## Heads-Up Display showing player health, XP, and level

@onready var hearts_container: HBoxContainer = $MarginContainer/VBoxContainer/HeartsContainer
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel

var heart_full_texture: Texture2D
var heart_half_texture: Texture2D
var heart_empty_texture: Texture2D

var max_hearts: int = 10
var heart_nodes: Array[TextureRect] = []
var _current_level: int = 1

func _ready() -> void:
	# Load heart textures
	heart_full_texture = load("res://assets/items/heart_full.svg")
	heart_half_texture = load("res://assets/items/heart_half.svg")
	heart_empty_texture = load("res://assets/items/heart_empty.svg")

	# Create heart display
	_create_hearts()

func _create_hearts() -> void:
	if not hearts_container:
		return

	# Clear existing hearts
	for child in hearts_container.get_children():
		child.queue_free()
	heart_nodes.clear()

	# Create heart icons
	for i in range(max_hearts):
		var heart = TextureRect.new()
		heart.texture = heart_full_texture
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)
		heart_nodes.append(heart)

func update_health(current_health: int, maximum_health: int = 100) -> void:
	# Each heart = 10 health points
	var health_per_heart = maximum_health / max_hearts
	var full_hearts = current_health / health_per_heart
	var has_half = (current_health % health_per_heart) >= (health_per_heart / 2)

	for i in range(heart_nodes.size()):
		var heart = heart_nodes[i]
		if i < full_hearts:
			heart.texture = heart_full_texture
		elif i == full_hearts and has_half:
			heart.texture = heart_half_texture
		else:
			heart.texture = heart_empty_texture

func set_max_hearts(count: int) -> void:
	max_hearts = count
	_create_hearts()

func update_xp(current: int, needed: int) -> void:
	if xp_bar:
		xp_bar.max_value = needed
		xp_bar.value = current

func set_level(level: int) -> void:
	_current_level = level
	if level_label:
		level_label.text = "Lv. " + str(level)
