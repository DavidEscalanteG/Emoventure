extends Node2D

const DIALOGO_ESCENA_2 := preload("res://dialogos/escena_10.dialogue") #escena_2.dialogue"
const ESCENA_TUTORIAL_MINIJUEGO_3 := "res://scenes/mision_3_nuevo/tutorial/Minijuego3_Tutorial.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("parca", $personajes/Parca)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_2)

func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(ESCENA_TUTORIAL_MINIJUEGO_3)
