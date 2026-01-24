extends Node
class_name WeaponSlots
## Manages weapon positions in slots around the player (max 4 weapons)

signal weapon_added(weapon: Node, slot: int)
signal weapon_removed(weapon: Node, slot: int)

const MAX_SLOTS: int = 4

## Distance from player center to weapon slot
@export var slot_distance: float = 24.0

## Slot angles (right, down, left, up)
const SLOT_ANGLES: Array[float] = [0.0, PI/2, PI, -PI/2]

var _weapons: Array[Node] = [null, null, null, null]
var _player: Node = null

func _ready() -> void:
	_player = get_parent()

func _process(_delta: float) -> void:
	_update_weapon_positions()

func _update_weapon_positions() -> void:
	if not _player:
		return

	# Fixed positions - weapons don't rotate with player movement
	for i in range(MAX_SLOTS):
		var weapon = _weapons[i]
		if weapon and is_instance_valid(weapon):
			var slot_angle = SLOT_ANGLES[i]
			var sprite = weapon.get_node_or_null("Sprite2D")
			if sprite:
				sprite.position = Vector2.from_angle(slot_angle) * slot_distance
				# Z-index: in front when below player, behind when above
				sprite.z_index = 1 if sin(slot_angle) > 0 else -1

## Add a weapon to the next available slot
func add_weapon(weapon: Node) -> int:
	for i in range(MAX_SLOTS):
		if _weapons[i] == null:
			_weapons[i] = weapon
			weapon_added.emit(weapon, i)
			return i
	return -1  # No slot available

## Remove a weapon from its slot
func remove_weapon(weapon: Node) -> void:
	for i in range(MAX_SLOTS):
		if _weapons[i] == weapon:
			_weapons[i] = null
			weapon_removed.emit(weapon, i)
			return

## Get weapon at specific slot
func get_weapon_at_slot(slot: int) -> Node:
	if slot >= 0 and slot < MAX_SLOTS:
		return _weapons[slot]
	return null

## Check if a slot is available
func has_empty_slot() -> bool:
	for weapon in _weapons:
		if weapon == null:
			return true
	return false

## Get the number of equipped weapons
func get_weapon_count() -> int:
	var count = 0
	for weapon in _weapons:
		if weapon != null:
			count += 1
	return count

## Register an existing weapon (for weapons already in scene)
func register_weapon(weapon: Node, slot: int = -1) -> int:
	if slot >= 0 and slot < MAX_SLOTS and _weapons[slot] == null:
		_weapons[slot] = weapon
		weapon_added.emit(weapon, slot)
		return slot
	return add_weapon(weapon)
