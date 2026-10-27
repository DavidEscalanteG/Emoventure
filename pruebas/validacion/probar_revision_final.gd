extends SceneTree

## Pruebas de regresión de muerte, puerta, botones, tutoriales y exportación.
## Usa APPDATA separado; no escribe partidas ni pulsa respuestas del cuestionario.
var fallos: int = 0
var comprobaciones: int = 0
var _clics: int = 0


func _initialize() -> void:
	call_deferred("_ejecutar")


func _comprobar(condicion: bool, mensaje: String) -> void:
	comprobaciones += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)


func _abrir(ruta: String) -> void:
	change_scene_to_file(ruta)
	await scene_changed
	await process_frame
	await process_frame


func _ejecutar() -> void:
	root.size = Vector2i(1920, 1080)
	await _probar_muerte()
	await _probar_memorias()
	await _probar_botones()
	await _probar_tutoriales()
	await _probar_pdf()
	current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	print("REVISION FINAL: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)


func _probar_muerte() -> void:
	var mapas: Array[String] = ["res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn"]
	mapas.append_array(root.get_node("GameManager").MAPAS_MINIJUEGO_1)
	for mapa: String in mapas:
		for emocion: String in ["alegria", "tristeza", "enojo", "desagrado", "sorpresa"]:
			await _abrir(mapa)
			var jugador: CharacterBody2D = root.get_node("DatosJugador").jugador
			jugador.vidas_actuales = 1
			jugador.aplicar_emocion(emocion, Color.WHITE, 0.08)
			jugador.recibir_danio()
			_comprobar(jugador.nivel_terminado and not jugador.puede_moverse, "La muerte bloquea al jugador con " + emocion)
			_comprobar(jugador.timer_emocion.is_stopped() and jugador.timer_congelar.is_stopped(), "La muerte cancela los temporizadores inmediatamente")
			await create_timer(0.15).timeout
			# Reproduce callbacks pendientes y órdenes externas después de morir.
			jugador.terminar_emocion()
			jugador._alternar_congelamiento()
			jugador.permitir_movimiento()
			jugador.aplicar_emocion("desagrado", Color.WHITE, 1.0)
			jugador.recibir_danio()
			_comprobar(not jugador.puede_moverse and jugador.vidas_actuales == 0, "Ningún callback reactiva al jugador muerto: " + emocion)
			_comprobar(jugador.timer_emocion.is_stopped() and jugador.timer_congelar.is_stopped(), "Muerte cancela ambos temporizadores")
			var posicion: Vector2 = jugador.global_position
			Input.action_press("move_right")
			await physics_frame
			await physics_frame
			Input.action_release("move_right")
			_comprobar(jugador.global_position.is_equal_approx(posicion), "El jugador muerto no se desplaza")
			current_scene._on_todas_las_emociones_recolectadas()
			_comprobar(current_scene.game_over_ui.visible and not current_scene.level_complete_ui.visible, "No puede ganar después de morir")
			for enemigo: Node in get_nodes_in_group("enemigos"):
				if enemigo.get("puede_moverse") != null:
					_comprobar(not enemigo.puede_moverse, "Enemigo detenido durante game over")
		# El botón real de reinicio debe crear una partida con movimiento normal.
		current_scene.game_over_ui._on_reiniciar_pressed()
		await scene_changed
		await physics_frame
		var jugador: CharacterBody2D = root.get_node("DatosJugador").jugador
		_comprobar(jugador.puede_moverse and jugador.vidas_actuales == jugador.vidas_maximas, "Reinicio restaura al jugador")
		for enemigo: Node in get_nodes_in_group("enemigos"):
			if enemigo.get("puede_moverse") != null:
				var posicion: Vector2 = enemigo.global_position
				await physics_frame
				await physics_frame
				_comprobar(enemigo.puede_moverse and not enemigo.global_position.is_equal_approx(posicion), "Serpiente se mueve al reiniciar")
	print("Laberinto: muerte con las cinco emociones y reinicio en los cinco mapas comprobados")


func _probar_memorias() -> void:
	await _abrir("res://scenes/mision_2_memorias/mision_2_memorias.tscn")
	_comprobar(not current_scene.puerta.get_node("GuiaVisual").visible and current_scene.puerta.disabled, "Puerta y guía inactivas antes de completar recuerdos")
	for cuadro: Node in current_scene.cuadros_container.get_children():
		cuadro.emocion_asignada = "felicidad"
		cuadro.marcar_completado(Color.WHITE)
	await create_timer(0.9).timeout
	_comprobar(current_scene.texto_retroalimentacion.visible and current_scene.puerta.disabled, "La última reflexión aparece antes de la guía")
	await create_timer(4.6).timeout
	var puerta: TextureButton = current_scene.puerta
	var guia: Control = puerta.get_node("GuiaVisual")
	_comprobar(guia.visible and not puerta.disabled, "Tras la reflexión aparecen puerta y guía visual")
	_comprobar(not current_scene.has_node("IndicacionPuerta"), "La guía sustituye la instrucción escrita")
	_comprobar(guia.mouse_filter == Control.MOUSE_FILTER_IGNORE, "El halo no intercepta la interacción")
	_comprobar(guia.get_node("ManoTocar").mouse_filter == Control.MOUSE_FILTER_IGNORE, "La mano no intercepta la interacción")
	var zona_guia: Rect2 = Rect2(puerta.global_position + guia.zona_puerta.position, guia.zona_puerta.size).grow(26.0)
	_comprobar(not zona_guia.intersects(current_scene.texto_contador.get_global_rect()), "La guía no tapa el contador")
	for cuadro: Control in current_scene.cuadros_container.get_children():
		_comprobar(not zona_guia.intersects(cuadro.get_global_rect()), "La guía no tapa las fotografías")
	_comprobar(current_scene.puerta.texture_click_mask != null, "Puerta usa máscara para excluir márgenes transparentes")
	_comprobar(not current_scene.puerta.texture_click_mask.get_bit(0, 0), "Margen transparente de puerta no recibe clics")
	_comprobar(current_scene.puerta.texture_click_mask.get_bit(250, 250), "Centro visible de puerta recibe clics")


func _pulsar(posicion: Vector2, presionado: bool) -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.position = posicion
	evento.global_position = posicion
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = presionado
	root.push_input(evento)


func _probar_botones() -> void:
	var cuestionario: Control = load("res://scenes/cuestionarios/EscenaCuestionario.tscn").instantiate()
	cuestionario.dimension = "atencion"
	cuestionario.preguntas = root.get_node("Cuestionarios").obtener_preguntas_para_dimension("atencion")
	current_scene.queue_free()
	await process_frame
	root.add_child(cuestionario)
	current_scene = cuestionario
	await process_frame
	await process_frame
	for boton: Button in cuestionario.botones_opciones:
		for conexion: Dictionary in boton.pressed.get_connections():
			boton.pressed.disconnect(conexion.callable)
		boton.pressed.connect(func() -> void: _clics += 1)
	for boton: Button in cuestionario.botones_opciones:
		boton.grab_focus()
		await create_timer(0.1).timeout
		_comprobar(boton.scale == Vector2.ONE, "El foco no amplía el área del botón")
		for estado: String in ["normal", "hover", "pressed", "disabled"]:
			var estilo: StyleBox = boton.get_theme_stylebox(estado)
			var ancho_texto: float = boton.get_theme_font("font").get_string_size(boton.text, HORIZONTAL_ALIGNMENT_LEFT, -1, boton.get_theme_font_size("font_size")).x
			_comprobar(ancho_texto <= boton.size.x - estilo.get_margin(SIDE_LEFT) - estilo.get_margin(SIDE_RIGHT), "Texto cabe en " + boton.text + ": " + estado)
		for otro: Button in cuestionario.botones_opciones:
			if otro != boton:
				_comprobar(not boton.get_global_rect().intersects(otro.get_global_rect()), "Opciones sin áreas superpuestas")
		var antes: int = _clics
		_pulsar(boton.get_global_rect().get_center(), true)
		_pulsar(boton.get_global_rect().get_center(), false)
		_comprobar(_clics == antes + 1, "El centro visible activa exactamente una opción")
	var antes: int = _clics
	_pulsar(Vector2(960, 450), true)
	_pulsar(Vector2(960, 450), false)
	_comprobar(_clics == antes, "Un clic fuera de los botones no responde el cuestionario")


func _probar_tutoriales() -> void:
	for ruta: String in ["res://scenes/mision_3_nuevo/tutorial/Minijuego3_Tutorial.tscn", "res://scenes/mision_4_payasos/tutorial/Minijuego4_Tutorial.tscn"]:
		await _abrir(ruta)
		_comprobar(current_scene.message_label.get_theme_font_size("font_size") == 42, "Tutorial usa mensaje de 42 como misión 1")
		for mensaje: String in current_scene.MESSAGES:
			current_scene.message_label.text = mensaje
			await process_frame
			await process_frame
			_comprobar(current_scene.bottom_panel.get_global_rect().encloses(current_scene.message_label.get_global_rect()), "Mensaje de tutorial cabe en el panel")
			_comprobar(current_scene.message_label.get_line_count() <= current_scene.message_label.get_visible_line_count(), "Mensaje de tutorial sin líneas recortadas")


func _probar_pdf() -> void:
	await _abrir("res://scenes/final/resultado_final.tscn")
	var directorio: String = OS.get_environment("CODEX_PDF_CAPTURE_DIR")
	if directorio.is_empty():
		directorio = "user://revision_pdf"
	DirAccess.make_dir_recursive_absolute(directorio)
	var datos: Node = root.get_node("DatosJugador")
	var manager: Node = root.get_node("GameManager")
	for genero: String in ["hombre", "mujer"]:
		datos.genero = genero
		datos.nombre_jugador = "María José Muñoz (revisión)"
		for puntaje: int in [8, 28, 40]:
			manager.cargar_puntajes_desde_guardado(0, {"atencion": puntaje, "claridad": puntaje, "reparacion": puntaje})
			_comprobar(current_scene._guardar_reporte_pdf(directorio.path_join("%s_%d.pdf" % [genero, puntaje])), "Exportación de PDF con acentos")
	# Ejercita ajuste de palabras largas y saltos de página.
	datos.nombre_jugador = "ÁÉÍÓÚüñ\\".repeat(140)
	_comprobar(current_scene._guardar_reporte_pdf(directorio.path_join("nombre_largo.pdf")), "Exportación con nombre largo")
