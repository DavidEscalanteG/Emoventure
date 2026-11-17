extends Control

@export var siguiente_escena: String
@export var siguiente_escena_legacy: String = ""

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var boton: Button = $Contenido/BotonContinuar

func _ready() -> void:
	# La recompensa y la salida existen desde el primer cuadro. La animación
	# sólo decora la llave; nunca debe ser necesaria para poder continuar.
	$Contenido.scale = Vector2.ONE
	boton.show()
	anim.play("mostrar_llave")

func _on_boton_continuar_pressed() -> void:
	AudioManager.play_ui_click()
	var destino := siguiente_escena if not siguiente_escena.is_empty() else siguiente_escena_legacy
	if destino.is_empty():
		push_warning("No se configuró destino para la transición post misión 1")
		return
	get_tree().change_scene_to_file.call_deferred(destino)
