extends Node2D

const DIALOGO_ESCENA_8 := preload("uid://bxdfug21llqcy") #escena_8.dialogue")
const SIGUIENTE_ESCENA := "uid://dr4vbuueuu56w" #escena_9.tcsn

@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_MISTERIO)
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	DialogueActors.registro_registrar_actor("payaso", $Personajes/Payaso)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	DialogueActors.animacion_establecer_animacion("mascota", "idle", "right")
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_8)


func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
