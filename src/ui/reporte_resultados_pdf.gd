extends RefCounted

## PDF vectorial A4 sin dependencias externas, con texto seleccionable.
const ANCHO_PAGINA: float = 595.0
const ALTO_PAGINA: float = 842.0
const MARGEN: float = 48.0
const ANCHO_CONTENIDO: float = ANCHO_PAGINA - MARGEN * 2.0
const COLOR_TEXTO: String = "0.13 0.20 0.26"
const COLOR_SUBTEXTO: String = "0.28 0.36 0.42"
const COLOR_ACENTO: String = "0.08 0.37 0.40"

var _paginas: Array[String] = []
var _contenido: String = ""
var _y: float = 0.0


func construir(nombre: String, genero: String, dimensiones: Array[Dictionary], resumen: String) -> PackedByteArray:
	_paginas.clear()
	_nueva_pagina()
	_parrafo("Una mirada a las tendencias que aparecieron durante tu aventura.", 10.5)
	_y -= 10.0
	_parrafo("Nombre: %s" % (nombre.strip_edges() if not nombre.strip_edges().is_empty() else "Sin especificar"), 10.5)
	_parrafo("Género: %s" % genero.capitalize(), 10.5)
	var fecha: Dictionary = Time.get_date_dict_from_system()
	_parrafo("Fecha: %02d/%02d/%04d" % [fecha.day, fecha.month, fecha.year], 10.5)
	_y -= 12.0
	var total: int = 0
	for dimension: Dictionary in dimensiones:
		var puntaje: int = int(dimension.puntaje)
		total += puntaje
		var nombre_dim: String = str(dimension.nombre)
		var mensaje_dim: String = str(dimension.get("mensaje", ""))
		if mensaje_dim.strip_edges().is_empty():
			mensaje_dim = obtener_interpretacion_tmms24(nombre_dim, puntaje, genero)
		_tarjeta(nombre_dim, puntaje, mensaje_dim)
	_y -= 4.0
	_asegurar_espacio(36.0)
	_texto("Puntaje total registrado: %d / 120" % total, MARGEN, _y, 11.5, true)
	_y -= 24.0
	_parrafo("Tu perfil emocional", 13.0, true)
	_y -= 2.0
	_parrafo(resumen, 10.5)
	_guardar_pagina()
	return _serializar()


func _nueva_pagina() -> void:
	_contenido = ""
	_rectangulo(0.0, 742.0, ANCHO_PAGINA, 100.0, "0.08 0.20 0.26")
	_texto("EMOVENTURE", MARGEN, 806.0, 11.5, true, "0.57 0.86 0.80")
	_texto("Resultados emocionales", MARGEN, 773.0, 24.0, true, "1 1 1")
	_y = 714.0


func _guardar_pagina() -> void:
	_rectangulo(MARGEN, 66.0, ANCHO_CONTENIDO, 0.7, "0.77 0.84 0.85")
	_texto("Definiciones de los componentes emocionales: (Oliva Delgado et al., 2011).", MARGEN, 52.0, 8.5, false, COLOR_SUBTEXTO)
	_texto("Nota: Resultados del instrumento TMMS-24 por sexo (Sánchez et al., 2024, p. 120).", MARGEN, 40.0, 8.5, false, COLOR_SUBTEXTO)
	_texto("Emoventure  |  Reporte personal de resultados", MARGEN, 26.0, 9.0)
	_texto("Página %d" % (_paginas.size() + 1), 491.0, 26.0, 9.0)
	_paginas.append(_contenido)


func _asegurar_espacio(alto: float) -> void:
	if _y - alto >= 74.0:
		return
	_guardar_pagina()
	_nueva_pagina()


func _obtener_definicion_componente(nombre: String) -> String:
	var n: String = nombre.strip_edges().to_lower()
	if n.contains("atenci"):
		return "Se refiere a la percepción de las propias emociones, es decir, a la capacidad para sentir y expresar las emociones de forma adecuada."
	elif n.contains("claridad"):
		return "Alude a la percepción que se tiene sobre la comprensión de los propios estados emocionales."
	elif n.contains("reparaci"):
		return "Se refiere a la capacidad percibida para regular los propios estados emocionales de forma correcta."
	return ""


func _tarjeta(nombre: String, puntaje: int, mensaje: String) -> void:
	var definicion: String = _obtener_definicion_componente(nombre)
	var lineas_def: PackedStringArray = _envolver_texto(definicion, ANCHO_CONTENIDO - 36.0, 9.5) if not definicion.is_empty() else PackedStringArray()
	var lineas_msg: PackedStringArray = _envolver_texto(mensaje, ANCHO_CONTENIDO - 36.0, 10.5)

	var alto: float = 52.0 + lineas_def.size() * 13.0 + lineas_msg.size() * 14.5
	_asegurar_espacio(alto + 10.0)

	# Fondo y borde izquierdo de la tarjeta
	_rectangulo(MARGEN, _y - alto, ANCHO_CONTENIDO, alto, "0.94 0.97 0.97")
	_rectangulo(MARGEN, _y - alto, 3.0, alto, COLOR_ACENTO)

	# 1. Subtítulo de la dimensión y puntaje
	_texto(nombre, MARGEN + 18.0, _y - 20.0, 12.5, true)
	_texto("%d / 40" % puntaje, 472.0, _y - 20.0, 11.5, true, COLOR_ACENTO)

	# 2. Definición del componente (debajo del subtítulo y encima de la barra)
	var cursor_y: float = _y - 35.0
	for linea_def: String in lineas_def:
		_texto(linea_def, MARGEN + 18.0, cursor_y, 9.5, false, COLOR_SUBTEXTO)
		cursor_y -= 13.0

	# 3. Barra de progreso
	var barra_y: float = cursor_y - 2.0
	_rectangulo(MARGEN + 18.0, barra_y, ANCHO_CONTENIDO - 36.0, 5.0, "0.80 0.88 0.88")
	_rectangulo(MARGEN + 18.0, barra_y, (ANCHO_CONTENIDO - 36.0) * clampf(puntaje / 40.0, 0.0, 1.0), 5.0, COLOR_ACENTO)

	# 4. Interpretación / resultado del jugador (debajo de la barra)
	cursor_y = barra_y - 15.0
	for linea_msg: String in lineas_msg:
		_texto(linea_msg, MARGEN + 18.0, cursor_y, 10.5, false, COLOR_TEXTO)
		cursor_y -= 14.5

	_y -= alto + 10.0


## Evalúa los puntajes según la Tabla 3 (Sánchez et al., 2024, p. 120) incluyendo <= y >=
static func obtener_interpretacion_tmms24(dimension: String, puntaje: int, genero: String) -> String:
	var g: String = genero.strip_edges().to_lower()
	var es_hombre: bool = g.begins_with("h") or (g.begins_with("m") and g.contains("masc")) or g == "niño" or g == "nino"
	var dim_norm: String = dimension.strip_edges().to_lower()

	if dim_norm.contains("atenci"):
		if es_hombre:
			if puntaje <= 21:
				return "Debe mejorar su atención: Presta poca atención (21 o menos)."
			elif puntaje <= 32:
				return "Adecuada atención (22 a 32)."
			else:
				return "Debe mejorar su atención: Presta demasiada atención (33 o más)."
		else:
			if puntaje <= 24:
				return "Debe mejorar su atención: Presta poca atención (24 o menos)."
			elif puntaje <= 35:
				return "Adecuada atención (25 a 35)."
			else:
				return "Debe mejorar su atención: Presta demasiada atención (36 o más)."

	elif dim_norm.contains("claridad"):
		if es_hombre:
			if puntaje <= 25:
				return "Debe mejorar su claridad (25 o menos)."
			elif puntaje <= 35:
				return "Adecuada claridad (26 a 35)."
			else:
				return "Excelente claridad (36 o más)."
		else:
			if puntaje <= 23:
				return "Debe mejorar su claridad (23 o menos)."
			elif puntaje <= 34:
				return "Adecuada claridad (24 a 34)."
			else:
				return "Excelente claridad (35 o más)."

	elif dim_norm.contains("reparaci"):
		if es_hombre:
			if puntaje <= 23:
				return "Debe mejorar su reparación (23 o menos)."
			elif puntaje <= 35:
				return "Adecuada reparación (24 a 35)."
			else:
				return "Excelente reparación (36 o más)."
		else:
			if puntaje <= 23:
				return "Debe mejorar su reparación (23 o menos)."
			elif puntaje <= 34:
				return "Adecuada reparación (24 a 34)."
			else:
				return "Excelente reparación (35 o más)."

	return ""


## Descarga el PDF directamente en el navegador si es Web (HTML5) o lo guarda en PC/Móvil nativo
static func descargar_o_guardar_pdf(bytes: PackedByteArray, nombre_archivo: String = "Resultados_Emoventure.pdf") -> bool:
	if bytes.is_empty():
		return false

	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(bytes, nombre_archivo, "application/pdf")
		return true

	var carpeta_descargas: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var ruta_final: String = carpeta_descargas.path_join(nombre_archivo) if not carpeta_descargas.is_empty() else "user://" + nombre_archivo
	var archivo := FileAccess.open(ruta_final, FileAccess.WRITE)
	if archivo == null:
		ruta_final = "user://" + nombre_archivo
		archivo = FileAccess.open(ruta_final, FileAccess.WRITE)
	if archivo == null:
		return false

	archivo.store_buffer(bytes)
	archivo.close()
	OS.shell_open(ProjectSettings.globalize_path(ruta_final))
	return true


func _parrafo(texto: String, tamano: float, negrita: bool = false) -> void:
	for linea: String in _envolver_texto(texto, ANCHO_CONTENIDO, tamano):
		_asegurar_espacio(tamano + 6.0)
		_texto(linea, MARGEN, _y, tamano, negrita)
		_y -= tamano + 4.0


func _envolver_texto(texto: String, ancho: float, tamano: float) -> PackedStringArray:
	var lineas: PackedStringArray = []
	var fuente: Font = ThemeDB.fallback_font
	for parrafo: String in texto.replace("\r", "").split("\n"):
		var linea: String = ""
		for palabra: String in parrafo.split(" ", false):
			var candidata: String = palabra if linea.is_empty() else linea + " " + palabra
			if fuente.get_string_size(candidata, HORIZONTAL_ALIGNMENT_LEFT, -1, int(ceil(tamano))).x * 1.12 <= ancho:
				linea = candidata
				continue
			if not linea.is_empty():
				lineas.append(linea)
			linea = ""
			for caracter: String in palabra:
				if fuente.get_string_size(linea + caracter, HORIZONTAL_ALIGNMENT_LEFT, -1, int(ceil(tamano))).x * 1.12 > ancho and not linea.is_empty():
					lineas.append(linea)
					linea = ""
				linea += caracter
		lineas.append(linea)
	return lineas


func _rectangulo(x: float, y: float, ancho: float, alto: float, color: String) -> void:
	_contenido += "q %s rg %.2f %.2f %.2f %.2f re f Q\n" % [color, x, y, ancho, alto]


func _texto(texto: String, x: float, y: float, tamano: float, negrita: bool = false, color: String = COLOR_TEXTO) -> void:
	_contenido += "BT /%s %.2f Tf %s rg 1 0 0 1 %.2f %.2f Tm (%s) Tj ET\n" % [
		"F2" if negrita else "F1", tamano, color, x, y, _texto_a_pdf_winansi(texto)
	]


func _serializar() -> PackedByteArray:
	var hijos: String = ""
	for i: int in range(_paginas.size()):
		hijos += "%d 0 R " % (5 + i * 2)
	var objetos: Array[String] = [
		"<< /Type /Catalog /Pages 2 0 R >>",
		"<< /Type /Pages /Kids [%s] /Count %d >>" % [hijos, _paginas.size()],
		"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
		"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>"
	]
	for i: int in range(_paginas.size()):
		objetos.append("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents %d 0 R >>" % (6 + i * 2))
		objetos.append("<< /Length %d >>\nstream\n%sendstream" % [_paginas[i].to_ascii_buffer().size(), _paginas[i]])
	var pdf: String = "%PDF-1.4\n"
	var offsets: Array[int] = [0]
	for i: int in range(objetos.size()):
		offsets.append(pdf.to_ascii_buffer().size())
		pdf += "%d 0 obj\n%s\nendobj\n" % [i + 1, objetos[i]]
	var inicio_xref: int = pdf.to_ascii_buffer().size()
	pdf += "xref\n0 %d\n0000000000 65535 f \n" % (objetos.size() + 1)
	for i: int in range(1, offsets.size()):
		pdf += "%010d 00000 n \n" % offsets[i]
	pdf += "trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % [objetos.size() + 1, inicio_xref]
	return pdf.to_ascii_buffer()


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
	return int(mapa.get(codigo_unicode, 63))
