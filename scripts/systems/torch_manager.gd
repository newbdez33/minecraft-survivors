extends Node
class_name TorchManager

## Torch Manager System
## Manages torch upgrades that increase night visibility radius

signal torch_level_changed(level: int)

## Current torch level (0 = no torch, 1-3 = upgrade levels)
var torch_level: int = 0

## Maximum torch level
const MAX_LEVEL: int = 3

## Base visibility radius (screen proportion, 0-1)
const BASE_VISIBILITY_RADIUS: float = 0.25

## Visibility radius bonus per torch level
## Level 0: 0.25 (base only - medium circle)
## Level 1: 0.25 + 0.15 = 0.40
## Level 2: 0.25 + 0.30 = 0.55
## Level 3: 0.25 + 0.60 = 0.85 (nearly full screen)
const TORCH_RADIUS_BONUS = [0.0, 0.15, 0.30, 0.60]

## Get visibility radius for night fog (0.0 - 1.0)
## Returns the radius proportion of the screen that should be visible
func get_visibility_radius() -> float:
	var bonus = 0.0
	if torch_level > 0 and torch_level <= MAX_LEVEL:
		bonus = TORCH_RADIUS_BONUS[torch_level]
	return BASE_VISIBILITY_RADIUS + bonus

## Upgrade torch to next level
func upgrade_torch() -> void:
	if torch_level < MAX_LEVEL:
		torch_level += 1
		torch_level_changed.emit(torch_level)
		print("[TORCH] Upgraded to level %d, visibility radius: %.2f" % [torch_level, get_visibility_radius()])

## Check if torch can be upgraded
func can_upgrade() -> bool:
	return torch_level < MAX_LEVEL

## Reset torch level
func reset() -> void:
	torch_level = 0
