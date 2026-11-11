extends SceneTree
## Ejecutar con detección móvil activa y APPDATA aislado; no utiliza partidas reales.

var checks := 0
var failures := 0
const UPPER := Rect2(480, 40, 930, 415)
const LOWER := Rect2(470, 465, 980, 575)

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func frames(count: int = 10) -> void:
	for i in range(count):
		await process_frame

func open_scene(path: String) -> void:
	change_scene_to_file(path)
	await scene_changed
	await frames()

func run_tests() -> void:
	if not root.get_node("MobileControlsSettings").is_mobile_device():
		push_error("Esta prueba requiere el perfil de simulación móvil, separado del proyecto normal.")
		quit(2)
		return
	root.size = Vector2i(640, 360)
	await open_scene("res://scenes/configuracion/configuracion.tscn")
	check(current_scene.option_controles.get_popup().get_theme_font_size("font_size") >= 48, "El desplegable conserva texto demasiado pequeño")
	for dimension: String in ["atencion", "claridad", "reparacion"]:
		var questions: Array[String] = root.get_node("Cuestionarios").obtener_preguntas_para_dimension(dimension)
		for index in range(questions.size()):
			if current_scene != null:
				var previous := current_scene
				root.remove_child(previous)
				previous.queue_free()
			var quiz: Node = load("res://scenes/cuestionarios/EscenaCuestionario.tscn").instantiate()
			quiz.dimension = dimension
			quiz.preguntas = questions
			quiz.indice = index
			root.add_child(quiz)
			current_scene = quiz
			await frames()
			check(UPPER.encloses(quiz.titulo_label.get_global_rect()), "Encabezado fuera de su pergamino: " + questions[index])
			check(LOWER.encloses(quiz.label_pregunta.get_global_rect()), "Pregunta fuera del pergamino: " + questions[index])
			check(quiz.label_pregunta.get_content_height() <= quiz.label_pregunta.size.y, "Pregunta recortada: " + questions[index])
			for button: Button in quiz.botones_opciones:
				check(LOWER.encloses(button.get_global_rect()), "Opción fuera del pergamino: " + button.text)
				check(not button.get_global_rect().intersects(quiz.label_pregunta.get_global_rect()), "Opción invade la pregunta")
				check(button.get_theme_font_size("font_size") >= 48, "Opción demasiado pequeña")
			for a in range(quiz.botones_opciones.size()):
				for b in range(a + 1, quiz.botones_opciones.size()):
					check(not quiz.botones_opciones[a].get_global_rect().intersects(quiz.botones_opciones[b].get_global_rect()), "Dos opciones superpuestas")
	await open_scene("res://scenes/final/resultado_final.tscn")
	var results := current_scene
	results._renderizar_resumen()
	var scroll: ScrollContainer = results.get_node("MarginContainer/MobileScroll")
	results.boton_descargar_pdf.text = results.TEXTO_BOTON_DESCARGA_EXITOSA + " (10)"
	await frames()
	scroll.scroll_vertical = 100000
	await frames()
	check(root.get_visible_rect().encloses(results.boton_menu_principal.get_global_rect()), "Continuar inaccesible al desplazar resultados")
	check(root.get_visible_rect().encloses(results.boton_descargar_pdf.get_global_rect()), "Mensaje de descarga fuera de pantalla")
	check(results.boton_menu_principal.pressed.get_connections().size() > 0, "Se perdió la señal Continuar")
	await open_scene("res://scenes/personalizacion/Personalizacion.tscn")
	var personal := current_scene
	personal.input_nombre_jugador.text = "Prueba Movil"
	var sidebar: ScrollContainer = personal.get_node("CanvasLayer/PanelLateral/MobileScroll")
	var touch_point: Vector2 = root.get_final_transform() * (sidebar.get_global_position() + Vector2(12, 200))
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.position = touch_point
	Input.parse_input_event(press)
	await frames(2)
	var drag := InputEventScreenDrag.new()
	drag.position = touch_point + Vector2(0, -80)
	drag.relative = Vector2(0, -80)
	Input.parse_input_event(drag)
	await frames(2)
	var release := InputEventScreenTouch.new()
	release.position = drag.position
	Input.parse_input_event(release)
	await frames(2)
	check(sidebar.scroll_vertical > 0, "El panel no responde al arrastre de un contacto táctil")
	sidebar.scroll_vertical = 100000
	await frames()
	var start: Button = personal.get_node("%Comenzar")
	check(root.get_visible_rect().encloses(start.get_global_rect()), "Comenzar aventura inaccesible al desplazar personalización")
	check(start.pressed.get_connections().size() > 0, "Se perdió la señal Comenzar aventura")
	check(personal.input_nombre_jugador.text == "Prueba Movil", "Se perdió el nombre durante la redistribución")
	await open_scene("res://scenes/mision_2_memorias/mision_2_memorias.tscn")
	var selector: Control = current_scene.get_node("SelectorEmocion")
	selector.mostrar(current_scene.get_node("CuadrosContainer/CuadroMemoria_00"))
	await frames(30)
	var name_label: Label = selector.emojis_container.get_node("EmotionName_tristeza")
	var name_point: Vector2 = root.get_final_transform() * name_label.get_global_rect().get_center()
	var name_touch := InputEventScreenTouch.new()
	name_touch.position = name_point
	name_touch.pressed = true
	Input.parse_input_event(name_touch)
	await frames(2)
	name_touch = InputEventScreenTouch.new()
	name_touch.position = name_point
	Input.parse_input_event(name_touch)
	await frames(2)
	check(selector.emocion_seleccionada == "tristeza", "Tocar el nombre no elige su emoción")
	check(not selector.boton_confirmar.disabled, "Confirmar sigue desactivado después de tocar un nombre")
	await open_scene("res://dialogos/ManagerDialogos/dialogue_ui.tscn")
	root.get_node("DialogueActors").reiniciar_estado_cinematica()
	var ui: Node = current_scene.get_node("Balloon")
	var line := DialogueLine.new()
	line.character = "Narrador"
	line.text = "Un texto largo para revisar el desplazamiento y el botón de continuar. ".repeat(20)
	var response := DialogueResponse.new()
	response.text = "Una respuesta suficientemente larga para comprobar su caja y su tamaño."
	line.responses = [response]
	ui.current_line = line
	ui._mostrar_linea()
	ui._mobile_continue.pressed.emit()
	await frames()
	check(ui.line_finished, "Continuar no completa el texto")
	check(ui.responses_menu.visible, "Al completar el texto no aparecen sus respuestas")
	check(ui._mobile_hint.visible, "Falta indicación de desplazamiento para un párrafo largo")
	check(ui._mobile_scroll.get_v_scroll_bar().max_value > ui._mobile_scroll.get_v_scroll_bar().page, "El diálogo largo no permite desplazarse")
	check(root.get_visible_rect().encloses(ui.responses_menu.get_global_rect()), "Las respuestas salen de pantalla")
	check(ui.get_node("MarginContainer").get_global_rect().encloses(ui._mobile_responses.get_global_rect()), "Las respuestas invaden el escenario")
	# El recurso artificial no tiene siguiente línea: capturamos la señal sin
	# ejecutar la continuación narrativa y probamos el contacto real del viewport.
	ui.responses_menu.response_selected.disconnect(ui._al_respuesta_seleccionada)
	var selected: Array = []
	ui.responses_menu.response_selected.connect(func(value: Variant) -> void: selected.append(value))
	var item: Control = ui.responses_menu.get_menu_items()[0]
	var response_point: Vector2 = root.get_final_transform() * item.get_global_rect().get_center()
	var response_touch := InputEventScreenTouch.new()
	response_touch.position = response_point
	response_touch.pressed = true
	Input.parse_input_event(response_touch)
	await frames(2)
	response_touch = InputEventScreenTouch.new()
	response_touch.position = response_point
	Input.parse_input_event(response_touch)
	await frames(2)
	check(selected.size() == 1, "Una respuesta no se puede elegir con un toque")
	ui.type_timer.stop()
	current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	print("PRESENTACION_MOVIL: ", checks, " comprobaciones, ", failures, " fallos")
	quit(1 if failures > 0 else 0)
