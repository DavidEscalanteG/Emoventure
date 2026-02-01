extends Node2D

const DIALOGO_ESCENA_1 := preload("uid://bnmyfdhejqf64") #escena_1.dialogue 
const SIGUIENTE_ESCENA := "uid://ojuxji1qnqno" #escena_2.tscn

#@onready var personajes := $personajes
@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.register_actor("gitana", $personajes/gitana)
	DialogueActors.register_actor("jugador", $personajes/JugadorCinematico)

	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.start_dialogue(DIALOGO_ESCENA_1)

func _on_dialogue_finished():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
