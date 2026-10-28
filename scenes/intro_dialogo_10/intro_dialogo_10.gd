extends Node2D

const DIALOGO_ESCENA_7 := preload("res://dialogos/escena_13.dialogue")
const SIGUIENTE_ESCENA := "res://scenes/intro_dialogo_12/intro_dialogo_12.tscn"

@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	DialogueActors.registro_registrar_actor("fran", $Personajes/Fran)
	DialogueActors.registro_registrar_actor("jaula", $Personajes/Jaula)
	DialogueActors.registro_registrar_actor("domador", $Personajes/Ringmaster)


	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_7)
	
func _on_dialogo_finalizado() -> void:
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
