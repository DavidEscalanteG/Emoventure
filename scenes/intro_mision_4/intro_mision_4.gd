extends Control

const DIALOGO_ESCENA_13 := preload("uid://b3x24e1bd0suu") #escena_13.dialogue"
const SIGUIENTE_ESCENA := "uid://bpufyh81mgv3u" #mapa_topos.tscn"

#@onready var personajes := $personajes
@onready var dialogue_ui: Node = $DialogueUI/Balloon

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_CALMA)
	
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_13)
	
func _on_dialogo_finalizado() -> void:
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _exit_tree() -> void:
	MusicManager.finalizar_override_dialogo()
