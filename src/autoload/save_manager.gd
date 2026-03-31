extends Node

const SAVE_FILE_PATH: String = "user://partidas_guardadas.json"
const ESCENA_SELECCION_GENERO: String = "res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn"
const ESCENA_FALLBACK: String = ESCENA_SELECCION_GENERO
const ESCENA_CUESTIONARIO: String = "res://scenes/cuestionarios/EscenaCuestionario.tscn"
const ESCENAS_EXCLUIDAS_GUARDADO: Array[String] = [
	"res://scenes/menu_principal/menu_principal.tscn",
	"res://scenes/menu_guardados/menu_guardados.tscn",
	"res://scenes/configuracion/configuracion.tscn",
	"res://scenes/creditos/creditos.tscn"
]

var _partidas: Array = []
var current_slot_id: String = ""
var _crear_nueva_partida: bool = false
var _ultima_escena_detectada: String = ""
var _estado_cuestionario_pendiente: Dictionary = {}


func _ready() -> void:
	_cargar_archivo()
	_ultima_escena_detectada = _obtener_escena_actual_path()


func _process(_delta: float) -> void:
	var escena_actual: String = _obtener_escena_actual_path()
	if escena_actual == _ultima_escena_detectada:
		return

	_ultima_escena_detectada = escena_actual
	_on_current_scene_changed()


func obtener_partidas() -> Array:
	return _partidas.duplicate(true)


func hay_partidas() -> bool:
	return not _partidas.is_empty()


func preparar_nueva_partida() -> void:
	current_slot_id = ""
	_crear_nueva_partida = true
	DatosJugador.reiniciar_estado_temporal()
	DatosJugador.apariencia = AparienciaJugador.new()
	DatosJugador.mascota = MascotaSeleccion.new()
	GameManager.reiniciar_puntajes()


func debe_crear_partida() -> bool:
	return _crear_nueva_partida


func confirmar_guardado_inicial(escena_siguiente: String) -> void:
	if current_slot_id.is_empty():
		current_slot_id = _generar_id_partida()
		_partidas.append({
			"id": current_slot_id,
			"created_at": Time.get_datetime_string_from_system(true),
			"nombre_mascota": "",
			"escena_actual": escena_siguiente
		})

	_actualizar_datos_slot(current_slot_id, escena_siguiente)
	_crear_nueva_partida = false
	_guardar_archivo()


func cargar_partida(slot_id: String) -> bool:
	var partida: Dictionary = _obtener_partida_por_id(slot_id)
	if partida.is_empty():
		return false

	current_slot_id = slot_id
	_crear_nueva_partida = false
	_aplicar_datos_partida(partida)

	var escena_guardada: String = partida.get("escena_actual", ESCENA_FALLBACK)
	if escena_guardada.is_empty():
		escena_guardada = ESCENA_FALLBACK
	if not ResourceLoader.exists(escena_guardada):
		escena_guardada = ESCENA_FALLBACK

	get_tree().change_scene_to_file(escena_guardada)
	return true


func eliminar_partida(slot_id: String) -> void:
	for i in range(_partidas.size()):
		if _partidas[i].get("id", "") == slot_id:
			_partidas.remove_at(i)
			if current_slot_id == slot_id:
				current_slot_id = ""
			_guardar_archivo()
			return


func actualizar_guardado_actual(scene_path: String = "") -> void:
	if current_slot_id.is_empty():
		return

	var escena_objetivo: String = scene_path
	if escena_objetivo.is_empty():
		escena_objetivo = _obtener_escena_actual_path()
	if escena_objetivo.is_empty() or _es_escena_excluida(escena_objetivo):
		return

	_actualizar_datos_slot(current_slot_id, escena_objetivo)
	_guardar_archivo()


func _on_current_scene_changed() -> void:
	if current_slot_id.is_empty():
		return

	var escena_actual: String = _obtener_escena_actual_path()
	if escena_actual.is_empty() or _es_escena_excluida(escena_actual):
		return

	_actualizar_datos_slot(current_slot_id, escena_actual)
	_guardar_archivo()


func _actualizar_datos_slot(slot_id: String, escena_actual: String) -> void:
	for i in range(_partidas.size()):
		if _partidas[i].get("id", "") != slot_id:
			continue

		var partida: Dictionary = _partidas[i] as Dictionary
		partida["id"] = slot_id
		partida["nombre_jugador"] = DatosJugador.nombre_jugador
		partida["nombre_mascota"] = DatosJugador.nombre_mascota
		partida["genero"] = DatosJugador.genero
		partida["apariencia"] = _serializar_apariencia(DatosJugador.apariencia)
		partida["mascota_indice"] = DatosJugador.obtener_indice_mascota()
		partida["puntaje_total"] = GameManager.obtener_puntaje_total()
		partida["puntajes_emocionales"] = GameManager.obtener_puntajes_por_dimension()
		partida["escena_actual"] = escena_actual
		var estado_cuestionario: Dictionary = _construir_estado_cuestionario(escena_actual)
		if estado_cuestionario.is_empty():
			partida.erase("estado_cuestionario")
		else:
			partida["estado_cuestionario"] = estado_cuestionario
		partida["updated_at"] = Time.get_datetime_string_from_system(true)
		_partidas[i] = partida
		return


func _obtener_partida_por_id(slot_id: String) -> Dictionary:
	for partida_data: Variant in _partidas:
		if typeof(partida_data) != TYPE_DICTIONARY:
			continue
		var partida: Dictionary = partida_data as Dictionary
		if partida.get("id", "") == slot_id:
			return partida
	return {}


func _aplicar_datos_partida(partida: Dictionary) -> void:
	DatosJugador.nombre_jugador = partida.get("nombre_jugador", DatosJugador.NOMBRE_JUGADOR_PREDETERMINADO)
	DatosJugador.nombre_mascota = partida.get("nombre_mascota", DatosJugador.NOMBRE_MASCOTA_PREDETERMINADO)
	DatosJugador.set_genero(partida.get("genero", DatosJugador.GENERO_HOMBRE))

	var apariencia_dict: Dictionary = partida.get("apariencia", {})
	_aplicar_apariencia_desde_diccionario(apariencia_dict)

	DatosJugador.set_indice_mascota(int(partida.get("mascota_indice", 0)))

	var puntaje_total_guardado: int = int(partida.get("puntaje_total", 0))
	var puntajes_emocionales_variant: Variant = partida.get("puntajes_emocionales", {})
	var puntajes_emocionales_guardados: Dictionary = {}
	if typeof(puntajes_emocionales_variant) == TYPE_DICTIONARY:
		puntajes_emocionales_guardados = puntajes_emocionales_variant
	GameManager.cargar_puntajes_desde_guardado(puntaje_total_guardado, puntajes_emocionales_guardados)

	var estado_cuestionario_variant: Variant = partida.get("estado_cuestionario", {})
	if typeof(estado_cuestionario_variant) == TYPE_DICTIONARY:
		_estado_cuestionario_pendiente = (estado_cuestionario_variant as Dictionary).duplicate(true)
	else:
		_estado_cuestionario_pendiente = {}



func obtener_estado_cuestionario_pendiente() -> Dictionary:
	return _estado_cuestionario_pendiente.duplicate(true)


func consumir_estado_cuestionario_pendiente() -> Dictionary:
	var estado: Dictionary = _estado_cuestionario_pendiente.duplicate(true)
	_estado_cuestionario_pendiente = {}
	return estado


func _construir_estado_cuestionario(escena_actual: String) -> Dictionary:
	if escena_actual != ESCENA_CUESTIONARIO:
		return {}

	if get_tree().current_scene == null:
		return {}

	var cuestionario: EscenaCuestionario = get_tree().current_scene as EscenaCuestionario
	if cuestionario == null:
		return {}

	var preguntas_serializadas: Array[String] = []
	for pregunta in cuestionario.preguntas:
		preguntas_serializadas.append(str(pregunta))

	var escena_siguiente_path: String = ""
	if cuestionario.escena_siguiente != null:
		escena_siguiente_path = cuestionario.escena_siguiente.resource_path

	return {
		"dimension": cuestionario.dimension,
		"preguntas": preguntas_serializadas,
		"indice": cuestionario.indice,
		"puntaje_local": cuestionario.puntaje_local,
		"narrativa_post_cuestionario": cuestionario.narrativa_post_cuestionario,
		"titulo_narrativa_post": cuestionario.titulo_narrativa_post,
		"escena_siguiente_path": escena_siguiente_path
	}


func _serializar_apariencia(apariencia: AparienciaJugador) -> Dictionary:
	return {
		"indice_cabello": apariencia.indice_cabello,
		"indice_ojos": apariencia.indice_ojos,
		"indice_boca": apariencia.indice_boca,
		"indice_cuerpo": apariencia.indice_cuerpo,
		"indice_nariz": apariencia.indice_nariz,
		"indice_cabeza": apariencia.indice_cabeza,
		"color_cabeza": apariencia.color_cabeza.to_html(true),
		"color_cabello": apariencia.color_cabello.to_html(true),
		"color_ojos": apariencia.color_ojos.to_html(true),
		"color_cuerpo": apariencia.color_cuerpo.to_html(true),
		"color_nariz": apariencia.color_nariz.to_html(true),
		"color_boca": apariencia.color_boca.to_html(true)
	}


func _aplicar_apariencia_desde_diccionario(data: Dictionary) -> void:
	DatosJugador.apariencia.indice_cabello = DatosJugador.validar_indice_cabello_por_genero(int(data.get("indice_cabello", DatosJugador.obtener_indice_cabello_inicio())))
	DatosJugador.apariencia.indice_ojos = int(data.get("indice_ojos", 0))
	DatosJugador.apariencia.indice_boca = int(data.get("indice_boca", 0))
	DatosJugador.apariencia.indice_cuerpo = int(data.get("indice_cuerpo", 0))
	DatosJugador.apariencia.indice_nariz = int(data.get("indice_nariz", 0))
	DatosJugador.apariencia.indice_cabeza = int(data.get("indice_cabeza", 0))

	DatosJugador.apariencia.color_cabeza = Color(data.get("color_cabeza", "ffffffff"))
	DatosJugador.apariencia.color_cabello = Color(data.get("color_cabello", "ffffffff"))
	DatosJugador.apariencia.color_ojos = Color(data.get("color_ojos", "ffffffff"))
	DatosJugador.apariencia.color_cuerpo = Color(data.get("color_cuerpo", "ffffffff"))
	DatosJugador.apariencia.color_nariz = Color(data.get("color_nariz", "ffffffff"))
	DatosJugador.apariencia.color_boca = Color(data.get("color_boca", "ffffffff"))


func _obtener_escena_actual_path() -> String:
	if get_tree().current_scene == null:
		return ""
	return get_tree().current_scene.scene_file_path


func _es_escena_excluida(scene_path: String) -> bool:
	return ESCENAS_EXCLUIDAS_GUARDADO.has(scene_path)


func _generar_id_partida() -> String:
	return "%s_%s" % [str(Time.get_unix_time_from_system()), str(randi_range(1000, 9999))]


func _cargar_archivo() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		_partidas = []
		return

	var archivo: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if archivo == null:
		push_warning("[SaveManager] No se pudo abrir el archivo de guardado")
		_partidas = []
		return

	var contenido: String = archivo.get_as_text()
	archivo.close()

	if contenido.is_empty():
		_partidas = []
		return

	var json: JSON = JSON.new()
	var error: int = json.parse(contenido)
	if error != OK:
		push_warning("[SaveManager] JSON de guardado inválido")
		_partidas = []
		return

	var data: Variant = json.data
	if typeof(data) == TYPE_ARRAY:
		_partidas = data
	else:
		_partidas = []


func _guardar_archivo() -> void:
	var archivo: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if archivo == null:
		push_warning("[SaveManager] No se pudo escribir el archivo de guardado")
		return

	archivo.store_string(JSON.stringify(_partidas, "\t"))
	archivo.close()
