extends Node2D

# ==================================================
# ESTADO
# ==================================================
var direccion_actual: String = "down"
var estado_actual: String = "idle" # idle | walk


# ==================================================
# REFERENCIAS A PARTES DEL CUERPO
# ==================================================
@onready var cabello: AnimatedSprite2D = $Cabello
@onready var cabeza: AnimatedSprite2D = $Cabeza
@onready var ojos: AnimatedSprite2D = $Ojos
@onready var boca: AnimatedSprite2D = $Boca
@onready var nariz: AnimatedSprite2D = $Nariz
@onready var cuerpo: AnimatedSprite2D = $Cuerpo


# ==================================================
# INVENTARIO VISUAL (SpriteFrames)
# Cada índice representa un "estilo"
# ==================================================
@export var coleccion_cabellos: Array[SpriteFrames]
@export var coleccion_cabezas: Array[SpriteFrames]
@export var coleccion_ojos: Array[SpriteFrames]
@export var coleccion_bocas: Array[SpriteFrames]
@export var coleccion_narices: Array[SpriteFrames]
@export var coleccion_cuerpos: Array[SpriteFrames]


# ==================================================
# EXPRESIONES (lógicas, no animaciones)
# ==================================================
@export var expresiones_ojos: Dictionary
# ejemplo:
# "neutral" -> "neutral"
# "feliz"   -> "happy"
# "enojado" -> "angry"


func _process(_delta: float) -> void:
	_sincronizar_partes()


func _sincronizar_partes() -> void:
	var anim: StringName = cuerpo.animation
	var frame: int = cuerpo.frame
	var flip_h: bool = cuerpo.flip_h
	var flip_v: bool = cuerpo.flip_v

	for sprite in [cabello, cabeza, ojos, boca, nariz]:
		if sprite.sprite_frames == null:
			continue
		if not sprite.sprite_frames.has_animation(anim):
			continue

		sprite.animation = anim
		sprite.frame = frame
		sprite.flip_h = flip_h
		sprite.flip_v = flip_v


# ==================================================
# API PÚBLICA (para DialogueActors)
# ==================================================

func establecer_direccion(dir: String) -> void:
	if direccion_actual == dir:
		return

	direccion_actual = dir
	_actualizar_animacion()


func establecer_expresion(nombre: String) -> void:
	if expresiones_ojos.has(nombre):
		var anim: String = expresiones_ojos[nombre]
		if ojos.sprite_frames and ojos.sprite_frames.has_animation(anim + "_" + direccion_actual):
			ojos.play(anim + "_" + direccion_actual)


func establecer_estado_movimiento(estado: String) -> void:
	if estado_actual == estado:
		return

	estado_actual = estado
	_actualizar_animacion()


# ==================================================
# BRIDGE CON DATOSJUGADOR (safe para CI)
# ==================================================

func _get_datos_jugador() -> Object:
	if Engine.has_singleton("DatosJugador"):
		return Engine.get_singleton("DatosJugador")
	return null


func _get_apariencia() -> Variant:
	var datos_jugador: Object = _get_datos_jugador()
	if datos_jugador == null:
		return null
	return datos_jugador.get("apariencia")


func _get_indice_apariencia(clave: String, fallback: int = 0) -> int:
	var apariencia: Variant = _get_apariencia()
	if apariencia == null:
		return fallback
	return int(apariencia.get(clave))


func _get_color_apariencia(clave: String, fallback: Color = Color.WHITE) -> Color:
	var apariencia: Variant = _get_apariencia()
	if apariencia == null:
		return fallback
	return apariencia.get(clave, fallback)


# ==================================================
# APLICAR APARIENCIA DESDE GLOBAL
# ==================================================

func aplicar_apariencia_desde_global() -> void:
	_validar_indices_por_genero()

	_aplicar_spriteframes(cabello, coleccion_cabellos, _get_indice_apariencia("indice_cabello"))
	_aplicar_spriteframes(cabeza, coleccion_cabezas, _get_indice_apariencia("indice_cabeza"))
	_aplicar_spriteframes(ojos, coleccion_ojos, _get_indice_apariencia("indice_ojos"))
	_aplicar_spriteframes(boca, coleccion_bocas, _get_indice_apariencia("indice_boca"))
	_aplicar_spriteframes(nariz, coleccion_narices, _get_indice_apariencia("indice_nariz"))
	_aplicar_spriteframes(cuerpo, coleccion_cuerpos, _get_indice_apariencia("indice_cuerpo"))

	restaurar_colores()
	actualizar_animacion_visual()


func _validar_indices_por_genero() -> void:
	var datos_jugador: Object = _get_datos_jugador()
	if datos_jugador == null:
		return
	datos_jugador.call("set_indice_cabello", _get_indice_apariencia("indice_cabello"))


func _aplicar_spriteframes(
	sprite: AnimatedSprite2D,
	coleccion: Array[SpriteFrames],
	indice: int
) -> void:
	aplicar_spriteframes_por_indice(sprite, coleccion, indice)


func aplicar_spriteframes_por_indice(
	sprite: AnimatedSprite2D,
	coleccion: Array[SpriteFrames],
	indice: int
) -> void:
	if coleccion.is_empty():
		return
	if indice < 0 or indice >= coleccion.size():
		return

	sprite.sprite_frames = coleccion[indice]


# ==================================================
# ANIMACIONES
# ==================================================
func _actualizar_animacion() -> void:
	actualizar_animacion_visual()


func actualizar_animacion_visual() -> void:
	var nombre_anim: String = estado_actual + "_" + direccion_actual

	if cuerpo.sprite_frames and cuerpo.sprite_frames.has_animation(nombre_anim):
		cuerpo.play(nombre_anim)


func _reproducir(sprite: AnimatedSprite2D, anim: String) -> void:
	if sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(anim):
		return
	sprite.play(anim)


# ==================================================
# COLORES
# ==================================================

func aplicar_color_emocion(color: Color) -> void:
	cuerpo.self_modulate = color
	cabeza.self_modulate = color


func _restaurar_colores() -> void:
	restaurar_colores()


func restaurar_colores() -> void:
	cabello.self_modulate = _get_color_apariencia("color_cabello")
	cabeza.self_modulate = _get_color_apariencia("color_cabeza")
	ojos.self_modulate = _get_color_apariencia("color_ojos")
	boca.self_modulate = _get_color_apariencia("color_boca")
	nariz.self_modulate = _get_color_apariencia("color_nariz")
	cuerpo.self_modulate = _get_color_apariencia("color_cuerpo")
