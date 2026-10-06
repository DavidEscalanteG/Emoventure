extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FALLO: " + message)
	else:
		print("OK: ", message)

func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func _open(path: String) -> void:
	change_scene_to_file(path)
	await scene_changed
	await process_frame

func _run() -> void:
	await _open("res://scenes/mision_3_hachas/nivel_1.tscn")
	var level := current_scene
	var player: CharacterBody2D = level.get_node("Jugador")
	await _frames(60)
	_check(is_instance_valid(level) and current_scene == level, "El suelo normal no mata al jugador")
	if not is_instance_valid(player):
		quit(1)
		return
	var start := player.position
	Input.action_press("ui_right")
	await _frames(15)
	Input.action_release("ui_right")
	_check(player.position.x > start.x, "Movimiento mediante acciones de entrada")
	Input.action_press("ui_accept")
	await _frames(3)
	_check(player.velocity.y < 0.0, "El salto despega del suelo")
	Input.action_release("ui_accept")
	await _frames(40)
	var overlay := level.get_node("PauseOverlay")
	overlay._set_pausa_activa(true)
	start = player.position
	await create_timer(0.1, true).timeout
	_check(paused and player.position == start, "La pausa detiene el movimiento")
	overlay._set_pausa_activa(false)
	_check(not paused, "Reanudar libera la pausa")
	player.morir()
	player.morir()
	await _frames(5)
	_check(current_scene != level, "La muerte reinicia una sola escena")

	await _open("res://scenes/mision_3_hachas/nivel2.tscn")
	var hazard_scene := current_scene
	var tiles: TileMapLayer = current_scene.get_node("TileMapLayer")
	var found_hazard := false
	for cell in tiles.get_used_cells():
		var data := tiles.get_cell_tile_data(cell)
		if data != null and data.get_collision_polygons_count(1) > 0:
			current_scene.get_node("Jugador").global_position = tiles.to_global(tiles.map_to_local(cell))
			found_hazard = true
			break
	_check(found_hazard, "El nivel contiene púas con colisión de daño")
	await _frames(10)
	await process_frame
	_check(not is_instance_valid(hazard_scene), "Las púas reinician el nivel al tocarlas")

	await _open("res://scenes/mision_3_hachas/mision_3_hachas.tscn")
	for number in range(1, 11):
		var expected := "mision_3_hachas.tscn" if number == 1 else "nivel%d.tscn" % number
		_check(current_scene.scene_file_path.get_file() == expected, "Secuencia del nivel %d" % number)
		var level_id := current_scene.get_instance_id()
		await _frames(60)
		_check(current_scene.get_instance_id() == level_id, "Spawn estable del nivel %d" % number)
		var gate := current_scene.get_node("Meta")
		var actor := current_scene.get_node("Jugador")
		actor.global_position = gate.global_position
		actor.velocity = Vector2.ZERO
		# Comprobar la señal real de colisión, no solo llamar al callback.
		await _frames(5)
		await process_frame
		await process_frame
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/cuestionarios/EscenaCuestionario.tscn", "El nivel 10 abre el cuestionario")
	if current_scene.scene_file_path == "res://scenes/cuestionarios/EscenaCuestionario.tscn":
		_check(current_scene.preguntas.size() == 4, "Cuatro preguntas de la misión 3")
		_check(current_scene.escena_siguiente != null, "El cuestionario tiene recompensa")
	var saves := root.get_node("SaveManager")
	_check(saves._debe_redirigir_mapa_rejugabilidad({"progreso_historia_bloqueado_100": true}, "res://scenes/mision_3_nuevo/minijuego3.tscn"), "Guardado completado redirige al mapa al cargar el minijuego 3 actual")
	root.get_node("GameManager").activar_modo_rejugabilidad()
	await _open("res://scenes/mision_3_hachas/nivel10.tscn")
	current_scene.get_node("Meta")._on_body_entered(current_scene.get_node("Jugador"))
	await process_frame
	await process_frame
	await process_frame
	_check(current_scene.scene_file_path == "res://scenes/rejugabilidad/mapa_rejugabilidad.tscn", "Rejugabilidad vuelve al mapa sin repetir cuestionario")
	var settings := root.get_node("MobileControlsSettings")
	var previous_mode: String = settings.control_mode
	settings.control_mode = settings.MODE_CRUCETA
	var controls: Node = load("res://src/ui/mobile_controls.tscn").instantiate()
	root.add_child(controls)
	controls.set_process(false)
	controls._on_btn_right_button_down()
	controls._apply_mode()
	_check(Input.is_action_pressed("move_right"), "La cruceta mantiene la pulsación")
	controls._on_btn_right_button_up()
	_check(not Input.is_action_pressed("move_right"), "La cruceta libera la pulsación")
	var touch: TouchScreenButton = controls.get_node("UI/Cruceta/BtnRight")
	_check(touch.texture_normal != null and touch.shape != null, "La cruceta tiene imagen y zona táctil")
	controls.free()
	settings.control_mode = previous_mode

	# Esta parte solo escribe en el perfil temporal de validación.
	if ProjectSettings.get_setting("application/config/name") == "EmoventureValidation":
		saves.preparar_nueva_partida()
		await _open("res://scenes/mision_3_hachas/nivel3.tscn")
		saves.confirmar_guardado_inicial(current_scene.scene_file_path)
		var slot: String = saves.current_slot_id
		await _open("res://scenes/mision_3_hachas/nivel4.tscn")
		await process_frame
		_check(saves._obtener_partida_por_id(slot).escena_actual.ends_with("nivel4.tscn"), "El guardado conserva el subnivel alcanzado")
		await _open("res://scenes/menu_principal/menu_principal.tscn")
		saves.cargar_partida(slot)
		await scene_changed
		_check(current_scene.scene_file_path.ends_with("nivel4.tscn"), "Cargar partida reanuda el subnivel")
	await _open("res://scenes/mision_1_recoleccion/mapa_2/mapa2.tscn")
	var collection := current_scene
	collection._timer_generacion_fuego.stop()
	collection.cantidad_fuegos_por_oleada = 1
	collection.tiempo_indicador_fuego = 0.1
	collection.tiempo_activo_fuego = 0.1
	collection.tiempo_parpadeo_fuego = 0.05
	collection._intentar_generar_fuegos()
	await create_timer(0.15).timeout
	_check(collection._fuegos_activos.size() == 1, "El indicador genera un fuego")
	paused = true
	await create_timer(0.3, true).timeout
	_check(collection._fuegos_activos.size() == 1, "La pausa detiene el ciclo del fuego")
	paused = false
	await create_timer(1.0).timeout
	_check(collection._fuegos_activos.is_empty() and collection._intersecciones_reservadas.is_empty(), "El fuego se extingue y libera su intersección")
	print("FUNCIONAMIENTO: %d fallos" % failures)
	await _open("res://scenes/menu_principal/menu_principal.tscn")
	await create_timer(0.3).timeout
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.25).timeout
	quit(1 if failures else 0)
