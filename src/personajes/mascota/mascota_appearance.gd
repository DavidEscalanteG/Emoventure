extends Node2D
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else null


# ---------------------------------------
# ESTADO
# ---------------------------------------
var direccion_actual: String = "down"
var estado_actual: String = "idle" # idle | walk | run

# ---------------------------------------
# REFERENCIAS
# ---------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ---------------------------------------
# COLECCIÓN VISUAL
# Cada SpriteFrames = una mascota completa
# ---------------------------------------
@export var coleccion_mascotas: Array[SpriteFrames] = []

func _ready() -> void:
	aplicar_mascota_desde_global()

# ---------------------------------------
# API PÚBLICA
# ---------------------------------------
func aplicar_mascota_desde_global() -> void:
	if coleccion_mascotas.is_empty():
		return

	var indice: int = DatosJugador.obtener_indice_mascota()

	if indice < 0 or indice >= coleccion_mascotas.size():
		indice = 0
		DatosJugador.set_indice_mascota(indice)

	sprite.sprite_frames = coleccion_mascotas[indice]

	# 👇 FORZAMOS ESTADO INICIAL
	estado_actual = "idle"
	direccion_actual = "left"

	_actualizar_animacion()


func establecer_estado_movimiento(estado: String) -> void:
	if estado_actual == estado:
		return

	estado_actual = estado
	_actualizar_animacion()


func set_direccion(dir: String) -> void:
	if direccion_actual == dir:
		return

	direccion_actual = dir
	_actualizar_animacion()


# ---------------------------------------
# ANIMACIÓN
# ---------------------------------------
func _actualizar_animacion() -> void:
	var anim: String = estado_actual + "_" + direccion_actual

	if sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(anim):
		return

	sprite.play(anim)
	sprite.frame = 0
