extends Node2D

@onready var level_complete_ui := $NivelCompletadoUI/Control
@onready var game_over_ui := $GameOverUI/Control

func _ready():

	Global.jugador.permitir_movimiento()

	Logs.log_debug("Enemigos encontrados: %d" % get_tree().get_nodes_in_group("enemigos").size())
	Logs.log_debug("Level complete UI listo")
	Global.emociones_recolectadas.clear()
	Global.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)
	
	Global.jugador.sin_vidas.connect(_on_jugador_sin_vidas)

func _on_todas_las_emociones_recolectadas():
	
	Global.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	Logs.log_debug("Nivel completado")
	
	Global.jugador.nivel_terminado = true
	Global.jugador._terminar_emocion()
	Global.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	level_complete_ui.mostrar(
		Global.emociones_recolectadas,
		Global.jugador.vidas_actuales
	)

func _on_jugador_sin_vidas():
	Global.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	game_over_ui.mostrar()
