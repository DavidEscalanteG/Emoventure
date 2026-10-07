extends Node2D

const DIALOGO_ESCENA_7 := preload("res://dialogos/escena_14.dialogue")
const SIGUIENTE_ESCENA := "res://scenes/final/resultado_final.tscn"

@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_7)
	
func _on_dialogo_finalizado() -> void:
	# Al terminar el diálogo, cambiamos de escena inmediatamente
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
