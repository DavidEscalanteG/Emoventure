extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("OK: ", message)
	else:
		failures += 1
		push_error("FALLO: " + message)


func _has_physical_key(action: String, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _run() -> void:
	var settings: Node = root.get_node("MobileControlsSettings")
	if not settings.is_mobile_device():
		_check(settings.control_mode == settings.MODE_OFF, "Escritorio desactiva controles táctiles automáticamente")
		_check(not settings.should_show_touch_controls(), "Escritorio no muestra la capa táctil")

	var required: Dictionary = {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
	}
	for action: String in required:
		for keycode: Key in required[action]:
			_check(_has_physical_key(action, keycode), "%s conserva %s" % [action, OS.get_keycode_string(keycode)])

	# La personalización sólo agrega una alternativa y jamás elimina las bases.
	settings.set_custom_key("move_up", KEY_Q)
	_check(_has_physical_key("move_up", KEY_Q), "La tecla personalizada se agrega a InputMap")
	settings.set_custom_key("move_up", KEY_W)
	_check(_has_physical_key("move_up", KEY_W) and _has_physical_key("move_up", KEY_UP), "Elegir una tecla base conserva WASD y flechas")
	settings.clear_custom_keys()

	var previous_mode: String = settings.control_mode
	settings.control_mode = settings.MODE_CRUCETA
	settings.controls_enabled = true
	var controls: Node = load("res://src/ui/mobile_controls.tscn").instantiate()
	root.add_child(controls)
	controls.set_process(false)

	controls._on_btn_up_button_down()
	_check(Input.is_action_pressed("move_up") and Input.is_action_pressed("ui_up"), "La cruceta emite movimiento y navegación")
	controls._on_btn_up_button_up()
	_check(not Input.is_action_pressed("move_up") and not Input.is_action_pressed("ui_up"), "La cruceta libera ambas acciones")

	settings.control_mode = settings.MODE_JOYSTICK
	controls._apply_mode()
	var base: Control = controls.get_node("UI/Joystick/JoystickBase")
	var center: Vector2 = base.global_position + base.size / 2.0
	controls._update_joystick(center + Vector2(0.0, 80.0))
	_check(Input.get_action_strength("move_down") > 0.5 and Input.get_action_strength("ui_down") > 0.5, "El joystick emite movimiento y navegación analógicos")
	controls._reset_joystick()
	_check(not Input.is_action_pressed("move_down") and not Input.is_action_pressed("ui_down"), "El joystick vuelve a neutro")

	controls.free()
	settings.control_mode = previous_mode

	change_scene_to_file("res://scenes/mision_3_nuevo/minijuego3.tscn")
	await scene_changed
	for _frame in range(5):
		await physics_frame
	var runner: CharacterBody2D = current_scene.get_node("Jugador")
	Input.action_press("move_up")
	await physics_frame
	Input.action_release("move_up")
	_check(runner.velocity.y < 0.0, "El minijuego 3 actual salta con move_up (W, flecha, cruceta o joystick)")

	var pause_overlay: CanvasLayer = current_scene.get_node("PauseOverlay")
	pause_overlay._alternar_pausa_por_escape()
	_check(paused and current_scene.get_node("PauseOverlay").get_node("PanelPausa").visible, "Escape abre el menú de pausa durante el juego")
	pause_overlay._alternar_pausa_por_escape()
	_check(not paused, "Escape vuelve a cerrar el menú de pausa")
	current_scene.queue_free()
	await process_frame

	change_scene_to_file("res://scenes/configuracion/configuracion.tscn")
	await scene_changed
	var config_screen: Control = current_scene
	config_screen._on_btn_teclado_pressed()
	config_screen._on_tecla_arriba_pressed()
	var q_down := InputEventKey.new()
	q_down.physical_keycode = KEY_Q
	q_down.pressed = true
	Input.parse_input_event(q_down)
	await process_frame
	_check(settings.custom_keys.get("move_up", KEY_NONE) == KEY_Q, "El panel emergente captura la tecla personalizada")
	settings.clear_custom_keys()
	current_scene.queue_free()
	await process_frame

	var tutorial_scenes: Array[String] = [
		"res://scenes/mision_1_recoleccion/tutorial/scripts/Minijuego1_Tutorial.tscn",
		"res://scenes/mision_2_memorias/tutorial/scripts/Minijuego2_Tutorial.tscn",
		"res://scenes/mision_3_nuevo/tutorial/Minijuego3_Tutorial.tscn",
		"res://scenes/mision_4_payasos/tutorial/Minijuego4_Tutorial.tscn",
	]
	for tutorial_path: String in tutorial_scenes:
		change_scene_to_file(tutorial_path)
		await scene_changed
		for _frame in range(3):
			await process_frame
		var skip_button := current_scene.find_child("SkipButton", true, false) as Control
		var tutorial_pause := current_scene.get_node("PauseOverlay") as CanvasLayer
		var pause_button := tutorial_pause.get_node("MarginTopRight/BtnPausa") as Control
		_check(
			skip_button != null and not pause_button.get_global_rect().intersects(skip_button.get_global_rect()),
			"Pausa no tapa Omitir tutorial en %s" % tutorial_path.get_file()
		)
	print("CONTROLES: %d fallos" % failures)
	quit(1 if failures else 0)
