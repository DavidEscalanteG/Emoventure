extends Node2D
var DialogueActors: Object = Engine.get_singleton("DialogueActors") if Engine.has_singleton("DialogueActors") else null
var MusicManager: Object = Engine.get_singleton("MusicManager") if Engine.has_singleton("MusicManager") else null


const DIALOGO_ESCENA_6_PATH: String = "res://dialogos/escena_6.dialogue"
const SIGUIENTE_ESCENA: String = "res://scenes/intro_dialogo_5/intro_dialogo_5.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_TENSION)
	
	#DialogueActors.registro_registrar_actor("mujer_lagarto", $Personajes/MujerLagarto)
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	var dialogo_resource: Resource = load(DIALOGO_ESCENA_6_PATH)
	if dialogo_resource == null:
		push_error("No se pudo cargar el diálogo: %s" % DIALOGO_ESCENA_6_PATH)
		return
	dialogue_ui.iniciar_dialogo(dialogo_resource)
	
func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
