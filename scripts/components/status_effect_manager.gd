extends Node
class_name StatusEffectManager
## Manages status effects on an entity (player or enemy)

signal effect_applied(effect)
signal effect_removed(effect)
signal effect_tick(effect, damage: int)

var active_effects: Array = []
var _tick_timers: Dictionary = {}  # effect -> time since last tick

func _process(delta: float) -> void:
	var effects_to_remove: Array = []

	for effect in active_effects:
		effect.remaining_time -= delta

		# Track tick timer
		if not _tick_timers.has(effect):
			_tick_timers[effect] = 0.0
		_tick_timers[effect] += delta

		# Apply tick damage
		if _tick_timers[effect] >= effect.tick_interval:
			_tick_timers[effect] -= effect.tick_interval
			effect_tick.emit(effect, effect.damage_per_tick)

		# Check for expiration
		if effect.is_expired():
			effects_to_remove.append(effect)

	# Remove expired effects
	for effect in effects_to_remove:
		_remove_effect_internal(effect)

func apply_effect(effect, stack: bool = true) -> void:
	# Check if same type already exists
	for existing in active_effects:
		if existing.type == effect.type:
			if stack:
				# Stack: add damage and refresh duration
				existing.damage_per_tick += effect.damage_per_tick
				existing.stack_count += 1
				existing.reset()
				print("[STATUS] Poison stacked! Now %d damage/tick (x%d)" % [existing.damage_per_tick, existing.stack_count])
			else:
				# No stack: just refresh duration
				existing.reset()
			return

	active_effects.append(effect)
	_tick_timers[effect] = 0.0
	effect_applied.emit(effect)

func remove_effect(effect_type: int) -> void:
	for effect in active_effects:
		if effect.type == effect_type:
			_remove_effect_internal(effect)
			return

func _remove_effect_internal(effect) -> void:
	active_effects.erase(effect)
	_tick_timers.erase(effect)
	effect_removed.emit(effect)

func has_effect(effect_type: int) -> bool:
	for effect in active_effects:
		if effect.type == effect_type:
			return true
	return false

func clear_all_effects() -> void:
	for effect in active_effects.duplicate():
		_remove_effect_internal(effect)

func get_effect(effect_type: int):
	for effect in active_effects:
		if effect.type == effect_type:
			return effect
	return null
