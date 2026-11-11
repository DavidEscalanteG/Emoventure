extends Control

const RUTA_MENU_PRINCIPAL := "res://scenes/menu_principal/menu_principal.tscn"

func _ready() -> void:
	if not OS.has_feature("web"):
		# _ready todavía está incorporando esta escena al árbol.
		get_tree().change_scene_to_file.call_deferred(RUTA_MENU_PRINCIPAL)

func _on_button_pressed() -> void:
	if OS.has_feature("web"):
		# 1. Forzamos el canal principal al 100%
		var bus_master := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(bus_master, false)
		AudioServer.set_bus_volume_db(bus_master, 0.0)
		
		# 2. BYPASS: Desconectamos la música del AudioManager por si él es el culpable
		MusicManager._reproductor.bus = "Master"
		
		# 3. BYPASS: Forzamos el volumen del reproductor ignorando el Fade
		MusicManager._reproductor.volume_db = 0.0
		
		# 4. Arrancamos la canción DE GOLPE (0.0 fade) antes de cambiar de escena
		# Asegúrate de usar .ogg si ya lo convertiste, o .mp3 si regresaste al original
		MusicManager.reproducir_clave("menu_principal", 0.0, 0.0, true)

	# 5. Cambiamos de escena. Como la canción ya arrancó, el MusicManager no la reiniciará
	get_tree().change_scene_to_file(RUTA_MENU_PRINCIPAL)
