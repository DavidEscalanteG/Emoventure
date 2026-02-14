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

@onready var panel_narrativa_post: PanelContainer = %PanelNarrativaPost
@onready var label_titulo_narrativa_post: Label = %TituloNarrativaPost
@onready var label_texto_narrativa_post: Label = %TextoNarrativaPost
@onready var boton_narrativa_post: Button = %BotonContinuarNarrativa


# ==================================================
# CICLO DE VIDA
# ==================================================
func _ready() -> void:
	if not Cuestionarios.validar_dimension_y_preguntas(dimension, preguntas):
		return

	mostrar_pregunta()


# ==================================================
# LÓGICA
# ==================================================
func mostrar_pregunta() -> void:
	label_pregunta.text = preguntas[indice]


func responder(valor: int) -> void:
	puntaje_local += valor
	indice += 1

	if indice < preguntas.size():
		mostrar_pregunta()
	else:
		_finalizar()


func _finalizar() -> void:
	if not Cuestionarios.es_dimension_soportada(dimension):
		push_error("[EscenaCuestionario] Dimensión inválida al finalizar: %s" % dimension)
		return
		
	Logs.log_debug("[DEBUG] Cuestionario terminado: %s %d" % [dimension, puntaje_local])
	GameManager.agregar_puntaje(dimension, puntaje_local)

	if not narrativa_post_cuestionario.strip_edges().is_empty():
		await _mostrar_narrativa_post()
		
	if escena_siguiente:
		get_tree().change_scene_to_packed(escena_siguiente)

func _mostrar_narrativa_post() -> void:
	label_titulo_narrativa_post.text = titulo_narrativa_post
	label_texto_narrativa_post.text = narrativa_post_cuestionario
	panel_narrativa_post.visible = true
	boton_narrativa_post.grab_focus()
	await boton_narrativa_post.pressed
	panel_narrativa_post.visible = false


# ==================================================
# BOTONES
# ==================================================
func _on_boton_1_pressed() -> void:
	responder(1)

func _on_boton_2_pressed() -> void:
	responder(2)

func _on_boton_3_pressed() -> void:
	responder(3)

func _on_boton_4_pressed() -> void:
	responder(4)

func _on_boton_5_pressed() -> void:
	responder(5)
