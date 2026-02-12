extends Node2D

@onready var level_complete_ui := $NivelCompletadoUI/Control
@onready var game_over_ui := $GameOverUI/Control

func _ready():

	DatosJugador.jugador.permitir_movimiento()

	Logs.log_debug("Enemigos encontrados: %d" % get_tree().get_nodes_in_group("enemigos").size())
	Logs.log_debug("Level complete UI listo")
	DatosJugador.emociones_recolectadas.clear()
	DatosJugador.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)
	
	DatosJugador.jugador.sin_vidas.connect(_on_jugador_sin_vidas)

func _on_todas_las_emociones_recolectadas():
	
	DatosJugador.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	Logs.log_debug("Nivel completado")
	
	DatosJugador.jugador.nivel_terminado = true
	DatosJugador.jugador._terminar_emocion()
	DatosJugador.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	level_complete_ui.mostrar(
		DatosJugador.emociones_recolectadas,
		DatosJugador.jugador.vidas_actuales
	)

func _on_jugador_sin_vidas():
	DatosJugador.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	game_over_ui.mostrar()
