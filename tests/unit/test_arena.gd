extends Node
## Unit tests for Arena

class_name TestArena

static func get_arena_instance():
	var script = load("res://scripts/arena.gd")
	if not script:
		return null
	var arena = Node2D.new()
	arena.set_script(script)
	return arena

# Test: Tile variant distribution
static func test_tile_variant_distribution() -> bool:
	var arena = get_arena_instance()
	if not arena:
		return false

	var variant_counts = [0, 0, 0]
	var total_samples = 1000

	# Sample many tiles
	for i in range(total_samples):
		var variant = arena._get_tile_variant(i * 7, i * 13)
		if variant >= 0 and variant <= 2:
			variant_counts[variant] += 1

	# Check distribution is roughly correct (with tolerance)
	# Expected: 70% grass, 15% variant1, 15% variant2
	var grass_pct = float(variant_counts[0]) / total_samples
	var v1_pct = float(variant_counts[1]) / total_samples
	var v2_pct = float(variant_counts[2]) / total_samples

	var grass_ok = grass_pct > 0.60 and grass_pct < 0.80  # 70% ± 10%
	var v1_ok = v1_pct > 0.05 and v1_pct < 0.25  # 15% ± 10%
	var v2_ok = v2_pct > 0.05 and v2_pct < 0.25  # 15% ± 10%

	arena.queue_free()
	return grass_ok and v1_ok and v2_ok

# Test: Tile variant is deterministic (same position = same variant)
static func test_tile_variant_deterministic() -> bool:
	var arena = get_arena_instance()
	if not arena:
		return false

	# Same coordinates should always return same variant
	var variant1 = arena._get_tile_variant(100, 200)
	var variant2 = arena._get_tile_variant(100, 200)
	var variant3 = arena._get_tile_variant(100, 200)

	arena.queue_free()
	return variant1 == variant2 and variant2 == variant3

# Test: Arena has correct tile size
static func test_arena_tile_size() -> bool:
	var arena = get_arena_instance()
	if not arena:
		return false

	# Tile size should be 32 (matching our SVG assets)
	var result = arena.tile_size == 32

	arena.queue_free()
	return result
