extends Node

const BUS_MUSICA := "Musica"

const AMBIENTE_MISTERIO := "misterio"
const AMBIENTE_TENSION := "tension"
const AMBIENTE_CALMA := "calma"
const AMBIENTE_TIERNURA := "ternura"

var _reproductor: AudioStreamPlayer
var _clave_actual: String = ""
var _override_dialogo_activo: String = ""
var _advertencias_emitidas: Dictionary[String, bool] = {}
var _ultima_ruta_escena: String = ""

var _pistas_por_clave: Dictionary[String, String] = {
	"menu_principal": "res://audios/musica/menu_principal.mp3",
	"personalizacion": "res://audios/musica/personalizacion.mp3",
	"mision_1": "res://audios/musica/mision_1.mp3",
	"mision_2": "res://audios/musica/mision_2.mp3",
	"mision_3": "res://audios/musica/mision_3.mp3",
	"mision_4": "res://audios/musica/mision_4.mp3",
	"transicion_llave": "res://audios/musica/transicion_llave.mp3",
	"cuestionario": "res://audios/musica/cuestionario.mp3",
	"resultado_final": "res://audios/musica/resultado_final.mp3",
	AMBIENTE_MISTERIO: "res://audios/musica/dialogo_misterio.mp3",
	AMBIENTE_TENSION: "res://audios/musica/dialogo_tension.mp3",
	AMBIENTE_CALMA: "res://audios/musica/dialogo_calma.mp3",
	AMBIENTE_TIERNURA: "res://audios/musica/dialogo_ternura.mp3"
}

var _pistas_por_escena: Dictionary[String, String] = {
	"res://scenes/main_menu/menu_principal/menu_principal.tscn": "menu_principal",
	"res://scenes/tutorials/intro_seleccion_genero/intro_seleccion_genero.tscn": "menu_principal",
	"res://scenes/personalizacion/Personalizacion.tscn": "personalizacion",
	"res://scenes/tutorials/intro_dialogo_1/intro_dialogo_1.tscn": AMBIENTE_MISTERIO,
	"res://scenes/tutorials/intro_dialogo_2/intro_dialogo_2.tscn": AMBIENTE_TENSION,
	"res://scenes/minigames/minigame_1/mapa_1/mision_1_recoleccion.tscn": "mision_1",
	"res://scenes/minigames/minigame_1/mapa_2/mapa2.tscn" : "mision_1",
	"res://scenes/minigames/minigame_1/mapa_3/mapa3.tscn" : "mision_1",
	"res://scenes/minigames/minigame_1/mapa_4/mapa4.tscn" : "mision_1",
	"res://scenes/minigames/minigame_1/mapa_5/mapa5.tscn" : "mision_1",
	"res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn": "transicion_llave",
	"res://scenes/tutorials/intro_dialogo_3/intro_dialogo_3.tscn": AMBIENTE_TENSION,
	"res://scenes/tutorials/intro_dialogo_4/intro_dialogo_4.tscn": AMBIENTE_TENSION,
	"res://scenes/tutorials/intro_dialogo_5/intro_dialogo_5.tscn": AMBIENTE_TIERNURA,
	"res://scenes/tutorials/intro_mision_2/intro_mision_2.tscn": AMBIENTE_MISTERIO,
	"res://scenes/minigames/minigame_2/mision_2_memorias.tscn": "mision_2",
	"res://scenes/cuestionarios/EscenaCuestionario.tscn": "cuestionario",
	"res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn": "transicion_llave",
	"res://scenes/minigames/minigame_3/mision_3_hachas.tscn": "mision_3",
	"res://scenes/recompensa_mision_3/recompensa_mision_3.tscn": "transicion_llave",
	"res://scenes/tutorials/intro_mision_4/intro_mision_4.tscn": AMBIENTE_CALMA,
	"res://scenes/minigames/minigame_4/mapa_topos.tscn": "mision_4",
	"res://scenes/results/final/resultado_final.tscn": "resultado_final"
}


func _ready() -> void:
	_reproductor = AudioStreamPlayer.new()
	_reproductor.name = "MusicPlayer"
	_reproductor.bus = _obtener_bus_musica()
	add_child(_reproductor)
	
	_validar_pistas_registradas()

	if get_tree().has_signal("current_scene_changed"):
		get_tree().current_scene_changed.connect(_on_current_scene_changed)

	_actualizar_musica_escena_actual()
	set_process(true)


func reproducir_dialogo_por_ambiente(ambiente: String) -> void:
	iniciar_override_dialogo(ambiente)


func _process(_delta: float) -> void:
	if _override_dialogo_activo.is_empty():
		_actualizar_musica_si_cambio_escena()


func _actualizar_musica_si_cambio_escena() -> void:
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		return

	var ruta_escena: String = escena_actual.scene_file_path
	if ruta_escena.is_empty() or ruta_escena == _ultima_ruta_escena:
		return

	_ultima_ruta_escena = ruta_escena
	_actualizar_musica_escena_actual(false)


func iniciar_override_dialogo(ambiente: String) -> void:
	if ambiente.is_empty():
		return

	_override_dialogo_activo = ambiente
	reproducir_clave(ambiente)


func finalizar_override_dialogo() -> void:
	if _override_dialogo_activo.is_empty():
		restaurar_tema_escena_actual()
		return

	_override_dialogo_activo = ""
	restaurar_tema_escena_actual()


func restaurar_tema_escena_actual() -> void:
	_actualizar_musica_escena_actual(true)


func reproducir_desde_ruta(ruta_pista: String, from_position: float = 0.0) -> void:
	if ruta_pista.is_empty():
		return

	if not ResourceLoader.exists(ruta_pista):
		push_warning("[MusicManager] Falta archivo de música: %s" % ruta_pista)
		return

	var stream := load(ruta_pista) as AudioStream
	if stream == null:
		push_warning("[MusicManager] No se pudo cargar el AudioStream: %s" % ruta_pista)
		return

	if _reproductor.stream == stream and _reproductor.playing:
		return

	_clave_actual = ""
	_reproductor.stream = stream
	_reproductor.play(from_position)


func reproducir_clave(clave: String) -> void:
	if _clave_actual == clave:
		return

	var ruta_pista: String = _pistas_por_clave.get(clave, "")
	if ruta_pista.is_empty():
		push_warning("[MusicManager] No existe una pista registrada para la clave '%s'" % clave)
		return

	if not ResourceLoader.exists(ruta_pista):
		if not _advertencias_emitidas.has(clave):
			_advertencias_emitidas[clave] = true
			push_warning("[MusicManager] Falta archivo de música para '%s': %s" % [clave, ruta_pista])
		return

	var stream := load(ruta_pista) as AudioStream
	if stream == null:
		push_warning("[MusicManager] No se pudo cargar el AudioStream: %s" % ruta_pista)
		return

	_clave_actual = clave
	_reproductor.stream = stream
	_reproductor.play()


func detener() -> void:
	_clave_actual = ""
	_override_dialogo_activo = ""
	_reproductor.stop()


func _on_current_scene_changed(_nueva_escena: Node) -> void:
	_actualizar_musica_escena_actual(false)


func _actualizar_musica_escena_actual(forzar_restauracion: bool = false) -> void:
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		return

	var ruta_escena: String = escena_actual.scene_file_path
	if ruta_escena.is_empty():
		return
		
	_ultima_ruta_escena = ruta_escena

	var clave: String = _pistas_por_escena.get(ruta_escena, "")
	if clave.is_empty():
		return


	# Prioridad explícita:
	# 1) tema base por escena
	# 2) override temporal de diálogo (misterio/tensión/calma/ternura)
	# 3) al cerrar diálogo, restaurar el tema base de la escena actual
	if not _override_dialogo_activo.is_empty() and not forzar_restauracion:
		return

	reproducir_clave(clave)


func _validar_pistas_registradas() -> void:
	var faltantes: Dictionary[String, PackedStringArray] = {}
	for clave in _pistas_por_clave.keys():
		var ruta: String = _pistas_por_clave[clave]
		if ResourceLoader.exists(ruta):
			continue
		var extension := ruta.get_extension().to_lower()
		if not faltantes.has(extension):
			faltantes[extension] = PackedStringArray()
		faltantes[extension].append("%s -> %s" % [clave, ruta])

	if faltantes.is_empty():
		return

	var detalles := PackedStringArray()
	for extension in faltantes.keys():
		detalles.append("%s: [%s]" % [extension, ", ".join(faltantes[extension])])

	push_warning("[MusicManager] Pistas faltantes al iniciar: %s" % " | ".join(detalles))


func _obtener_bus_musica() -> String:
	if AudioManager == null:
		return BUS_MUSICA

	if AudioManager.BUS_MUSICA != BUS_MUSICA:
		push_warning("[MusicManager] BUS_MUSICA no coincide con AudioManager (%s != %s). Se usará '%s'." % [BUS_MUSICA, AudioManager.BUS_MUSICA, AudioManager.BUS_MUSICA])
	return AudioManager.BUS_MUSICA
