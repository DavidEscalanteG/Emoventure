extends RefCounted

## PDF vectorial A4 sin dependencias externas, con texto seleccionable.
const ANCHO_PAGINA: float = 595.0
const ALTO_PAGINA: float = 842.0
const MARGEN: float = 48.0
const ANCHO_CONTENIDO: float = ANCHO_PAGINA - MARGEN * 2.0
const COLOR_TEXTO: String = "0.13 0.20 0.26"
const COLOR_ACENTO: String = "0.08 0.37 0.40"

var _paginas: Array[String] = []
var _contenido: String = ""
var _y: float = 0.0


func construir(nombre: String, genero: String, dimensiones: Array[Dictionary], resumen: String) -> PackedByteArray:
	_paginas.clear()
	_nueva_pagina()
	_parrafo("Una mirada a las tendencias que aparecieron durante tu aventura.", 11.0)
	_y -= 16.0
	_parrafo("Nombre: %s" % (nombre.strip_edges() if not nombre.strip_edges().is_empty() else "Sin especificar"), 11.0)
	_parrafo("Género: %s" % genero.capitalize(), 11.0)
	var fecha: Dictionary = Time.get_date_dict_from_system()
	_parrafo("Fecha: %02d/%02d/%04d" % [fecha.day, fecha.month, fecha.year], 11.0)
	_y -= 20.0
	var total: int = 0
	for dimension: Dictionary in dimensiones:
		var puntaje: int = int(dimension.puntaje)
		total += puntaje
		_tarjeta(str(dimension.nombre), puntaje, str(dimension.mensaje))
	_y -= 8.0
	_asegurar_espacio(44.0)
	_texto("Puntaje total registrado: %d / 120" % total, MARGEN, _y, 12.0, true)
	_y -= 34.0
	_parrafo("Tu perfil emocional", 14.0, true)
	_y -= 4.0
	_parrafo(resumen, 11.0)
	_guardar_pagina()
	return _serializar()


func _nueva_pagina() -> void:
	_contenido = ""
	_rectangulo(0.0, 730.0, ANCHO_PAGINA, 112.0, "0.08 0.20 0.26")
	_texto("EMOVENTURE", MARGEN, 801.0, 12.0, true, "0.57 0.86 0.80")
	_texto("Resultados emocionales", MARGEN, 766.0, 25.0, true, "1 1 1")
	_y = 699.0


func _guardar_pagina() -> void:
	_rectangulo(MARGEN, 51.0, ANCHO_CONTENIDO, 0.7, "0.77 0.84 0.85")
	_texto("Emoventure  |  Reporte personal de resultados", MARGEN, 34.0, 9.0)
	_texto("Página %d" % (_paginas.size() + 1), 491.0, 34.0, 9.0)
	_paginas.append(_contenido)


func _asegurar_espacio(alto: float) -> void:
	if _y - alto >= 76.0:
		return
	_guardar_pagina()
	_nueva_pagina()


func _tarjeta(nombre: String, puntaje: int, mensaje: String) -> void:
	var lineas: PackedStringArray = _envolver_texto(mensaje, ANCHO_CONTENIDO - 36.0, 11.0)
	var alto: float = 68.0 + lineas.size() * 16.0
	_asegurar_espacio(alto + 16.0)
	_rectangulo(MARGEN, _y - alto, ANCHO_CONTENIDO, alto, "0.94 0.97 0.97")
	_rectangulo(MARGEN, _y - alto, 3.0, alto, COLOR_ACENTO)
	_texto(nombre, MARGEN + 18.0, _y - 24.0, 13.0, true)
	_texto("%d / 40" % puntaje, 472.0, _y - 24.0, 12.0, true, COLOR_ACENTO)
	_rectangulo(MARGEN + 18.0, _y - 42.0, ANCHO_CONTENIDO - 36.0, 5.0, "0.80 0.88 0.88")
	_rectangulo(MARGEN + 18.0, _y - 42.0, (ANCHO_CONTENIDO - 36.0) * clampf(puntaje / 40.0, 0.0, 1.0), 5.0, COLOR_ACENTO)
	var linea_y: float = _y - 62.0
	for linea: String in lineas:
		_texto(linea, MARGEN + 18.0, linea_y, 11.0)
		linea_y -= 16.0
	_y -= alto + 16.0


func _parrafo(texto: String, tamano: float, negrita: bool = false) -> void:
	for linea: String in _envolver_texto(texto, ANCHO_CONTENIDO, tamano):
		_asegurar_espacio(tamano + 7.0)
		_texto(linea, MARGEN, _y, tamano, negrita)
		_y -= tamano + 5.0


func _envolver_texto(texto: String, ancho: float, tamano: float) -> PackedStringArray:
	var lineas: PackedStringArray = []
	# Margen conservador entre las métricas de la fuente del motor y Helvetica.
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
			# También admite nombres o palabras largas sin espacios.
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
	return int(mapa.get(codigo_unicode, 63)) # ? cuando no se puede mapear


