extends SceneTree
## Regresión de can_process en Godot 4.5.2: el ratón emulado de un contacto
## no debe retirar la escena antes de recibir la liberación del dedo.
## Ejecutar en la copia móvil, con APPDATA temporal.

const MENU := "res://scenes/menu_principal/menu_principal.tscn"
var checks := 0
var failures := 0

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

func tap_transition(button: Control, expected: String) -> void:
	var previous := current_scene
	var point: Vector2 = root.get_final_transform() * button.get_global_transform_with_canvas() * (button.size / 2)
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventScreenTouch.new()
	event.position = point
	Input.parse_input_event(event)
	check(is_instance_valid(previous) and previous.is_inside_tree(), "La escena sigue disponible hasta terminar el evento táctil")
	await frames()
	check(current_scene != null and current_scene.scene_file_path == expected, "El contacto abre " + expected)
	check(not is_instance_valid(previous), "La escena anterior se libera tras la transición")

func run() -> void:
	if not root.get_node("MobileControlsSettings").is_mobile_device():
		push_error("Usar la copia móvil con APPDATA temporal")
		quit(2)
		return
	root.size = Vector2i(854, 480)
	root.get_node("SaveManager").set_process(false)
	var cases := [
		[MENU, "Configuracion", "res://scenes/configuracion/configuracion.tscn"],
		["res://scenes/configuracion/configuracion.tscn", "BtnVolver", MENU],
		[MENU, "Creditos", "res://scenes/creditos/creditos.tscn"],
		["res://scenes/creditos/creditos.tscn", "MargenPrincipal/Contenido/BotonVolver", MENU],
		[MENU, "Comenzar", "res://scenes/menu_guardados/menu_guardados.tscn"],
		["res://scenes/menu_guardados/menu_guardados.tscn", "CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BotonesInferiores/BotonVolver", MENU],
		["res://scenes/menu_guardados/menu_guardados.tscn", "CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BotonesInferiores/BotonNuevaPartida", "res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn"],
		["res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn", "VBoxContainer/HBoxContainer/ContenedorHombre", "res://scenes/personalizacion/Personalizacion.tscn"],
	]
	for item: Array in cases:
		await open_scene(item[0])
		await tap_transition(current_scene.get_node(item[1]), item[2])
		print("CAMBIO_ESCENA destino=", item[2], " fallos=", failures)
	# El final de un diálogo también cambia de escena desde una señal de botón.
	await open_scene("res://scenes/intro_dialogo_1/intro_dialogo_1.tscn")
	var ui: Node = current_scene.get_node("DialogueUI/Balloon")
	var resource: DialogueResource = root.get_node("DialogueManager").create_resource_from_text("~ start\nNarrador: Fin del diálogo de prueba.\n=> END")
	await ui.iniciar_dialogo(resource)
	ui.type_timer.stop()
	ui._gestionar_avance()
	await frames()
	await tap_transition(ui._mobile_continue, "res://scenes/intro_dialogo_2/intro_dialogo_2.tscn")
	# Salir de pausa tampoco debe dejar un contacto sobre la escena retirada.
	var pause: Node = current_scene.get_node("PauseOverlay")
	pause._set_pausa_activa(true)
	await frames()
	var exit: Control = pause.find_child("BtnMenuPrincipal", true, false)
	if exit != null:
		await tap_transition(exit, MENU)
	else:
		check(false, "Se encuentra el botón de volver al menú desde pausa")
	current_scene.queue_free()
	await frames()
	root.get_node("MusicManager").detener()
	await create_timer(0.5).timeout
	print("CAMBIOS_ESCENA: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)
