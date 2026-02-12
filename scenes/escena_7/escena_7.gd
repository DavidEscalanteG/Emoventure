extends Node2D

const DIALOGO_ESCENA_7 := preload("uid://b5t1y0j0xbtoe") #escena_7.dialogue")
const SIGUIENTE_ESCENA := "uid://607ynm435j8g" #escena_8.tcsn

@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.register_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.register_actor("mascota", $Personajes/Mascota)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.start_dialogue(DIALOGO_ESCENA_7)
	

func _on_dialogue_finished():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
