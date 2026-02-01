extends CanvasLayer
## Splash/Landing screen that shows before main menu
## Shows game logo with fade-in animation, then auto-transitions to main menu

@onready var background: TextureRect = $Background
@onready var logo_container: CenterContainer = $LogoContainer

func _ready() -> void:
	# Check for test mode - skip splash and menu
	if _check_test_mode():
		call_deferred("_load_game_direct")
		return

	# Start invisible
	background.modulate.a = 0.0
	logo_container.modulate.a = 0.0

	# Fade in, hold, fade out, then go to main menu
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 1.0, 0.5)
	tween.tween_property(logo_container, "modulate:a", 1.0, 0.5)

	tween.set_parallel(false)
	tween.tween_interval(1.5)

	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, 0.3)
	tween.tween_property(logo_container, "modulate:a", 0.0, 0.3)

	tween.set_parallel(false)
	tween.tween_callback(_load_main_menu)


func _check_test_mode() -> bool:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--test-mode" or arg.begins_with("--test"):
			print("[SPLASH] Test mode detected, skipping to game...")
			return true
	return false


func _load_game_direct() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _load_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
