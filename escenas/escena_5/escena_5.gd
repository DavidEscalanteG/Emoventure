extends Node2D

const DIALOGO_ESCENA_5 := preload("res://dialogos/escena_5.dialogue")
const SIGUIENTE_ESCENA := "res://escenas/escena_6/escena_6.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.register_actor("mujer_lagarto", $Personajes/MujerLagarto)
	DialogueActors.register_actor("jugador", $Personajes/Jugador)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.start_dialogue(DIALOGO_ESCENA_5)
	
func _on_dialogue_finished():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
