extends Node2D

const DIALOGO_ESCENA_2 := preload("res://dialogos/escena__2.dialogue")
const SIGUIENTE_ESCENA := "res://escenas/escena_3/escena_3.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.register_actor("gitana", $personajes/gitana)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.start_dialogue(DIALOGO_ESCENA_2)

func _on_dialogue_finished():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
