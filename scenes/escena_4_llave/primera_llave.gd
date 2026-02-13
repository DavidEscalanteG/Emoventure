extends Control

@export var siguiente_escena: String

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var boton: Button = $Contenido/BotonContinuar

func _ready() -> void:
	boton.visible = false
	anim.play("mostrar_llave")

func _on_boton_continuar_pressed() -> void:
	get_tree().change_scene_to_file(siguiente_escena)
