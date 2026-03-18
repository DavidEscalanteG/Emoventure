extends Control

const MAPA_REJUGABILIDAD_SCENE: String = "res://scenes/rejugabilidad/mapa_rejugabilidad.tscn"
const DIMENSIONES: Array[String] = ["atencion", "claridad", "reparacion"]
const TEXTO_BOTON_DESCARGA_POR_DEFECTO: String = "Descargar resultados en PDF"
const TEXTO_BOTON_DESCARGA_EXITOSA: String = "¡Archivo descargado exitosamente en tu carpeta de descargas!"
const SEGUNDOS_REACTIVAR_DESCARGA: int = 10
const NOMBRES_DIMENSION: Dictionary[String, String] = {
	"atencion": "Atención emocional",
	"claridad": "Claridad emocional",
	"reparacion": "Reparación emocional"
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
	label_narrativa.text = "Ahora te revelaré quién eres"
	_renderizar_resumen()
	boton_descargar_pdf.text = TEXTO_BOTON_DESCARGA_POR_DEFECTO
	boton_descargar_pdf.pressed.connect(_on_boton_descargar_pdf_pressed)
	boton_menu_principal.pressed.connect(_on_boton_menu_principal_pressed)
	dialogo_guardar_pdf.file_selected.connect(_on_dialogo_guardar_pdf_file_selected)


func _renderizar_resumen() -> void:
	var puntajes: Dictionary[String, int] = GameManager.obtener_puntajes_por_dimension()
	var total_global: int = 0
	for dimension in DIMENSIONES:
		total_global += puntajes.get(dimension, 0)

	_actualizar_tarjeta_dimension("atencion", puntajes.get("atencion", 0), titulo_atencion, barra_atencion, mensaje_atencion)
	_actualizar_tarjeta_dimension("claridad", puntajes.get("claridad", 0), titulo_claridad, barra_claridad, mensaje_claridad)
	_actualizar_tarjeta_dimension("reparacion", puntajes.get("reparacion", 0), titulo_reparacion, barra_reparacion, mensaje_reparacion)

	label_perfil_final.text = _construir_texto_perfil_final(puntajes, total_global)


func _actualizar_tarjeta_dimension(dimension: String, puntaje: int, titulo: Label, barra: ProgressBar, mensaje: Label) -> void:
	titulo.text = "%s · %d/40" % [NOMBRES_DIMENSION.get(dimension, dimension.capitalize()), puntaje]
	barra.min_value = 0
	barra.max_value = 40
	barra.value = puntaje
	mensaje.text = _obtener_mensaje_dimension(dimension, puntaje)


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
	if not UMBRALES_MENSAJES_POR_GENERO.has(genero):
		genero = GENERO_HOMBRE
	return UMBRALES_MENSAJES_POR_GENERO.get(genero, {})


func _construir_texto_perfil_final(puntajes: Dictionary[String, int], total_global: int) -> String:
	var dimension_dominante: String = ""
	var puntaje_mayor: int = -1

	for dimension in DIMENSIONES:
		var actual: int = puntajes.get(dimension, 0)
		if actual > puntaje_mayor:
			puntaje_mayor = actual
			dimension_dominante = dimension

	var etiqueta_dominante: String = NOMBRES_DIMENSION.get(dimension_dominante, "tu dimensión principal")
	return "Tu energía emocional dominante está en %s. Puntaje total acumulado: %d puntos.\n\nSigue explorando, porque cada emoción comprendida te vuelve más fuerte." % [etiqueta_dominante, total_global]


func _on_boton_descargar_pdf_pressed() -> void:
	AudioManager.play_ui_click()
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
	var lineas: PackedStringArray = _construir_lineas_reporte()
	var pdf_data: PackedByteArray = _construir_pdf_simple(lineas)
	var archivo: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo crear el PDF en: %s" % path)
		return false
	archivo.store_buffer(pdf_data)
	archivo.close()
	print("PDF de resultados guardado en: %s" % path)
	return true


func _construir_lineas_reporte() -> PackedStringArray:
	var puntajes: Dictionary[String, int] = GameManager.obtener_puntajes_por_dimension()
	var total_global: int = 0
	for dimension in DIMENSIONES:
		total_global += puntajes.get(dimension, 0)

	var lineas: PackedStringArray = [
		"Reporte de resultados emocionales",
		"",
		"Nombre: %s" % str(DatosJugador.nombre_jugador),
		"Género: %s" % str(DatosJugador.genero),
		"Puntaje total: %d" % total_global,
		""
	]

	for dimension in DIMENSIONES:
		var puntaje: int = puntajes.get(dimension, 0)
		lineas.append("%s: %d/40" % [NOMBRES_DIMENSION.get(dimension, dimension), puntaje])
		lineas.append(_obtener_mensaje_dimension(dimension, puntaje))
		lineas.append("")

	lineas.append(label_perfil_final.text)
	return lineas


func _construir_pdf_simple(lineas: PackedStringArray) -> PackedByteArray:
	var objetos: Array[String] = []
	objetos.append("<< /Type /Catalog /Pages 2 0 R >>")
	objetos.append("<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
	objetos.append("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>")
	objetos.append("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")

	var contenido: String = "BT\n/F1 12 Tf\n50 790 Td\n"
	for linea in lineas:
		contenido += "(%s) Tj\n0 -18 Td\n" % _texto_a_pdf_winansi(linea)
	contenido += "ET\n"
	objetos.append("<< /Length %d >>\nstream\n%sendstream" % [contenido.to_utf8_buffer().size(), contenido])

	var pdf: String = "%PDF-1.4\n"
	var offsets: Array[int] = [0]
	for i in range(objetos.size()):
		offsets.append(pdf.to_utf8_buffer().size())
		pdf += "%d 0 obj\n%s\nendobj\n" % [i + 1, objetos[i]]

	var inicio_xref: int = pdf.to_utf8_buffer().size()
	pdf += "xref\n0 %d\n" % (objetos.size() + 1)
	pdf += "0000000000 65535 f \n"
	for i in range(1, offsets.size()):
		pdf += "%010d 00000 n \n" % offsets[i]

	pdf += "trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF" % [objetos.size() + 1, inicio_xref]
	return pdf.to_utf8_buffer()


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


func _texto_a_pdf_winansi(texto: String) -> String:
	var escapado: String = ""
	for caracter in texto:
		match caracter:
			"\\":
				escapado += "\\\\"
			"(":
				escapado += "\\("
			")":
				escapado += "\\)"
			_:
				escapado += _caracter_a_octal_pdf(caracter)
	return escapado


func _caracter_a_octal_pdf(caracter: String) -> String:
	var codigo_unicode: int = caracter.unicode_at(0)
	var codigo_winansi: int = codigo_unicode
	if codigo_unicode > 255:
		codigo_winansi = _mapear_unicode_a_winansi(codigo_unicode)
	var octal: String = String.num_int64(codigo_winansi, 8)
	return "\\" + octal.pad_zeros(3)


func _mapear_unicode_a_winansi(codigo_unicode: int) -> int:
	var mapa: Dictionary[int, int] = {
		8364: 128, # €
		8218: 130, # ‚
		402: 131, # ƒ
		8222: 132, # „
		8230: 133, # …
		8224: 134, # †
		8225: 135, # ‡
		710: 136, # ˆ
		8240: 137, # ‰
		352: 138, # Š
		8249: 139, # ‹
		338: 140, # Œ
		381: 142, # Ž
		8216: 145, # ‘
		8217: 146, # ’
		8220: 147, # “
		8221: 148, # ”
		8226: 149, # •
		8211: 150, # –
		8212: 151, # —
		732: 152, # ˜
		8482: 153, # ™
		353: 154, # š
		8250: 155, # ›
		339: 156, # œ
		382: 158, # ž
		376: 159 # Ÿ
	}
	return int(mapa.get(codigo_unicode, 63)) # ? cuando no se puede mapear


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


func _on_boton_menu_principal_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(MAPA_REJUGABILIDAD_SCENE)
