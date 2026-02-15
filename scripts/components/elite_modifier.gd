extends Node
class_name EliteModifier
## Applies elite status to any enemy: boosted stats, golden visuals, abilities

const HP_MULT: float = 2.5
const DAMAGE_MULT: float = 1.5
const SPEED_MULT: float = 1.2
const XP_MULT: float = 20.0
const SCALE_MULT: float = 1.3

static var _elite_shader: Shader = null


## Apply elite modifications to an enemy (idempotent - skips if already elite)
static func apply(enemy: CharacterBody2D) -> void:
	if enemy.is_in_group("elite"):
		return

	# Stat multipliers
	if "health" in enemy:
		enemy.health = int(enemy.health * HP_MULT)
	if "damage" in enemy:
		enemy.damage = int(enemy.damage * DAMAGE_MULT)
	if "explosion_damage" in enemy:
		enemy.explosion_damage = int(enemy.explosion_damage * DAMAGE_MULT)
	if "potion_damage" in enemy:
		enemy.potion_damage = int(enemy.potion_damage * DAMAGE_MULT)
	if "speed" in enemy:
		enemy.speed = enemy.speed * SPEED_MULT
	if "xp_value" in enemy:
		enemy.xp_value = int(enemy.xp_value * XP_MULT)

	# Update HealthComponent if present
	var health_comp = enemy.get_node_or_null("HealthComponent")
	if health_comp and "max_health" in health_comp:
		health_comp.max_health = enemy.health
		health_comp.current_health = enemy.health

	# Elite monsters don't drop meat
	if "meat_drop_chance" in enemy:
		enemy.meat_drop_chance = 0.0

	# Scale up (multiply existing scale)
	enemy.scale *= SCALE_MULT

	# Apply golden outline shader to Sprite2D
	var sprite = enemy.get_node_or_null("Sprite2D")
	if sprite:
		if _elite_shader == null:
			_elite_shader = load("res://assets/shaders/elite_outline.gdshader")
		if _elite_shader:
			var mat = ShaderMaterial.new()
			mat.shader = _elite_shader
			sprite.material = mat

	# Add to elite group
	enemy.add_to_group("elite")

	# Play elite spawn SFX
	var audio = enemy.get_node_or_null("/root/AudioManager")
	if audio:
		audio.play_sfx_at("elite_spawn", enemy.global_position)

	# Trigger enemy-specific elite ability
	if enemy.has_method("make_elite"):
		enemy.make_elite()
