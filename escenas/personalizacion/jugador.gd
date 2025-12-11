extends CharacterBody2D

# --- REFERENCIAS (Asegúrate de tener los mismos nombres de nodos en esta escena) ---
@onready var sprite_cabello = $Node2D/Cabello
@onready var sprite_ojos = $Node2D/Ojos
@onready var sprite_boca = $Node2D/Boca
@onready var sprite_cuerpo = $Node2D/Cuerpo
@onready var sprite_nariz = $Node2D/Nariz
@onready var sprite_cabeza = $Node2D/Cabeza

# --- INVENTARIO (Copia y pega las mismas listas del otro script en el inspector) ---
@export var coleccion_cabellos: Array[Texture2D]
@export var coleccion_ojos: Array[Texture2D]
@export var coleccion_boca: Array[Texture2D]
@export var coleccion_cuerpo: Array[Texture2D]
@export var coleccion_nariz: Array[Texture2D]
@export var coleccion_cabeza: Array[Texture2D]

# Diccionario para expresiones (Opcional, para diálogos)
@export var expresiones_ojos: Dictionary 

func _ready():
	cargar_apariencia_desde_global()

func cargar_apariencia_desde_global():
	# RECONSTRUCCIÓN: Usamos los datos guardados en "Global"
	
	# 1. Texturas
	if coleccion_cabellos.size() > 0:
		sprite_cabello.texture = coleccion_cabellos[Global.apariencia.indice_cabello]
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
		
	# 2. Colores
	sprite_cabello.self_modulate = Global.apariencia.color_cabello
	sprite_cabeza.self_modulate = Global.apariencia.color_cabeza
	sprite_ojos.self_modulate = Global.apariencia.color_ojos
	sprite_boca.self_modulate = Global.apariencia.color_boca
	sprite_nariz.self_modulate = Global.apariencia.color_nariz
	sprite_cuerpo.self_modulate = Global.apariencia.color_cuerpo

# Función para diálogos (Mantiene el color de ojos original)
func cambiar_gesto(nombre_emocion: String):
	if expresiones_ojos.has(nombre_emocion):
		sprite_ojos.texture = expresiones_ojos[nombre_emocion]
		# IMPORTANTE: Re-aplicar el color guardado, o la expresión saldrá blanca
		sprite_ojos.self_modulate = Global.apariencia.color_ojos
