extends Node2D

const DIALOGO_ESCENA_5 := preload("uid://caiwc0mkeiv5k") #escena_5.dialogue"
const SIGUIENTE_ESCENA := "uid://b0tuj3njkfr0j" #intro_dialogo_4.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.reproducir_dialogo_por_ambiente(MusicManager.AMBIENTE_TENSION)
	
	DialogueActors.registro_registrar_actor("mujer_lagarto", $Personajes/MujerLagarto)
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_5)
	
func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)