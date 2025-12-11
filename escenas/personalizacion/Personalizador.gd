extends CharacterBody2D

# --- 1. REFERENCIAS A LOS NODOS VISUALES ---
# Asegúrate de que estos nombres coincidan con tu árbol de escena
@onready var sprite_cabello = $Node2D/Cabello
@onready var sprite_ojos = $Node2D/Ojos
@onready var sprite_boca = $Node2D/Boca
@onready var sprite_cuerpo = $Node2D/Cuerpo
@onready var sprite_nariz = $Node2D/Nariz
@onready var sprite_cabeza = $Node2D/Cabeza

# --- 2. EL INVENTARIO (Listas de imágenes) ---
# Recuerda volver a llenar estas listas en el Inspector después de pegar el script
@export var coleccion_cabellos: Array[Texture2D]
@export var coleccion_ojos: Array[Texture2D]
@export var coleccion_boca: Array[Texture2D]
@export var coleccion_cuerpo: Array[Texture2D]
@export var coleccion_nariz: Array[Texture2D]
@export var coleccion_cabeza: Array[Texture2D]

# --- 3. LA MEMORIA (Índices) ---
var indice_cabello: int = 0
var indice_ojos: int = 0
var indice_boca: int = 0
var indice_cuerpo: int = 0
var indice_nariz: int = 0
var indice_cabeza: int = 0

func _ready():
	# 1. Primero leemos los defaults que pusiste en Global
	cargar_valores_iniciales()
	
	# 2. Luego actualizamos las texturas visualmente
	actualizar_apariencia()

func actualizar_apariencia():
	# Protecciones para evitar errores si las listas están vacías
	if coleccion_cabellos.size() > 0: sprite_cabello.texture = coleccion_cabellos[indice_cabello]
	if coleccion_ojos.size() > 0: sprite_ojos.texture = coleccion_ojos[indice_ojos]
	if coleccion_boca.size() > 0: sprite_boca.texture = coleccion_boca[indice_boca]
	if coleccion_cuerpo.size() > 0: sprite_cuerpo.texture = coleccion_cuerpo[indice_cuerpo]
	if coleccion_nariz.size() > 0: sprite_nariz.texture = coleccion_nariz[indice_nariz]
	if coleccion_cabeza.size() > 0: sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]

func cargar_valores_iniciales():
	# --- A. RECUPERAR ÍNDICES (Texturas) ---
	# Copiamos lo que haya en Global a nuestras variables locales
	indice_cabello = Global.apariencia.indice_cabello
	indice_ojos = Global.apariencia.indice_ojos
	indice_boca = Global.apariencia.indice_boca
	indice_cuerpo = Global.apariencia.indice_cuerpo
	indice_nariz = Global.apariencia.indice_nariz
	indice_cabeza = Global.apariencia.indice_cabeza

	# --- B. RECUPERAR COLORES (Tintes) ---
	# Aplicamos directamente el color a los sprites
	sprite_cabello.self_modulate = Global.apariencia.color_cabello
	sprite_ojos.self_modulate = Global.apariencia.color_ojos
	sprite_boca.self_modulate = Global.apariencia.color_boca
	
	# Grupo de la Piel (Cabeza, cuerpo, nariz)
	sprite_cabeza.self_modulate = Global.apariencia.color_cabeza
	sprite_cuerpo.self_modulate = Global.apariencia.color_cuerpo # O color_cabeza si quieres que coincidan
	sprite_nariz.self_modulate = Global.apariencia.color_nariz   # O color_cabeza
# --- 4. FUNCIONES LÓGICAS (Cambio de textura) ---

# CABELLO
func cabello_siguiente():
	if coleccion_cabellos.size() == 0: return
	indice_cabello = (indice_cabello + 1) % coleccion_cabellos.size()
	sprite_cabello.texture = coleccion_cabellos[indice_cabello]

func cabello_anterior():
	if coleccion_cabellos.size() == 0: return
	indice_cabello -= 1
	if indice_cabello < 0: indice_cabello = coleccion_cabellos.size() - 1
	sprite_cabello.texture = coleccion_cabellos[indice_cabello]

# CABEZA (PIEL)
func cabeza_siguiente():
	if coleccion_cabeza.size() == 0: return
	indice_cabeza = (indice_cabeza + 1) % coleccion_cabeza.size()
	sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]

func cabeza_anterior():
	if coleccion_cabeza.size() == 0: return
	indice_cabeza -= 1
	if indice_cabeza < 0: indice_cabeza = coleccion_cabeza.size() - 1
	sprite_cabeza.texture = coleccion_cabeza[indice_cabeza]

# OJOS
func ojos_siguiente():
	if coleccion_ojos.size() == 0: return
	indice_ojos = (indice_ojos + 1) % coleccion_ojos.size()
	sprite_ojos.texture = coleccion_ojos[indice_ojos]

func ojos_anterior():
	if coleccion_ojos.size() == 0: return
	indice_ojos -= 1
	if indice_ojos < 0: indice_ojos = coleccion_ojos.size() - 1
	sprite_ojos.texture = coleccion_ojos[indice_ojos]

# NARIZ
func nariz_siguiente():
	if coleccion_nariz.size() == 0: return
	indice_nariz = (indice_nariz + 1) % coleccion_nariz.size()
	sprite_nariz.texture = coleccion_nariz[indice_nariz]

func nariz_anterior():
	if coleccion_nariz.size() == 0: return
	indice_nariz -= 1
	if indice_nariz < 0: indice_nariz = coleccion_nariz.size() - 1
	sprite_nariz.texture = coleccion_nariz[indice_nariz]

# BOCA
func boca_siguiente():
	if coleccion_boca.size() == 0: return
	indice_boca = (indice_boca + 1) % coleccion_boca.size()
	sprite_boca.texture = coleccion_boca[indice_boca]

func boca_anterior():
	if coleccion_boca.size() == 0: return
	indice_boca -= 1
	if indice_boca < 0: indice_boca = coleccion_boca.size() - 1
	sprite_boca.texture = coleccion_boca[indice_boca]

# CUERPO (ROPA)
func cuerpo_siguiente():
	if coleccion_cuerpo.size() == 0: return
	indice_cuerpo = (indice_cuerpo + 1) % coleccion_cuerpo.size()
	sprite_cuerpo.texture = coleccion_cuerpo[indice_cuerpo]

func cuerpo_anterior():
	if coleccion_cuerpo.size() == 0: return
	indice_cuerpo -= 1
	if indice_cuerpo < 0: indice_cuerpo = coleccion_cuerpo.size() - 1
	sprite_cuerpo.texture = coleccion_cuerpo[indice_cuerpo]


# --- 5. CONEXIONES DE BOTONES (SEÑALES) ---
# Tienes que reconectar el "pressed()" de tus botones a estas funciones

func _on_btn_cabello_siguiente_pressed() -> void: cabello_siguiente()
func _on_btn_cabello_atras_pressed() -> void: cabello_anterior()

func _on_btn_cabeza_siguiente_pressed() -> void: cabeza_siguiente()
func _on_btn_cabeza_atras_pressed() -> void: cabeza_anterior()

func _on_btn_ojos_siguiente_pressed() -> void: ojos_siguiente()
func _on_btn_ojos_atras_pressed() -> void: ojos_anterior()

func _on_btn_nariz_siguiente_pressed() -> void: nariz_siguiente()
func _on_btn_nariz_atras_pressed() -> void: nariz_anterior()

func _on_btn_boca_siguiente_pressed() -> void: boca_siguiente()
func _on_btn_boca_atras_pressed() -> void: boca_anterior()

func _on_btn_cuerpo_siguiente_pressed() -> void: cuerpo_siguiente()
func _on_btn_cuerpo_atras_pressed() -> void: cuerpo_anterior()


# --- 6. CONEXIONES DE COLOR (COLOR PICKERS) ---

func _on_color_picker_button_color_changed(color_elegido):
	# Color Cabello
	sprite_cabello.self_modulate = color_elegido

func _on_color_picker_button_cabeza_color_changed(color_elegido):
	# Color Piel 
	sprite_cabeza.self_modulate = color_elegido


func _on_color_picker_button_ojos_color_changed(color_elegido):
	# Color Ojos
	sprite_ojos.self_modulate = color_elegido

func _on_color_picker_button_boca_color_changed(color_elegido):
	sprite_boca.self_modulate = color_elegido
	
func _on_color_picker_button_cuerpo_color_changed(color_elegido):
	sprite_cuerpo.self_modulate = color_elegido



# --- 7. BOTÓN FINAL: GUARDAR Y JUGAR ---

func _on_comenzar_pressed() -> void:
	# A. Guardar índices (Qué ropa lleva)
	Global.apariencia.indice_cabello = indice_cabello
	Global.apariencia.indice_ojos = indice_ojos
	Global.apariencia.indice_boca = indice_boca
	Global.apariencia.indice_cuerpo = indice_cuerpo
	Global.apariencia.indice_nariz = indice_nariz
	Global.apariencia.indice_cabeza = indice_cabeza
	
	# B. Guardar colores (Qué tinte lleva)
	Global.apariencia.color_cabello = sprite_cabello.self_modulate
	Global.apariencia.color_cabeza = sprite_cabeza.self_modulate
	Global.apariencia.color_ojos = sprite_ojos.self_modulate
	
	# Colores derivados (por si acaso)
	Global.apariencia.color_cuerpo = sprite_cuerpo.self_modulate
	Global.apariencia.color_nariz = sprite_nariz.self_modulate
	Global.apariencia.color_boca = sprite_boca.self_modulate

	# C. Cambiar de escena
	get_tree().change_scene_to_file("res://escenas/escena_1/escena_1.tscn")
