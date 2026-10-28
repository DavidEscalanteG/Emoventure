extends Node2D

# --------------------------------------------------
# REFERENCIAS
# --------------------------------------------------

@onready var apariencia: Node2D = $Jugador/PlayerAppearance
@onready var mascota: Node2D = $Mascota
@onready var panel_nombre_jugador: Control = %PanelNombreJugador
@onready var input_nombre_jugador: LineEdit = %InputNombreJugador
@onready var label_error_nombre_jugador: Label = %ErrorNombreJugador
@onready var editor_colores: VBoxContainer = %HSVColorEditor

# --------------------------------------------------
# ESTADO TEMPORAL (índices del menú)
# --------------------------------------------------

var indice_cabello: int = 0
var indice_ojos: int = 0
var indice_boca: int = 0
var indice_cuerpo: int = 0
var indice_nariz: int = 0
var indice_cabeza: int = 0

const ESCALA_PULSO_HOVER: float = 1.03
const DURACION_PULSO_HOVER: float = 0.89
const ESCALA_PRESION_BOTON: float = 0.97
const OSCURECIMIENTO_PRESION_BOTON: float = 0.82
const DURACION_SACUDIDA_PANEL_NOMBRE: float = 0.08
const DISTANCIA_SACUDIDA_PANEL_NOMBRE: float = 16.0
const REPETICIONES_SACUDIDA_PANEL_NOMBRE: int = 4
const MARGEN_RETRATO: Vector2 = Vector2(12, 8)

var _escala_base_botones: Dictionary = {}
var _tweens_hover_botones: Dictionary = {}
var _modulate_base_botones: Dictionary = {}
var _botones_presionados: Dictionary = {}
var _tween_sacudida_panel_nombre: Tween = null
var _posicion_base_panel_nombre: Vector2 = Vector2.ZERO
var _limites_retrato: Rect2 = Rect2()

# --------------------------------------------------
# CICLO DE VIDA
# --------------------------------------------------

func _ready() -> void:
	_aplicar_marcos_pixelados()
	cargar_desde_global()
	_validar_cabello_por_genero()
	refrescar_preview()
	_inicializar_nombre_jugador()
	_inicializar_posicion_panel_nombre()
	configurar_hover_botones()
	_configurar_pestanas_color()
	
	mascota.aplicar_mascota_desde_global()
	_actualizar_miniatura_mascota()
	%RetratoPeinado.resized.connect(_ajustar_retrato_peinado)
	_ajustar_retrato_peinado.call_deferred()


func _aplicar_marcos_pixelados() -> void:
	var tema_base: Theme = preload("res://assets/temas/tema_personalizacion.tres")
	var tema: Theme = tema_base.duplicate() as Theme
	var estilos_ampliados: Dictionary = {}
	# Los mismos tiles de 16/32 px del menú y configuración, ampliados sin
	# suavizado para que el relieve y los bordes sigan viéndose en esta pantalla.
	for tipo: StringName in [&"Button", &"BotonPrincipal", &"Panel", &"PanelContainer", &"LineEdit"]:
		for nombre: StringName in tema_base.get_stylebox_list(tipo):
			var origen: StyleBox = tema_base.get_stylebox(nombre, tipo)
			if not origen is StyleBoxTexture:
				continue
			if not estilos_ampliados.has(origen):
				var estilo: StyleBoxTexture = origen.duplicate() as StyleBoxTexture
				var imagen: Image = estilo.texture.get_image().get_region(Rect2i(estilo.region_rect))
				imagen.resize(imagen.get_width() * 3, imagen.get_height() * 3, Image.INTERPOLATE_NEAREST)
				estilo.texture = ImageTexture.create_from_image(imagen)
				estilo.region_rect = Rect2(Vector2.ZERO, imagen.get_size())
				for lado: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
					estilo.set_texture_margin(lado, estilo.get_texture_margin(lado) * 3.0)
				estilos_ampliados[origen] = estilo
			tema.set_stylebox(nombre, tipo, estilos_ampliados[origen])
	for nodo: Node in find_children("*", "Control", true, false):
		var control: Control = nodo as Control
		if control.theme == tema_base:
			control.theme = tema


func _configurar_pestanas_color() -> void:
	var grupo: ButtonGroup = ButtonGroup.new()
	for seccion: String in ["Cabello", "Ropa", "Piel"]:
		var boton: Button = editor_colores.get_node("PestanasColor/" + seccion)
		boton.button_group = grupo
		boton.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			seleccionar_seccion_color(seccion)
		)
		var editor: PanelContainer = editor_colores.get_node("HSVEditor" + seccion)
		editor.color_actualizado.connect(_actualizar_colores_retrato)
	seleccionar_seccion_color("Cabello")


func seleccionar_seccion_color(seccion: String) -> void:
	if seccion not in ["Cabello", "Ropa", "Piel"]:
		return
	for nombre: String in ["Cabello", "Ropa", "Piel"]:
		var editor: Control = editor_colores.get_node("HSVEditor" + nombre)
		var boton: Button = editor_colores.get_node("PestanasColor/" + nombre)
		editor.visible = nombre == seccion
		boton.set_pressed_no_signal(nombre == seccion)


# --------------------------------------------------
# SINCRONIZACIÓN
# --------------------------------------------------

func cargar_desde_global() -> void:
	indice_cabello = DatosJugador.apariencia.indice_cabello
	indice_ojos = DatosJugador.apariencia.indice_ojos
	indice_boca = DatosJugador.apariencia.indice_boca
	indice_cuerpo = DatosJugador.apariencia.indice_cuerpo
	indice_nariz = DatosJugador.apariencia.indice_nariz
	indice_cabeza = DatosJugador.apariencia.indice_cabeza


func guardar_en_global() -> void:
	DatosJugador.set_indice_cabello(indice_cabello)
	DatosJugador.apariencia.indice_ojos = indice_ojos
	DatosJugador.apariencia.indice_boca = indice_boca
	DatosJugador.apariencia.indice_cuerpo = indice_cuerpo
	DatosJugador.apariencia.indice_nariz = indice_nariz
	DatosJugador.apariencia.indice_cabeza = indice_cabeza


func refrescar_preview() -> void:
	guardar_en_global()
	apariencia.aplicar_apariencia_desde_global()
	_actualizar_retrato_peinado()


func _actualizar_retrato_peinado() -> void:
	# Cada capa conserva sus coordenadas originales. Solo la piel se limita a
	# la cabeza; el cabello puede extenderse por debajo de la barbilla.
	var regiones: Dictionary = {}
	var texturas: Dictionary = {}
	_limites_retrato = Rect2()
	for pieza: String in ["Cuerpo", "Cabello"]:
		var origen: AnimatedSprite2D = apariencia.get_node(pieza)
		var retrato: Sprite2D = get_node("%" + pieza)
		retrato.texture = null
		retrato.visible = false
		if not origen.sprite_frames.has_animation("idle_down") or origen.sprite_frames.get_frame_count("idle_down") == 0:
			continue
		var fotograma: Texture2D = origen.sprite_frames.get_frame_texture("idle_down", 0)
		# La opción sin cabello contiene un fotograma vacío.
		if fotograma == null:
			continue
		var imagen: Image = fotograma.get_image()
		if pieza == "Cuerpo":
			imagen = _extraer_cabeza_retrato(imagen)
			fotograma = ImageTexture.create_from_image(imagen)
		var region: Rect2 = Rect2(imagen.get_used_rect())
		if not region.has_area():
			continue
		regiones[pieza] = region
		texturas[pieza] = fotograma
		_limites_retrato = region if _limites_retrato.size == Vector2.ZERO else _limites_retrato.merge(region)
	for pieza: String in ["Cuerpo", "Cabello"]:
		if not regiones.has(pieza):
			continue
		var retrato: Sprite2D = get_node("%" + pieza)
		var region: Rect2 = regiones[pieza]
		var textura: AtlasTexture = AtlasTexture.new()
		textura.atlas = texturas[pieza]
		textura.region = region
		retrato.texture = textura
		retrato.visible = true
		retrato.offset = region.get_center() - _limites_retrato.get_center()
		retrato.material = apariencia.get_node(pieza).material
	_ajustar_retrato_peinado()
	_actualizar_colores_retrato()


func _extraer_cabeza_retrato(origen: Image) -> Image:
	# La cabeza del idle_down comparte hoja con el cuerpo. A partir de la fila
	# 26, seguimos la mandíbula para conservar nariz y barbilla sin hombros.
	var cabeza: Image = Image.create(origen.get_width(), origen.get_height(), false, Image.FORMAT_RGBA8)
	cabeza.fill(Color.TRANSPARENT)
	cabeza.blit_rect(origen, Rect2i(0, 0, origen.get_width(), 26), Vector2i.ZERO)
	for franja: Rect2i in [Rect2i(28, 26, 9, 1), Rect2i(29, 27, 7, 1), Rect2i(30, 28, 5, 1)]:
		cabeza.blit_rect(origen, franja, franja.position)
	return cabeza


func _ajustar_retrato_peinado() -> void:
	if _limites_retrato.size == Vector2.ZERO:
		return
	var area: Control = %RetratoPeinado
	var disponible: Vector2 = area.size - MARGEN_RETRATO
	# Escala entera para mantener nítido el pixel art, incluso con pelo largo.
	var factor: float = maxf(1.0, floorf(minf(disponible.x / _limites_retrato.size.x, disponible.y / _limites_retrato.size.y)))
	%Retrato.scale = Vector2.ONE * factor
	%Retrato.position = (area.size * 0.5).floor()


func _actualizar_colores_retrato() -> void:
	%Cuerpo.self_modulate = apariencia.cuerpo.self_modulate
	%Cabello.self_modulate = apariencia.cabello.self_modulate


func _actualizar_miniatura_mascota() -> void:
	# Usa la misma orientación en el escenario y en su selector.
	var fotogramas: SpriteFrames = mascota.sprite.sprite_frames
	var animacion: StringName = &"idle_right"
	mascota.sprite.flip_h = false
	if not fotogramas.has_animation(animacion) or fotogramas.get_frame_count(animacion) == 0:
		# Algunas hojas de gato solo tienen el reposo hacia la izquierda.
		animacion = &"idle_left"
		mascota.set_direccion("left")
		mascota.sprite.flip_h = true
	else:
		mascota.set_direccion("right")
	var fotograma: Texture2D = fotogramas.get_frame_texture(animacion, 0)
	var textura: AtlasTexture = AtlasTexture.new()
	textura.atlas = fotograma
	textura.region = Rect2(fotograma.get_image().get_used_rect())
	%MiniaturaMascota.texture = textura
	%MiniaturaMascota.flip_h = mascota.sprite.flip_h


# --------------------------------------------------
# UTILIDADES DE ÍNDICES
# --------------------------------------------------

func _siguiente(indice: int, coleccion: Array) -> int:
	if coleccion.is_empty():
		return indice
	return (indice + 1) % coleccion.size()

func _anterior(indice: int, coleccion: Array) -> int:
	if coleccion.is_empty():
		return indice
	indice -= 1
	return indice if indice >= 0 else coleccion.size() - 1


# --------------------------------------------------
# BOTONES – PARTES DEL CUERPO
# --------------------------------------------------

func _on_btn_cabello_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cabello = DatosJugador.avanzar_indice_cabello()
	refrescar_preview()

func _on_btn_cabello_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cabello = DatosJugador.retroceder_indice_cabello()
	refrescar_preview()


func _on_btn_cabeza_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cabeza = _siguiente(indice_cabeza, apariencia.coleccion_cabezas)
	refrescar_preview()

func _on_btn_cabeza_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cabeza = _anterior(indice_cabeza, apariencia.coleccion_cabezas)
	refrescar_preview()


func _on_btn_ojos_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_ojos = _siguiente(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()

func _on_btn_ojos_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_ojos = _anterior(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()


func _on_btn_nariz_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_nariz = _siguiente(indice_nariz, apariencia.coleccion_narices)
	refrescar_preview()

func _on_btn_nariz_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_nariz = _anterior(indice_nariz, apariencia.coleccion_narices)
	refrescar_preview()


func _on_btn_boca_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_boca = _siguiente(indice_boca, apariencia.coleccion_bocas)
	refrescar_preview()

func _on_btn_boca_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_boca = _anterior(indice_boca, apariencia.coleccion_bocas)
	refrescar_preview()


func _on_btn_cuerpo_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cuerpo = _siguiente(indice_cuerpo, apariencia.coleccion_cuerpos)
	refrescar_preview()
func _on_btn_cuerpo_atras_pressed() -> void:
	AudioManager.play_ui_click()
	indice_cuerpo = _anterior(indice_cuerpo, apariencia.coleccion_cuerpos)
	refrescar_preview()


# --------------------------------------------------
# COLOR PICKERS
# --------------------------------------------------

func _on_color_picker_button_cabeza_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_cabeza = color
	apariencia.restaurar_colores()

func _on_color_picker_button_ojos_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_ojos = color
	apariencia.restaurar_colores()

func _on_color_picker_button_boca_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_boca = color
	apariencia.restaurar_colores()

func _on_color_picker_button_cuerpo_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_cuerpo = color
	apariencia.restaurar_colores()

# --------------------------------------------------
# BOTÓN FINAL
# --------------------------------------------------

func _on_comenzar_pressed() -> void:
	AudioManager.play_ui_click()
	var validacion: Dictionary = DatosJugador.validar_nombre(input_nombre_jugador.text)
	if not validacion.ok:
		label_error_nombre_jugador.text = "Escribe tu nombre para continuar." if DatosJugador.limpiar_nombre(input_nombre_jugador.text).is_empty() else "Ese nombre no está permitido."
		_sacudir_panel_nombre_jugador()
		return

	DatosJugador.nombre_jugador = validacion.nombre
	label_error_nombre_jugador.text = ""
	guardar_en_global()
	SaveManager.confirmar_guardado_inicial("res://scenes/intro_dialogo_1/intro_dialogo_1.tscn")
	get_tree().change_scene_to_file("uid://dlfpd1a8lfh5") #intro_dialogo_1.tscn


func _on_mascota_siguiente_pressed() -> void:
	AudioManager.play_ui_click()
	_actualizar_indice_mascota(1)


func mascota_anterior() -> void:
	# Compatibilidad temporal: usar _actualizar_indice_mascota(-1).
	_actualizar_indice_mascota(-1)


func _on_mascota_anterior_pressed() -> void:
	AudioManager.play_ui_click()
	mascota_anterior()


func _actualizar_indice_mascota(delta: int) -> void:
	if mascota.coleccion_mascotas.is_empty():
		return

	var indice: int = DatosJugador.obtener_indice_mascota()
	indice = (indice + delta) % mascota.coleccion_mascotas.size()

	if indice < 0:
		indice += mascota.coleccion_mascotas.size()

	DatosJugador.set_indice_mascota(indice)
	mascota.aplicar_mascota_desde_global()
	_actualizar_miniatura_mascota()

func _validar_cabello_por_genero() -> void:
	if DatosJugador.genero == "":
		return
	
	var rango: Vector2i = DatosJugador.obtener_rango_cabello_por_genero(DatosJugador.genero)
	
	if indice_cabello < rango.x or indice_cabello > rango.y:
		DatosJugador.set_indice_cabello(rango.x)
		indice_cabello = DatosJugador.apariencia.indice_cabello


func _inicializar_nombre_jugador() -> void:
	if DatosJugador.nombre_jugador.is_empty():
		DatosJugador.nombre_jugador = DatosJugador.NOMBRE_JUGADOR_PREDETERMINADO

	input_nombre_jugador.text = DatosJugador.nombre_jugador
	label_error_nombre_jugador.text = ""


func configurar_hover_botones() -> void:
	for boton in find_children("*", "BaseButton", true, false):
		var boton_base := boton as BaseButton
		var control := boton_base as Control
		if boton_base == null or control == null:
			continue

		_escala_base_botones[control] = control.scale
		_modulate_base_botones[control] = control.modulate
		control.pivot_offset = control.size / 2.0
		control.resized.connect(func() -> void:
			if is_instance_valid(control):
				control.pivot_offset = control.size / 2.0
		)
		control.mouse_entered.connect(func() -> void:
			_on_boton_mouse_entered(control)
		)
		control.mouse_exited.connect(func() -> void:
			_on_boton_mouse_exited(control)
		)
		boton_base.button_down.connect(func() -> void:
			_on_boton_button_down(control)
		)
		boton_base.button_up.connect(func() -> void:
			_on_boton_button_up(control)
		)


func _on_boton_mouse_entered(boton: Control) -> void:
	if _esta_boton_presionado(boton):
		return
	_iniciar_pulso_boton(boton)


func _on_boton_mouse_exited(boton: Control) -> void:
	if _esta_boton_presionado(boton):
		return
	_detener_pulso_boton(boton)


func _iniciar_pulso_boton(boton: Control) -> void:
	if _esta_boton_presionado(boton):
		return
	_detener_tween_boton(boton)

	var escala_base: Vector2 = _escala_base_botones.get(boton, boton.scale)
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(boton, "scale", escala_base * ESCALA_PULSO_HOVER, DURACION_PULSO_HOVER)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER)
	_tweens_hover_botones[boton] = tween


func _detener_pulso_boton(boton: Control) -> void:
	if _esta_boton_presionado(boton):
		return
	_detener_tween_boton(boton)

	var escala_base: Vector2 = _escala_base_botones.get(boton, Vector2.ONE)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER)
	_tweens_hover_botones[boton] = tween


func _detener_tween_boton(boton: Control) -> void:
	var tween: Tween = _tweens_hover_botones.get(boton)
	if tween != null and tween.is_running():
		tween.kill()


func _on_boton_button_down(boton: Control) -> void:
	_botones_presionados[boton] = true
	_detener_tween_boton(boton)

	var escala_base: Vector2 = _escala_base_botones.get(boton, Vector2.ONE)
	var modulate_base: Color = _modulate_base_botones.get(boton, Color.WHITE)
	var modulate_presionado := Color(
		modulate_base.r * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.g * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.b * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.a
	)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base * ESCALA_PRESION_BOTON, DURACION_PULSO_HOVER * 0.45)
	tween.parallel().tween_property(boton, "modulate", modulate_presionado, DURACION_PULSO_HOVER * 0.45)
	_tweens_hover_botones[boton] = tween


func _on_boton_button_up(boton: Control) -> void:
	_botones_presionados[boton] = false
	_detener_tween_boton(boton)

	var escala_base: Vector2 = _escala_base_botones.get(boton, Vector2.ONE)
	var modulate_base: Color = _modulate_base_botones.get(boton, Color.WHITE)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER * 0.5)
	tween.parallel().tween_property(boton, "modulate", modulate_base, DURACION_PULSO_HOVER * 0.5)
	_tweens_hover_botones[boton] = tween

	if boton.get_global_rect().has_point(boton.get_global_mouse_position()):
		_iniciar_pulso_boton(boton)


func _esta_boton_presionado(boton: Control) -> bool:
	return _botones_presionados.get(boton, false)


func _sacudir_panel_nombre_jugador() -> void:
	if panel_nombre_jugador == null:
		return

	if _tween_sacudida_panel_nombre != null and _tween_sacudida_panel_nombre.is_running():
		_tween_sacudida_panel_nombre.kill()
	else:
		# El contenedor calcula esta posición después de _ready y al redimensionar.
		_posicion_base_panel_nombre = panel_nombre_jugador.position

	panel_nombre_jugador.position = _posicion_base_panel_nombre
	
	_tween_sacudida_panel_nombre = create_tween()
	_tween_sacudida_panel_nombre.set_trans(Tween.TRANS_SINE)
	_tween_sacudida_panel_nombre.set_ease(Tween.EASE_IN_OUT)

	for iteracion in REPETICIONES_SACUDIDA_PANEL_NOMBRE:
		var direccion: float = 1.0 if iteracion % 2 == 0 else -1.0
		var desplazamiento: Vector2 = Vector2(DISTANCIA_SACUDIDA_PANEL_NOMBRE * direccion, 0.0)
		_tween_sacudida_panel_nombre.tween_property(
			panel_nombre_jugador,
			"position",
			_posicion_base_panel_nombre + desplazamiento,
			DURACION_SACUDIDA_PANEL_NOMBRE
		)

	_tween_sacudida_panel_nombre.tween_property(
		panel_nombre_jugador,
		"position",
		_posicion_base_panel_nombre,
		DURACION_SACUDIDA_PANEL_NOMBRE
	)
	
	_tween_sacudida_panel_nombre.finished.connect(func() -> void:
		if is_instance_valid(panel_nombre_jugador):
			panel_nombre_jugador.position = _posicion_base_panel_nombre
	)


func _inicializar_posicion_panel_nombre() -> void:
	if panel_nombre_jugador == null:
		return
	_posicion_base_panel_nombre = panel_nombre_jugador.position
