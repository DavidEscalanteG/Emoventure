extends Node

var last_scene := ""
var busy := false
var elapsed := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("MOBILE_PC user_data=", OS.get_user_data_dir())
	print("MOBILE_PC simulated_mobile=", MobileControlsSettings.is_mobile_device())

func _process(delta: float) -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path != last_scene:
		last_scene = scene.scene_file_path
		print("MOBILE_PC SCENE ", last_scene)
	if busy:
		return
	elapsed += delta
	if elapsed < 0.2:
		return
	elapsed = 0.0
	if FileAccess.file_exists("res://command.json"):
		var command: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://command.json"))
		DirAccess.remove_absolute(ProjectSettings.globalize_path("res://command.json"))
		if command is Dictionary:
			busy = true
			_execute(command)

func _execute(c: Dictionary) -> void:
	match c.get("op", ""):
		"questionnaire":
			get_tree().paused = false
			var next_scene: Node = load("res://scenes/cuestionarios/EscenaCuestionario.tscn").instantiate()
			next_scene.dimension = "atencion"
			next_scene.preguntas = Cuestionarios.obtener_preguntas_para_dimension("atencion")
			next_scene.escena_siguiente = load("res://scenes/menu_principal/menu_principal.tscn")
			var previous := get_tree().current_scene
			if previous != null:
				get_tree().root.remove_child(previous)
				previous.queue_free()
			get_tree().root.add_child(next_scene)
			get_tree().current_scene = next_scene
			await get_tree().create_timer(0.5).timeout
		"case":
			get_tree().paused = false
			get_tree().change_scene_to_file(c.path)
			await get_tree().create_timer(c.get("delay", 0.8)).timeout
			await _execute({"op": "touch", "events": c.events, "tag": c.tag})
			busy = false
			return
		"scene":
			get_tree().paused = false
			get_tree().change_scene_to_file(c.path)
			await get_tree().create_timer(1.0).timeout
		"size":
			get_tree().root.size = Vector2i(c.w, c.h)
			await get_tree().create_timer(0.5).timeout
		"mode":
			MobileControlsSettings.set_control_mode(c.mode)
		"touch":
			for item: Dictionary in c.events:
				var event: InputEvent
				if item.get("kind", "touch") == "drag":
					event = InputEventScreenDrag.new()
					event.relative = Vector2(item.get("dx", 0), item.get("dy", 0))
				else:
					event = InputEventScreenTouch.new()
					event.pressed = item.pressed
				event.index = item.get("index", 0)
				event.position = Vector2(item.x, item.y)
				Input.parse_input_event(event)
				await get_tree().create_timer(item.get("wait", 0.05)).timeout
				if item.has("tag"):
					await snapshot(item.tag)
		"quit":
			get_tree().quit()
	await get_tree().process_frame
	if c.has("tag"):
		await snapshot(c.tag)
	busy = false

func snapshot(tag: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://evidence/" + tag + ".png")
	var scene := get_tree().current_scene
	var data := {"scene": last_scene, "paused": get_tree().paused, "window": str(get_tree().root.size), "viewport": str(get_viewport().get_visible_rect()), "mobile_mode": MobileControlsSettings.control_mode, "nodes": []}
	if scene != null and scene.has_method("responder"):
		data["question_index"] = scene.indice
		data["question_score"] = scene.puntaje_local
	if scene != null and scene.get("puntos") != null:
		data["points"] = scene.puntos
	if scene != null:
		_collect(scene, data.nodes)
	var file := FileAccess.open("res://evidence/" + tag + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	print("MOBILE_PC SNAPSHOT ", tag)

func _collect(node: Node, output: Array) -> void:
	if node is Control and node.is_visible_in_tree():
		var item := {"path": str(node.get_path()), "class": node.get_class(), "rect": str(node.get_global_rect())}
		if node is Label or node is Button or node is LineEdit or node is RichTextLabel:
			item["text"] = node.text
		output.append(item)
	if node is CharacterBody2D:
		output.append({"path": str(node.get_path()), "position": str(node.position), "velocity": str(node.velocity)})
	if node is CanvasLayer and node.get_script() != null and node.get_script().resource_path == "res://src/ui/mobile_controls.gd":
		output.append({"path": str(node.get_path()), "visible": node.visible, "actions": node.get("_pressed_actions"), "joy_pointer": node.get("_joy_pointer")})
	for child: Node in node.get_children():
		_collect(child, output)
