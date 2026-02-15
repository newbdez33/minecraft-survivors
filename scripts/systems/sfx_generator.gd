extends RefCounted
## Procedural 8-bit sound generator using AudioStreamWAV
## Generates retro chiptune sounds for UI, pickups, and simple effects

enum WaveType { SQUARE, SAWTOOTH, TRIANGLE, NOISE }

const SAMPLE_RATE: int = 22050
const MIX_RATE: int = 22050

## Generate a procedural sound and return an AudioStreamWAV
static func generate(config: Dictionary) -> AudioStreamWAV:
	var wave_type: int = config.get("wave_type", WaveType.SQUARE)
	var frequency: float = config.get("frequency", 440.0)
	var duration: float = config.get("duration", 0.1)
	var volume: float = config.get("volume", 0.5)
	var attack: float = config.get("attack", 0.01)
	var decay: float = config.get("decay", 0.05)
	var freq_end: float = config.get("freq_end", frequency)
	var duty_cycle: float = config.get("duty_cycle", 0.5)

	var sample_count: int = int(duration * SAMPLE_RATE)
	if sample_count <= 0:
		sample_count = 1

	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)

	var phase: float = 0.0
	var current_freq: float = frequency

	for i in range(sample_count):
		var t: float = float(i) / float(sample_count)

		# Frequency slide from start to end
		if freq_end != frequency:
			current_freq = lerpf(frequency, freq_end, t)

		# Envelope (attack-decay)
		var envelope: float = 1.0
		var attack_samples: float = attack * SAMPLE_RATE
		var decay_start: float = 1.0 - decay / duration
		if i < attack_samples and attack_samples > 0:
			envelope = float(i) / attack_samples
		elif t > decay_start:
			envelope = 1.0 - (t - decay_start) / (1.0 - decay_start)
		envelope = clampf(envelope, 0.0, 1.0)

		# Generate waveform
		var sample_value: float = _generate_sample(wave_type, phase, duty_cycle)
		sample_value *= envelope * volume

		# Convert to 16-bit signed integer
		var sample_int: int = clampi(int(sample_value * 32767.0), -32768, 32767)
		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF

		# Advance phase
		phase += current_freq / float(SAMPLE_RATE)
		if phase >= 1.0:
			phase -= 1.0

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


static func _generate_sample(wave_type: int, phase: float, duty_cycle: float) -> float:
	match wave_type:
		WaveType.SQUARE:
			return 1.0 if phase < duty_cycle else -1.0
		WaveType.SAWTOOTH:
			return 2.0 * phase - 1.0
		WaveType.TRIANGLE:
			if phase < 0.5:
				return 4.0 * phase - 1.0
			else:
				return 3.0 - 4.0 * phase
		WaveType.NOISE:
			return randf_range(-1.0, 1.0)
		_:
			return 0.0


## Concatenate multiple note AudioStreamWAVs into a single stream
static func _concatenate_notes(note_streams: Array) -> AudioStreamWAV:
	var combined_data: PackedByteArray = PackedByteArray()
	for note: AudioStreamWAV in note_streams:
		combined_data.append_array(note.data)

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = combined_data
	return stream


## Helper to generate a sequence of notes and concatenate them
static func _generate_sequence(notes: Array[float], config: Dictionary) -> AudioStreamWAV:
	var note_streams: Array = []
	for freq in notes:
		var note_config: Dictionary = config.duplicate()
		note_config["frequency"] = freq
		note_streams.append(generate(note_config))
	return _concatenate_notes(note_streams)


# --- Single-note Presets ---

## Preset: XP collect blip - short ascending chiptune
static func xp_collect() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 880.0,
		"freq_end": 1760.0,
		"duration": 0.08,
		"volume": 0.3,
		"attack": 0.005,
		"decay": 0.03,
		"duty_cycle": 0.25
	})


## Preset: Button click - very short square blip
static func button_click() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 660.0,
		"freq_end": 440.0,
		"duration": 0.04,
		"volume": 0.25,
		"attack": 0.002,
		"decay": 0.02,
		"duty_cycle": 0.5
	})


## Preset: Poison tick - low buzzy tone
static func poison_tick() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 110.0,
		"freq_end": 90.0,
		"duration": 0.15,
		"volume": 0.2,
		"attack": 0.01,
		"decay": 0.08
	})


## Preset: Player death - descending sad tone
static func player_death() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 440.0,
		"freq_end": 110.0,
		"duration": 0.6,
		"volume": 0.4,
		"attack": 0.01,
		"decay": 0.3
	})


## Preset: Player take damage - short hurt blip
static func take_damage() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.NOISE,
		"frequency": 200.0,
		"freq_end": 100.0,
		"duration": 0.12,
		"volume": 0.3,
		"attack": 0.005,
		"decay": 0.06
	})


## Preset: Heal sound - gentle ascending tone
static func heal() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 440.0,
		"freq_end": 880.0,
		"duration": 0.2,
		"volume": 0.3,
		"attack": 0.01,
		"decay": 0.1
	})


## Preset: Sword hit - sharp attack
static func sword_hit() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.NOISE,
		"frequency": 400.0,
		"freq_end": 150.0,
		"duration": 0.08,
		"volume": 0.35,
		"attack": 0.002,
		"decay": 0.04
	})


## Preset: Bow shot - twang sound
static func bow_shot() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 880.0,
		"freq_end": 220.0,
		"duration": 0.1,
		"volume": 0.3,
		"attack": 0.002,
		"decay": 0.06
	})


## Preset: Arrow hit impact
static func arrow_hit() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.NOISE,
		"frequency": 300.0,
		"freq_end": 100.0,
		"duration": 0.06,
		"volume": 0.25,
		"attack": 0.002,
		"decay": 0.03
	})


## Preset: Crossbow shot - deeper twang
static func crossbow_shot() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 660.0,
		"freq_end": 165.0,
		"duration": 0.12,
		"volume": 0.3,
		"attack": 0.002,
		"decay": 0.07
	})


## Preset: Enemy hit reaction
static func enemy_hit() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 300.0,
		"freq_end": 150.0,
		"duration": 0.06,
		"volume": 0.2,
		"attack": 0.002,
		"decay": 0.03,
		"duty_cycle": 0.25
	})


## Preset: Enemy death - short descending pop
static func enemy_death() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 440.0,
		"freq_end": 110.0,
		"duration": 0.15,
		"volume": 0.25,
		"attack": 0.005,
		"decay": 0.08,
		"duty_cycle": 0.5
	})


## Preset: Creeper explosion - heavy noise burst
static func creeper_explosion() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.NOISE,
		"frequency": 150.0,
		"freq_end": 40.0,
		"duration": 0.4,
		"volume": 0.6,
		"attack": 0.005,
		"decay": 0.25
	})


## Preset: Skeleton arrow shot
static func skeleton_arrow() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 660.0,
		"freq_end": 330.0,
		"duration": 0.08,
		"volume": 0.25,
		"attack": 0.002,
		"decay": 0.04
	})


## Preset: Witch poison throw - bubbly
static func witch_poison_throw() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 330.0,
		"freq_end": 660.0,
		"duration": 0.15,
		"volume": 0.25,
		"attack": 0.01,
		"decay": 0.08
	})


## Preset: Enderman teleport - eerie warble
static func enderman_teleport() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 1200.0,
		"freq_end": 200.0,
		"duration": 0.25,
		"volume": 0.3,
		"attack": 0.005,
		"decay": 0.15,
		"duty_cycle": 0.15
	})


## Preset: Spider jump - quick chirp
static func spider_jump() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": 200.0,
		"freq_end": 600.0,
		"duration": 0.1,
		"volume": 0.25,
		"attack": 0.005,
		"decay": 0.05,
		"duty_cycle": 0.3
	})


## Preset: Boss appear - deep ominous rumble
static func boss_appear() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 80.0,
		"freq_end": 60.0,
		"duration": 0.8,
		"volume": 0.5,
		"attack": 0.05,
		"decay": 0.4
	})


## Preset: Boss attack - heavy impact slam
static func boss_attack() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.SAWTOOTH,
		"frequency": 120.0,
		"freq_end": 50.0,
		"duration": 0.4,
		"volume": 0.55,
		"attack": 0.01,
		"decay": 0.25
	})


## Preset: Meat collect - softer pickup
static func meat_collect() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 523.0,
		"freq_end": 784.0,
		"duration": 0.1,
		"volume": 0.25,
		"attack": 0.005,
		"decay": 0.05
	})


## Preset: Night transition - eerie descending
static func night_transition() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 440.0,
		"freq_end": 220.0,
		"duration": 0.5,
		"volume": 0.25,
		"attack": 0.05,
		"decay": 0.3
	})


# --- Multi-note Sequence Presets ---

## Preset: Combo milestone - ascending arpeggio chime
static func combo_milestone() -> AudioStreamWAV:
	return _generate_sequence(
		[523.0, 659.0, 784.0, 1047.0],  # C5, E5, G5, C6
		{"wave_type": WaveType.TRIANGLE, "duration": 0.08, "volume": 0.35, "attack": 0.005, "decay": 0.04}
	)


## Preset: Player level up - triumphant ascending fanfare
static func level_up() -> AudioStreamWAV:
	return _generate_sequence(
		[523.0, 659.0, 784.0, 1047.0, 1319.0],  # C5-E6
		{"wave_type": WaveType.SQUARE, "duration": 0.1, "volume": 0.35, "attack": 0.005, "decay": 0.05, "duty_cycle": 0.25}
	)


## Preset: Sword evolve - epic ascending with glow
static func sword_evolve() -> AudioStreamWAV:
	return _generate_sequence(
		[262.0, 330.0, 392.0, 523.0, 659.0, 784.0, 1047.0],
		{"wave_type": WaveType.TRIANGLE, "duration": 0.1, "volume": 0.35, "attack": 0.005, "decay": 0.05}
	)


## Preset: Health collect (golden apple) - sparkle
static func health_collect() -> AudioStreamWAV:
	return _generate_sequence(
		[784.0, 988.0, 1175.0],  # G5, B5, D6
		{"wave_type": WaveType.TRIANGLE, "duration": 0.06, "volume": 0.3, "attack": 0.003, "decay": 0.03}
	)


## Preset: Upgrade select - satisfying confirm
static func upgrade_select() -> AudioStreamWAV:
	return _generate_sequence(
		[523.0, 784.0],  # C5, G5
		{"wave_type": WaveType.SQUARE, "duration": 0.08, "volume": 0.3, "attack": 0.003, "decay": 0.04, "duty_cycle": 0.25}
	)


## Preset: Game over - dramatic descending
static func game_over() -> AudioStreamWAV:
	return _generate_sequence(
		[523.0, 440.0, 349.0, 262.0, 196.0],  # C5 down to G3
		{"wave_type": WaveType.SAWTOOTH, "duration": 0.15, "volume": 0.35, "attack": 0.005, "decay": 0.08}
	)


## Preset: Wave start - alert horn
static func wave_start() -> AudioStreamWAV:
	# Custom durations per note, so build manually
	var note_streams: Array = []
	var notes: Array[float] = [392.0, 392.0, 523.0]  # G4, G4, C5
	for i in range(notes.size()):
		var dur: float = 0.12 if i < 2 else 0.2
		note_streams.append(generate({
			"wave_type": WaveType.SQUARE,
			"frequency": notes[i],
			"duration": dur,
			"volume": 0.35,
			"attack": 0.005,
			"decay": dur * 0.4,
			"duty_cycle": 0.5
		}))
	return _concatenate_notes(note_streams)


## Preset: Achievement unlock - fanfare
static func achievement_unlock() -> AudioStreamWAV:
	return _generate_sequence(
		[523.0, 659.0, 784.0, 1047.0, 784.0, 1047.0],
		{"wave_type": WaveType.SQUARE, "duration": 0.08, "volume": 0.3, "attack": 0.003, "decay": 0.04, "duty_cycle": 0.25}
	)


## Preset: Elite spawn - ascending triangle wave, ominous power-up
static func elite_spawn() -> AudioStreamWAV:
	return generate({
		"wave_type": WaveType.TRIANGLE,
		"frequency": 400.0,
		"freq_end": 800.0,
		"duration": 0.3,
		"volume": 0.4,
		"attack": 0.01,
		"decay": 0.15
	})


## Generate XP collect sound at a specific pitch index (0-7 for C-C octave)
static func xp_collect_pitched(pitch_index: int) -> AudioStreamWAV:
	# C major scale: C5, D5, E5, F5, G5, A5, B5, C6
	var scale: Array[float] = [523.0, 587.0, 659.0, 698.0, 784.0, 880.0, 988.0, 1047.0]
	var idx: int = clampi(pitch_index, 0, scale.size() - 1)
	return generate({
		"wave_type": WaveType.SQUARE,
		"frequency": scale[idx],
		"freq_end": scale[idx] * 1.2,
		"duration": 0.06,
		"volume": 0.25,
		"attack": 0.003,
		"decay": 0.025,
		"duty_cycle": 0.25
	})
