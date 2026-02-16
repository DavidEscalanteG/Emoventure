extends Node2D
var DialogueActors: Object = Engine.get_singleton("DialogueActors") if Engine.has_singleton("DialogueActors") else null
var MusicManager: Object = Engine.get_singleton("MusicManager") if Engine.has_singleton("MusicManager") else null


const DIALOGO_ESCENA_1 = preload("res://dialogos/escena_1.dialogue")
const SIGUIENTE_ESCENA: String = "res://scenes/intro_dialogo_2/intro_dialogo_2.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_MISTERIO)
	
	DialogueActors.registro_registrar_actor("gitana", $personajes/gitana)
	DialogueActors.registro_registrar_actor("jugador", $personajes/JugadorCinematico)

	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)

	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_1)


func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
