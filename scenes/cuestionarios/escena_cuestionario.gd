extends Control
class_name EscenaCuestionario

# ==================================================
# REFERENCIAS
# ==================================================
@onready var label_pregunta: RichTextLabel = %PreguntaRichTextLabel
@onready var titulo_label: Label = %TituloLabel

@export var escena_siguiente: PackedScene

# ==================================================
# DATOS DEL CUESTIONARIO (INYECCIÓN)
# ==================================================
var preguntas: Array[String] = []
var dimension: String = ""
var narrativa_post_cuestionario: String = ""
var titulo_narrativa_post: String = "Rescate completado"


# ==================================================
# ESTADO
# ==================================================
var indice: int = 0
var puntaje_local: int = 0
var finalizando: bool = false

const FUENTE_PREGUNTA_MAXIMA := 58
const FUENTE_PREGUNTA_MINIMA := 32 # Reducido ligeramente para permitir mayor margen en textos muy largos
const PASO_AJUSTE_FUENTE := 2
const MARGEN_VERTICAL_PREGUNTA := 12.0

@onready var panel_narrativa_post: PanelContainer = %PanelNarrativaPost
@onready var label_titulo_narrativa_post: Label = %TituloNarrativaPost
@onready var label_texto_narrativa_post: Label = %TextoNarrativaPost
@onready var boton_narrativa_post: Button = %BotonContinuarNarrativa
@onready var botones_opciones: Array[Button] = [
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/OpcionesVBoxContainer/HBoxContainer/ColumnaIzquierda/Boton_1,
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/OpcionesVBoxContainer/HBoxContainer/ColumnaDerecha/Boton_2,
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/OpcionesVBoxContainer/HBoxContainer/ColumnaIzquierda/Boton_3,
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/OpcionesVBoxContainer/HBoxContainer/ColumnaDerecha/Boton_4,
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Boton_5,
]


# ==================================================
# CICLO DE VIDA
# ==================================================
func _ready() -> void:
	# El tema ya distingue hover y pulsación. Mantener la escala fija evita que
	# las opciones invadan otras filas o salgan del pergamino al recibir foco.
	if not boton_narrativa_post.pressed.is_connected(_on_boton_narrativa_post_pressed):
		boton_narrativa_post.pressed.connect(_on_boton_narrativa_post_pressed)
		
	_restaurar_estado_desde_guardado_si_aplica()

	if not Cuestionarios.validar_dimension_y_preguntas(dimension, preguntas):
		return

	if indice >= preguntas.size():
		_finalizar()
		return
	
	mostrar_pregunta()


# ==================================================
# LÓGICA
# ==================================================

func _restaurar_estado_desde_guardado_si_aplica() -> void:
	var estado: Dictionary = SaveManager.consumir_estado_cuestionario_pendiente()
	if estado.is_empty():
		return

	var dimension_guardada: String = str(estado.get("dimension", ""))
	if not dimension_guardada.is_empty():
		dimension = dimension_guardada

	var preguntas_guardadas_variant: Variant = estado.get("preguntas", [])
	if typeof(preguntas_guardadas_variant) == TYPE_ARRAY:
		preguntas.clear()
		for pregunta in preguntas_guardadas_variant:
			preguntas.append(str(pregunta))

	var indice_guardado: int = maxi(0, int(estado.get("indice", indice)))
	if not preguntas.is_empty():
		indice = mini(indice_guardado, preguntas.size())
	else:
		indice = 0

	puntaje_local = maxi(0, int(estado.get("puntaje_local", puntaje_local)))
	narrativa_post_cuestionario = str(estado.get("narrativa_post_cuestionario", narrativa_post_cuestionario))
	titulo_narrativa_post = str(estado.get("titulo_narrativa_post", titulo_narrativa_post))

	var escena_siguiente_path: String = str(estado.get("escena_siguiente_path", ""))
	if not escena_siguiente_path.is_empty() and ResourceLoader.exists(escena_siguiente_path):
		escena_siguiente = load(escena_siguiente_path) as PackedScene


func mostrar_pregunta() -> void:
	var pregunta_actual := preguntas[indice]
	label_pregunta.text = pregunta_actual
	
	# Usamos call_deferred para asegurarnos de que Godot calcule el tamaño del contenedor tras pintar el texto
	call_deferred("_ajustar_tamano_pregunta", pregunta_actual)


func _ajustar_tamano_pregunta(_pregunta: String) -> void:
	var alto_disponible: float = maxf(1.0, label_pregunta.size.y - MARGEN_VERTICAL_PREGUNTA)
	var tamano := FUENTE_PREGUNTA_MAXIMA

	while tamano >= FUENTE_PREGUNTA_MINIMA:
		label_pregunta.add_theme_font_size_override("normal_font_size", tamano)
		if label_pregunta.get_content_height() <= alto_disponible:
			break
		tamano -= PASO_AJUSTE_FUENTE

	label_pregunta.add_theme_font_size_override("normal_font_size", maxi(tamano, FUENTE_PREGUNTA_MINIMA))


func responder(valor: int) -> void:
	if finalizando:
		return
		
	puntaje_local += valor
	indice += 1
	SaveManager.actualizar_guardado_actual()

	if indice < preguntas.size():
		mostrar_pregunta()
	else:
		_finalizar()


func _finalizar() -> void:
	if finalizando:
		return

	finalizando = true
	_set_botones_opciones_habilitados(false)
	
	if not Cuestionarios.es_dimension_soportada(dimension):
		push_error("[EscenaCuestionario] Dimensión inválida al finalizar: %s" % dimension)
		finalizando = false
		_set_botones_opciones_habilitados(true)
		return
		
	Logs.log_debug("[DEBUG] Cuestionario terminado: %s %d" % [dimension, puntaje_local])
	GameManager.agregar_puntaje(dimension, puntaje_local)

	if not narrativa_post_cuestionario.strip_edges().is_empty():
		await _mostrar_narrativa_post()
		
	if escena_siguiente and is_inside_tree():
		var tree := get_tree()
		if tree:
			tree.change_scene_to_packed(escena_siguiente)


func _mostrar_narrativa_post() -> void:
	label_titulo_narrativa_post.text = titulo_narrativa_post
	label_texto_narrativa_post.text = narrativa_post_cuestionario
	panel_narrativa_post.visible = true
	boton_narrativa_post.grab_focus()
	await boton_narrativa_post.pressed
	panel_narrativa_post.visible = false


func _set_botones_opciones_habilitados(habilitados: bool) -> void:
	for boton in botones_opciones:
		if is_instance_valid(boton):
			boton.disabled = not habilitados
			
			
# ==================================================
# BOTONES
# ==================================================
func _on_boton_1_pressed() -> void:
	AudioManager.play_ui_click()
	responder(1)

func _on_boton_2_pressed() -> void:
	AudioManager.play_ui_click()
	responder(2)

func _on_boton_3_pressed() -> void:
	AudioManager.play_ui_click()
	responder(3)

func _on_boton_4_pressed() -> void:
	AudioManager.play_ui_click()
	responder(4)

func _on_boton_5_pressed() -> void:
	AudioManager.play_ui_click()
	responder(5)


func _on_boton_narrativa_post_pressed() -> void:
	AudioManager.play_ui_click()
