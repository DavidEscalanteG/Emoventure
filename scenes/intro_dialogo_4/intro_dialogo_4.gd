extends Node2D

const DIALOGO_ESCENA_6 := preload("res://dialogos/escena_4.dialogue")
const SIGUIENTE_ESCENA := "uid://c7ncdodlaop87" #intro_dialogo_5.tscn

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	
	#DialogueActors.registro_registrar_actor("mujer_lagarto", $Personajes/MujerLagarto)
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_6)
	
func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
