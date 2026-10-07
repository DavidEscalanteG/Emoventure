extends Node2D

const DIALOGO_ESCENA_5 := preload("res://dialogos/escena_12.dialogue") 
const SIGUIENTE_ESCENA := "res://scenes/mision_4_payasos/tutorial/Minijuego4_Tutorial.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("fran", $personajes/Fran)
	DialogueActors.registro_registrar_actor("jugador", $personajes/JugadorCinematico)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_5)
	
func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
