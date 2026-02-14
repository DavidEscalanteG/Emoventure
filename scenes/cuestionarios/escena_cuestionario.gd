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

var panel_narrativa_post: PanelContainer
var label_titulo_narrativa_post: Label
var label_texto_narrativa_post: Label
var boton_narrativa_post: Button


# ==================================================
# CICLO DE VIDA
# ==================================================
func _ready() -> void:
	if not Cuestionarios.validar_dimension_y_preguntas(dimension, preguntas):
		return

	_crear_panel_narrativa_post()
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

func _crear_panel_narrativa_post() -> void:
	panel_narrativa_post = PanelContainer.new()
	panel_narrativa_post.visible = false
	panel_narrativa_post.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_narrativa_post.custom_minimum_size = Vector2(980, 320)
	panel_narrativa_post.position = Vector2(470, 380)

	var margen: MarginContainer = MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 28)
	margen.add_theme_constant_override("margin_top", 28)
	margen.add_theme_constant_override("margin_right", 28)
	margen.add_theme_constant_override("margin_bottom", 28)
	panel_narrativa_post.add_child(margen)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margen.add_child(vbox)

	label_titulo_narrativa_post = Label.new()
	label_titulo_narrativa_post.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_titulo_narrativa_post.add_theme_font_size_override("font_size", 38)
	vbox.add_child(label_titulo_narrativa_post)

	label_texto_narrativa_post = Label.new()
	label_texto_narrativa_post.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_texto_narrativa_post.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_texto_narrativa_post.custom_minimum_size = Vector2(0, 140)
	label_texto_narrativa_post.add_theme_font_size_override("font_size", 24)
	vbox.add_child(label_texto_narrativa_post)

	boton_narrativa_post = Button.new()
	boton_narrativa_post.text = "Continuar"
	boton_narrativa_post.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(boton_narrativa_post)

	$CanvasLayer.add_child(panel_narrativa_post)

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
