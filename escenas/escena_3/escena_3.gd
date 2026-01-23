extends Node2D

const DIALOGO_ESCENA_3 := preload("res://dialogos/escena_3.dialogue")
#const SIGUIENTE_ESCENA := "res://escenas/escena_3/escena_3.tscn"

#@onready var personajes := $personajes
@onready var level_complete_ui := $NivelCompletadoUI/Control

func _ready() -> void:
	print("Enemigos encontrados:", get_tree().get_nodes_in_group("enemigos").size())

	print(level_complete_ui)
	Global.emociones_recolectadas.clear()
	Global.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)

	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(DIALOGO_ESCENA_3)

func _on_todas_las_emociones_recolectadas():
	
	Global.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	print("Nivel completado")
	
	Global.jugador.nivel_terminado = true
	Global.jugador._terminar_emocion()
	Global.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	level_complete_ui.mostrar(
		Global.emociones_recolectadas,
		Global.jugador.vidas_actuales
	)
