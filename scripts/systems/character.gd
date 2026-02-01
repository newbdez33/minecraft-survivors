extends RefCounted
class_name GameCharacter
## Character definition with stats and unlock requirements

var id: String
var name: String
var description: String
var sprite_path: String
var is_unlocked: bool = false

# Base stats (multipliers)
var health_mult: float = 1.0
var speed_mult: float = 1.0
var damage_mult: float = 1.0
var xp_mult: float = 1.0
var pickup_range_mult: float = 1.0

# Unlock requirement
var unlock_requirement: String = ""
var unlock_condition_type: String = ""  # "survival_time", "kills", "level", etc.
var unlock_condition_value: int = 0

func _init(p_id: String = "", p_name: String = "", p_desc: String = "") -> void:
	id = p_id
	name = p_name
	description = p_desc

func apply_to_player(player: Node) -> void:
	# Apply stat multipliers
	if "max_health" in player:
		player.max_health = int(player.max_health * health_mult)
		player.current_health = player.max_health

	if "speed" in player:
		player.speed *= speed_mult

	if "xp_multiplier" in player:
		player.xp_multiplier *= xp_mult

	# Store damage multiplier for weapons to use
	player.set_meta("damage_mult", damage_mult)
	player.set_meta("pickup_range_mult", pickup_range_mult)

	# Change player sprite
	if sprite_path and sprite_path != "":
		var sprite_node = player.get_node_or_null("Sprite2D")
		if sprite_node:
			if ResourceLoader.exists(sprite_path):
				var texture = load(sprite_path)
				if texture:
					sprite_node.texture = texture
					print("[CHARACTER] Applied sprite: %s" % sprite_path)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"is_unlocked": is_unlocked
	}

func from_dict(data: Dictionary) -> void:
	if "is_unlocked" in data:
		is_unlocked = data.is_unlocked
