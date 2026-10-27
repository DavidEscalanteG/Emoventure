extends SceneTree

## Captura una escena sin interactuar con guardados ni con ventanas del usuario.
func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var argumentos: PackedStringArray = OS.get_cmdline_user_args()
	root.size = Vector2i(1920, 1080)
	var escena: Node = load(argumentos[0]).instantiate()
	if escena.has_method("mostrar_pregunta"):
		escena.dimension = "atencion"
		escena.preguntas = root.get_node("Cuestionarios").obtener_preguntas_para_dimension("atencion")
	root.add_child(escena)
	current_scene = escena
	if argumentos.size() > 2 and argumentos[2] == "puerta" and escena.has_method("_mostrar_puerta"):
		for cuadro: Node in escena.cuadros_container.get_children():
			cuadro.emocion_asignada = "felicidad"
			cuadro.marcar_completado(Color.WHITE)
		# Incluye la última reflexión, la aparición de la puerta y el primer toque.
		await create_timer(6.25).timeout
	for cuadro: int in range(90):
		await process_frame
	await RenderingServer.frame_post_draw
	var resultado: Error = root.get_texture().get_image().save_png(argumentos[1])
	escena.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	if resultado != OK:
		quit(1)
		return
	print("CAPTURA OK")
	quit()
