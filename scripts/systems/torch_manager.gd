extends Node
class_name TorchManager

## Torch Manager System
## Manages torch upgrades that illuminate the night and reduce spawn rates

signal torch_level_changed(level: int)

## Current torch level (0 = no torch, 1-3 = upgrade levels)
var torch_level: int = 0

## Maximum torch level
const MAX_LEVEL: int = 3

## Torch effect values per level
## Level 1: 25% brightness boost, 25% spawn rate reduction
## Level 2: 50% brightness boost, 50% spawn rate reduction
## Level 3: 75% brightness boost, spawn rate back to normal
const TORCH_BRIGHTNESS_BONUS = [0.0, 0.25, 0.50, 0.75]
const TORCH_SPAWN_REDUCTION = [0.0, 0.25, 0.50, 1.0]  # 1.0 = fully negates night penalty

## Get brightness bonus for night (0.0 - 1.0)
## Returns how much to lerp from night tint towards day tint
func get_night_brightness_bonus() -> float:
	if torch_level <= 0 or torch_level > MAX_LEVEL:
		return 0.0
	return TORCH_BRIGHTNESS_BONUS[torch_level]

## Get spawn rate reduction for night (0.0 - 1.0)
## Returns how much to reduce the night spawn penalty
func get_spawn_rate_reduction() -> float:
	if torch_level <= 0 or torch_level > MAX_LEVEL:
		return 0.0
	return TORCH_SPAWN_REDUCTION[torch_level]

## Upgrade torch to next level
func upgrade_torch() -> void:
	if torch_level < MAX_LEVEL:
		torch_level += 1
		torch_level_changed.emit(torch_level)
		print("[TORCH] Upgraded to level %d" % torch_level)

## Check if torch can be upgraded
func can_upgrade() -> bool:
	return torch_level < MAX_LEVEL

## Reset torch level
func reset() -> void:
	torch_level = 0
