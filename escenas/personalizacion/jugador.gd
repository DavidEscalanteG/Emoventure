extends CharacterBody2D

# --- REFERENCIAS A LOS NODOS VISUALES ---
@onready var sprite_cabello = $Node2D/Cabello
@onready var sprite_ojos = $Node2D/Ojos
@onready var sprite_boca = $Node2D/Boca
@onready var sprite_cuerpo = $Node2D/Cuerpo
@onready var sprite_nariz = $Node2D/Nariz
@onready var sprite_cabeza = $Node2D/Cabeza

# --- LISTAS DE TEXTURAS (EL INVENTARIO) ---

@export var coleccion_cabellos: Array[Texture2D]
@export var coleccion_ojos: Array[Texture2D]
@export var coleccion_boca: Array[Texture2D]
@export var coleccion_cuerpo: Array[Texture2D]
@export var coleccion_nariz: Array[Texture2D]
@export var coleccion_cabeza: Array[Texture2D]



		
# --- ÍNDICES (MEMORIA) ---
# Guardamos qué número de la lista estamos usando (0 es el primero)
var indice_cabello: int = 0
var indice_ojos: int = 0
var indice_boca: int = 0
var indice_cuerpo: int = 0
var indice_nariz: int = 0
var indice_cabeza: int = 0

func _ready():
	# Al iniciar, cargamos la primera opción de cada lista
	actualizar_apariencia()


func actualizar_apariencia():
	# Verificamos que la lista no esté vacía para evitar errores
	if coleccion_cabellos.size() > 0:
		sprite_cabello.texture = coleccion_cabellos[indice_cabello]
		
	if coleccion_ojos.size() > 0:
		sprite_ojos.texture = coleccion_ojos[indice_ojos]
	
	if coleccion_boca.size() > 0:
		sprite_boca.texture = coleccion_boca[indice_boca]
		
	if coleccion_cuerpo.size() > 0:
		sprite_cuerpo.texture = coleccion_cuerpo[indice_cuerpo]
		
	if coleccion_nariz.size() > 0:
		sprite_nariz.texture = coleccion_nariz[indice_nariz]
		
	if coleccion_cabeza.size() > 0:
		sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]
	
# Función para el botón "Siguiente Peinado"
func cabello_siguiente():
	# Aumentamos el índice
	indice_cabello += 1
	
	# Si llegamos al final de la lista, volvemos al principio (loop)
	if indice_cabello >= coleccion_cabellos.size():
		indice_cabello = 0
		
	# Aplicamos el cambio
	sprite_cabello.texture = coleccion_cabellos[indice_cabello]


# Función para el botón "Peinado Anterior"
func cabello_anterior():
	indice_cabello -= 1
	
	# Si bajamos de 0, vamos al último de la lista
	if indice_cabello < 0:
		indice_cabello = coleccion_cabellos.size() - 1
		
	sprite_cabello.texture = coleccion_cabellos[indice_cabello]
	
# Función para el botón "Siguiente Cabeza"
func cabeza_siguiente():
	# Aumentamos el índice
	indice_cabeza += 1
	
	# Si llegamos al final de la lista, volvemos al principio (loop)
	if indice_cabeza >= coleccion_cabeza.size():
		indice_cabeza = 0
		
	# Aplicamos el cambio
	sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]


# Función para el botón "Cabeza Anterior"
func cabeza_anterior():
	indice_cabeza -= 1
	
	# Si bajamos de 0, vamos al último de la lista
	if indice_cabeza < 0:
		indice_cabeza = coleccion_cabeza.size() - 1
		
	sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]
	
# Función para el botón "Siguiente Ojos"
func ojos_siguiente():
	# Aumentamos el índice
	indice_ojos += 1
	
	# Si llegamos al final de la lista, volvemos al principio (loop)
	if indice_ojos >= coleccion_ojos.size():
		indice_ojos = 0
		
	# Aplicamos el cambio
	sprite_ojos.texture = coleccion_ojos[indice_ojos]


# Función para el botón "Ojos Anterior"
func ojos_anterior():
	indice_ojos -= 1
	
	# Si bajamos de 0, vamos al último de la lista
	if indice_ojos < 0:
		indice_ojos = coleccion_ojos.size() - 1
		
	sprite_ojos.texture = coleccion_ojos[indice_ojos]
	
# Función para el botón "Siguiente nariz"
func nariz_siguiente():
	# Aumentamos el índice
	indice_nariz += 1
	
	# Si llegamos al final de la lista, volvemos al principio (loop)
	if indice_nariz >= coleccion_nariz.size():
		indice_nariz = 0
		
	# Aplicamos el cambio
	sprite_nariz.texture = coleccion_nariz[indice_nariz]


# Función para el botón "Nariz Anterior"
func nariz_anterior():
	indice_nariz -= 1
	
	# Si bajamos de 0, vamos al último de la lista
	if indice_nariz < 0:
		indice_nariz = coleccion_nariz.size() - 1
		
	sprite_nariz.texture = coleccion_nariz[indice_nariz]
	
# Función para el botón "Siguiente boca"
func boca_siguiente():
	# Aumentamos el índice
	indice_boca += 1
	
	# Si llegamos al final de la lista, volvemos al principio (loop)
	if indice_boca >= coleccion_boca.size():
		indice_boca = 0
		
	# Aplicamos el cambio
	sprite_boca.texture = coleccion_boca[indice_boca]


# Función para el botón "Boca Anterior"
func boca_anterior():
	indice_boca -= 1
	
	# Si bajamos de 0, vamos al último de la lista
	if indice_boca < 0:
		indice_boca = coleccion_boca.size() - 1
		
	sprite_boca.texture = coleccion_boca[indice_boca]

func _on_btn_cabello_siguiente_pressed() -> void:
	cabello_siguiente()


func _on_btn_cabello_atras_pressed() -> void:
	cabello_anterior()


func _on_btn_cabeza_atras_pressed() -> void:
	cabeza_anterior()


func _on_btn_cabeza_siguiente_pressed() -> void:
	cabeza_siguiente()


func _on_btn_ojos_atras_pressed() -> void:
	ojos_anterior()


func _on_btn_ojos_siguiente_pressed() -> void:
	ojos_siguiente()


func _on_btn_nariz_atras_pressed() -> void:
	nariz_anterior()


func _on_btn_nariz_siguiente_pressed() -> void:
	nariz_siguiente()


func _on_btn_boca_atras_pressed() -> void:
	boca_anterior()


func _on_btn_boca_siguiente_pressed() -> void:
	boca_siguiente()


func _on_btn_cuerpo_atras_pressed() -> void:
	pass # Replace with function body.


#func _on_btn_cuerpo_siguiente_pressed() -> void:
	pass # Replace with function body.

#func _on_h_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_color_picker_button_color_changed(color_elegido):
	$Node2D/Cabello.self_modulate = color_elegido


func _on_color_picker_button_cabeza_color_changed(color_elegido):
	$Node2D/Cabeza.self_modulate = color_elegido


func _on_color_picker_button_ojos_color_changed(color_elegido):
	$Node2D/Ojos.self_modulate = color_elegido


func _on_comenzar_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/escena_1/escena_1.tscn")
