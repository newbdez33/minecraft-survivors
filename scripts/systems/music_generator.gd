extends RefCounted
## Procedural ambient music generator
## Creates 12-second looping AudioStreamWAV tracks per biome
## Uses triangle/square waves + noise for Three Kingdoms-inspired ambient feel

const SAMPLE_RATE: int = 22050
const LOOP_DURATION: float = 12.0
const TOTAL_SAMPLES: int = SAMPLE_RATE * 12  # 264600

# BPM and note timing
const BPM: float = 60.0
const BEAT_DURATION: float = 60.0 / BPM  # 1.0 second per beat
const NOTE_DURATION: float = 0.4  # Each note sustain
const NOTE_SAMPLES: int = int(NOTE_DURATION * SAMPLE_RATE)

# Pentatonic scales per biome (frequencies in Hz)
# Plains: C major pentatonic (C4, D4, E4, G4, A4)
const PLAINS_SCALE: Array = [261.6, 293.7, 329.6, 392.0, 440.0]
# Desert: D minor pentatonic (D4, F4, G4, A4, C5)
const DESERT_SCALE: Array = [293.7, 349.2, 392.0, 440.0, 523.3]
# Snow: E minor pentatonic (E4, G4, A4, B4, D5)
const SNOW_SCALE: Array = [329.6, 392.0, 440.0, 493.9, 587.3]
# Swamp: A minor pentatonic (A3, C4, D4, E4, G4)
const SWAMP_SCALE: Array = [220.0, 261.6, 293.7, 329.6, 392.0]

# Bass drone frequencies (root note, one octave down)
const PLAINS_BASS: float = 130.8  # C3
const DESERT_BASS: float = 146.8  # D3
const SNOW_BASS: float = 164.8   # E3
const SWAMP_BASS: float = 110.0  # A2

# Volume levels
const BASS_VOLUME: float = 0.08
const MELODY_VOLUME: float = 0.06
const TEXTURE_VOLUME: float = 0.02


## Generate a looping ambient track for a given biome
## biome: BiomeManager.Biome enum value (0=Plains, 1=Desert, 2=Snow, 3=Swamp)
static func generate_biome_track(biome: int) -> AudioStreamWAV:
	var scale: Array = _get_scale(biome)
	var bass_freq: float = _get_bass_freq(biome)

	var data: PackedByteArray = PackedByteArray()
	data.resize(TOTAL_SAMPLES * 2)  # 16-bit = 2 bytes per sample

	# Seed for deterministic melody per biome
	var melody_seed: int = biome * 12345 + 67890

	# Generate each sample
	var bass_phase: float = 0.0
	var melody_phase: float = 0.0
	var current_melody_freq: float = scale[0]
	var note_counter: int = 0
	var beat_sample_count: int = int(BEAT_DURATION * SAMPLE_RATE)

	for i in range(TOTAL_SAMPLES):
		var sample: float = 0.0

		# Layer 1: Bass drone (triangle wave, continuous)
		sample += _triangle(bass_phase) * BASS_VOLUME

		# Layer 2: Melody (triangle wave, sparse notes ~45% probability)
		# Change note every beat
		if i > 0 and i % beat_sample_count == 0:
			note_counter += 1
			# Deterministic pseudo-random note selection
			var note_hash: int = (melody_seed + note_counter * 374761393)
			if note_hash < 0:
				note_hash = -note_hash
			var note_prob: int = note_hash % 100
			if note_prob < 45:
				# Pick a note from the scale
				var note_idx: int = (note_hash / 100) % scale.size()
				current_melody_freq = scale[note_idx]
			else:
				# Silence (rest)
				current_melody_freq = 0.0

		if current_melody_freq > 0.0:
			# Apply note envelope (fade in/out within beat)
			var beat_pos: int = i % beat_sample_count
			var beat_t: float = float(beat_pos) / float(beat_sample_count)
			var envelope: float = 1.0
			if beat_t < 0.05:
				envelope = beat_t / 0.05  # Attack
			elif beat_t > 0.6:
				envelope = (1.0 - beat_t) / 0.4  # Release
			envelope = clampf(envelope, 0.0, 1.0)

			var wave_type: float = _triangle(melody_phase) if biome != 1 else _square(melody_phase, 0.25)
			sample += wave_type * MELODY_VOLUME * envelope

		# Layer 3: Noise texture (very quiet ambient hiss, biome-colored)
		var noise_val: float = _deterministic_noise(i, biome)
		sample += noise_val * TEXTURE_VOLUME

		# Clamp and convert to 16-bit
		sample = clampf(sample, -1.0, 1.0)
		var sample_int: int = clampi(int(sample * 32767.0), -32768, 32767)
		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF

		# Advance phases
		bass_phase += bass_freq / float(SAMPLE_RATE)
		if bass_phase >= 1.0:
			bass_phase -= 1.0

		if current_melody_freq > 0.0:
			melody_phase += current_melody_freq / float(SAMPLE_RATE)
			if melody_phase >= 1.0:
				melody_phase -= 1.0
		else:
			melody_phase = 0.0

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = TOTAL_SAMPLES
	return stream


static func _get_scale(biome: int) -> Array:
	match biome:
		0: return PLAINS_SCALE
		1: return DESERT_SCALE
		2: return SNOW_SCALE
		3: return SWAMP_SCALE
		_: return PLAINS_SCALE


static func _get_bass_freq(biome: int) -> float:
	match biome:
		0: return PLAINS_BASS
		1: return DESERT_BASS
		2: return SNOW_BASS
		3: return SWAMP_BASS
		_: return PLAINS_BASS


static func _triangle(phase: float) -> float:
	if phase < 0.5:
		return 4.0 * phase - 1.0
	else:
		return 3.0 - 4.0 * phase


static func _square(phase: float, duty: float) -> float:
	return 1.0 if phase < duty else -1.0


## Deterministic noise that sounds slightly different per biome
static func _deterministic_noise(sample_idx: int, biome: int) -> float:
	var h: int = sample_idx * 1103515245 + biome * 12345 + 1013904223
	if h < 0:
		h = -h
	return float(h % 2001 - 1000) / 1000.0
