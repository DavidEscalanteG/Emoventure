extends Control

@onready var label_pregunta := %PreguntaRichTextLabel

var preguntas := [
	"Presto mucha atención a los sentimientos.",
	"Normalmente me preocupo mucho por lo que siento.",
	"Normalmente dedico tiempo a pensar en mis emociones.",
	"Pienso que merece la pena prestar atención a mis emociones.",
	"Dejo que mis sentimientos afecten a mis pensamientos.",
	"Pienso en mi estado de ánimo constantemente.",
	"A menudo pienso en mis sentimientos.",
	"Presto mucha atención a cómo me siento."
]

var dimension := "atencion"

var indice := 0
var puntaje_local := 0

func _ready() -> void:
	mostrar_pregunta()

func mostrar_pregunta() -> void:
	label_pregunta.text = preguntas[indice]

func responder(valor: int) -> void:
	puntaje_local += valor
	indice += 1
	
	if indice < preguntas.size():
		mostrar_pregunta()
	else:
		GameManager.agregar_puntaje(dimension, puntaje_local)
		print("Se termino el cuestionario")
		terminar_cuestionario()

func terminar_cuestionario() -> void:
	get_tree().change_scene_to_file("res://escenas/escena_4_llave/PrimeraLlave.tscn")


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
