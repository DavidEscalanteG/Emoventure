extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	change_scene_to_file("res://scenes/mision_3_nuevo/minijuego3.tscn")
	await scene_changed
	for i in range(5):
		await process_frame
	print("VERIFY mobile=", root.get_node("MobileControlsSettings").is_mobile_device())
	print("VERIFY pause_before=", current_scene.has_node("PauseOverlay"))
	var goal: Node = current_scene.get_node("Jugador").meta_del_nivel
	goal.call("_iniciar_cuestionario")
	for i in range(10):
		await process_frame
	print("VERIFY current_scene=", current_scene.scene_file_path)
	print("VERIFY pause_after=", current_scene.has_node("PauseOverlay"))
	print("VERIFY questions=", current_scene.preguntas.size())
	if DisplayServer.get_name() != "headless":
		await root.get_node("PCMobileProbe").snapshot("43_transicion_real_sin_pausa")
	current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	quit()
