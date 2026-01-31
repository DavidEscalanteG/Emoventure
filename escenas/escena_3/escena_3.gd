extends Node2D

#@onready var personajes := $personajes
@onready var level_complete_ui := $NivelCompletadoUI/Control

func _ready():

	Global.jugador.permitir_movimiento()

	print("Enemigos encontrados:", get_tree().get_nodes_in_group("enemigos").size())
	print(level_complete_ui)
	Global.emociones_recolectadas.clear()
	Global.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)

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
