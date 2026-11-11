extends Control

const MAPA_REJUGABILIDAD_SCENE: String = "res://scenes/rejugabilidad/mapa_rejugabilidad.tscn"
const REPORTE_PDF = preload("res://src/ui/reporte_resultados_pdf.gd")
const DIMENSIONES: Array[String] = ["atencion", "claridad", "reparacion"]
const TEXTO_BOTON_DESCARGA_POR_DEFECTO: String = "Descargar resultados en PDF"
const TEXTO_BOTON_DESCARGA_EXITOSA: String = "¡Archivo descargado exitosamente en tu carpeta de descargas!"
const SEGUNDOS_REACTIVAR_DESCARGA: int = 10

const NOMBRES_DIMENSION: Dictionary[String, String] = {
	"atencion": "Atención emocional",
	"claridad": "Claridad emocional",
	"reparacion": "Reparación emocional"
}

const DEFINICIONES_DIMENSION: Dictionary[String, String] = {
	"atencion": "Se refiere a la percepción de las propias emociones, es decir, a la capacidad para sentir y expresar las emociones de forma adecuada.",
	"claridad": "Alude a la percepción que se tiene sobre la comprensión de los propios estados emocionales.",
	"reparacion": "Se refiere a la capacidad percibida para regular los propios estados emocionales de forma correcta."
}

const GENERO_HOMBRE: String = "hombre"
const GENERO_MUJER: String = "mujer"
const CARPETA_DESCARGAS_FALLBACK: String = "user://"

const UMBRALES_MENSAJES_POR_GENERO: Dictionary[String, Dictionary] = {
	GENERO_HOMBRE: {
		"atencion": {
			"bajo_max": 21,
			"medio_max": 32,
			"mensajes": {
				"bajo": "Debe mejorar su atención: presta poca atención.",
				"medio": "Adecuada atención.",
				"alto": "Debe mejorar su atención: presta demasiada atención."
			}
		},
		"claridad": {
			"bajo_max": 25,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su claridad emocional.",
				"medio": "Adecuada claridad emocional.",
				"alto": "Excelente claridad emocional."
			}
		},
		"reparacion": {
			"bajo_max": 23,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su reparación de las emociones.",
				"medio": "Adecuada reparación de las emociones.",
				"alto": "Excelente reparación de las emociones."
			}
		}
	},
	GENERO_MUJER: {
		"atencion": {
			"bajo_max": 24,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su atención: presta poca atención.",
				"medio": "Adecuada atención.",
				"alto": "Debe mejorar su atención: presta demasiada atención."
			}
		},
		"claridad": {
			"bajo_max": 23,
			"medio_max": 34,
			"mensajes": {
				"bajo": "Debe mejorar su claridad emocional.",
				"medio": "Adecuada claridad emocional.",
				"alto": "Excelente claridad emocional."
			}
		},
		"reparacion": {
			"bajo_max": 23,
			"medio_max": 34,
			"mensajes": {
				"bajo": "Debe mejorar su reparación de las emociones.",
				"medio": "Adecuada reparación de las emociones.",
				"alto": "Excelente reparación de las emociones."
			}
		}
	}
}

@onready var margin_container: Control = $MarginContainer
@onready var vbox_principal: VBoxContainer = $MarginContainer/VBoxPrincipal
@onready var label_narrativa: Label = %NarrativaLabel
@onready var tarjetas_container: VBoxContainer = %TarjetasContainer
@onready var label_perfil_final: Label = %PerfilFinalLabel
@onready var boton_descargar_pdf: Button = %BotonDescargarPDF
@onready var boton_menu_principal: Button = %BotonMenuPrincipal
@onready var dialogo_guardar_pdf: FileDialog = %DialogoGuardarPDF

@onready var titulo_atencion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/TituloAtencion"
@onready var barra_atencion: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/BarraAtencion"
@onready var mensaje_atencion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/MensajeAtencion"

@onready var titulo_claridad: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/TituloClaridad"
@onready var barra_claridad: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/BarraClaridad"
@onready var mensaje_claridad: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/MensajeClaridad"

@onready var titulo_reparacion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/TituloReparacion"
@onready var barra_reparacion: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/BarraReparacion"
@onready var mensaje_reparacion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/MensajeReparacion"

var cuenta_regresiva_descarga_activa: bool = false


func _ready() -> void:
	label_narrativa.text = "Una mirada a las tendencias que aparecieron durante tu aventura"
	_compactar_espaciado_interfaz()
	_renderizar_resumen()

	boton_descargar_pdf.visible = true
	boton_menu_principal.visible = true
	boton_descargar_pdf.text = TEXTO_BOTON_DESCARGA_POR_DEFECTO

	if not boton_descargar_pdf.pressed.is_connected(_on_boton_descargar_pdf_pressed):
		boton_descargar_pdf.pressed.connect(_on_boton_descargar_pdf_pressed)
	if not boton_menu_principal.pressed.is_connected(_on_boton_rejugabilidad_pressed):
		boton_menu_principal.pressed.connect(_on_boton_rejugabilidad_pressed)
	if not dialogo_guardar_pdf.file_selected.is_connected(_on_dialogo_guardar_pdf_file_selected):
		dialogo_guardar_pdf.file_selected.connect(_on_dialogo_guardar_pdf_file_selected)

	if not get_viewport().size_changed.is_connected(_ajustar_escala_a_pantalla):
		get_viewport().size_changed.connect(_ajustar_escala_a_pantalla)
	call_deferred("_ajustar_escala_a_pantalla")


func _compactar_espaciado_interfaz() -> void:
	if vbox_principal != null:
		vbox_principal.add_theme_constant_override("separation", 6)
	if tarjetas_container != null:
		tarjetas_container.add_theme_constant_override("separation", 6)

	var tamano_perfil: int = label_perfil_final.get_theme_font_size("font_size")
	if tamano_perfil > 14:
		label_perfil_final.add_theme_font_size_override("font_size", max(tamano_perfil - 3, 13))


func _ajustar_escala_a_pantalla() -> void:
	await get_tree().process_frame
	if margin_container == null or boton_menu_principal == null:
		return

	margin_container.scale = Vector2.ONE
	margin_container.position = Vector2.ZERO
	await get_tree().process_frame

	var alto_pantalla: float = get_viewport_rect().size.y
	var ancho_pantalla: float = get_viewport_rect().size.x
	var borde_inferior_boton: float = boton_menu_principal.get_global_rect().end.y
	var margen_inferior: float = 16.0

	if borde_inferior_boton > alto_pantalla - margen_inferior and borde_inferior_boton > 0.0:
		var factor: float = clampf((alto_pantalla - margen_inferior) / borde_inferior_boton, 0.65, 1.0)
		margin_container.scale = Vector2(factor, factor)
		margin_container.position.x = (ancho_pantalla - (ancho_pantalla * factor)) * 0.5


func _renderizar_resumen() -> void:
	var puntajes: Dictionary[String, int] = GameManager.obtener_puntajes_por_dimension()
	var total_global: int = 0
	for dimension in DIMENSIONES:
		total_global += puntajes.get(dimension, 0)

	_actualizar_tarjeta_dimension("atencion", puntajes.get("atencion", 0), titulo_atencion, barra_atencion, mensaje_atencion)
	_actualizar_tarjeta_dimension("claridad", puntajes.get("claridad", 0), titulo_claridad, barra_claridad, mensaje_claridad)
	_actualizar_tarjeta_dimension("reparacion", puntajes.get("reparacion", 0), titulo_reparacion, barra_reparacion, mensaje_reparacion)

	label_perfil_final.text = _construir_texto_perfil_final(puntajes, total_global, true)


func _actualizar_tarjeta_dimension(dimension: String, puntaje: int, titulo: Label, barra: ProgressBar, mensaje: Label) -> void:
	titulo.text = "%s · %d/40" % [NOMBRES_DIMENSION.get(dimension, dimension.capitalize()), puntaje]
	_insertar_definicion_en_tarjeta(dimension, titulo, barra, mensaje)
	barra.min_value = 0
	barra.max_value = 40
	barra.value = puntaje
	mensaje.text = _obtener_mensaje_dimension(dimension, puntaje)


func _insertar_definicion_en_tarjeta(dimension: String, titulo: Label, barra: ProgressBar, mensaje: Label) -> void:
	var contenedor: VBoxContainer = titulo.get_parent() as VBoxContainer
	if contenedor == null:
		return

	contenedor.add_theme_constant_override("separation", 2)
	var margen_nodo: MarginContainer = contenedor.get_parent() as MarginContainer
	if margen_nodo != null:
		margen_nodo.add_theme_constant_override("margin_top", 6)
		margen_nodo.add_theme_constant_override("margin_bottom", 6)

	var nombre_nodo: String = "Definicion_" + dimension
	var label_def: Label = contenedor.get_node_or_null(nombre_nodo) as Label
	if label_def == null:
		label_def = Label.new()
		label_def.name = nombre_nodo
		label_def.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label_def.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tamano_base: int = mensaje.get_theme_font_size("font_size")
		label_def.add_theme_font_size_override("font_size", clampi(tamano_base - 4, 11, 14))
		label_def.modulate = Color(1.0, 1.0, 1.0, 0.82)
		contenedor.add_child(label_def)

	label_def.text = DEFINICIONES_DIMENSION.get(dimension, "")
	contenedor.move_child(label_def, barra.get_index())


func _obtener_mensaje_dimension(dimension: String, puntaje: int) -> String:
	var umbrales_genero: Dictionary = _obtener_umbrales_genero()
	var config: Dictionary = umbrales_genero.get(dimension, {})
	if config.is_empty():
		return "Sin configuración de mensaje para esta dimensión."

	var mensajes: Dictionary = config.get("mensajes", {})
	if puntaje <= int(config.get("bajo_max", 16)):
		return mensajes.get("bajo", "")
	if puntaje <= int(config.get("medio_max", 28)):
		return mensajes.get("medio", "")
	return mensajes.get("alto", "")


func _obtener_umbrales_genero() -> Dictionary:
	var genero: String = str(DatosJugador.genero).to_lower().strip_edges()
	if (genero.begins_with("m") and not genero.contains("masc")) or genero.begins_with("f") or genero == "niña" or genero == "nina" or genero == "chica":
		genero = GENERO_MUJER
	elif not UMBRALES_MENSAJES_POR_GENERO.has(genero):
		genero = GENERO_HOMBRE
	return UMBRALES_MENSAJES_POR_GENERO.get(genero, {})


func _construir_texto_perfil_final(puntajes: Dictionary[String, int], total_global: int, incluir_citas_pie: bool = true) -> String:
	var dimensiones_mayores: Array[String] = []
	var puntaje_mayor: int = -1

	for dimension in DIMENSIONES:
		var actual: int = puntajes.get(dimension, 0)
		if actual > puntaje_mayor:
			puntaje_mayor = actual
			dimensiones_mayores = [NOMBRES_DIMENSION[dimension]]
		elif actual == puntaje_mayor:
			dimensiones_mayores.append(NOMBRES_DIMENSION[dimension])

	var resumen: String
	if puntaje_mayor <= 0:
		resumen = "Aún no se han registrado respuestas."
	elif dimensiones_mayores.size() == DIMENSIONES.size():
		resumen = "Las tres dimensiones tienen la misma puntuación."
	elif dimensiones_mayores.size() > 1:
		resumen = "La puntuación más alta se comparte entre %s." % " y ".join(dimensiones_mayores)
	else:
		resumen = "La puntuación más alta fue en %s." % dimensiones_mayores[0]

	var texto_base: String = "%s Total registrado: %d puntos. Estos resultados describen tendencias personales y no una calificación." % [resumen, total_global]
	if incluir_citas_pie:
		texto_base += "\nDefiniciones: (Oliva Delgado et al., 2011) | Baremo TMMS-24 por sexo: (Sánchez et al., 2024, p. 120)."
	return texto_base


func _on_boton_descargar_pdf_pressed() -> void:
	AudioManager.play_ui_click()

	if OS.has_feature("web"):
		var pdf_data: PackedByteArray = _construir_reporte_pdf()
		if not pdf_data.is_empty():
			JavaScriptBridge.download_buffer(pdf_data, _construir_nombre_pdf(), "application/pdf")
			_iniciar_cooldown_boton_descarga()
		return

	var ruta_pdf_sugerida: String = _construir_ruta_pdf_sugerida()
	if _guardar_reporte_pdf(ruta_pdf_sugerida):
		_iniciar_cooldown_boton_descarga()
		return

	dialogo_guardar_pdf.current_path = ruta_pdf_sugerida
	dialogo_guardar_pdf.popup_centered_ratio(0.6)


func _on_dialogo_guardar_pdf_file_selected(path: String) -> void:
	var ruta_pdf: String = path
	if not ruta_pdf.to_lower().ends_with(".pdf"):
		ruta_pdf += ".pdf"
	if _guardar_reporte_pdf(ruta_pdf):
		_iniciar_cooldown_boton_descarga()


func _guardar_reporte_pdf(path: String) -> bool:
	var pdf_data: PackedByteArray = _construir_reporte_pdf()
	var archivo: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo crear el PDF en: %s" % path)
		return false
	archivo.store_buffer(pdf_data)
	archivo.close()
	print("PDF de resultados guardado en: %s" % path)
	return true


func _construir_reporte_pdf() -> PackedByteArray:
	var puntajes: Dictionary[String, int] = GameManager.obtener_puntajes_por_dimension()
	var dimensiones: Array[Dictionary] = []
	var total: int = 0
	for dimension: String in DIMENSIONES:
		var puntaje: int = puntajes.get(dimension, 0)
		total += puntaje
		dimensiones.append({
			"nombre": NOMBRES_DIMENSION[dimension],
			"puntaje": puntaje,
			"mensaje": _obtener_mensaje_dimension(dimension, puntaje)
		})
	return REPORTE_PDF.new().construir(
		str(DatosJugador.nombre_jugador),
		str(DatosJugador.genero),
		dimensiones,
		_construir_texto_perfil_final(puntajes, total, false)
	)


func _construir_ruta_pdf_sugerida() -> String:
	var carpeta_descargas: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if carpeta_descargas.is_empty():
		carpeta_descargas = CARPETA_DESCARGAS_FALLBACK
	var nombre_archivo: String = _construir_nombre_pdf()
	return carpeta_descargas.path_join(nombre_archivo)


func _construir_nombre_pdf() -> String:
	var nombre_jugador: String = str(DatosJugador.nombre_jugador).strip_edges()
	if nombre_jugador.is_empty():
		nombre_jugador = "jugador"
	nombre_jugador = _sanitizar_nombre_archivo(nombre_jugador)

	var fecha_actual: Dictionary = Time.get_date_dict_from_system()
	var fecha_formateada: String = "%02d-%02d-%04d" % [
		int(fecha_actual.get("day", 1)),
		int(fecha_actual.get("month", 1)),
		int(fecha_actual.get("year", 1970))
	]
	return "resultado_emocional_%s_%s.pdf" % [nombre_jugador, fecha_formateada]


func _sanitizar_nombre_archivo(valor: String) -> String:
	var salida: String = ""
	for caracter in valor:
		var codigo: int = caracter.unicode_at(0)
		var es_letra_o_numero: bool = (
			(codigo >= 48 and codigo <= 57) # 0-9
			or (codigo >= 65 and codigo <= 90) # A-Z
			or (codigo >= 97 and codigo <= 122) # a-z
			or codigo >= 192 # letras acentuadas y otros caracteres unicode comunes
		)
		if es_letra_o_numero:
			salida += caracter
		elif caracter == " " or caracter == "-" or caracter == "_":
			salida += "_"

	salida = salida.strip_edges()
	if salida.is_empty():
		return "jugador"
	return salida


func _iniciar_cooldown_boton_descarga() -> void:
	if cuenta_regresiva_descarga_activa:
		return

	cuenta_regresiva_descarga_activa = true
	boton_descargar_pdf.disabled = true
	for segundos_restantes in range(SEGUNDOS_REACTIVAR_DESCARGA, 0, -1):
		boton_descargar_pdf.text = "%s (%d)" % [TEXTO_BOTON_DESCARGA_EXITOSA, segundos_restantes]
		await get_tree().create_timer(1.0).timeout

	boton_descargar_pdf.disabled = false
	boton_descargar_pdf.text = TEXTO_BOTON_DESCARGA_POR_DEFECTO
	cuenta_regresiva_descarga_activa = false


func _on_boton_rejugabilidad_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(MAPA_REJUGABILIDAD_SCENE)
