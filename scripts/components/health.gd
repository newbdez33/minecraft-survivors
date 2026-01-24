extends Node
class_name HealthComponent
## Reusable health component for players and enemies
## Manages health, damage, healing, and death

signal health_changed(current: int, maximum: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	var old_health = current_health
	current_health = max(0, current_health - amount)

	if current_health != old_health:
		damaged.emit(amount)
		health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0:
		return

	var old_health = current_health
	current_health = min(max_health, current_health + amount)

	if current_health != old_health:
		healed.emit(current_health - old_health)
		health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
