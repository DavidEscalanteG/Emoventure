extends Node2D

var direccion_actual: String = "down"

# --- REFERENCIAS A SPRITES ---
@onready var sprite_cabello: Sprite2D = $Cabello
@onready var sprite_ojos: Sprite2D = $Ojos
@onready var sprite_boca: Sprite2D = $Boca
@onready var sprite_cuerpo: Sprite2D = $Cuerpo
@onready var sprite_nariz: Sprite2D = $Nariz
@onready var sprite_cabeza: Sprite2D = $Cabeza

# --- INVENTARIO VISUAL ---
@export var coleccion_cabellos: Array[Dictionary]

@export var coleccion_ojos: Array[Texture2D]
@export var coleccion_boca: Array[Texture2D]
@export var coleccion_cuerpo: Array[Texture2D]
@export var coleccion_nariz: Array[Texture2D]
@export var coleccion_cabeza: Array[Texture2D]

# --- EXPRESIONES ---
@export var expresiones_ojos: Dictionary

# --- DIRECCIONES ---
func set_direccion(dir: String) -> void:
	if direccion_actual == dir:
		return
	direccion_actual = dir
	aplicar_apariencia_desde_global()

# --------------------------------------------------
# APLICAR APARIENCIA
# --------------------------------------------------
func aplicar_apariencia_desde_global() -> void:
	
	# --- CABELLO CON DIRECCIÓN ---
	if coleccion_cabellos.size() > 0:
		var estilo := coleccion_cabellos[Global.apariencia.indice_cabello]
		if estilo.has(direccion_actual):
			sprite_cabello.texture = estilo[direccion_actual]
		
		
	if coleccion_cabeza.size() > 0:
		sprite_cabeza.texture = coleccion_cabeza[Global.apariencia.indice_cabeza]
	if coleccion_ojos.size() > 0:
		sprite_ojos.texture = coleccion_ojos[Global.apariencia.indice_ojos]
	if coleccion_boca.size() > 0:
		sprite_boca.texture = coleccion_boca[Global.apariencia.indice_boca]
	if coleccion_nariz.size() > 0:
		sprite_nariz.texture = coleccion_nariz[Global.apariencia.indice_nariz]
	if coleccion_cuerpo.size() > 0:
		sprite_cuerpo.texture = coleccion_cuerpo[Global.apariencia.indice_cuerpo]

	restaurar_colores()


func aplicar_color_emocion(color: Color) -> void:
	sprite_cuerpo.self_modulate = color
	sprite_cabeza.self_modulate = color


func restaurar_colores() -> void:
	sprite_cabello.self_modulate = Global.apariencia.color_cabello
	sprite_cabeza.self_modulate = Global.apariencia.color_cabeza
	sprite_ojos.self_modulate = Global.apariencia.color_ojos
	sprite_boca.self_modulate = Global.apariencia.color_boca
	sprite_nariz.self_modulate = Global.apariencia.color_nariz
	sprite_cuerpo.self_modulate = Global.apariencia.color_cuerpo


# --------------------------------------------------
# EXPRESIONES / DIÁLOGOS
# --------------------------------------------------
func cambiar_gesto(nombre_emocion: String) -> void:
	if expresiones_ojos.has(nombre_emocion):
		sprite_ojos.texture = expresiones_ojos[nombre_emocion]
		sprite_ojos.self_modulate = Global.apariencia.color_ojos
