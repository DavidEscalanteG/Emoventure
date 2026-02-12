extends Control

# ==================================================
# CONFIGURACIÓN (Inspector)
# ==================================================

# Clave del color dentro de Global.apariencia
# Ejemplos:
# "color_cabello"
# "color_ojos"
# "color_cuerpo"
@export var clave_color_global: String

# Referencia al PlayerAppearance
# Ruta: Jugador/PlayerAppearance
@export var apariencia: Node2D


# ==================================================
# REFERENCIAS A SLIDERS
# ==================================================

@onready var slider_h: HSlider = $HSliderHue
@onready var slider_s: HSlider = $HSliderSat
@onready var slider_v: HSlider = $HSliderVal


# ==================================================
# CICLO DE VIDA
# ==================================================

func _ready() -> void:
	_configurar_sliders()
	_sincronizar_desde_global()
	_generar_gradientes_iniciales()
	_conectar_signals()


# ==================================================
# CONFIGURACIÓN INICIAL
# ==================================================

func _configurar_sliders() -> void:
	# Hue
	slider_h.min_value = 0.0
	slider_h.max_value = 1.0
	slider_h.step = 0.001

	# Saturation
	slider_s.min_value = 0.0
	slider_s.max_value = 1.0
	slider_s.step = 0.001

	# Value (limitado)
	slider_v.min_value = 0.125
	slider_v.max_value = 1.0
	slider_v.step = 0.001

func _conectar_signals() -> void:
	slider_h.value_changed.connect(_on_hue_changed)
	slider_s.value_changed.connect(_on_sat_changed)
	slider_v.value_changed.connect(_on_val_changed)


# ==================================================
# SINCRONIZACIÓN
# ==================================================

func _sincronizar_desde_global() -> void:
	if not Global.tiene_clave_color_apariencia(clave_color_global):
		push_warning("Clave no encontrada en Global.apariencia: " + clave_color_global)
		return

	var c: Color = Global.obtener_color_apariencia(clave_color_global)

	slider_h.value = c.h
	slider_s.value = c.s
	slider_v.value = max(c.v, slider_v.min_value)


# ==================================================
# CALLBACKS DE SLIDERS
# ==================================================

func _on_hue_changed(_value: float) -> void:
	_generar_gradiente_saturacion(slider_h.value, slider_v.value)
	_generar_gradiente_value(slider_h.value, slider_s.value)
	_actualizar_color()



func _on_sat_changed(_value: float) -> void:
	_generar_gradiente_value(slider_h.value, slider_s.value)
	_actualizar_color()	


func _on_val_changed(_value: float) -> void:
	_generar_gradiente_saturacion(slider_h.value, slider_v.value)
	_actualizar_color()


# ==================================================
# ACTUALIZAR COLOR
# ==================================================

func _actualizar_color() -> void:
	var nuevo_color := Color.from_hsv(
		slider_h.value,
		slider_s.value,
		slider_v.value
	)

	Global.set_color_apariencia(clave_color_global, nuevo_color)

	if apariencia:
		apariencia._restaurar_colores()


# ==================================================
# GRADIENTES (IMÁGENES POR CÓDIGO)
# ==================================================

func _crear_imagen_base(ancho := 256, alto := 8) -> Image:
	return Image.create(ancho, alto, false, Image.FORMAT_RGBA8)


func _generar_gradientes_iniciales() -> void:
	_generar_gradiente_hue()

	var c: Color = Global.obtener_color_apariencia(clave_color_global)
	_generar_gradiente_saturacion(c.h, c.v)
	_generar_gradiente_value(c.h, c.s)


func _generar_gradiente_hue() -> void:
	var img := _crear_imagen_base()

	for x in img.get_width():
		var h := float(x) / float(img.get_width() - 1)
		var color := Color.from_hsv(h, 1.0, 1.0)
		for y in img.get_height():
			img.set_pixel(x, y, color)

	_asignar_fondo(slider_h, img)


func _generar_gradiente_saturacion(hue: float, value: float) -> void:
	var img := _crear_imagen_base()

	for x in img.get_width():
		var s := float(x) / float(img.get_width() - 1)
		var color := Color.from_hsv(hue, s, value)
		for y in img.get_height():
			img.set_pixel(x, y, color)

	_asignar_fondo(slider_s, img)


func _generar_gradiente_value(hue: float, sat: float) -> void:
	var img := _crear_imagen_base()

	for x in img.get_width():
		var v := float(x) / float(img.get_width() - 1)
		var color := Color.from_hsv(hue, sat, v)
		for y in img.get_height():
			img.set_pixel(x, y, color)

	_asignar_fondo(slider_v, img)


# ==================================================
# APLICAR TEXTURA A SLIDER
# ==================================================

func _asignar_fondo(slider: HSlider, img: Image) -> void:
	var tex := ImageTexture.create_from_image(img)

	var style := StyleBoxTexture.new()
	style.texture = tex
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 10

	slider.add_theme_stylebox_override("slider", style)
