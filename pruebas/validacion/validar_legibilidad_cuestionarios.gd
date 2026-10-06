extends Node

const ESCENA_CUESTIONARIO := preload("res://scenes/cuestionarios/EscenaCuestionario.tscn")
const RECTANGULO_SUPERIOR := Rect2(480, 40, 930, 415)
const RECTANGULO_INFERIOR := Rect2(470, 465, 980, 575)


func _ready() -> void:
	call_deferred("_validar")


func _validar() -> void:
	var cuestionario: EscenaCuestionario = ESCENA_CUESTIONARIO.instantiate()
	cuestionario.dimension = Cuestionarios.DIMENSION_ATENCION
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_dimension(cuestionario.dimension)
	get_tree().root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
	await get_tree().process_frame
	await get_tree().process_frame

	var errores: Array[String] = []
	var total := 0
	var directorio_capturas := OS.get_environment("CODEX_QUIZ_CAPTURE_DIR")
	if not directorio_capturas.is_empty():
		DirAccess.make_dir_recursive_absolute(directorio_capturas)
	for dimension: String in [
		Cuestionarios.DIMENSION_ATENCION,
		Cuestionarios.DIMENSION_CLARIDAD,
		Cuestionarios.DIMENSION_REPARACION,
	]:
		for pregunta: String in Cuestionarios.obtener_preguntas_para_dimension(dimension):
			total += 1
			cuestionario.label_pregunta.text = pregunta
			cuestionario._ajustar_tamano_pregunta(pregunta)
			await get_tree().process_frame
			_validar_pregunta(cuestionario, pregunta, errores)
			if not directorio_capturas.is_empty():
				await get_tree().process_frame
				var imagen := get_tree().root.get_viewport().get_texture().get_image()
				var nombre := "%02d_%s.png" % [total, dimension]
				var resultado := imagen.save_png(directorio_capturas.path_join(nombre))
				if resultado != OK:
					errores.append("No se pudo guardar %s" % nombre)

	if errores.is_empty():
		print("VALIDACIÓN OK: %d preguntas legibles, sin recortes ni solapamientos." % total)
		get_tree().quit(0)
		return

	for error: String in errores:
		push_error(error)
	get_tree().quit(1)


func _validar_pregunta(cuestionario: EscenaCuestionario, pregunta: String, errores: Array[String]) -> void:
	var label := cuestionario.label_pregunta
	if label.get_content_height() > label.size.y:
		errores.append("Texto recortado: %s" % pregunta)

	var rect_pregunta := label.get_global_rect()
	if not RECTANGULO_INFERIOR.encloses(rect_pregunta):
		errores.append("Pregunta fuera del rectángulo inferior: %s (%s)" % [pregunta, rect_pregunta])
	for boton: Button in cuestionario.botones_opciones:
		if rect_pregunta.intersects(boton.get_global_rect()):
			errores.append("Pregunta sobrepuesta al botón '%s': %s" % [boton.text, pregunta])

	var viewport_rect := Rect2(Vector2.ZERO, get_tree().root.get_viewport().get_visible_rect().size)
	if not viewport_rect.encloses(rect_pregunta):
		errores.append("Pregunta fuera de pantalla: %s" % pregunta)
	for boton: Button in cuestionario.botones_opciones:
		if not viewport_rect.encloses(boton.get_global_rect()):
			errores.append("Botón fuera de pantalla: %s" % boton.text)
		if not RECTANGULO_INFERIOR.encloses(boton.get_global_rect()):
			errores.append("Botón fuera del rectángulo inferior: %s (%s)" % [boton.text, boton.get_global_rect()])

	if not RECTANGULO_SUPERIOR.encloses(cuestionario.titulo_label.get_global_rect()):
		errores.append("Encabezado fuera del pergamino superior")
