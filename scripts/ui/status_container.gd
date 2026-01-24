extends HBoxContainer
class_name StatusContainer
## Container for status effect icons in HUD

const StatusIconClass = preload("res://scripts/ui/status_icon.gd")

var _icons: Dictionary = {}  # effect_type -> StatusIcon
var _status_manager: Node = null

func _ready() -> void:
	add_theme_constant_override("separation", 4)

func connect_to_player(player: Node) -> void:
	_status_manager = player.get_node_or_null("StatusEffectManager")
	if _status_manager:
		_status_manager.effect_applied.connect(_on_effect_applied)
		_status_manager.effect_removed.connect(_on_effect_removed)

func _on_effect_applied(effect) -> void:
	if effect.type in _icons:
		return  # Already showing

	var icon = StatusIconClass.new()
	icon.setup(effect.type)
	add_child(icon)
	_icons[effect.type] = icon

func _on_effect_removed(effect) -> void:
	if effect.type in _icons:
		var icon = _icons[effect.type]
		_icons.erase(effect.type)
		icon.queue_free()

func _process(_delta: float) -> void:
	if not _status_manager:
		return

	# Update timers
	for effect in _status_manager.active_effects:
		if effect.type in _icons:
			_icons[effect.type].update_time(effect.remaining_time)
