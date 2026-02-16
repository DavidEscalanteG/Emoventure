extends Control

@export var corazon_lleno: Texture2D
@export var corazon_vacio: Texture2D

@onready var corazones: Array[TextureRect] = [
	$HBoxContainer/Vida1,
	$HBoxContainer/Vida2,
	$HBoxContainer/Vida3
]

func _ready() -> void:
	DatosJugador.lives_ui = self
	actualizar_vidas(3)

func actualizar_vidas(vidas_actuales: int) -> void:
	for i in range(corazones.size()):
		if i < vidas_actuales:
			corazones[i].texture = corazon_lleno
		else:
			corazones[i].texture = corazon_vacio
