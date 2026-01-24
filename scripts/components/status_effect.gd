extends RefCounted
class_name StatusEffect
## Represents a status effect (poison, burn, slow, etc.)

enum Type { POISON, BURN, SLOW, STUN }

var type: Type = Type.POISON
var duration: float = 5.0
var tick_interval: float = 0.5
var damage_per_tick: int = 2
var remaining_time: float = 0.0
var stack_count: int = 1  # Number of stacks

func _init(effect_type: Type = Type.POISON, effect_duration: float = 5.0, tick_int: float = 0.5, dmg_per_tick: int = 2) -> void:
	type = effect_type
	duration = effect_duration
	tick_interval = tick_int
	damage_per_tick = dmg_per_tick
	remaining_time = duration

func is_expired() -> bool:
	return remaining_time <= 0.0

func reset() -> void:
	remaining_time = duration
