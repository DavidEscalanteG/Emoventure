extends Node2D

const DIALOGO_ESCENA_8 := preload("uid://bxdfug21llqcy") #escena_8.dialogue")
const SIGUIENTE_ESCENA := "uid://dr4vbuueuu56w" #escena_9.tcsn

@onready var dialogue_ui := $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	DialogueActors.registro_registrar_actor("payaso", $Personajes/Payaso)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	DialogueActors.animacion_set_animacion("mascota", "idle", "right")
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_8)


func _on_dialogo_finalizado():
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
