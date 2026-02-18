extends Control

@export var siguiente_escena: String
@export var siguiente_escena_legacy: String = ""

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var boton: Button = $Contenido/BotonContinuar

func _ready() -> void:
	boton.visible = false
	anim.play("mostrar_llave")

func _on_boton_continuar_pressed() -> void:
	AudioManager.play_ui_click()
	var destino := siguiente_escena if not siguiente_escena.is_empty() else siguiente_escena_legacy
	if destino.is_empty():
		push_warning("No se configuró destino para la transición post misión 2")
		return
	get_tree().change_scene_to_file(destino)
