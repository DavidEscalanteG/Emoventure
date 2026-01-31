extends CharacterBody2D

@onready var apariencia: Node = $PlayerAppearance

func _ready() -> void:

	# Apariencia inicial
	apariencia.aplicar_apariencia_desde_global()
	apariencia.set_direction("down")
	apariencia.set_estado_movimiento("idle")
