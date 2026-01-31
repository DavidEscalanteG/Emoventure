extends Node2D

# ---------------------------------------
# ESTADO
# ---------------------------------------
var direccion_actual: String = "down"
var estado_actual: String = "idle" # idle | walk | run

# ---------------------------------------
# REFERENCIAS
# ---------------------------------------
@onready var sprite: AnimatedSprite2D = $Sprite

# ---------------------------------------
# COLECCIÓN VISUAL
# Cada SpriteFrames = una mascota completa
# ---------------------------------------
@export var coleccion_mascotas: Array[SpriteFrames] = []


# ---------------------------------------
# API PÚBLICA
# ---------------------------------------
func aplicar_mascota_desde_global() -> void:
	if coleccion_mascotas.is_empty():
		return

	var indice: int = int(Global.mascota["indice"])

	if indice < 0 or indice >= coleccion_mascotas.size():
		indice = 0
		Global.mascota["indice"] = indice

	sprite.sprite_frames = coleccion_mascotas[indice]
	_actualizar_animacion()


func set_estado_movimiento(estado: String) -> void:
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

	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
