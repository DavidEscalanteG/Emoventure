extends SceneTree
## Encuadre de actores, separación de demostraciones y navegación táctil.
## Requiere el perfil móvil aislado descrito en README.md.

var checks := 0
var failures := 0
var evidence := ""
var captures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int = 10) -> void:
	for i in range(count):
		await process_frame

func open_scene(path: String) -> void:
	paused = false
	root.get_node("DialogueActors").reiniciar_estado_cinematica()
	root.get_node("DialogueActors")._registro_actores._actores.clear()
	change_scene_to_file(path)
	await scene_changed
	await frames(20)

func capture(name: String) -> void:
	if evidence.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(evidence.path_join(name + ".png"))
	captures += 1

func run() -> void:
	if not root.get_node("MobileControlsSettings").is_mobile_device():
		quit(2)
		return
	evidence = OS.get_environment("EMO_COMPOSITION_DIR")
	if not evidence.is_empty():
		DirAccess.make_dir_recursive_absolute(evidence)
	var presentation := root.get_node("MobilePresentation")
	for resolution: Vector2i in [Vector2i(854, 480), Vector2i(640, 360)]:
		root.size = resolution
		await open_scene("res://scenes/mision_2_memorias/mision_2_memorias.tscn")
		var selector: Control = current_scene.get_node("SelectorEmocion")
		selector.mostrar(current_scene.get_node("CuadrosContainer/CuadroMemoria_00"))
		await create_timer(0.5).timeout
		check(not selector.visor.get_global_rect().intersects(selector.emojis_container.get_global_rect()), "La fotografía tapa las emociones")
		for control: Control in [selector.visor, selector.emojis_container, selector.boton_confirmar, selector.get_node("BotonCancelar")]:
			check(root.get_visible_rect().encloses(control.get_global_rect()), "Selector fuera de pantalla: " + str(control.get_path()))
		check(selector.emojis_container.find_children("EmotionName*", "Label", false, false).size() == 7, "Faltan nombres de emociones")
		var first: TextureButton = selector.emojis_container.get_child(0)
		selector.seleccionar_emocion(first.emocion_id, first)
		await frames()
		check(not selector.boton_confirmar.disabled, "No se habilita Confirmar tras elegir una emoción")
		for a: Control in selector.emojis_container.get_children():
			for b: Control in selector.emojis_container.get_children():
				if a.get_index() < b.get_index():
					check(not a.get_global_rect().intersects(b.get_global_rect()), "La emoción seleccionada tapa otra opción o etiqueta")
		await capture("%d_memorias_seleccion" % resolution.x)
		await open_scene("res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn")
		var settings := root.get_node("MobileControlsSettings")
		var controls := current_scene.find_child("MobileControls", true, false)
		check(controls != null, "Faltan controles de movimiento")
		if controls != null:
			settings.set_control_mode("joystick")
			await frames()
			var base: Control = controls.joystick_base
			check(root.get_visible_rect().encloses(base.get_global_rect()), "Joystick fuera de pantalla: " + str(base.get_global_rect()))
			var point: Vector2 = root.get_final_transform() * (base.get_global_rect().get_center() + Vector2(60, 0))
			var touch := InputEventScreenTouch.new()
			touch.position = point
			touch.pressed = true
			Input.parse_input_event(touch)
			await frames(2)
			check(Input.get_action_strength("move_right") > 0, "Joystick no responde al toque")
			touch = InputEventScreenTouch.new()
			touch.position = point
			Input.parse_input_event(touch)
			await frames(2)
			check(is_zero_approx(Input.get_action_strength("move_right")), "Joystick queda pulsado al soltar")
			await capture("%d_laberinto_joystick" % resolution.x)
			settings.set_control_mode("cruceta")
		await open_scene("res://scenes/mision_3_nuevo/minijuego3.tscn")
		var runner: CharacterBody2D = current_scene.get_node("Jugador")
		await create_timer(0.3).timeout
		var runner_controls := current_scene.get_node_or_null("MobileControls")
		check(runner_controls == null or not runner_controls.visible, "La cruceta tapa la carrera automática")
		var jump := InputEventScreenTouch.new()
		jump.position = root.get_final_transform() * Vector2(960, 540)
		jump.pressed = true
		Input.parse_input_event(jump)
		await frames(3)
		check(runner.tocando_pantalla, "La carrera no recibe el toque")
		check(runner.velocity.y < 0, "La carrera no salta con un toque")
		jump = InputEventScreenTouch.new()
		jump.position = root.get_final_transform() * Vector2(960, 540)
		Input.parse_input_event(jump)
		await frames(2)
		check(not runner.tocando_pantalla, "La carrera conserva el toque al soltar")
		await capture("%d_carrera" % resolution.x)
		for number in range(1, 13):
			var path := "res://scenes/intro_dialogo_%d/intro_dialogo_%d.tscn" % [number, number]
			if not ResourceLoader.exists(path):
				continue
			await open_scene(path)
			await create_timer(1.2).timeout
			var balloon: Control = current_scene.get_node("DialogueUI/Balloon")
			balloon.type_timer.stop()
			balloon.label.visible_characters = -1
			await frames()
			var panel: Control = balloon.get_node("MarginContainer")
			check(root.get_visible_rect().encloses(panel.get_global_rect()), path + ": diálogo fuera de pantalla")
			if current_scene.has_meta("mobile_story_stage"):
				var bounds: Rect2 = current_scene.get_meta("mobile_actor_bounds")
				var rendered: Rect2 = root.canvas_transform * bounds
				# La mascota de la escena 5 entra desde fuera del borde derecho;
				# ese desplazamiento lateral forma parte de la coreografía original.
				check(rendered.position.y >= 0 and rendered.end.y <= 640, path + ": reparto fuera de la altura del escenario: " + str(rendered))
				check(rendered.end.y < panel.get_global_rect().position.y, path + ": diálogo oculta actores")
				var actors: Node = current_scene.get_node_or_null("personajes")
				if actors == null:
					actors = current_scene.get_node("Personajes")
				var before: Rect2 = presentation._actor_bounds(actors)
				presentation._restore_story_frame()
				presentation._frame_story(current_scene)
				check(before.is_equal_approx(presentation._actor_bounds(actors)), path + ": el encuadre altera posiciones globales")
				var actual: Rect2 = root.canvas_transform * before
				check(actual.position.y >= 0 and actual.end.y <= 640, path + ": actores actuales invaden el diálogo")
			await capture("%d_dialogo_%02d" % [resolution.x, number])
		# El encuadre narrativo no debe filtrarse a escenas sin cámara.
		await open_scene("res://scenes/configuracion/configuracion.tscn")
		check(root.canvas_transform.is_equal_approx(Transform2D.IDENTITY), "Encuadre narrativo persiste al salir")
		var tutorials := [
			"res://scenes/mision_1_recoleccion/tutorial/scripts/Minijuego1_Tutorial.tscn",
			"res://scenes/mision_2_memorias/tutorial/scripts/Minijuego2_Tutorial.tscn",
			"res://scenes/mision_3_nuevo/tutorial/Minijuego3_Tutorial.tscn",
			"res://scenes/mision_4_payasos/tutorial/Minijuego4_Tutorial.tscn"]
		for index in range(tutorials.size()):
			await open_scene(tutorials[index])
			var panel: Control = current_scene.get_node_or_null("Bottom")
			if panel == null:
				panel = current_scene.get_node("TutorialUI/Overlay/BottomPanel")
			var source := current_scene.get_node_or_null("Arena")
			var demo_rect := Rect2()
			if source != null:
				demo_rect = source.get_global_rect()
			elif current_scene.has_node("DemoWorld"):
				demo_rect = current_scene.get_node("DemoWorld").transform * Rect2(270, 120, 1380, 680)
			else:
				demo_rect = current_scene.get_node("TutorialDemo").get_global_rect()
			check(root.get_visible_rect().encloses(demo_rect), "Demostración fuera de pantalla: " + tutorials[index])
			check(not demo_rect.intersects(panel.get_global_rect()), "Demostración bajo instrucciones: " + tutorials[index])
			var steps: int = [12, 6, 5, 5][index]
			for step in range(steps):
				current_scene.call("_go_to_step" if index < 2 else "_show_step", step)
				await create_timer(0.9).timeout
				await frames()
				if index == 1:
					var demo: Control = current_scene.get_node("TutorialDemo")
					var top: Control = demo.get_node("TopInfo")
					check(not top.get_global_rect().intersects(demo.photos_grid.get_global_rect()), "Progreso tapa las fotografías")
					if demo.emotion_panel.visible:
						check(not demo.photos_grid.get_global_rect().intersects(demo.emotion_panel.get_global_rect()), "Emociones tapan fotografías")
						check(demo.get_global_rect().encloses(demo.emotion_panel.get_global_rect()), "Emociones fuera de la demostración: " + str(demo.emotion_panel.get_global_rect()) + " dentro de " + str(demo.get_global_rect()))
						check(demo.emotion_panel.get_global_rect().encloses(demo.accept_button.get_global_rect()), "Aceptar fuera de su panel")
				for button: Node in panel.find_children("*Button", "Button", true, false):
					if button.is_visible_in_tree():
						check(panel.get_global_rect().encloses(button.get_global_rect()), "Navegación sale del panel: " + str(button.get_path()))
						check(button.pressed.get_connections().size() > 0, "Navegación perdió su señal")
				await capture("%d_tutorial_%d_paso_%02d" % [resolution.x, index + 1, step])
			print("COMPOSICION tutorial=", index + 1, " resolución=", resolution, " fallos=", failures)
	print("COMPOSICION_MOVIL: ", checks, " comprobaciones, ", failures, " fallos, ", captures, " capturas")
	if current_scene != null:
		current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	quit(0 if failures == 0 else 1)
