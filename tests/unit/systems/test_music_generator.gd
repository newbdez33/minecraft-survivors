extends Node
class_name TestMusicGenerator
## MusicGenerator unit tests - procedural ambient music generation

const MusicGeneratorClass = preload("res://scripts/systems/music_generator.gd")

static func get_test_name() -> String:
	return "Music Generator Tests"

static func run_tests() -> Dictionary:
	var results = {"passed": 0, "failed": 0, "tests": []}

	# Constants
	_add_result(results, test_sample_rate())
	_add_result(results, test_loop_duration())
	_add_result(results, test_scales_defined())

	# Generation
	_add_result(results, test_generate_plains_track())
	_add_result(results, test_generate_desert_track())
	_add_result(results, test_generate_snow_track())
	_add_result(results, test_generate_swamp_track())

	# Stream properties
	_add_result(results, test_stream_format())
	_add_result(results, test_stream_loops())
	_add_result(results, test_stream_data_length())

	# Determinism
	_add_result(results, test_different_biomes_differ())
	_add_result(results, test_same_biome_same_data())

	return results

static func _add_result(results: Dictionary, test_result: Dictionary) -> void:
	results.tests.append(test_result)
	if test_result.passed:
		results.passed += 1
	else:
		results.failed += 1

# --- Tests ---

static func test_sample_rate() -> Dictionary:
	return {"name": "Sample rate is 22050", "passed": MusicGeneratorClass.SAMPLE_RATE == 22050}

static func test_loop_duration() -> Dictionary:
	return {"name": "Loop duration is 12 seconds", "passed": MusicGeneratorClass.LOOP_DURATION == 12.0}

static func test_scales_defined() -> Dictionary:
	var passed = (
		MusicGeneratorClass.PLAINS_SCALE.size() == 5
		and MusicGeneratorClass.DESERT_SCALE.size() == 5
		and MusicGeneratorClass.SNOW_SCALE.size() == 5
		and MusicGeneratorClass.SWAMP_SCALE.size() == 5
	)
	return {"name": "All 4 biome scales have 5 notes (pentatonic)", "passed": passed}

static func test_generate_plains_track() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(0)
	return {"name": "Plains track generates an AudioStreamWAV", "passed": stream != null and stream is AudioStreamWAV}

static func test_generate_desert_track() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(1)
	return {"name": "Desert track generates an AudioStreamWAV", "passed": stream != null and stream is AudioStreamWAV}

static func test_generate_snow_track() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(2)
	return {"name": "Snow track generates an AudioStreamWAV", "passed": stream != null and stream is AudioStreamWAV}

static func test_generate_swamp_track() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(3)
	return {"name": "Swamp track generates an AudioStreamWAV", "passed": stream != null and stream is AudioStreamWAV}

static func test_stream_format() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(0)
	var passed = (
		stream.format == AudioStreamWAV.FORMAT_16_BITS
		and stream.mix_rate == 22050
		and stream.stereo == false
	)
	return {"name": "Stream format is 16-bit mono at 22050 Hz", "passed": passed}

static func test_stream_loops() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(0)
	var passed = (
		stream.loop_mode == AudioStreamWAV.LOOP_FORWARD
		and stream.loop_begin == 0
		and stream.loop_end == MusicGeneratorClass.TOTAL_SAMPLES
	)
	return {"name": "Stream has forward loop set to full duration", "passed": passed}

static func test_stream_data_length() -> Dictionary:
	var stream = MusicGeneratorClass.generate_biome_track(0)
	var expected_bytes = MusicGeneratorClass.TOTAL_SAMPLES * 2  # 16-bit = 2 bytes per sample
	return {"name": "Stream data length matches 12s at 22050 Hz", "passed": stream.data.size() == expected_bytes}

static func test_different_biomes_differ() -> Dictionary:
	var plains = MusicGeneratorClass.generate_biome_track(0)
	var desert = MusicGeneratorClass.generate_biome_track(1)
	# Compare first 100 bytes - different biomes should produce different audio
	var differ = false
	for i in range(min(100, plains.data.size())):
		if plains.data[i] != desert.data[i]:
			differ = true
			break
	return {"name": "Different biomes generate different audio data", "passed": differ}

static func test_same_biome_same_data() -> Dictionary:
	var stream1 = MusicGeneratorClass.generate_biome_track(0)
	var stream2 = MusicGeneratorClass.generate_biome_track(0)
	# Since generation is deterministic (no randf), same biome should produce same data
	var same = true
	# Check first 200 bytes
	for i in range(min(200, stream1.data.size())):
		if stream1.data[i] != stream2.data[i]:
			same = false
			break
	return {"name": "Same biome generates identical audio data (deterministic)", "passed": same}
