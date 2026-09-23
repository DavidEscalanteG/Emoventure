extends Node2D

# 1. Solo cambias estas dos líneas en cada escena nueva:
const ARCHIVO_DIALOGO := preload("res://dialogos/escena_2.dialogue") 
const ESCENA_SIGUIENTE := "res://scenes/mision_1_recoleccion/tutorial/Minijuego1_Tutorial.tscn"

@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_TENSION)
	
	# Asegúrate de que el nombre del actor coincida con tu nueva escena
	DialogueActors.registro_registrar_actor("gitana", $personajes/gitana) 
	
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	dialogue_ui.iniciar_dialogo(ARCHIVO_DIALOGO) # Ya no tienes que cambiar el nombre aquí

func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(ESCENA_SIGUIENTE) # Ni cambiar el nombre aquí

func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
