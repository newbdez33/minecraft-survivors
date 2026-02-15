extends Node
class_name TestBiomeManager
## BiomeManager unit tests - zone math, tile selection, transitions

const BiomeManagerClass = preload("res://scripts/systems/biome_manager.gd")

static func get_test_name() -> String:
	return "Biome Manager Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Core enum/constants
	_add_result(results, test_biome_enum_values())
	_add_result(results, test_radius_constants())
	_add_result(results, test_tile_paths_defined())

	# get_primary_biome tests
	_add_result(results, test_origin_is_plains())
	_add_result(results, test_inner_radius_is_plains())
	_add_result(results, test_east_is_desert())
	_add_result(results, test_north_is_snow())
	_add_result(results, test_west_is_swamp())
	_add_result(results, test_south_is_swamp())

	# get_tile_biome tests (transition zone)
	_add_result(results, test_tile_biome_inner_is_plains())
	_add_result(results, test_tile_biome_outer_is_target())
	_add_result(results, test_tile_biome_transition_deterministic())

	# get_tile_variant tests
	_add_result(results, test_variant_range())
	_add_result(results, test_variant_deterministic())

	# biome_name tests
	_add_result(results, test_biome_names())

	# _tile_hash determinism
	_add_result(results, test_tile_hash_deterministic())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# --- Tests ---

static func test_biome_enum_values() -> Dictionary:
	var passed = (
		BiomeManagerClass.Biome.PLAINS == 0
		and BiomeManagerClass.Biome.DESERT == 1
		and BiomeManagerClass.Biome.SNOW == 2
		and BiomeManagerClass.Biome.SWAMP == 3
	)
	return {"name": "Biome enum has correct values (PLAINS=0, DESERT=1, SNOW=2, SWAMP=3)", "passed": passed}

static func test_radius_constants() -> Dictionary:
	var passed = (
		BiomeManagerClass.INNER_RADIUS == 800.0
		and BiomeManagerClass.TRANSITION_WIDTH == 300.0
		and BiomeManagerClass.OUTER_RADIUS == 1100.0
	)
	return {"name": "Radius constants are correct (800/300/1100)", "passed": passed}

static func test_tile_paths_defined() -> Dictionary:
	var passed = (
		BiomeManagerClass.TILE_PATHS.size() == 4
		and BiomeManagerClass.TILE_PATHS[BiomeManagerClass.Biome.PLAINS].size() == 3
		and BiomeManagerClass.TILE_PATHS[BiomeManagerClass.Biome.DESERT].size() == 3
		and BiomeManagerClass.TILE_PATHS[BiomeManagerClass.Biome.SNOW].size() == 3
		and BiomeManagerClass.TILE_PATHS[BiomeManagerClass.Biome.SWAMP].size() == 3
	)
	return {"name": "Tile paths defined for all 4 biomes with 3 variants each", "passed": passed}

static func test_origin_is_plains() -> Dictionary:
	var biome = BiomeManagerClass.get_primary_biome(Vector2.ZERO)
	return {"name": "Origin (0,0) is Plains", "passed": biome == BiomeManagerClass.Biome.PLAINS}

static func test_inner_radius_is_plains() -> Dictionary:
	# Test at 799px in various directions - should all be Plains
	var east = BiomeManagerClass.get_primary_biome(Vector2(799, 0))
	var south = BiomeManagerClass.get_primary_biome(Vector2(0, 799))
	var west = BiomeManagerClass.get_primary_biome(Vector2(-799, 0))
	var north = BiomeManagerClass.get_primary_biome(Vector2(0, -799))
	var passed = (
		east == BiomeManagerClass.Biome.PLAINS
		and south == BiomeManagerClass.Biome.PLAINS
		and west == BiomeManagerClass.Biome.PLAINS
		and north == BiomeManagerClass.Biome.PLAINS
	)
	return {"name": "All positions within 800px are Plains", "passed": passed}

static func test_east_is_desert() -> Dictionary:
	# East (right, positive x) at 1200px
	var biome = BiomeManagerClass.get_primary_biome(Vector2(1200, 0))
	return {"name": "East (1200, 0) is Desert", "passed": biome == BiomeManagerClass.Biome.DESERT}

static func test_north_is_snow() -> Dictionary:
	# North (screen-up, negative y) at 1200px → Snow (210-330 degrees)
	var biome = BiomeManagerClass.get_primary_biome(Vector2(0, -1200))
	return {"name": "North/up (0, -1200) is Snow", "passed": biome == BiomeManagerClass.Biome.SNOW}

static func test_west_is_swamp() -> Dictionary:
	# West (negative x) at 1200px → Swamp (90-210 degrees, 180°)
	var biome = BiomeManagerClass.get_primary_biome(Vector2(-1200, 0))
	return {"name": "West (-1200, 0) is Swamp", "passed": biome == BiomeManagerClass.Biome.SWAMP}

static func test_south_is_swamp() -> Dictionary:
	# South (screen-down, positive y) at 1200px → Swamp (90-210 degrees, 90°)
	var biome = BiomeManagerClass.get_primary_biome(Vector2(0, 1200))
	return {"name": "South/down (0, 1200) is Swamp", "passed": biome == BiomeManagerClass.Biome.SWAMP}

static func test_tile_biome_inner_is_plains() -> Dictionary:
	# Tile at (5, 5) -> world pos ~(176, 176) -> well within inner radius
	var biome = BiomeManagerClass.get_tile_biome(5, 5)
	return {"name": "Tile within inner radius returns Plains", "passed": biome == BiomeManagerClass.Biome.PLAINS}

static func test_tile_biome_outer_is_target() -> Dictionary:
	# Tile at (40, 0) -> world pos ~(1296, 16) -> beyond outer radius, east
	var biome = BiomeManagerClass.get_tile_biome(40, 0)
	return {"name": "Tile beyond outer radius returns target biome (Desert for east)", "passed": biome == BiomeManagerClass.Biome.DESERT}

static func test_tile_biome_transition_deterministic() -> Dictionary:
	# Same tile coords should always return the same biome
	var biome1 = BiomeManagerClass.get_tile_biome(28, 2)
	var biome2 = BiomeManagerClass.get_tile_biome(28, 2)
	return {"name": "Tile biome in transition zone is deterministic", "passed": biome1 == biome2}

static func test_variant_range() -> Dictionary:
	# Test many tiles - all variants should be 0, 1, or 2
	var all_valid = true
	for tx in range(50):
		for ty in range(50):
			var v = BiomeManagerClass.get_tile_variant(tx, ty)
			if v < 0 or v > 2:
				all_valid = false
				break
	return {"name": "All tile variants are in range 0-2", "passed": all_valid}

static func test_variant_deterministic() -> Dictionary:
	var v1 = BiomeManagerClass.get_tile_variant(123, 456)
	var v2 = BiomeManagerClass.get_tile_variant(123, 456)
	return {"name": "Tile variant is deterministic for same coordinates", "passed": v1 == v2}

static func test_biome_names() -> Dictionary:
	var passed = (
		BiomeManagerClass.biome_name(BiomeManagerClass.Biome.PLAINS) == "Plains"
		and BiomeManagerClass.biome_name(BiomeManagerClass.Biome.DESERT) == "Desert"
		and BiomeManagerClass.biome_name(BiomeManagerClass.Biome.SNOW) == "Snow"
		and BiomeManagerClass.biome_name(BiomeManagerClass.Biome.SWAMP) == "Swamp"
		and BiomeManagerClass.biome_name(99) == "Unknown"
	)
	return {"name": "biome_name() returns correct strings for all biomes", "passed": passed}

static func test_tile_hash_deterministic() -> Dictionary:
	var h1 = BiomeManagerClass._tile_hash(42, 77)
	var h2 = BiomeManagerClass._tile_hash(42, 77)
	var h_diff = BiomeManagerClass._tile_hash(42, 78)
	var passed = h1 == h2 and h1 != h_diff
	return {"name": "Tile hash is deterministic and varies with position", "passed": passed}
