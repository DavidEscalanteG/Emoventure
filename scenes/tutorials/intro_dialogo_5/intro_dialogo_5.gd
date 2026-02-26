extends Node2D

const DIALOGO_ESCENA_7 := preload("uid://b5t1y0j0xbtoe") #escena_7.dialogue")
const SIGUIENTE_ESCENA := "uid://607ynm435j8g" #escena_8.tcsn

@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_TIERNURA)
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_7)
	

func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
