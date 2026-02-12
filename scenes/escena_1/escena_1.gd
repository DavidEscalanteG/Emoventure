extends Node2D

const DIALOGO_ESCENA_1 := preload("uid://bnmyfdhejqf64") #escena_1.dialogue 
const SIGUIENTE_ESCENA := "uid://ojuxji1qnqno" #escena_2.tscn

#@onready var personajes := $personajes
@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("gitana", $personajes/gitana)
	DialogueActors.registro_registrar_actor("jugador", $personajes/JugadorCinematico)

	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_1)

func _on_dialogo_finalizado():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
