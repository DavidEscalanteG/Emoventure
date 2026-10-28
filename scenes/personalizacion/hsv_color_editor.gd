extends PanelContainer

signal color_actualizado

## Editor compartido por cabello, ropa, piel y gorro.
@export var clave_color_global: String
@export var titulo: String = "Color"
@export var apariencia: Node2D

const INDICADOR: Texture2D = preload("res://assets/assets_personalizacion/indicador_color.svg")
const INDICADOR_ACTIVO: Texture2D = preload("res://assets/assets_personalizacion/indicador_color_activo.svg")

@onready var slider_h: HSlider = $Contenido/Tono/HSliderHue
@onready var slider_s: HSlider = $Contenido/Saturacion/HSliderSat
@onready var slider_v: HSlider = $Contenido/Brillo/HSliderVal
@onready var valor_h: Label = $Contenido/Tono/Encabezado/Valor
@onready var valor_s: Label = $Contenido/Saturacion/Encabezado/Valor
@onready var valor_v: Label = $Contenido/Brillo/Encabezado/Valor
@onready var muestra: Panel = $Contenido/Tono/Encabezado/Muestra

var _estilo_muestra: StyleBoxFlat


func _ready() -> void:
	$Contenido/Encabezado/Titulo.text = titulo
	_estilo_muestra = muestra.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	muestra.add_theme_stylebox_override("panel", _estilo_muestra)
	_configurar_sliders()
	_sincronizar_desde_global()
	_generar_gradiente_hue()
	_generar_gradiente_saturacion()
	_generar_gradiente_brillo()
	_actualizar_indicadores()
	slider_h.value_changed.connect(_on_hue_changed)
	slider_s.value_changed.connect(_on_sat_changed)
	slider_v.value_changed.connect(_on_val_changed)


func _configurar_sliders() -> void:
	for barra: HSlider in [slider_h, slider_s, slider_v]:
		barra.min_value = 0.0
		barra.max_value = 1.0
		barra.step = 0.001
		barra.focus_mode = Control.FOCUS_ALL
		barra.add_theme_icon_override("grabber", INDICADOR)
		barra.add_theme_icon_override("grabber_highlight", INDICADOR_ACTIVO)
		barra.add_theme_icon_override("grabber_disabled", INDICADOR)
		barra.add_theme_stylebox_override("grabber_area", StyleBoxEmpty.new())
		barra.add_theme_stylebox_override("grabber_area_highlight", StyleBoxEmpty.new())
	# Conserva el límite de brillo del editor original.
	slider_v.min_value = 0.125


func _sincronizar_desde_global() -> void:
	if not DatosJugador.tiene_clave_color_apariencia(clave_color_global):
		push_warning("Clave no encontrada en DatosJugador.apariencia: " + clave_color_global)
		return
	var color: Color = DatosJugador.obtener_color_apariencia(clave_color_global)
	slider_h.value = color.h
	slider_s.value = color.s
	slider_v.value = maxf(color.v, slider_v.min_value)


func _on_hue_changed(_valor: float) -> void:
	_generar_gradiente_saturacion()
	_generar_gradiente_brillo()
	_actualizar_color()


func _on_sat_changed(_valor: float) -> void:
	_generar_gradiente_brillo()
	_actualizar_color()


func _on_val_changed(_valor: float) -> void:
	_generar_gradiente_saturacion()
	_actualizar_color()


func _color_actual() -> Color:
	return Color.from_hsv(slider_h.value, slider_s.value, slider_v.value)


func _actualizar_color() -> void:
	DatosJugador.set_color_apariencia(clave_color_global, _color_actual())
	_actualizar_indicadores()
	if apariencia:
		apariencia.restaurar_colores()
	color_actualizado.emit()


func _actualizar_indicadores() -> void:
	valor_h.text = "%d°" % roundi(slider_h.value * 360.0)
	valor_s.text = "%d%%" % roundi(slider_s.value * 100.0)
	valor_v.text = "%d%%" % roundi(slider_v.value * 100.0)
	_estilo_muestra.bg_color = _color_actual()


func _generar_gradiente_hue() -> void:
	_asignar_gradiente(slider_h, 0)


func _generar_gradiente_saturacion() -> void:
	_asignar_gradiente(slider_s, 1)


func _generar_gradiente_brillo() -> void:
	_asignar_gradiente(slider_v, 2)


func _asignar_gradiente(barra: HSlider, canal: int) -> void:
	# Borde en píxeles y degradado sin relleno superpuesto al arrastrar.
	var imagen: Image = Image.create(256, 16, false, Image.FORMAT_RGBA8)
	imagen.fill(Color("#080e1c"))
	imagen.fill_rect(Rect2i(1, 1, 254, 14), Color("#56607a"))
	for x: int in range(2, 254):
		var proporcion: float = float(x - 2) / 251.0
		var color: Color
		match canal:
			0:
				color = Color.from_hsv(proporcion, 1.0, 1.0)
			1:
				color = Color.from_hsv(slider_h.value, proporcion, slider_v.value)
			2:
				# El extremo izquierdo representa el mínimo real permitido.
				color = Color.from_hsv(slider_h.value, slider_s.value, lerpf(slider_v.min_value, 1.0, proporcion))
		for y: int in range(2, 14):
			imagen.set_pixel(x, y, color)
	var estilo: StyleBoxTexture = StyleBoxTexture.new()
	estilo.texture = ImageTexture.create_from_image(imagen)
	estilo.texture_margin_left = 2.0
	estilo.texture_margin_right = 2.0
	estilo.texture_margin_top = 2.0
	estilo.texture_margin_bottom = 2.0
	estilo.content_margin_top = 16.0
	estilo.content_margin_bottom = 16.0
	barra.add_theme_stylebox_override("slider", estilo)
