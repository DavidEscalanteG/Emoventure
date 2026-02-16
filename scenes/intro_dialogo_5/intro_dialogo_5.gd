extends Node2D
var DialogueActors: Object = Engine.get_singleton("DialogueActors") if Engine.has_singleton("DialogueActors") else null
var MusicManager: Object = Engine.get_singleton("MusicManager") if Engine.has_singleton("MusicManager") else null


const DIALOGO_ESCENA_7 = preload("res://dialogos/escena_7.dialogue")
const SIGUIENTE_ESCENA: String = "res://scenes/intro_mision_2/intro_mision_2.tscn"

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
