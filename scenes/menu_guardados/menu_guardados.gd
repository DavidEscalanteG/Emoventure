extends Control

const ESCENA_SELECCION_GENERO: String = "res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn"
const ESCENA_MENU_PRINCIPAL: String = "res://scenes/menu_principal/menu_principal.tscn"
const ESCENA_JUGADOR_PREVIEW: PackedScene = preload("res://jugador/jugador.tscn")
const ANIMACION_PREVIEW: String = "idle_down"
const HITOS_PROGRESO: Array[Dictionary] = [
	{"porcentaje": 100, "prefijos": ["res://scenes/rejugabilidad/"]},
	{"porcentaje": 80, "prefijos": ["res://scenes/mision_4_payasos/", "res://scenes/intro_mision_4/"]},
	{"porcentaje": 60, "prefijos": ["res://scenes/mision_3_hachas/", "res://scenes/intro_dialogo_5/"]},
	{"porcentaje": 40, "prefijos": ["res://scenes/mision_2_memorias/", "res://scenes/intro_mision_2/", "res://scenes/intro_dialogo_4/"]},
	{"porcentaje": 20, "prefijos": ["res://scenes/mision_1_recoleccion/", "res://scenes/transicion_post_mision_1/", "res://scenes/intro_dialogo_3/"]}
]

@onready var contenedor_partidas: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContenedorPartidas
@onready var scroll_partidas: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var boton_nueva_partida: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BotonesInferiores/BotonNuevaPartida
@onready var etiqueta_vacio: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EtiquetaVacio


func _ready() -> void:
	_refrescar_lista()


func _refrescar_lista() -> void:
	for hijo in contenedor_partidas.get_children():
		hijo.queue_free()

	var partidas: Array = SaveManager.obtener_partidas()
	etiqueta_vacio.visible = partidas.is_empty()
	scroll_partidas.visible = not partidas.is_empty()

	for index in range(partidas.size()):
		var slot: Dictionary = partidas[index] as Dictionary
		var fila: Control = _crear_fila_partida(index + 1, slot)
		contenedor_partidas.add_child(fila)
	boton_nueva_partida.visible = true
	InteractiveButtonFX.aplicar_a_botones_en(self)


func _crear_fila_partida(indice_visual: int, slot: Dictionary) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 196)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _crear_estilo_tarjeta_guardado(indice_visual))

	var margen: MarginContainer = MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 26)
	margen.add_theme_constant_override("margin_right", 26)
	margen.add_theme_constant_override("margin_top", 18)
	margen.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margen)

	var fila: HBoxContainer = HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_BEGIN
	fila.add_theme_constant_override("separation", 24)
	fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margen.add_child(fila)

	var insignia: PanelContainer = PanelContainer.new()
	insignia.custom_minimum_size = Vector2(70, 70)
	insignia.add_theme_stylebox_override("panel", _crear_estilo_insignia())
	fila.add_child(insignia)

	var numero: Label = Label.new()
	numero.text = "%02d" % indice_visual
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	numero.add_theme_font_size_override("font_size", 30)
	numero.add_theme_color_override("font_color", Color("#24152f"))
	insignia.add_child(numero)

	var preview: Control = _crear_preview_apariencia(slot.get("apariencia", {}))
	preview.custom_minimum_size = Vector2(142, 132)
	fila.add_child(preview)

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 7)
	fila.add_child(info)

	var nombre: Label = Label.new()
	nombre.text = str(slot.get("nombre_jugador", "Aventurero sin nombre"))
	nombre.add_theme_font_size_override("font_size", 36)
	nombre.add_theme_color_override("font_color", Color("#ffe39a"))
	nombre.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	nombre.add_theme_constant_override("shadow_offset_x", 2)
	nombre.add_theme_constant_override("shadow_offset_y", 2)
	info.add_child(nombre)

	var progreso: int = _calcular_progreso_historia(slot)

	var detalle: Label = Label.new()
	detalle.text = "%s  •  %d%% completado" % [_descripcion_progreso(progreso), progreso]
	detalle.add_theme_font_size_override("font_size", 25)
	_aplicar_texto_claro(detalle, Color("#d9e8ff"))
	info.add_child(detalle)

	var barra_progreso: ProgressBar = ProgressBar.new()
	barra_progreso.min_value = 0
	barra_progreso.max_value = 100
	barra_progreso.step = 20
	barra_progreso.value = progreso
	barra_progreso.show_percentage = true
	barra_progreso.add_theme_font_size_override("font_size", 21)
	barra_progreso.custom_minimum_size = Vector2(0, 28)
	barra_progreso.add_theme_stylebox_override("background", _crear_estilo_barra_fondo())
	barra_progreso.add_theme_stylebox_override("fill", _crear_estilo_barra_relleno(progreso))
	barra_progreso.add_theme_color_override("font_color", Color.WHITE)
	barra_progreso.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	info.add_child(barra_progreso)

	var nombre_mascota: String = str(slot.get("nombre_mascota", "")).strip_edges()
	if nombre_mascota.is_empty():
		nombre_mascota = "Sin compañero asignado"
	else:
		nombre_mascota = "Compañero: %s" % nombre_mascota
	var metadata: Label = Label.new()
	metadata.text = "%s   •   Puntaje: %d   •   Última sesión: %s" % [
		nombre_mascota,
		int(slot.get("puntaje_total", 0)),
		_formatear_fecha(slot.get("updated_at", slot.get("created_at", "")))
	]
	metadata.add_theme_font_size_override("font_size", 20)
	metadata.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_aplicar_texto_claro(metadata, Color("#aebfd8"))
	info.add_child(metadata)
	
	var acciones: VBoxContainer = VBoxContainer.new()
	acciones.alignment = BoxContainer.ALIGNMENT_CENTER
	acciones.custom_minimum_size = Vector2(230, 0)
	acciones.add_theme_constant_override("separation", 10)
	fila.add_child(acciones)

	var boton_jugar: Button = Button.new()
	boton_jugar.text = "Cargar"
	boton_jugar.custom_minimum_size = Vector2(220, 52)
	boton_jugar.add_theme_font_size_override("font_size", 27)
	_configurar_boton_accion(boton_jugar, Color("#3478b8"), Color("#5aa7e8"))
	boton_jugar.tooltip_text = "Continuar esta aventura"
	boton_jugar.pressed.connect(_on_cargar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_jugar)

	var boton_eliminar: Button = Button.new()
	boton_eliminar.text = "Eliminar"
	boton_eliminar.custom_minimum_size = Vector2(220, 46)
	boton_eliminar.add_theme_font_size_override("font_size", 24)
	_configurar_boton_accion(boton_eliminar, Color("#6d354d"), Color("#a54b67"))
	boton_eliminar.tooltip_text = "Eliminar permanentemente esta partida"
	boton_eliminar.pressed.connect(_on_eliminar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_eliminar)

	return panel


func _crear_preview_apariencia(datos_apariencia: Dictionary) -> Control:
	var contenedor: PanelContainer = PanelContainer.new()
	contenedor.custom_minimum_size = Vector2(142, 132)
	contenedor.add_theme_stylebox_override("panel", _crear_estilo_preview())

	var lienzo := Control.new()
	lienzo.custom_minimum_size = contenedor.custom_minimum_size
	contenedor.add_child(lienzo)

	var personaje: Node2D = _instanciar_player_appearance()
	if personaje == null:
		var sin_preview: Label = Label.new()
		sin_preview.text = "Sin\npreview"
		sin_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_aplicar_texto_claro(sin_preview, Color("#aebfd8"))
		sin_preview.size = lienzo.custom_minimum_size
		lienzo.add_child(sin_preview)
		return contenedor

	personaje.scale = Vector2(4.0, 4.0)
	personaje.position = Vector2(71, 91)
	lienzo.add_child(personaje)
	_aplicar_apariencia_preview(personaje, datos_apariencia)

	return contenedor


func _crear_estilo_tarjeta_guardado(indice_visual: int) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#142442f2") if indice_visual % 2 == 1 else Color("#192a4bf2")
	estilo.border_color = Color("#6f94c7")
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(18)
	estilo.shadow_color = Color(0, 0, 0, 0.45)
	estilo.shadow_size = 8
	return estilo


func _crear_estilo_insignia() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#f2c45f")
	estilo.border_color = Color("#fff0b5")
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(16)
	return estilo


func _crear_estilo_preview() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#0a1428d9")
	estilo.border_color = Color("#3e608f")
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(14)
	return estilo


func _crear_estilo_barra_fondo() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#080f20")
	estilo.set_corner_radius_all(9)
	return estilo


func _crear_estilo_barra_relleno(progreso: int) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#53c6ad") if progreso < 100 else Color("#f2c45f")
	estilo.set_corner_radius_all(9)
	return estilo


func _configurar_boton_accion(boton: Button, base: Color, resaltado: Color) -> void:
	boton.add_theme_stylebox_override("normal", _crear_estilo_boton(base, Color(base).lightened(0.25)))
	boton.add_theme_stylebox_override("hover", _crear_estilo_boton(resaltado, Color("#ffe39a")))
	boton.add_theme_stylebox_override("pressed", _crear_estilo_boton(base.darkened(0.2), Color.WHITE))
	boton.add_theme_stylebox_override("focus", _crear_estilo_boton(resaltado, Color.WHITE))
	boton.add_theme_color_override("font_color", Color.WHITE)
	boton.add_theme_color_override("font_hover_color", Color.WHITE)
	boton.add_theme_color_override("font_pressed_color", Color.WHITE)
	boton.add_theme_color_override("font_focus_color", Color.WHITE)


func _crear_estilo_boton(relleno: Color, borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = relleno
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(11)
	estilo.content_margin_top = 8.0
	estilo.content_margin_bottom = 8.0
	return estilo


func _aplicar_texto_claro(control: Control, color: Color = Color.WHITE) -> void:
	control.add_theme_color_override("font_color", color)
	control.add_theme_color_override("font_hover_color", color)
	control.add_theme_color_override("font_pressed_color", color)
	control.add_theme_color_override("font_focus_color", color)
	control.add_theme_color_override("font_disabled_color", color.darkened(0.25))


func _descripcion_progreso(progreso: int) -> String:
	match progreso:
		100:
			return "Aventura completada"
		80:
			return "Misión final"
		60:
			return "Pasillo de la lengua filosa"
		40:
			return "Memorias eternas"
		20:
			return "Laberinto emocional"
		_:
			return "Inicio de la aventura"


func _formatear_fecha(valor: Variant) -> String:
	var fecha := str(valor).strip_edges()
	if fecha.is_empty():
		return "Sin fecha"
	fecha = fecha.replace("T", " ")
	if fecha.ends_with("Z"):
		fecha = fecha.trim_suffix("Z")
	return fecha.substr(0, mini(fecha.length(), 16))


func _instanciar_player_appearance() -> Node2D:
	var jugador_temporal: Node = ESCENA_JUGADOR_PREVIEW.instantiate()
	if jugador_temporal == null:
		return null

	var apariencia: Node = jugador_temporal.get_node_or_null("PlayerAppearance")
	if apariencia == null:
		jugador_temporal.queue_free()
		return null

	var apariencia_preview: Node2D = apariencia.duplicate() as Node2D
	jugador_temporal.queue_free()
	return apariencia_preview


func _aplicar_apariencia_preview(apariencia_preview: Node2D, datos_apariencia: Dictionary) -> void:
	var cabello: AnimatedSprite2D = apariencia_preview.get_node_or_null("Cabello")
	var cabeza: AnimatedSprite2D = apariencia_preview.get_node_or_null("Cabeza")
	var ojos: AnimatedSprite2D = apariencia_preview.get_node_or_null("Ojos")
	var boca: AnimatedSprite2D = apariencia_preview.get_node_or_null("Boca")
	var nariz: AnimatedSprite2D = apariencia_preview.get_node_or_null("Nariz")
	var cuerpo: AnimatedSprite2D = apariencia_preview.get_node_or_null("Cuerpo")

	_aplicar_sprite_en_preview(apariencia_preview, cabello, "coleccion_cabellos", int(datos_apariencia.get("indice_cabello", 0)))
	_aplicar_sprite_en_preview(apariencia_preview, cabeza, "coleccion_cabezas", int(datos_apariencia.get("indice_cabeza", 0)))
	_aplicar_sprite_en_preview(apariencia_preview, ojos, "coleccion_ojos", int(datos_apariencia.get("indice_ojos", 0)))
	_aplicar_sprite_en_preview(apariencia_preview, boca, "coleccion_bocas", int(datos_apariencia.get("indice_boca", 0)))
	_aplicar_sprite_en_preview(apariencia_preview, nariz, "coleccion_narices", int(datos_apariencia.get("indice_nariz", 0)))
	_aplicar_sprite_en_preview(apariencia_preview, cuerpo, "coleccion_cuerpos", int(datos_apariencia.get("indice_cuerpo", 0)))

	if cabello:
		cabello.self_modulate = _color_desde_guardado(datos_apariencia.get("color_cabello", "ffffffff"), Color.WHITE)
	if cabeza:
		cabeza.self_modulate = _color_desde_guardado(datos_apariencia.get("color_cabeza", "ffffffff"), Color.WHITE)
	if ojos:
		ojos.self_modulate = _color_desde_guardado(datos_apariencia.get("color_ojos", "ffffffff"), Color.WHITE)
	if boca:
		boca.self_modulate = _color_desde_guardado(datos_apariencia.get("color_boca", "ffffffff"), Color.WHITE)
	if nariz:
		nariz.self_modulate = _color_desde_guardado(datos_apariencia.get("color_nariz", "ffffffff"), Color.WHITE)
	if cuerpo:
		cuerpo.self_modulate = _color_desde_guardado(datos_apariencia.get("color_cuerpo", "ffffffff"), Color.WHITE)

	for sprite in [cabello, cabeza, ojos, boca, nariz, cuerpo]:
		_reproducir_animacion_preview(sprite)


func _aplicar_sprite_en_preview(apariencia_preview: Node2D, sprite: AnimatedSprite2D, clave_coleccion: String, indice: int) -> void:
	if sprite == null:
		return

	var coleccion_variant: Variant = apariencia_preview.get(clave_coleccion)
	if typeof(coleccion_variant) != TYPE_ARRAY:
		return

	var coleccion: Array = coleccion_variant as Array
	if coleccion.is_empty():
		return

	var indice_ajustado: int = clampi(indice, 0, coleccion.size() - 1)
	apariencia_preview.call("aplicar_spriteframes_por_indice", sprite, coleccion, indice_ajustado)


func _color_desde_guardado(valor: Variant, color_default: Color) -> Color:
	if typeof(valor) == TYPE_COLOR:
		return valor as Color
	if typeof(valor) == TYPE_STRING:
		return Color(valor as String)
	return color_default


func _reproducir_animacion_preview(sprite: AnimatedSprite2D) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(ANIMACION_PREVIEW):
		return

	sprite.play(ANIMACION_PREVIEW)
	sprite.frame = 0
	sprite.stop()
	
	
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


func _calcular_progreso_historia(slot: Dictionary) -> int:
	if bool(slot.get("progreso_historia_bloqueado_100", false)):
		return 100

	var escena_actual: String = slot.get("escena_actual", "")
	if escena_actual.is_empty():
		return 0

	for hito in HITOS_PROGRESO:
		var porcentaje: int = int(hito.get("porcentaje", 0))
		var prefijos: PackedStringArray = hito.get("prefijos", PackedStringArray())
		for prefijo in prefijos:
			if escena_actual.begins_with(prefijo):
				return porcentaje

	return 0
