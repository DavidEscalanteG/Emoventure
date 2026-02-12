extends Node2D

const DIALOGO_ESCENA_2 := preload("uid://43a3ofv6np6u") #escena_2.dialogue"
const SIGUIENTE_ESCENA := "uid://dhr0rstqdkcin" #escena_3.tscn

#@onready var personajes := $personajes
@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registrar_actor("gitana", $personajes/gitana)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_2)

func _on_dialogo_finalizado():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
