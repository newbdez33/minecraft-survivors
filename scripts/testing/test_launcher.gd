extends SceneTree
## Test Launcher - Run from command line
## Usage: godot res://scenes/main.tscn -- --test-mode --scenario=FULL_AUTO --duration=60
##
## This script is deprecated. Use the built-in test mode instead:
##   godot res://scenes/main.tscn -- --test-mode [options]
##
## Options:
##   --scenario=FULL_AUTO|POISON_TEST|SURVIVAL_TEST|UPGRADE_TEST|DAY_NIGHT_TEST
##   --duration=120 (seconds)
##   --speed=1.0 (time multiplier)
##   --no-screenshots (disable auto screenshots)

func _init() -> void:
	print("\n" + "=".repeat(60))
	print("  THREE KINGDOMS SURVIVORS - TEST LAUNCHER")
	print("=".repeat(60))
	print("")
	print("RECOMMENDED: Use built-in test mode instead:")
	print("  godot res://scenes/main.tscn -- --test-mode --duration=60")
	print("")
	print("Starting test with built-in mode...")
	print("")

	# Parse args and pass them through
	var user_args = OS.get_cmdline_user_args()
	var test_args = ["--test-mode"]

	for arg in user_args:
		test_args.append(arg)

	# Set the args for the game to read
	# Note: This approach changes root scene directly
	change_scene_to_file("res://scenes/main.tscn")
