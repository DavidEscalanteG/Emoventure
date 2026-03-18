extends Control

const ESCENA_SELECCION_GENERO: String = "res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn"
const ESCENA_MENU_PRINCIPAL: String = "res://scenes/menu_principal/menu_principal.tscn"

@onready var contenedor_partidas: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContenedorPartidas
@onready var boton_nueva_partida: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BotonesInferiores/BotonNuevaPartida
@onready var etiqueta_vacio: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EtiquetaVacio


func _ready() -> void:
	_refrescar_lista()


func _refrescar_lista() -> void:
	for hijo in contenedor_partidas.get_children():
		hijo.queue_free()

	var partidas: Array = SaveManager.obtener_partidas()
	etiqueta_vacio.visible = partidas.is_empty()

	for index in range(partidas.size()):
		var slot: Dictionary = partidas[index] as Dictionary
		var fila: Control = _crear_fila_partida(index + 1, slot)
		contenedor_partidas.add_child(fila)
	boton_nueva_partida.visible = true


func _crear_fila_partida(indice_visual: int, slot: Dictionary) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110)

	var margen: MarginContainer = MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 12)
	margen.add_theme_constant_override("margin_right", 12)
	margen.add_theme_constant_override("margin_top", 8)
	margen.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margen)

	var fila: HBoxContainer = HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_BEGIN
	fila.add_theme_constant_override("separation", 16)
	margen.add_child(fila)

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(info)

	var nombre: Label = Label.new()
	nombre.text = "%d. %s" % [indice_visual, slot.get("nombre_jugador", "Sin nombre")]
	nombre.add_theme_font_size_override("font_size", 34)
	info.add_child(nombre)

	var genero: String = slot.get("genero", "")
	var apariencia: Dictionary = slot.get("apariencia", {})
	var resumen: String = "Apariencia: %s | Cabello #%d | Ojos #%d | Cuerpo #%d" % [
		genero.capitalize(),
		int(apariencia.get("indice_cabello", 0)),
		int(apariencia.get("indice_ojos", 0)),
		int(apariencia.get("indice_cuerpo", 0))
	]

	var detalle: Label = Label.new()
	detalle.text = resumen
	detalle.add_theme_font_size_override("font_size", 24)
	info.add_child(detalle)

	var escena: Label = Label.new()
	escena.text = "Escena guardada: %s" % slot.get("escena_actual", "N/A")
	escena.add_theme_font_size_override("font_size", 20)
	info.add_child(escena)

	var acciones: VBoxContainer = VBoxContainer.new()
	acciones.alignment = BoxContainer.ALIGNMENT_CENTER
	acciones.custom_minimum_size = Vector2(250, 0)
	fila.add_child(acciones)

	var boton_jugar: Button = Button.new()
	boton_jugar.text = "Cargar"
	boton_jugar.custom_minimum_size = Vector2(220, 42)
	boton_jugar.pressed.connect(_on_cargar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_jugar)

	var boton_eliminar: Button = Button.new()
	boton_eliminar.text = "Eliminar"
	boton_eliminar.custom_minimum_size = Vector2(220, 42)
	boton_eliminar.pressed.connect(_on_eliminar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_eliminar)

	return panel


func _on_cargar_partida_pressed(slot_id: String) -> void:
	AudioManager.play_ui_click()
	SaveManager.cargar_partida(slot_id)


func _on_eliminar_partida_pressed(slot_id: String) -> void:
	AudioManager.play_ui_click()
	SaveManager.eliminar_partida(slot_id)
	_refrescar_lista()


func _on_boton_nueva_partida_pressed() -> void:
	AudioManager.play_ui_click()
	SaveManager.preparar_nueva_partida()
	get_tree().change_scene_to_file(ESCENA_SELECCION_GENERO)


func _on_boton_volver_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(ESCENA_MENU_PRINCIPAL)
