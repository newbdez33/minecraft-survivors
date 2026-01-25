extends Node2D
class_name Torch
## Torch weapon - provides visibility in darkness
## Passive weapon that doesn't attack but lights up the night

signal level_changed(new_level: int)

@export var level: int = 1
@export var hand_offset: float = 24.0  # Distance from player center

const MAX_LEVEL: int = 3

var _current_facing: Vector2 = Vector2.RIGHT
var _managed_by_slots: bool = false

## Reference to TorchManager for syncing visibility
var torch_manager: Node = null

func _ready() -> void:
	_update_weapon_position()
	_find_torch_manager()

func _find_torch_manager() -> void:
	# Find TorchManager in the scene
	var root = get_tree().current_scene
	if root:
		torch_manager = root.get_node_or_null("TorchManager")

func _process(_delta: float) -> void:
	# Check if managed by weapon slots
	if not _managed_by_slots:
		var parent = get_parent()
		if parent:
			var weapon_slots = parent.get_node_or_null("WeaponSlots")
			if weapon_slots:
				_managed_by_slots = true

	# Only update position if not managed by WeaponSlots
	if not _managed_by_slots:
		var parent = get_parent()
		if parent and parent is CharacterBody2D:
			if parent.velocity.length() > 10:
				_current_facing = parent.velocity.normalized()
				_update_weapon_position()

	# Animate flame flicker
	_animate_flame()

func _animate_flame() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Subtle flickering effect
		var flicker = sin(Time.get_ticks_msec() * 0.01) * 0.1
		sprite.modulate = Color(1.0, 0.9 + flicker, 0.8 + flicker)

func upgrade() -> void:
	if level < MAX_LEVEL:
		level += 1
		level_changed.emit(level)

		# Sync with TorchManager
		if torch_manager and torch_manager.has_method("upgrade_torch"):
			# TorchManager already upgraded by UpgradeManager, just sync level
			pass

func _update_weapon_position() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.position = _current_facing * hand_offset
		# Z-index: in front when facing down, behind when facing up
		sprite.z_index = 1 if _current_facing.y > 0 else -1
