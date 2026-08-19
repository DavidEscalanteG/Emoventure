extends Node

const DIMENSION_ATENCION: String = "atencion"
const DIMENSION_CLARIDAD: String = "claridad"
const DIMENSION_REPARACION: String = "reparacion"

const PREGUNTAS_POR_DIMENSION: Dictionary[String, Array] = {
	DIMENSION_ATENCION: [
		"Presto mucha atención a los sentimientos.",
		"Normalmente me preocupo mucho por lo que siento.",
		"Normalmente dedico tiempo a pensar en mis emociones.",
		"Pienso que merece la pena prestar atención a mis emociones y estado de ánimo.",
		"Dejo que mis sentimientos afecten a mis pensamientos.",
		"Pienso en mi estado de ánimo constantemente.",
		"A menudo pienso en mis sentimientos.",
		"Presto mucha atención a cómo me siento."
	],
	DIMENSION_CLARIDAD: [
		"Tengo claros mis sentimientos.",
		"Frecuentemente puedo definir mis sentimientos.",
		"Casi siempre sé cómo me siento.",
		"Normalmente conozco mis sentimientos sobre las personas.",
		"A menudo me doy cuenta de mis sentimientos en diferentes situaciones.",
		"Siempre puedo decir cómo me siento.",
		"A veces puedo decir cuáles son mis emociones.",
		"Puedo llegar a comprender mis sentimientos"
	],
	DIMENSION_REPARACION: [
		"Aunque a veces me siento triste, suelo tener una visión optimista.",
		"Aunque me sienta mal, procuro pensar en cosas agradables.",
		"Cuando estoy triste, pienso en todos los placeres de la vida.",
		"Intento tener pensamientos positivos aunque me sienta mal.",
		"Si doy demasiadas vueltas a las cosas, complicándolas, trato de calmarme.",
		"Me esfuerzo por tener un buen estado de ánimo.",
		"Tengo mucha energía cuando me siento feliz.",
		"Cuando estoy enfadado intento que se me pase."
	]
}

const DIMENSION_POR_MISION: Dictionary[int, String] = {
	1: DIMENSION_ATENCION,
	2: DIMENSION_CLARIDAD,
	3: DIMENSION_REPARACION,
	4: DIMENSION_REPARACION
}

const RANGO_PREGUNTAS_POR_MISION: Dictionary[int, Vector2i] = {
	3: Vector2i(0, 3),
	4: Vector2i(4, 7)
}

func obtener_dimension_para_mision(numero_mision: int) -> String:
	return DIMENSION_POR_MISION.get(numero_mision, "")


func obtener_preguntas_para_dimension(dimension: String) -> Array[String]:
	var preguntas_crudas: Array = PREGUNTAS_POR_DIMENSION.get(dimension, [])
	var preguntas: Array[String] = []
	for pregunta in preguntas_crudas:
		preguntas.append(str(pregunta))
	return preguntas


func obtener_preguntas_para_mision(numero_mision: int) -> Array[String]:
	var dimension: String = obtener_dimension_para_mision(numero_mision)
	var preguntas: Array[String] = obtener_preguntas_para_dimension(dimension)
	if preguntas.is_empty():
		return []

	if not RANGO_PREGUNTAS_POR_MISION.has(numero_mision):
		return preguntas

	var rango: Vector2i = RANGO_PREGUNTAS_POR_MISION[numero_mision]
	var indice_inicio: int = maxi(0, rango.x)
	var indice_fin: int = mini(rango.y, preguntas.size() - 1)
	if indice_inicio > indice_fin:
		push_error("[Cuestionarios] Rango inválido para misión %d: %s" % [numero_mision, rango])
		return []

	var subset: Array[String] = []
	for i in range(indice_inicio, indice_fin + 1):
		subset.append(preguntas[i])
	return subset


func es_dimension_soportada(dimension: String) -> bool:
	return PREGUNTAS_POR_DIMENSION.has(dimension)


func validar_mision(numero_mision: int) -> bool:
	var dimension: String = obtener_dimension_para_mision(numero_mision)
	if dimension.is_empty():
		push_error("[Cuestionarios] Misión sin dimensión soportada: %d" % numero_mision)
		return false

	var preguntas: Array[String] = obtener_preguntas_para_mision(numero_mision)
	if preguntas.is_empty():
		push_error("[Cuestionarios] Misión %d sin preguntas configuradas" % numero_mision)
		return false

	return true


func validar_dimension_y_preguntas(dimension: String, preguntas: Array[String]) -> bool:
	if not es_dimension_soportada(dimension):
		push_error("[Cuestionarios] Dimensión no soportada: %s" % dimension)
		return false

	if preguntas.is_empty():
		push_error("[Cuestionarios] Dimensión %s sin preguntas" % dimension)
		return false

	return true
