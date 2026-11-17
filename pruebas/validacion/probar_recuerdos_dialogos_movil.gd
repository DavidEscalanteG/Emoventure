extends SceneTree

var checks := 0
var failures := 0
var output := OS.get_environment("EMO_TOUCH_OUTPUT")

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 10) -> void:
	for index in range(count):
		await process_frame

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func open_scene(path: String) -> void:
	change_scene_to_file(path)
	await scene_changed
	await frames()

func screen_point(control: Control, local: Vector2 = Vector2.INF) -> Vector2:
	return root.get_final_transform() * control.get_global_transform_with_canvas() * (control.size / 2 if local == Vector2.INF else local)

func touch(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames(2)

func tap(control: Control) -> void:
	var point := screen_point(control)
	await touch(point, true)
	await touch(point, false)
	await frames()

func drag(control: Control) -> void:
	var point := screen_point(control, Vector2(control.size.x / 2, control.size.y * 0.8))
	await touch(point, true)
	for step in range(8):
		var event := InputEventScreenDrag.new()
		event.relative = Vector2(0, -9)
		point += event.relative
		event.position = point
		Input.parse_input_event(event)
		await frames(2)
	await touch(point, false)
	await frames()

func capture(name: String) -> void:
	if output.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name + ".png"))

func memories() -> void:
	await open_scene("res://scenes/mision_2_memorias/mision_2_memorias.tscn")
	var game := current_scene
	var selector: Control = game.selector
	check(game.puerta.mouse_filter == Control.MOUSE_FILTER_IGNORE, "La puerta invisible no intercepta el selector")
	var emotions := ["felicidad", "tristeza", "enojo", "asombro", "ansiedad", "desagrado", "amor"]
	var cards: Array = game.cuadros_container.get_children()
	# Cancelar no guarda ni completa recuerdos.
	await tap(cards[0])
	await create_timer(0.8).timeout
	await tap(selector.emojis_container.get_node("EmotionName_amor"))
	await tap(selector.get_node("BotonCancelar"))
	await create_timer(0.35).timeout
	check(not cards[0].completado and game.cuadros_completados == 0, "Cancelar conserva el recuerdo pendiente")
	for index in range(cards.size()):
		await tap(cards[index])
		await create_timer(0.8).timeout
		check(selector.visible, "El dibujo abre el selector")
		if index % 2 == 0:
			await tap(selector.emojis_container.get_node("EmotionName_" + emotions[index]))
		else:
			for emoji: Node in selector.emojis_container.get_children():
				if emoji is TextureButton and emoji.emocion_id == emotions[index]:
					await tap(emoji)
		check(selector.emocion_seleccionada == emotions[index], "Se elige emoción por icono o nombre")
		check(not selector.boton_confirmar.disabled, "Confirmar queda activo")
		await capture("%d_selector_%d" % [root.size.x, index])
		await tap(selector.boton_confirmar)
		await create_timer(0.4).timeout
		check(cards[index].completado, "Confirmar completa el recuerdo %d" % index)
		check(cards[index].emocion_asignada == emotions[index], "Se guarda la emoción elegida")
		check(game.cuadros_completados == index + 1, "El contador aumenta una sola vez")
		check(not selector.visible, "Confirmar cierra el selector")
		if not cards[index].completado:
			return
	await create_timer(5.5).timeout
	check(not game.puerta.disabled, "La puerta se activa tras los siete recuerdos")
	check(game.puerta.mouse_filter == Control.MOUSE_FILTER_STOP, "La puerta revelada recibe toques")
	await capture("%d_recuerdos_completos" % root.size.x)
	await tap(game.puerta)
	await create_timer(0.7).timeout
	check(current_scene.has_method("responder"), "Tocar la puerta abre el cuestionario")

func dialogues() -> void:
	await open_scene("res://dialogos/ManagerDialogos/dialogue_ui.tscn")
	var ui: Node = current_scene.get_node("Balloon")
	var source := "~ start\nNarrador: " + "Este párrafo es largo y debe poder leerse completo sin avanzar al deslizar. ".repeat(12)
	source += "\nNarrador: Segunda línea, antes de tomar una decisión.\n"
	for index in range(5):
		source += "- Opción %d: %s\n\tNarrador: Elegiste %d.\n\t=> END\n" % [index, "Una decisión extensa con varias frases que hay que desplazar para poder leer. ".repeat(5), index]
	var resource: DialogueResource = root.get_node("DialogueManager").create_resource_from_text(source)
	await ui.iniciar_dialogo(resource)
	ui.type_timer.stop()
	await frames()
	var first: DialogueLine = ui.current_line
	await touch(screen_point(ui, Vector2(900, 200)), true)
	await touch(screen_point(ui, Vector2(900, 200)), false)
	check(ui.current_line == first and not ui.line_finished, "Tocar fuera del diálogo no lo adelanta")
	var accept := InputEventAction.new()
	accept.action = &"ui_accept"
	accept.pressed = true
	ui._unhandled_input(accept)
	check(ui.current_line == first and not ui.line_finished, "El avance global no evita el botón móvil")
	await drag(ui._mobile_scroll)
	check(ui.current_line == first and not ui.line_finished, "Deslizar no completa ni cambia la línea en escritura")
	await tap(ui.label)
	check(ui.current_line == first and not ui.line_finished, "Tocar el texto no completa ni cambia la línea")
	await tap(ui._mobile_continue)
	check(ui.line_finished and ui.current_line == first, "Continuar completa la escritura sin saltar la línea")
	await drag(ui._mobile_scroll)
	check(ui.current_line == first, "Deslizar el diálogo completo no pasa de línea")
	check(ui._mobile_scroll.scroll_vertical > 0, "El gesto desplaza el diálogo largo")
	await capture("%d_dialogo_desplazado" % root.size.x)
	await tap(ui._mobile_continue)
	check(ui.current_line != first and ui.current_line.text.begins_with("Segunda"), "Sólo Continuar avanza a la siguiente línea")
	ui.type_timer.stop()
	await tap(ui._mobile_continue)
	check(ui.responses_menu.visible, "Continuar muestra las decisiones")
	check(not ui._mobile_continue.visible, "No se salta una decisión con Continuar")
	var decision: DialogueLine = ui.current_line
	var responses: ScrollContainer = ui._mobile_responses
	check(responses.get_v_scroll_bar().max_value > responses.get_v_scroll_bar().page, "Las opciones largas tienen desplazamiento")
	for item: Button in ui.responses_menu.get_menu_items():
		check(item.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Las opciones largas se envuelven")
		check(item.size.x <= responses.size.x, "Las opciones no necesitan desplazamiento horizontal")
	var point := screen_point(responses, Vector2(responses.size.x / 2, 40))
	await touch(point, true)
	check(ui.current_line == decision, "Empezar a tocar una opción no la elige")
	await touch(point, false)
	# Volver a la decisión para probar un arrastre que empieza sobre un botón.
	ui.current_line = decision
	ui._mostrar_linea()
	ui.type_timer.stop()
	ui._gestionar_avance()
	await frames()
	await drag(responses)
	check(ui.current_line == decision and ui.responses_menu.visible, "Arrastrar sobre una opción no la selecciona")
	check(responses.scroll_vertical > 0, "Se desplazan opciones empezando sobre su texto")
	await capture("%d_opciones_desplazadas" % root.size.x)
	responses.scroll_vertical = 100000
	await frames()
	var last: Button = ui.responses_menu.get_menu_items()[-1]
	var last_rect: Rect2 = last.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, last.size)
	var visible_rect: Rect2 = responses.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, responses.size)
	var visible_part := last_rect.intersection(visible_rect)
	check(visible_part.has_area(), "La última opción se alcanza al desplazar")
	point = root.get_final_transform() * visible_part.get_center()
	await touch(point, true)
	check(ui.current_line == decision, "La última opción tampoco se elige al presionar")
	await touch(point, false)
	await frames()
	check(ui.current_line.text == "Elegiste 4.", "Soltar sobre la última opción la elige una sola vez")
	ui.type_timer.stop()

func desktop_dialogue() -> void:
	root.size = Vector2i(960, 540)
	await open_scene("res://dialogos/ManagerDialogos/dialogue_ui.tscn")
	var ui: Node = current_scene.get_node("Balloon")
	var resource: DialogueResource = root.get_node("DialogueManager").create_resource_from_text("~ start\nNarrador: Primera línea de escritorio.\nNarrador: Segunda línea de escritorio.\n- Opción uno\n\tNarrador: Primera opción.\n\t=> END\n- Opción dos\n\tNarrador: Segunda opción.\n\t=> END")
	await ui.iniciar_dialogo(resource)
	ui.type_timer.stop()
	await frames()
	check(ui._mobile_continue == null, "Escritorio conserva su interfaz")
	await tap(ui)
	check(ui.line_finished, "El clic de escritorio completa la escritura")
	await tap(ui)
	check(ui.current_line.text.begins_with("Segunda línea"), "El clic de escritorio avanza")
	ui.type_timer.stop()
	var accept := InputEventAction.new()
	accept.action = &"ui_accept"
	accept.pressed = true
	ui._unhandled_input(accept)
	await frames()
	check(ui.responses_menu.visible, "El teclado muestra las respuestas en escritorio")
	var item: Control = ui.responses_menu.get_menu_items()[1]
	var point := screen_point(item)
	await touch(point, true)
	check(ui.current_line.text == "Segunda opción.", "Las decisiones de escritorio conservan selección al presionar")
	await touch(point, false)
	ui.type_timer.stop()

func run() -> void:
	if root.get_node("MobileControlsSettings").is_mobile_device():
		check(root.get_node("MobileControlsSettings").is_mobile_device(), "Perfil de prueba móvil activo")
		for resolution: Vector2i in [Vector2i(640, 360), Vector2i(854, 480)]:
			root.size = resolution
			await memories()
			await dialogues()
			print("RECUERDOS_DIALOGOS resolución=", resolution, " fallos=", failures)
	else:
		await desktop_dialogue()
	current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.5).timeout
	print("RECUERDOS_DIALOGOS: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)
