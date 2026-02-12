extends Node2D

const DIALOGO_ESCENA_8 := preload("uid://bxdfug21llqcy") #escena_8.dialogue")
const SIGUIENTE_ESCENA := "uid://dr4vbuueuu56w" #escena_9.tcsn

@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.register_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.register_actor("mascota", $Personajes/Mascota)
	DialogueActors.register_actor("payaso", $Personajes/Payaso)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

	DialogueActors.set_anim("mascota", "idle", "right")
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.start_dialogue(DIALOGO_ESCENA_8)


func _on_dialogue_finished():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
