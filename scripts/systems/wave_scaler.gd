extends Node
class_name WaveScaler
## Post-wave-30 infinite scaling for enemies, bosses, and elites.
## All methods are static. No scaling is applied for waves 1-30.

## Scaling starts after this wave
const SCALING_START_WAVE: int = 30

## Normal enemy scaling per wave past 30
const NORMAL_HP_PER_WAVE: float = 0.10
const NORMAL_DMG_PER_WAVE: float = 0.05
const NORMAL_SPEED_PER_WAVE: float = 0.02
const NORMAL_SPEED_CAP: float = 0.50
const NORMAL_XP_PER_WAVE: float = 0.10

## Boss scaling per 5-wave cycle past 30
const BOSS_HP_PER_CYCLE: float = 0.50
const BOSS_DMG_PER_CYCLE: float = 0.25
const BOSS_SPEED_PER_CYCLE: float = 0.10
const BOSS_SPEED_CAP: float = 1.00
const BOSS_CYCLE_WAVES: int = 5

## Elite scaling past wave 30
const ELITE_CHANCE_PER_WAVE: float = 0.01
const ELITE_CHANCE_CAP: float = 0.50
const ELITE_MAX_PER_5_WAVES: int = 1

## Safety caps
const MAX_HEALTH: int = 2147483647  # 2^31 - 1
const MAX_DAMAGE: int = 100000
const MAX_XP: int = 1000000


## Returns scaling multipliers for a given wave.
## For waves <= 30, all multipliers are 1.0.
## Returns: { "hp": float, "damage": float, "speed": float, "xp": float }
static func get_scaling_multipliers(wave: int, is_boss: bool) -> Dictionary:
	if wave <= SCALING_START_WAVE:
		return {"hp": 1.0, "damage": 1.0, "speed": 1.0, "xp": 1.0}

	var waves_past = wave - SCALING_START_WAVE

	if is_boss:
		var cycles = int(waves_past / BOSS_CYCLE_WAVES)
		var hp_mult = 1.0 + cycles * BOSS_HP_PER_CYCLE
		var dmg_mult = 1.0 + cycles * BOSS_DMG_PER_CYCLE
		var spd_mult = 1.0 + minf(cycles * BOSS_SPEED_PER_CYCLE, BOSS_SPEED_CAP)
		var xp_mult = hp_mult  # XP matches health scaling
		return {"hp": hp_mult, "damage": dmg_mult, "speed": spd_mult, "xp": xp_mult}
	else:
		var hp_mult = 1.0 + waves_past * NORMAL_HP_PER_WAVE
		var dmg_mult = 1.0 + waves_past * NORMAL_DMG_PER_WAVE
		var spd_mult = 1.0 + minf(waves_past * NORMAL_SPEED_PER_WAVE, NORMAL_SPEED_CAP)
		var xp_mult = 1.0 + waves_past * NORMAL_XP_PER_WAVE
		return {"hp": hp_mult, "damage": dmg_mult, "speed": spd_mult, "xp": xp_mult}


## Apply wave scaling to an enemy's stats in-place.
## Must be called AFTER the enemy is added to the scene tree.
static func apply_scaling(enemy: CharacterBody2D, wave: int, is_boss: bool) -> void:
	if wave <= SCALING_START_WAVE:
		return

	var mults = get_scaling_multipliers(wave, is_boss)

	if "health" in enemy:
		enemy.health = mini(int(enemy.health * mults.hp), MAX_HEALTH)
	if "damage" in enemy:
		enemy.damage = mini(int(enemy.damage * mults.damage), MAX_DAMAGE)
	if "explosion_damage" in enemy:
		enemy.explosion_damage = mini(int(enemy.explosion_damage * mults.damage), MAX_DAMAGE)
	if "potion_damage" in enemy:
		enemy.potion_damage = mini(int(enemy.potion_damage * mults.damage), MAX_DAMAGE)
	if "speed" in enemy:
		enemy.speed = enemy.speed * mults.speed
	if "xp_value" in enemy:
		enemy.xp_value = mini(int(enemy.xp_value * mults.xp), MAX_XP)

	# Update HealthComponent if present
	var health_comp = enemy.get_node_or_null("HealthComponent")
	if health_comp and "max_health" in health_comp:
		health_comp.max_health = enemy.health
		health_comp.current_health = enemy.health

	# Boss-specific: scale special attack damages
	if is_boss:
		if "charge_damage" in enemy:
			enemy.charge_damage = mini(int(enemy.charge_damage * mults.damage), MAX_DAMAGE)
		if "stomp_damage" in enemy:
			enemy.stomp_damage = mini(int(enemy.stomp_damage * mults.damage), MAX_DAMAGE)
		if "contact_damage" in enemy:
			enemy.contact_damage = mini(int(enemy.contact_damage * mults.damage), MAX_DAMAGE)
		if "sonic_boom_damage" in enemy:
			enemy.sonic_boom_damage = mini(int(enemy.sonic_boom_damage * mults.damage), MAX_DAMAGE)
		if "melee_damage" in enemy:
			enemy.melee_damage = mini(int(enemy.melee_damage * mults.damage), MAX_DAMAGE)
		if "beam_damage" in enemy:
			enemy.beam_damage = mini(int(enemy.beam_damage * mults.damage), MAX_DAMAGE)
		if "skull_damage" in enemy:
			enemy.skull_damage = mini(int(enemy.skull_damage * mults.damage), MAX_DAMAGE)
		if "breath_damage" in enemy:
			enemy.breath_damage = mini(int(enemy.breath_damage * mults.damage), MAX_DAMAGE)


## Get elite spawn chance for post-wave-30 scaling.
## Returns -1.0 for waves <= 30 (caller should fall through to original logic).
static func get_elite_chance(wave: int, is_night: bool) -> float:
	if wave <= SCALING_START_WAVE:
		return -1.0

	var waves_past = wave - SCALING_START_WAVE
	var chance = 0.25 + waves_past * ELITE_CHANCE_PER_WAVE
	chance = minf(chance, ELITE_CHANCE_CAP)

	if is_night:
		chance += 0.10

	return chance


## Get max simultaneous elites for post-wave-30 scaling.
## Returns -1 for waves <= 30 (caller should fall through to original logic).
static func get_max_elites(wave: int) -> int:
	if wave <= SCALING_START_WAVE:
		return -1

	var waves_past = wave - SCALING_START_WAVE
	var extra = int(waves_past / 5) * ELITE_MAX_PER_5_WAVES
	return 5 + extra
