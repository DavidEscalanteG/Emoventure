extends Control

@export var siguiente_escena: String

@onready var anim := $AnimationPlayer
@onready var boton := $Contenido/BotonContinuar

func _ready():
	boton.visible = false
	anim.play("mostrar_llave")

func _on_boton_continuar_pressed() -> void:
	get_tree().change_scene_to_file(siguiente_escena)
