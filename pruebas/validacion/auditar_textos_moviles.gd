extends SceneTree
## Renderiza textos reales con un perfil de usuario aislado. No escribe partidas.

var output_dir := ""
var records: Array[Dictionary] = []
var cases: Array[Dictionary] = []
var scenario := ""
var capture_count := 0
var mobile_size := Vector2i(854, 480)
var focused_scene := ""

func _initialize() -> void:
	call_deferred("run_audit")

func frames(count: int = 4) -> void:
	for i in range(count):
		await process_frame

func run_audit() -> void:
	output_dir = OS.get_environment("EMO_TEXT_AUDIT_DIR")
	focused_scene = OS.get_environment("EMO_TEXT_AUDIT_SCENE")
	if output_dir.is_empty():
		push_error("Falta EMO_TEXT_AUDIT_DIR; se requiere un directorio de evidencias.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output_dir)
	var paths: Array[String] = []
	find_files("res://scenes", ".tscn", paths)
	paths.sort()
	for window_size: Vector2i in [Vector2i(854, 480), Vector2i(640, 360)]:
		mobile_size = window_size
		root.size = window_size
		for path: String in paths:
			if not focused_scene.is_empty() and path != focused_scene:
				continue
			if path.contains("/mision_3_hachas/") or path.ends_with("EscenaCuestionario.tscn") or path.ends_with("Topo.tscn") or path.ends_with("estela_particulas.tscn") or path.ends_with("JugadorBase.tscn") or path.ends_with("editor_color.tscn") or path.ends_with("Checkpoint.tscn"):
				continue
			await open_scene(path)
			if current_scene == null:
				continue
			scenario = path
			complete_visible_dialogue(current_scene)
			await frames()
			await inspect_case(true)
			if path.contains("Tutorial.tscn"):
				var steps: int = current_scene.get_script().get_script_constant_map().get("STEP_COUNT", 5)
				for step in range(1, steps):
					if current_scene.has_method("_go_to_step"):
						current_scene.call("_go_to_step", step)
					elif current_scene.has_method("_show_step"):
						current_scene.call("_show_step", step)
					await frames(12)
					scenario = path + "#step_" + str(step)
					await inspect_case(true)
			if path.contains("/mision_1_recoleccion/") and not path.contains("/tutorial/"):
				var emotions: Array[String] = ["alegria", "tristeza", "enojo", "desagrado", "sorpresa"]
				await current_scene.get_node("NivelCompletadoUI/Control").mostrar(emotions, 3)
				await frames(4)
				scenario = path + "#victory"
				await inspect_case(true)
			if path.ends_with("mapa_topos.tscn"):
				current_scene.call("_finalizar_mision")
				await frames()
				scenario = path + "#defeat"
				await inspect_case(true)
		if focused_scene.is_empty():
			await audit_edges()
			await audit_questions()
			await audit_dialogues()
		print("TEXT_AUDIT resolution_done=", window_size, " cases=", cases.size(), " texts=", records.size())
	var result := {"cases": cases, "texts": records, "captures": capture_count, "criterion": "Candidato a texto pequeño si su fuente nominal renderizada es menor a 14 px. No certifica legibilidad en un teléfono físico."}
	var file := FileAccess.open(output_dir.path_join("audit.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
	print("TEXT_AUDIT DONE cases=", cases.size(), " texts=", records.size(), " captures=", capture_count)
	if current_scene != null:
		current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	quit()

func find_files(directory: String, extension: String, paths: Array[String]) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.ends_with(extension):
			paths.append(directory.path_join(file))
	for subdir in DirAccess.get_directories_at(directory):
		find_files(directory.path_join(subdir), extension, paths)

func open_scene(path: String) -> void:
	paused = false
	root.get_node("DialogueActors").reiniciar_estado_cinematica()
	root.get_node("DialogueActors")._registro_actores._actores.clear()
	change_scene_to_file(path)
	await scene_changed
	await frames(24)

func complete_visible_dialogue(node: Node) -> void:
	if node.get_script() != null and node.get_script().resource_path == "res://dialogos/ManagerDialogos/dialogue_ui.gd":
		node.type_timer.stop()
		node.type_sound.stop()
		node.label.visible_characters = -1
		node.line_finished = true
	for child in node.get_children():
		complete_visible_dialogue(child)

func inspect_case(capture: bool) -> void:
	var start := records.size()
	collect_texts(current_scene)
	var id := "%dx%d_%04d" % [mobile_size.x, mobile_size.y, cases.size()]
	cases.append({"id": id, "scenario": scenario, "texts_start": start, "texts_count": records.size() - start})
	if capture and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output_dir.path_join(id + ".png"))
		capture_count += 1

func collect_texts(node: Node) -> void:
	if (node is Label or node is RichTextLabel or node is Button or node is LineEdit) and node.is_visible_in_tree():
		var text: String = node.text
		if not text.strip_edges().is_empty():
			var key := "normal_font_size" if node is RichTextLabel else "font_size"
			var font_size: int = node.get_theme_font_size(key)
			var logical_transform: Transform2D = node.get_global_transform_with_canvas()
			var physical_transform: Transform2D = root.get_final_transform() * logical_transform
			var logical_rect: Rect2 = logical_transform * Rect2(Vector2.ZERO, node.size)
			var visible_rect := root.get_visible_rect()
			var scroll_ancestor := false
			var ancestor: Node = node.get_parent()
			while ancestor != null:
				if ancestor is ScrollContainer:
					scroll_ancestor = true
				ancestor = ancestor.get_parent()
			var clipped := false
			if node is RichTextLabel:
				clipped = node.get_content_height() > node.size.y + 2.0
			elif node is Label:
				clipped = node.get_line_count() > node.get_visible_line_count()
			records.append({"scenario": scenario, "resolution": str(mobile_size), "node": str(node.get_path()), "text": text, "font": font_size, "rendered_font_px": snappedf(font_size * physical_transform.x.length(), 0.01), "rect": var_to_str(logical_rect), "small": font_size * physical_transform.x.length() < 14.0, "outside_viewport": not visible_rect.grow(2).encloses(logical_rect), "scrollable": scroll_ancestor, "clipped": clipped})
	for child in node.get_children():
		collect_texts(child)

func audit_questions() -> void:
	for dimension: String in ["atencion", "claridad", "reparacion"]:
		var questions: Array[String] = root.get_node("Cuestionarios").obtener_preguntas_para_dimension(dimension)
		for index in range(questions.size()):
			paused = false
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
			await frames(8)
			scenario = "questionnaire#" + dimension + "_cold_" + str(index)
			await inspect_case(true)

func audit_edges() -> void:
	var saves := root.get_node("SaveManager")
	saves._partidas = [{"id": "text-audit-only", "nombre_jugador": "Alejandra Fernanda", "nombre_mascota": "Compañero de aventura", "escena_actual": "res://scenes/final/resultado_final.tscn", "puntaje_total": 120, "updated_at": "2026-11-01T12:00:00", "apariencia": {}}]
	await open_scene("res://scenes/menu_guardados/menu_guardados.tscn")
	scenario = "saved_games#long_names"
	await inspect_case(true)
	saves._partidas.clear()
	await open_scene("res://scenes/creditos/creditos.tscn")
	var credits: ScrollContainer = current_scene.get_node("MargenPrincipal/Contenido/ScrollContainer")
	credits.scroll_vertical = 100000
	await frames()
	scenario = "credits#bottom"
	await inspect_case(true)
	await open_scene("res://scenes/final/resultado_final.tscn")
	for gender: String in ["hombre", "mujer"]:
		root.get_node("DatosJugador").genero = gender
		for scores: Array in [[8, 8, 8], [26, 30, 30], [40, 40, 40], [8, 30, 40], [40, 8, 30], [30, 40, 8]]:
			root.get_node("GameManager").cargar_puntajes_desde_guardado(0, {"atencion": scores[0], "claridad": scores[1], "reparacion": scores[2]})
			current_scene._renderizar_resumen()
			await frames()
			scenario = "results#" + gender + str(scores)
			await inspect_case(true)
	current_scene.boton_descargar_pdf.text = current_scene.TEXTO_BOTON_DESCARGA_EXITOSA + " (10)"
	var result_scroll := current_scene.find_child("MobileScroll", true, false) as ScrollContainer
	if result_scroll != null:
		result_scroll.scroll_vertical = 100000
	await frames()
	scenario = "results#download_message_bottom"
	await inspect_case(true)
	await open_scene("res://scenes/mision_2_memorias/mision_2_memorias.tscn")
	var selector: Control = current_scene.get_node("SelectorEmocion")
	selector.mostrar(current_scene.get_node("CuadrosContainer/CuadroMemoria_00"))
	await frames(30)
	scenario = "memories#selector_unselected"
	await inspect_case(true)
	for option: Node in selector.emojis_container.get_children():
		if option is TextureButton:
			selector.seleccionar_emocion(option.emocion_id, option)
			await frames()
			scenario = "memories#selector_" + option.emocion_id
			await inspect_case(true)
	selector.cancelar_seleccion()
	await frames(30)
	var constants: Dictionary = current_scene.get_script().get_script_constant_map()
	var messages: Array = constants.MENSAJES_RETROALIMENTACION_GENERICO.duplicate()
	for group: Array in constants.MENSAJES_RETROALIMENTACION_POR_EMOCION.values():
		messages.append_array(group)
	var longest := ""
	for message: String in messages:
		if message.length() > longest.length():
			longest = message
	for index in range(messages.size()):
		var label: Label = current_scene.get_node("Retroalimentacion")
		label.text = messages[index]
		label.show()
		label.modulate.a = 1.0
		await frames()
		scenario = "memories#feedback_" + str(index)
		await inspect_case(messages[index] == longest)
	await open_scene("res://scenes/mision_4_payasos/mapa_topos.tscn")
	current_scene.puntos = 45
	current_scene.total_topos_aparecidos = 50
	current_scene._finalizar_mision()
	await frames()
	scenario = "clowns#victory"
	await inspect_case(true)
	current_scene.intentos_mision_4 = 4
	current_scene.puntos = 9
	current_scene._mostrar_derrota({"porcentaje_aciertos": 0.15, "total_aparecidos": 60})
	await frames()
	scenario = "clowns#defeat_two_actions"
	await inspect_case(true)

func audit_dialogues() -> void:
	if current_scene != null:
		var previous := current_scene
		root.remove_child(previous)
		previous.queue_free()
	var layout: Node = load("res://dialogos/ManagerDialogos/dialogue_ui.tscn").instantiate()
	root.add_child(layout)
	current_scene = layout
	var ui: Node = layout.get_node("Balloon")
	await frames()
	var paths: Array[String] = []
	find_files("res://dialogos", ".dialogue", paths)
	paths.sort()
	for path in paths:
		var resource: Resource = load(path)
		if resource == null:
			continue
		var longest := 0
		for value: Dictionary in resource.lines.values():
			if value.get("type", "") == "dialogue":
				longest = maxi(longest, str(value.get("text", "")).length())
		for key in resource.lines:
			var value: Dictionary = resource.lines[key]
			if value.get("type", "") != "dialogue" and value.get("type", "") != "response":
				continue
			var line := DialogueLine.new()
			line.character = str(value.get("character", "Narrador")).replace("{{DatosJugador.nombre_mascota}}", "Compañero de aventura")
			line.text = str(value.get("text", "")).replace("{{DatosJugador.nombre_jugador}}", "Alejandra Fernanda").replace("{{DatosJugador.nombre_mascota}}", "Compañero de aventura")
			ui.current_line = line
			ui._mostrar_linea()
			ui.type_timer.stop()
			ui.type_sound.stop()
			ui.label.visible_characters = -1
			if value.get("type", "") == "response":
				var response := DialogueResponse.new()
				response.text = line.text
				ui.responses_menu.responses = [response]
				ui.responses_menu.show()
			await frames(3)
			scenario = path + "#line_" + str(key)
			await inspect_case(line.text.length() == longest or value.get("type", "") == "response")
