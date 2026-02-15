extends Node

const VOLUMEN_MUSICA_DB: float = -10.0

const AMBIENTE_MISTERIO := "misterio"
const AMBIENTE_TENSION := "tension"
const AMBIENTE_CALMA := "calma"
const AMBIENTE_TIERNURA := "ternura"

var _reproductor: AudioStreamPlayer
var _clave_actual: String = ""
var _advertencias_emitidas: Dictionary[String, bool] = {}

var _pistas_por_clave: Dictionary[String, String] = {
	"menu": "res://audios/musica/menu_principal.ogg",
	"personalizacion": "res://audios/musica/personalizacion.ogg",
	"mision_1": "res://audios/musica/mision_1.ogg",
	"mision_2": "res://audios/musica/mision_2.ogg",
	"mision_3": "res://audios/musica/mision_3.ogg",
	"mision_4": "res://audios/musica/mision_4.ogg",
	"transicion_llave": "res://audios/musica/transicion_llave.ogg",
	"cuestionario": "res://audios/musica/cuestionario.ogg",
	"resultado_final": "res://audios/musica/resultado_final.ogg",
	AMBIENTE_MISTERIO: "res://audios/musica/dialogo_misterio.ogg",
	AMBIENTE_TENSION: "res://audios/musica/dialogo_tension.ogg",
	AMBIENTE_CALMA: "res://audios/musica/dialogo_calma.ogg",
	AMBIENTE_TIERNURA: "res://audios/musica/dialogo_ternura.ogg"
}

var _pistas_por_escena: Dictionary[String, String] = {
	"res://scenes/menu_principal/menu_principal.tscn": "menu",
	"res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn": "menu",
	"res://scenes/personalizacion/Personalizacion.tscn": "personalizacion",
	"res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn": "mision_1",
	"res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn": "transicion_llave",
	"res://scenes/mision_2_memorias/mision_2_memorias.tscn": "mision_2",
	"res://scenes/cuestionarios/EscenaCuestionario.tscn": "cuestionario",
	"res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn": "transicion_llave",
	"res://scenes/mision_3_hachas/mision_3_hachas.tscn": "mision_3",
	"res://scenes/recompensa_mision_3/recompensa_mision_3.tscn": "transicion_llave",
	"res://scenes/mision_4_payasos/mapa_topos.tscn": "mision_4",
	"res://scenes/final/resultado_final.tscn": "resultado_final"
}


func _ready() -> void:
	_reproductor = AudioStreamPlayer.new()
	_reproductor.name = "MusicPlayer"
	_reproductor.bus = "Master"
	_reproductor.volume_db = VOLUMEN_MUSICA_DB
	add_child(_reproductor)

	if get_tree().has_signal("current_scene_changed"):
		get_tree().current_scene_changed.connect(_on_current_scene_changed)

	_actualizar_musica_escena_actual()


func reproducir_dialogo_por_ambiente(ambiente: String) -> void:
	reproducir_clave(ambiente)


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
	_reproductor.stop()


func _on_current_scene_changed(_nueva_escena: Node) -> void:
	_actualizar_musica_escena_actual()


func _actualizar_musica_escena_actual() -> void:
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		return

	var ruta_escena: String = escena_actual.scene_file_path
	if ruta_escena.is_empty():
		return

	var clave: String = _pistas_por_escena.get(ruta_escena, "")
	if clave.is_empty():
		return

	reproducir_clave(clave)