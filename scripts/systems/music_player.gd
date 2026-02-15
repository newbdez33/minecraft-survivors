extends Node
## MusicPlayer - Dual AudioStreamPlayer crossfade controller
## Manages two AudioStreamPlayers for seamless biome music transitions

const CROSSFADE_DURATION: float = 2.0
const MUSIC_BUS_NAME: String = "Music"

var _player_a: AudioStreamPlayer = null
var _player_b: AudioStreamPlayer = null
var _active_player: AudioStreamPlayer = null
var _fading_player: AudioStreamPlayer = null

var _crossfading: bool = false
var _crossfade_time: float = 0.0
var _target_volume_db: float = -10.0  # Ambient music should be quiet

var _current_biome: int = -1


func _ready() -> void:
	_player_a = AudioStreamPlayer.new()
	_player_a.name = "MusicPlayerA"
	_player_a.bus = MUSIC_BUS_NAME
	_player_a.volume_db = _target_volume_db
	add_child(_player_a)

	_player_b = AudioStreamPlayer.new()
	_player_b.name = "MusicPlayerB"
	_player_b.bus = MUSIC_BUS_NAME
	_player_b.volume_db = -80.0
	add_child(_player_b)

	_active_player = _player_a


func _process(delta: float) -> void:
	if not _crossfading:
		return

	_crossfade_time += delta
	var t: float = clampf(_crossfade_time / CROSSFADE_DURATION, 0.0, 1.0)

	# Fade out old, fade in new
	if _fading_player:
		_fading_player.volume_db = lerpf(_target_volume_db, -80.0, t)
	if _active_player:
		_active_player.volume_db = lerpf(-80.0, _target_volume_db, t)

	if t >= 1.0:
		_crossfading = false
		if _fading_player:
			_fading_player.stop()
		_fading_player = null


## Play a biome track with crossfade from current
func play_track(stream: AudioStreamWAV, biome: int) -> void:
	if biome == _current_biome:
		return

	_current_biome = biome

	# Determine which player to use next
	var next_player: AudioStreamPlayer
	if _active_player == _player_a:
		next_player = _player_b
	else:
		next_player = _player_a

	# Setup the new track
	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()

	# Start crossfade
	_fading_player = _active_player
	_active_player = next_player
	_crossfading = true
	_crossfade_time = 0.0


## Stop all music
func stop_music() -> void:
	_crossfading = false
	_current_biome = -1
	if _player_a:
		_player_a.stop()
	if _player_b:
		_player_b.stop()


## Get currently playing biome
func get_current_biome() -> int:
	return _current_biome


## Check if music is playing
func is_playing() -> bool:
	if _active_player:
		return _active_player.playing
	return false
