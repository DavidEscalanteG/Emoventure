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

const FUENTE_PREGUNTA_BASE: int = 79
const FUENTE_PREGUNTA_MEDIA: int = 68
const FUENTE_PREGUNTA_LARGA: int = 58

@onready var panel_narrativa_post: PanelContainer = %PanelNarrativaPost
@onready var label_titulo_narrativa_post: Label = %TituloNarrativaPost
@onready var label_texto_narrativa_post: Label = %TextoNarrativaPost
@onready var boton_narrativa_post: Button = %BotonContinuarNarrativa


func _get_cuestionarios() -> Object:
	if Engine.has_singleton("Cuestionarios"):
		return Engine.get_singleton("Cuestionarios")
	return null


func _get_game_manager() -> Object:
	if Engine.has_singleton("GameManager"):
		return Engine.get_singleton("GameManager")
	return null


func _get_logs() -> Object:
	if Engine.has_singleton("Logs"):
		return Engine.get_singleton("Logs")
	return null


# ==================================================
# CICLO DE VIDA
# ==================================================
func _ready() -> void:
	var cuestionarios: Object = _get_cuestionarios()
	if cuestionarios == null:
		push_error("Cuestionarios no está disponible.")
		return

	if not bool(cuestionarios.call("validar_dimension_y_preguntas", dimension, preguntas)):
		return

	mostrar_pregunta()


# ==================================================
# LÓGICA
# ==================================================
func mostrar_pregunta() -> void:
	var pregunta_actual: String = preguntas[indice]
	label_pregunta.add_theme_font_size_override("normal_font_size", _obtener_tamano_fuente_para_pregunta(pregunta_actual))
	label_pregunta.text = pregunta_actual


func _obtener_tamano_fuente_para_pregunta(pregunta: String) -> int:
	var longitud: int = pregunta.length()

	if longitud >= 120:
		return FUENTE_PREGUNTA_LARGA
	if longitud >= 90:
		return FUENTE_PREGUNTA_MEDIA

	return FUENTE_PREGUNTA_BASE


func responder(valor: int) -> void:
	puntaje_local += valor
	indice += 1

	if indice < preguntas.size():
		mostrar_pregunta()
	else:
		_finalizar()


func _finalizar() -> void:
	var cuestionarios: Object = _get_cuestionarios()
	if cuestionarios == null:
		push_error("Cuestionarios no está disponible al finalizar.")
		return

	if not bool(cuestionarios.call("es_dimension_soportada", dimension)):
		push_error("[EscenaCuestionario] Dimensión inválida al finalizar: %s" % dimension)
		return

	var logs: Object = _get_logs()
	if logs != null:
		logs.call("log_debug", "[DEBUG] Cuestionario terminado: %s %d" % [dimension, puntaje_local])

	var game_manager: Object = _get_game_manager()
	if game_manager == null:
		push_error("GameManager no está disponible al finalizar cuestionario.")
		return
	game_manager.call("agregar_puntaje", dimension, puntaje_local)

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
