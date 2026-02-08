extends Node
## SFXConnector - Wires existing game signals to AudioManager
## Add as child of Main scene to connect all signal-based SFX

var _audio: Node = null
var _player: Node = null
var _sword: Node = null
var _bow: Node = null
var _wave_manager: Node = null
var _day_night_cycle: Node = null
var _upgrade_ui: Node = null
var _combo_system: Node = null
var _status_effect_manager: Node = null
var _achievement_manager: Node = null

func _ready() -> void:
	_audio = get_node_or_null("/root/AudioManager")
	# Defer connection to ensure all nodes are ready
	call_deferred("_connect_all_signals")


func _connect_all_signals() -> void:
	var parent: Node = get_parent()
	if not parent:
		return

	_connect_player_signals(parent)
	_connect_weapon_signals(parent)
	_connect_system_signals(parent)
	_connect_ui_signals(parent)


func _connect_player_signals(parent: Node) -> void:
	_player = parent.get_node_or_null("Player")
	if not _player:
		return

	if _player.has_signal("leveled_up"):
		_player.leveled_up.connect(_on_player_leveled_up)
	if _player.has_signal("died"):
		_player.died.connect(_on_player_died)
	if _player.has_signal("health_changed"):
		_player.health_changed.connect(_on_player_health_changed)

	# Status effect manager
	_status_effect_manager = _player.get_node_or_null("StatusEffectManager")
	if _status_effect_manager:
		if _status_effect_manager.has_signal("effect_applied"):
			_status_effect_manager.effect_applied.connect(_on_effect_applied)


func _connect_weapon_signals(parent: Node) -> void:
	if not _player:
		return

	# Sword
	_sword = _player.get_node_or_null("Sword")
	if _sword:
		if _sword.has_signal("attacked"):
			_sword.attacked.connect(_on_sword_attacked)
		if _sword.has_signal("evolved"):
			_sword.evolved.connect(_on_sword_evolved)

	# Bow (may be added later via upgrade)
	_bow = _player.get_node_or_null("Bow")
	if _bow:
		_connect_bow(_bow)

	# Watch for bow being added dynamically
	_player.child_entered_tree.connect(_on_player_child_added)


func _connect_system_signals(parent: Node) -> void:
	# Wave manager
	_wave_manager = parent.get_node_or_null("WaveManager")
	if _wave_manager and _wave_manager.has_signal("wave_started"):
		_wave_manager.wave_started.connect(_on_wave_started)

	# Day/night cycle
	_day_night_cycle = parent.get_node_or_null("DayNightCycle")
	if _day_night_cycle and _day_night_cycle.has_signal("night_started"):
		_day_night_cycle.night_started.connect(_on_night_started)

	# Combo system (might be child of spawner or standalone)
	_combo_system = parent.get_node_or_null("ComboSystem")
	if not _combo_system:
		_combo_system = parent.get_node_or_null("MobSpawner/ComboSystem")
	if _combo_system and _combo_system.has_signal("milestone_reached"):
		_combo_system.milestone_reached.connect(_on_combo_milestone)

	# Achievement manager
	_achievement_manager = parent.get_node_or_null("AchievementManager")
	if _achievement_manager and _achievement_manager.has_signal("achievement_unlocked"):
		_achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)


func _connect_ui_signals(parent: Node) -> void:
	# Upgrade UI
	_upgrade_ui = parent.get_node_or_null("UpgradeUI")
	if _upgrade_ui and _upgrade_ui.has_signal("upgrade_selected"):
		_upgrade_ui.upgrade_selected.connect(_on_upgrade_selected)


func _connect_bow(bow: Node) -> void:
	if bow.has_signal("arrow_fired"):
		bow.arrow_fired.connect(_on_bow_fired)
	if bow.has_signal("evolved_to_crossbow"):
		bow.evolved_to_crossbow.connect(_on_bow_evolved)
	_bow = bow


func _exit_tree() -> void:
	if _player and is_instance_valid(_player):
		if _player.child_entered_tree.is_connected(_on_player_child_added):
			_player.child_entered_tree.disconnect(_on_player_child_added)


func _on_player_child_added(child: Node) -> void:
	# Detect bow added via upgrade
	if child.name == "Bow" and not _bow:
		# Wait a frame for bow to be fully ready
		await get_tree().process_frame
		if not is_instance_valid(self) or not is_instance_valid(child):
			return
		_connect_bow(child)


func _play(sfx_name: String) -> void:
	if _audio and _audio.has_method("play_sfx"):
		_audio.play_sfx(sfx_name)


# --- Signal Handlers ---

var _last_health: int = -1

func _on_player_leveled_up(_new_level: int) -> void:
	_play("player_level_up")


func _on_player_died() -> void:
	_play("player_death")


func _on_player_health_changed(current: int, _maximum: int) -> void:
	if _last_health < 0:
		_last_health = current
		return

	if current < _last_health:
		_play("player_take_damage")
	elif current > _last_health:
		_play("player_heal")

	_last_health = current


func _on_effect_applied(effect) -> void:
	var StatusEffectClass = load("res://scripts/components/status_effect.gd")
	if StatusEffectClass and effect.type == StatusEffectClass.Type.POISON:
		_play("poison_applied")


func _on_sword_attacked(_enemies_hit: int) -> void:
	_play("sword_hit")


func _on_sword_evolved(_new_tier: int) -> void:
	_play("sword_evolve")


func _on_bow_fired(_arrow: Node2D) -> void:
	_play("bow_shot")


func _on_bow_evolved() -> void:
	_play("sword_evolve")


func _on_wave_started(_wave_number: int) -> void:
	_play("wave_start")


func _on_night_started() -> void:
	_play("night_transition")


func _on_upgrade_selected(_upgrade) -> void:
	_play("upgrade_select")


func _on_combo_milestone(_combo: int, _bonus: float) -> void:
	_play("combo_milestone")


func _on_achievement_unlocked(_achievement) -> void:
	_play("achievement_unlock")
