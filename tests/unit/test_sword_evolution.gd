extends Node
## Unit tests for Sword Evolution System

class_name TestSwordEvolution

static func get_sword_instance():
	var scene = load("res://scenes/weapons/iron_blade.tscn")
	return scene.instantiate() if scene else null

# Test: Sword initializes at Wood tier
static func test_sword_starts_at_wood_tier() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var result = sword.current_tier == SwordBase.Tier.IRON_BLADE
	sword.queue_free()
	return result

# Test: Wood sword has correct base damage
static func test_iron_blade_damage() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var result = sword.damage == 5
	sword.queue_free()
	return result

# Test: Wood sword has correct attack range
static func test_iron_blade_range() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var result = sword.attack_range == 30.0
	sword.queue_free()
	return result

# Test: Wood sword attack cooldown
static func test_iron_blade_cooldown() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var result = sword.attack_cooldown == 1.2
	sword.queue_free()
	return result

# Test: Kill count increments
static func test_kill_count_increments() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.on_enemy_killed()
	sword.on_enemy_killed()
	sword.on_enemy_killed()

	var result = sword.kill_count == 3
	sword.queue_free()
	return result

# Test: Sword evolves at correct kill threshold
static func test_sword_evolves_at_threshold() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	# Wood tier evolves at 50 kills
	for i in range(50):
		sword.on_enemy_killed()

	var result = sword.current_tier == SwordBase.Tier.STEEL_BLADE
	sword.queue_free()
	return result

# Test: Stone sword has correct damage
static func test_steel_blade_damage() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.STEEL_BLADE)
	var result = sword.damage == 8
	sword.queue_free()
	return result

# Test: Stone sword has correct range
static func test_steel_blade_range() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.STEEL_BLADE)
	var result = sword.attack_range == 35.0
	sword.queue_free()
	return result

# Test: Iron sword has correct damage
static func test_fine_steel_blade_damage() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.FINE_STEEL)
	var result = sword.damage == 12
	sword.queue_free()
	return result

# Test: Iron sword has correct range
static func test_fine_steel_blade_range() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.FINE_STEEL)
	var result = sword.attack_range == 40.0
	sword.queue_free()
	return result

# Test: Diamond sword has correct damage
static func test_divine_weapon_damage() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.DIVINE)
	var result = sword.damage == 15
	sword.queue_free()
	return result

# Test: Diamond sword has correct range
static func test_divine_weapon_range() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.DIVINE)
	var result = sword.attack_range == 45.0
	sword.queue_free()
	return result

# Test: Diamond sword doesn't evolve further
static func test_divine_weapon_max_tier() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.DIVINE)
	# Try to evolve many times
	for i in range(100):
		sword.on_enemy_killed()

	var result = sword.current_tier == SwordBase.Tier.DIVINE
	sword.queue_free()
	return result

# Test: Kill count resets after evolution
static func test_kill_count_resets_on_evolution() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	# Evolve to stone
	for i in range(50):
		sword.on_enemy_killed()

	var result = sword.kill_count == 0
	sword.queue_free()
	return result

# Test: Evolved signal is emitted
static func test_evolved_signal_emitted() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var signal_received = false
	var received_tier = 0
	sword.evolved.connect(func(tier):
		signal_received = true
		received_tier = tier
	)

	# Evolve to stone
	for i in range(50):
		sword.on_enemy_killed()

	var result = signal_received and received_tier == SwordBase.Tier.STEEL_BLADE
	sword.queue_free()
	return result

# Test: Tier name getter works
static func test_tier_name_getter() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	var wood_name = sword.get_tier_name()
	sword.set_tier(SwordBase.Tier.DIVINE)
	var diamond_name = sword.get_tier_name()

	var result = wood_name == "Iron Blade" and diamond_name == "Divine Weapon"
	sword.queue_free()
	return result

# Test: Kills to next tier getter works
static func test_kills_to_next_tier() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	# Wood tier needs 50 kills
	var kills_needed = sword.get_kills_to_next_tier()
	sword.on_enemy_killed()
	var kills_after_one = sword.get_kills_to_next_tier()

	var result = kills_needed == 50 and kills_after_one == 49
	sword.queue_free()
	return result

# Test: Diamond sword returns -1 for kills to next tier
static func test_diamond_no_next_tier() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	sword.set_tier(SwordBase.Tier.DIVINE)
	var result = sword.get_kills_to_next_tier() == -1
	sword.queue_free()
	return result

# Test: Full evolution path Wood -> Stone -> Iron -> Diamond
static func test_full_evolution_path() -> bool:
	var sword = get_sword_instance()
	if not sword:
		return false

	# Start at Wood
	if sword.current_tier != SwordBase.Tier.IRON_BLADE:
		sword.queue_free()
		return false

	# Evolve to Stone (50 kills)
	for i in range(50):
		sword.on_enemy_killed()
	if sword.current_tier != SwordBase.Tier.STEEL_BLADE:
		sword.queue_free()
		return false

	# Evolve to Iron (150 more kills)
	for i in range(150):
		sword.on_enemy_killed()
	if sword.current_tier != SwordBase.Tier.FINE_STEEL:
		sword.queue_free()
		return false

	# Evolve to Diamond (400 more kills)
	for i in range(400):
		sword.on_enemy_killed()
	if sword.current_tier != SwordBase.Tier.DIVINE:
		sword.queue_free()
		return false

	sword.queue_free()
	return true
