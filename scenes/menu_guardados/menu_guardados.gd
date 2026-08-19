extends Control

const ESCENA_SELECCION_GENERO: String = "res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn"
const ESCENA_MENU_PRINCIPAL: String = "res://scenes/menu_principal/menu_principal.tscn"
const ESCENA_JUGADOR_PREVIEW: PackedScene = preload("res://jugador/jugador.tscn")
const TEMA_BOTONES: Theme = preload("res://assets/temas/tema_botones.tres")
const TEXTO_TARJETA_GUARDADO: Texture2D = preload("res://assets/ui/Tiles/Large tiles/Thin outline/tile_0013.png")
const ANIMACION_PREVIEW: String = "idle_down"
const HITOS_PROGRESO: Array[Dictionary] = [
	{"porcentaje": 100, "prefijos": ["res://scenes/rejugabilidad/"]},
	{"porcentaje": 80, "prefijos": ["res://scenes/mision_4_payasos/", "res://scenes/intro_mision_4/"]},
	{"porcentaje": 60, "prefijos": ["res://scenes/mision_3_hachas/", "res://scenes/intro_dialogo_5/"]},
	{"porcentaje": 40, "prefijos": ["res://scenes/mision_2_memorias/", "res://scenes/intro_mision_2/", "res://scenes/intro_dialogo_4/"]},
	{"porcentaje": 20, "prefijos": ["res://scenes/mision_1_recoleccion/", "res://scenes/transicion_post_mision_1/", "res://scenes/intro_dialogo_3/"]}
]

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
	InteractiveButtonFX.aplicar_a_botones_en(self)


func _crear_fila_partida(indice_visual: int, slot: Dictionary) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 168)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _crear_estilo_tarjeta_guardado())

	var margen: MarginContainer = MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 22)
	margen.add_theme_constant_override("margin_right", 22)
	margen.add_theme_constant_override("margin_top", 16)
	margen.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margen)

	var fila: HBoxContainer = HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_BEGIN
	fila.add_theme_constant_override("separation", 20)
	fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margen.add_child(fila)

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 6)
	fila.add_child(info)

	var nombre: Label = Label.new()
	nombre.text = "%d. %s" % [indice_visual, slot.get("nombre_jugador", "Sin nombre")]
	nombre.add_theme_font_size_override("font_size", 32)
	_aplicar_texto_negro(nombre)
	info.add_child(nombre)

	var apariencia: Dictionary = slot.get("apariencia", {})
	var progreso: int = _calcular_progreso_historia(slot)

	var detalle: Label = Label.new()
	detalle.text = "Avance en la historia: %d%%" % progreso
	detalle.add_theme_font_size_override("font_size", 32)
	_aplicar_texto_negro(detalle)
	info.add_child(detalle)

	var barra_progreso: ProgressBar = ProgressBar.new()
	barra_progreso.min_value = 0
	barra_progreso.max_value = 100
	barra_progreso.step = 20
	barra_progreso.value = progreso
	barra_progreso.show_percentage = true
	barra_progreso.add_theme_font_size_override("font_size", 25)
	barra_progreso.custom_minimum_size = Vector2(0, 30)
	_aplicar_texto_negro(barra_progreso)
	info.add_child(barra_progreso)

	var preview: Control = _crear_preview_apariencia(apariencia)
	preview.custom_minimum_size = Vector2(132, 118)
	fila.add_child(preview)
	
	var acciones: VBoxContainer = VBoxContainer.new()
	acciones.alignment = BoxContainer.ALIGNMENT_CENTER
	acciones.custom_minimum_size = Vector2(248, 0)
	acciones.add_theme_constant_override("separation", 10)
	fila.add_child(acciones)

	var boton_jugar: Button = Button.new()
	boton_jugar.text = "Cargar"
	boton_jugar.custom_minimum_size = Vector2(220, 44)
	boton_jugar.theme = TEMA_BOTONES
	boton_jugar.add_theme_font_size_override("font_size", 30)
	_aplicar_texto_negro(boton_jugar)
	boton_jugar.pressed.connect(_on_cargar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_jugar)

	var boton_eliminar: Button = Button.new()
	boton_eliminar.text = "Eliminar"
	boton_eliminar.custom_minimum_size = Vector2(220, 44)
	boton_eliminar.theme = TEMA_BOTONES
	boton_eliminar.add_theme_font_size_override("font_size", 30)
	_aplicar_texto_negro(boton_eliminar)
	boton_eliminar.pressed.connect(_on_eliminar_partida_pressed.bind(slot.get("id", "")))
	acciones.add_child(boton_eliminar)

	return panel


func _crear_preview_apariencia(datos_apariencia: Dictionary) -> Control:
	var contenedor: Control = Control.new()
	contenedor.custom_minimum_size = Vector2(132, 118)

	var personaje: Node2D = _instanciar_player_appearance()
	if personaje == null:
		var sin_preview: Label = Label.new()
		sin_preview.text = "Sin\npreview"
		sin_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_aplicar_texto_negro(sin_preview)
		sin_preview.size = contenedor.custom_minimum_size
		contenedor.add_child(sin_preview)
		return contenedor

	personaje.scale = Vector2(4.0, 4.0)
	personaje.position = Vector2(66, 84)
	contenedor.add_child(personaje)
	_aplicar_apariencia_preview(personaje, datos_apariencia)

	return contenedor


func _crear_estilo_tarjeta_guardado() -> StyleBoxTexture:
	var estilo: StyleBoxTexture = StyleBoxTexture.new()
	estilo.texture = TEXTO_TARJETA_GUARDADO
	estilo.texture_margin_left = 6.0
	estilo.texture_margin_top = 6.0
	estilo.texture_margin_right = 6.0
	estilo.texture_margin_bottom = 6.0
	return estilo


func _aplicar_texto_negro(control: Control) -> void:
	control.add_theme_color_override("font_color", Color.BLACK)
	control.add_theme_color_override("font_hover_color", Color.BLACK)
	control.add_theme_color_override("font_pressed_color", Color.BLACK)
	control.add_theme_color_override("font_focus_color", Color.BLACK)
	control.add_theme_color_override("font_disabled_color", Color.BLACK)


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
