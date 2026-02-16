extends SceneTree

func _init() -> void:
	print("=" .repeat(60))
	print("TRANSLATION TEST - All UI Text")
	print("=" .repeat(60))
	
	var languages = ["en", "ja", "zh"]
	var keys = [
		# Main Menu
		"GAME_TITLE", "START_GAME", "SETTINGS", "SCOREBOARD", "QUIT",
		# Settings
		"SFX_VOLUME", "MUSIC_VOLUME", "SCREEN_SHAKE", "DAMAGE_NUMBERS",
		"PAUSE_ON_UPGRADE", "LANGUAGE", "CLOSE",
		# HUD
		"HUD_LEVEL", "HUD_WAVE", "HUD_KILLS",
		# Game Over
		"YOU_DIED", "SURVIVAL_TIME", "KILLS", "LEVEL", "WAVE", "RESPAWN", "MAIN_MENU",
		# Upgrades
		"UPGRADE_SHARPNESS", "UPGRADE_KNOCKBACK", "UPGRADE_LOOTING",
		"UPGRADE_PROTECTION", "UPGRADE_SWIFTNESS", "UPGRADE_SWEEPING", "UPGRADE_HASTE",
		"ALL_MAXED",
		# Weapons
		"IRON_BLADE", "STEEL_BLADE", "FINE_STEEL_BLADE", "DIVINE_WEAPON",
		# Misc
		"PAUSED", "RESUME", "HIGH_SCORES", "NO_SCORES"
	]
	
	for lang in languages:
		TranslationServer.set_locale(lang)
		print("\n[%s] Language: %s" % [lang.to_upper(), lang])
		print("-".repeat(40))
		
		var missing = []
		for key in keys:
			var translated = tr(key)
			if translated == key:
				missing.append(key)
				print("  MISSING: %s" % key)
			else:
				print("  %s = %s" % [key, translated])
		
		if missing.size() > 0:
			print("\n  WARNING: %d missing translations!" % missing.size())
	
	print("\n" + "=".repeat(60))
	print("Test Complete")
	print("=".repeat(60))
	quit(0)
