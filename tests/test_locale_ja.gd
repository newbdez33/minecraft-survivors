extends SceneTree

func _init() -> void:
	# Set Japanese locale
	TranslationServer.set_locale("ja")
	print("[TEST] Locale set to: " + TranslationServer.get_locale())
	print("[TEST] HUD_LEVEL = " + tr("HUD_LEVEL"))
	print("[TEST] HUD_WAVE = " + tr("HUD_WAVE"))
	print("[TEST] HUD_KILLS = " + tr("HUD_KILLS"))
	print("[TEST] LEVEL = " + tr("LEVEL"))
	print("[TEST] WAVE = " + tr("WAVE"))
	print("[TEST] KILLS = " + tr("KILLS"))
	quit(0)
