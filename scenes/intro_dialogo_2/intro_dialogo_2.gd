extends Node2D

const DIALOGO_ESCENA_2 := preload("uid://43a3ofv6np6u") #escena_2.dialogue"
const SIGUIENTE_ESCENA := "uid://dhr0rstqdkcin" #mision_1_recoleccion.tscn

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_TENSION)
	
	DialogueActors.registro_registrar_actor("gitana", $personajes/gitana)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_2)

func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
