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



# ==================================================
# ESTADO
# ==================================================
var indice: int = 0
var puntaje_local: int = 0


# ==================================================
# CICLO DE VIDA
# ==================================================
func _ready() -> void:
	if preguntas.is_empty():
		push_warning("Cuestionario iniciado sin preguntas")
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
	print("[DEBUG] Cuestionario terminado:", dimension, puntaje_local)

	GameManager.agregar_puntaje(dimension, puntaje_local)

	if escena_siguiente:
		get_tree().change_scene_to_packed(escena_siguiente)


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
