extends Node2D

const DIALOGO_ESCENA_2 := preload("res://dialogos/escena_9.dialogue") #escena_2.dialogue"
const ESCENA_TUTORIAL_MINIJUEGO_1 := "res://scenes/intro_dialogo_7/intro_dialogo_7.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:	
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_2)

func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(ESCENA_TUTORIAL_MINIJUEGO_1)
