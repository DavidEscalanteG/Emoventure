extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		quit(1)
		return
	var result := change_scene_to_file(args[0])
	if result != OK:
		quit(1)
		return
	await scene_changed
	for frame in range(180):
		await physics_frame
	print("SMOKE OK: ", args[0])
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.25).timeout
	quit()
