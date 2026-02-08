extends Node
## AudioManager singleton - SFX playback, bus control, object pool
## Registered as autoload: AudioManager

const SFXGeneratorClass = preload("res://scripts/systems/sfx_generator.gd")

const SFX_BUS_NAME: String = "SFX"
const MUSIC_BUS_NAME: String = "Music"

const GLOBAL_POOL_SIZE: int = 8
const POSITIONAL_POOL_SIZE: int = 16

# XP orb throttle settings
const XP_MAX_PER_SECOND: int = 20
const XP_PITCH_RESET_TIME: float = 0.5  # Reset pitch index after gap

# Round-robin pools
var _global_pool: Array[AudioStreamPlayer] = []
var _global_index: int = 0
var _positional_pool: Array[AudioStreamPlayer2D] = []
var _positional_index: int = 0

# Sound cache (lazy loaded)
var _sound_cache: Dictionary = {}

# XP orb state
var _xp_count_this_second: int = 0
var _xp_timer: float = 0.0
var _xp_pitch_index: int = 0
var _xp_last_play_time: float = 0.0

# Pitch randomization per sound
var _pitch_variance: Dictionary = {
	"sword_hit": 0.15,
	"enemy_hit": 0.2,
	"enemy_death": 0.15,
	"xp_orb": 0.0,  # Uses ascending pitch instead
	"skeleton_arrow": 0.1,
	"spider_jump": 0.15,
	"creeper_explosion": 0.05,
}

# Volume adjustments per sound (relative dB offset)
var _volume_db: Dictionary = {
	"creeper_explosion": 3.0,
	"boss_appear": 2.0,
	"player_death": 2.0,
	"wave_start": 1.0,
	"xp_orb": -4.0,
	"enemy_hit": -3.0,
	"enemy_death": -2.0,
	"button_click": -2.0,
}


func _ready() -> void:
	_setup_audio_buses()
	_create_global_pool()
	_create_positional_pool()
	_precache_procedural_sounds()


func _process(delta: float) -> void:
	# Reset XP throttle counter each second
	_xp_timer += delta
	if _xp_timer >= 1.0:
		_xp_timer -= 1.0
		_xp_count_this_second = 0

	# Reset XP pitch index after silence gap
	var time_now: float = Time.get_ticks_msec() / 1000.0
	if time_now - _xp_last_play_time > XP_PITCH_RESET_TIME:
		_xp_pitch_index = 0


## Setup audio bus layout: Master -> SFX, Music
func _setup_audio_buses() -> void:
	# Check if buses already exist
	if AudioServer.get_bus_index(SFX_BUS_NAME) == -1:
		var sfx_idx: int = AudioServer.bus_count
		AudioServer.add_bus(sfx_idx)
		AudioServer.set_bus_name(sfx_idx, SFX_BUS_NAME)
		AudioServer.set_bus_send(sfx_idx, "Master")

	if AudioServer.get_bus_index(MUSIC_BUS_NAME) == -1:
		var music_idx: int = AudioServer.bus_count
		AudioServer.add_bus(music_idx)
		AudioServer.set_bus_name(music_idx, MUSIC_BUS_NAME)
		AudioServer.set_bus_send(music_idx, "Master")

	# Load saved volume settings
	_load_volume_settings()


## Create pool of global AudioStreamPlayers (UI, non-positional sounds)
func _create_global_pool() -> void:
	for i in range(GLOBAL_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "GlobalSFX_%d" % i
		player.bus = SFX_BUS_NAME
		add_child(player)
		_global_pool.append(player)


## Create pool of positional AudioStreamPlayer2Ds (combat, world sounds)
func _create_positional_pool() -> void:
	for i in range(POSITIONAL_POOL_SIZE):
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.name = "PositionalSFX_%d" % i
		player.bus = SFX_BUS_NAME
		player.max_distance = 800.0
		player.attenuation = 1.5
		add_child(player)
		_positional_pool.append(player)


## Pre-generate all procedural sounds and cache them
func _precache_procedural_sounds() -> void:
	_sound_cache["xp_orb"] = SFXGeneratorClass.xp_collect()
	_sound_cache["button_click"] = SFXGeneratorClass.button_click()
	_sound_cache["poison_tick"] = SFXGeneratorClass.poison_tick()
	_sound_cache["combo_milestone"] = SFXGeneratorClass.combo_milestone()
	_sound_cache["player_level_up"] = SFXGeneratorClass.level_up()
	_sound_cache["player_death"] = SFXGeneratorClass.player_death()
	_sound_cache["player_take_damage"] = SFXGeneratorClass.take_damage()
	_sound_cache["player_heal"] = SFXGeneratorClass.heal()
	_sound_cache["sword_hit"] = SFXGeneratorClass.sword_hit()
	_sound_cache["sword_evolve"] = SFXGeneratorClass.sword_evolve()
	_sound_cache["bow_shot"] = SFXGeneratorClass.bow_shot()
	_sound_cache["arrow_hit"] = SFXGeneratorClass.arrow_hit()
	_sound_cache["crossbow_shot"] = SFXGeneratorClass.crossbow_shot()
	_sound_cache["enemy_hit"] = SFXGeneratorClass.enemy_hit()
	_sound_cache["enemy_death"] = SFXGeneratorClass.enemy_death()
	_sound_cache["creeper_explosion"] = SFXGeneratorClass.creeper_explosion()
	_sound_cache["skeleton_arrow"] = SFXGeneratorClass.skeleton_arrow()
	_sound_cache["witch_poison_throw"] = SFXGeneratorClass.witch_poison_throw()
	_sound_cache["enderman_teleport"] = SFXGeneratorClass.enderman_teleport()
	_sound_cache["spider_jump"] = SFXGeneratorClass.spider_jump()
	_sound_cache["boss_appear"] = SFXGeneratorClass.boss_appear()
	_sound_cache["boss_attack"] = SFXGeneratorClass.boss_attack()
	_sound_cache["health_collect"] = SFXGeneratorClass.health_collect()
	_sound_cache["meat_collect"] = SFXGeneratorClass.meat_collect()
	_sound_cache["upgrade_select"] = SFXGeneratorClass.upgrade_select()
	_sound_cache["game_over"] = SFXGeneratorClass.game_over()
	_sound_cache["wave_start"] = SFXGeneratorClass.wave_start()
	_sound_cache["night_transition"] = SFXGeneratorClass.night_transition()
	_sound_cache["achievement_unlock"] = SFXGeneratorClass.achievement_unlock()
	_sound_cache["poison_applied"] = SFXGeneratorClass.poison_tick()

	# Pre-generate XP pitched sounds
	for i in range(8):
		_sound_cache["xp_orb_%d" % i] = SFXGeneratorClass.xp_collect_pitched(i)


## Play a global (non-positional) sound effect
func play_sfx(sfx_name: String) -> void:
	if sfx_name == "xp_orb":
		_play_xp_orb()
		return

	var stream: AudioStream = _get_sound(sfx_name)
	if not stream:
		return

	var player: AudioStreamPlayer = _get_next_global_player()
	player.stream = stream
	player.volume_db = _volume_db.get(sfx_name, 0.0)
	player.pitch_scale = _get_pitch(sfx_name)
	player.play()


## Play a positional sound effect at a world position
func play_sfx_at(sfx_name: String, world_position: Vector2) -> void:
	if sfx_name == "xp_orb":
		_play_xp_orb_at(world_position)
		return

	var stream: AudioStream = _get_sound(sfx_name)
	if not stream:
		return

	var player: AudioStreamPlayer2D = _get_next_positional_player()
	player.stream = stream
	player.global_position = world_position
	player.volume_db = _volume_db.get(sfx_name, 0.0)
	player.pitch_scale = _get_pitch(sfx_name)
	player.play()


## Set SFX bus volume (0.0 to 1.0)
func set_sfx_volume(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(SFX_BUS_NAME)
	if bus_idx >= 0:
		if value <= 0.01:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


## Set Music bus volume (0.0 to 1.0)
func set_music_volume(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if bus_idx >= 0:
		if value <= 0.01:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


## Get SFX volume (0.0 to 1.0)
func get_sfx_volume() -> float:
	var bus_idx: int = AudioServer.get_bus_index(SFX_BUS_NAME)
	if bus_idx >= 0 and not AudioServer.is_bus_mute(bus_idx):
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0


## Get Music volume (0.0 to 1.0)
func get_music_volume() -> float:
	var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if bus_idx >= 0 and not AudioServer.is_bus_mute(bus_idx):
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0


## XP orb with throttle and ascending pitch scale
func _play_xp_orb() -> void:
	if _xp_count_this_second >= XP_MAX_PER_SECOND:
		return

	_xp_count_this_second += 1
	var time_now: float = Time.get_ticks_msec() / 1000.0
	_xp_last_play_time = time_now

	var pitched_name: String = "xp_orb_%d" % _xp_pitch_index
	var stream: AudioStream = _get_sound(pitched_name)
	if not stream:
		stream = _get_sound("xp_orb")
	if not stream:
		return

	var player: AudioStreamPlayer = _get_next_global_player()
	player.stream = stream
	player.volume_db = _volume_db.get("xp_orb", -4.0)
	player.pitch_scale = 1.0
	player.play()

	_xp_pitch_index = (_xp_pitch_index + 1) % 8


## XP orb positional variant
func _play_xp_orb_at(world_position: Vector2) -> void:
	if _xp_count_this_second >= XP_MAX_PER_SECOND:
		return

	_xp_count_this_second += 1
	var time_now: float = Time.get_ticks_msec() / 1000.0
	_xp_last_play_time = time_now

	var pitched_name: String = "xp_orb_%d" % _xp_pitch_index
	var stream: AudioStream = _get_sound(pitched_name)
	if not stream:
		stream = _get_sound("xp_orb")
	if not stream:
		return

	var player: AudioStreamPlayer2D = _get_next_positional_player()
	player.stream = stream
	player.global_position = world_position
	player.volume_db = _volume_db.get("xp_orb", -4.0)
	player.pitch_scale = 1.0
	player.play()

	_xp_pitch_index = (_xp_pitch_index + 1) % 8


func _get_sound(sfx_name: String) -> AudioStream:
	if sfx_name in _sound_cache:
		return _sound_cache[sfx_name]

	# Try loading .ogg file from assets (cache null on miss to avoid repeated I/O)
	var ogg_path: String = "res://assets/audio/sfx/%s.ogg" % sfx_name
	if ResourceLoader.exists(ogg_path):
		var stream: AudioStream = load(ogg_path) as AudioStream
		_sound_cache[sfx_name] = stream
		return stream

	_sound_cache[sfx_name] = null
	return null


func _get_next_global_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = _global_pool[_global_index]
	_global_index = (_global_index + 1) % GLOBAL_POOL_SIZE
	return player


func _get_next_positional_player() -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D = _positional_pool[_positional_index]
	_positional_index = (_positional_index + 1) % POSITIONAL_POOL_SIZE
	return player


func _get_pitch(sfx_name: String) -> float:
	var variance: float = _pitch_variance.get(sfx_name, 0.1)
	if variance <= 0.0:
		return 1.0
	return randf_range(1.0 - variance, 1.0 + variance)


func _load_volume_settings() -> void:
	var save_path: String = "user://settings.json"
	if not FileAccess.file_exists(save_path):
		return

	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return

	var json: JSON = JSON.new()
	var error: int = json.parse(file.get_as_text())
	file.close()

	if error != OK or not json.data is Dictionary:
		return

	var data: Dictionary = json.data
	if "sfx_volume" in data:
		set_sfx_volume(float(data.sfx_volume))
	if "music_volume" in data:
		set_music_volume(float(data.music_volume))
