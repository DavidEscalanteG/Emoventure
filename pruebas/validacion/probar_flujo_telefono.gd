extends SceneTree

var checks := 0
var failures := 0
var output := OS.get_environment("EMO_PHONE_OUTPUT")

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 12) -> void:
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

func capture(name: String) -> void:
	if output.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name + ".png"))

func screen_rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, control.size)

func tap(button: BaseButton) -> void:
	var point: Vector2 = root.get_final_transform() * screen_rect(button).get_center()
	var down := InputEventScreenTouch.new()
	down.position = point
	down.pressed = true
	Input.parse_input_event(down)
	# parse_input_event no realiza la conversión que el sistema de ventanas
	# aplica al dedo en Android: enviar también su clic de ratón emulado.
	var mouse := InputEventMouseButton.new()
	mouse.device = -1
	mouse.position = point
	mouse.global_position = point
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	Input.parse_input_event(mouse)
	await frames(2)
	var up := InputEventScreenTouch.new()
	up.position = point
	Input.parse_input_event(up)
	mouse = InputEventMouseButton.new()
	mouse.device = -1
	mouse.position = point
	mouse.global_position = point
	mouse.button_index = MOUSE_BUTTON_LEFT
	Input.parse_input_event(mouse)
	await frames()

func check_reward() -> void:
	var reward := current_scene
	var content: Control = reward.get_node("Contenido")
	var key: TextureRect = content.get_node("Llave")
	check(content.scale.is_equal_approx(Vector2.ONE), "La recompensa debe tener escala normal desde el inicio")
	check(key.is_visible_in_tree() and key.texture != null, "Debe aparecer la llave")
	check(reward.boton.is_visible_in_tree() and not reward.boton.disabled, "Debe aparecer Continuar activo")
	check(root.get_visible_rect().encloses(key.get_global_rect()), "La llave debe caber en pantalla")
	check(root.get_visible_rect().encloses(reward.boton.get_global_rect()), "Continuar debe caber en pantalla")
	check(reward.boton.size.y >= 104, "Continuar necesita altura táctil")

func run() -> void:
	var mobile: bool = root.get_node("MobileControlsSettings").is_mobile_device()
	var resolutions := [Vector2i(640, 360), Vector2i(854, 480), Vector2i(1280, 576)]
	if not mobile:
		resolutions = [Vector2i(960, 540)]
	for resolution: Vector2i in resolutions:
		root.size = resolution
		await open_scene("res://scenes/configuracion/configuracion.tscn")
		if mobile:
			# Área clara interior del marco, no sus bordes de madera.
			var inner := Rect2(510, 338, 900, 624)
			for row_name: String in ["Master", "Musica", "SFX", "Controles"]:
				var row: Control = current_scene.get_node(row_name)
				for control: Control in row.get_children():
					if control.is_visible_in_tree():
						check(inner.encloses(screen_rect(control)), "Configuración sale del marco: " + str(control.get_path()))
						if control is Label:
							check(control.get_line_count() <= 2, "Texto de configuración demasiado alto")
			check(inner.encloses(current_scene.get_node("BtnVolver").get_global_rect()), "Volver sale del marco")
			for mode in range(2):
				current_scene.option_controles.select(mode)
				current_scene.option_controles.item_selected.emit(mode)
				await frames()
				check(root.get_node("MobileControlsSettings").should_show_touch_controls(), "Se pierden los controles táctiles")
				await capture("%d_configuracion_%d" % [resolution.x, mode])
		await open_scene("res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn")
		var data := root.get_node("DatosJugador")
		data.emociones_recolectadas.assign(["alegria", "tristeza", "enojo", "desagrado", "sorpresa"])
		current_scene._on_todas_las_emociones_recolectadas()
		await create_timer(3.5).timeout
		var result: Control = current_scene.level_complete_ui
		var panel: Control = result.get_node("Panel")
		if mobile:
			check(result.find_children("*", "ScrollContainer", true, false).is_empty(), "La victoria no debe tener desplazamiento")
			check(root.get_visible_rect().encloses(screen_rect(panel)), "La victoria sale de pantalla")
			for control: Node in panel.find_children("*", "Control", true, false):
				if control.is_visible_in_tree():
					check(screen_rect(panel).grow(1).encloses(screen_rect(control)), "Contenido fuera del panel: " + str(control.get_path()))
			check(result.boton.size.y >= 104, "Continuar necesita altura táctil")
			check(is_equal_approx(result.boton.size.x, result.boton.size.y), "Continuar conserva forma cuadrada")
		check(result.boton.is_visible_in_tree() and not result.boton.disabled, "Continuar victoria disponible")
		await capture("%d_victoria" % resolution.x)
		await tap(result.boton)
		check(current_scene.has_method("responder"), "Un toque abre el cuestionario")
		if not current_scene.has_method("responder"):
			break
		for question in range(current_scene.preguntas.size()):
			await tap(current_scene.botones_opciones[2])
			if not current_scene.has_method("responder"):
				break
		await frames()
		check(current_scene.scene_file_path.ends_with("transicion_post_mision_1.tscn"), "El cuestionario abre la primera llave")
		if not current_scene.has_node("Contenido"):
			break
		check_reward()
		await create_timer(1.2).timeout
		check_reward()
		await capture("%d_llave_1" % resolution.x)
		await tap(current_scene.boton)
		check(current_scene.scene_file_path.ends_with("intro_dialogo_3.tscn"), "Un toque en la llave continúa la historia")
		await open_scene("res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn")
		# Una animación interrumpida tampoco puede bloquear la salida.
		current_scene.anim.stop()
		await frames()
		check_reward()
		await capture("%d_llave_2_interrumpida" % resolution.x)
		var pause: Node = current_scene.get_node("PauseOverlay")
		pause._set_pausa_activa(true)
		await frames()
		pause._set_pausa_activa(false)
		await tap(current_scene.boton)
		check(current_scene.scene_file_path.ends_with("intro_dialogo_6.tscn"), "La segunda llave continúa tras pausar y reanudar")
		print("PHONE resolución=", resolution, " móvil=", mobile, " fallos=", failures)
	current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.5).timeout
	print("FLUJO_TELEFONO: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)
