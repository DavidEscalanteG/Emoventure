extends Node2D

const DIALOGO_ESCENA_5 := preload("res://dialogos/escena_5.dialogue")

func _ready() -> void:
	DialogueActors.register_actor("mujer_lagarto", $Personajes/MujerLagarto)
	#DialogueActors.register_actor("carlos", $Personajes/Carlos)
	
	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(DIALOGO_ESCENA_5)
