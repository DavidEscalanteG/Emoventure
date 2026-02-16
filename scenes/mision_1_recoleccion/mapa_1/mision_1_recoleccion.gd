extends Node2D
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else null
var AudioManager: Object = Engine.get_singleton("AudioManager") if Engine.has_singleton("AudioManager") else null
var Logs: Object = Engine.get_singleton("Logs") if Engine.has_singleton("Logs") else null


const SFX_NIVEL_COMPLETADO := "res://audios/sfx/nivel_completado.mp3"
const SFX_GAME_OVER := "res://audios/sfx/game_over.mp3"

@onready var level_complete_ui: Control = $NivelCompletadoUI/Control
@onready var game_over_ui: Control = $GameOverUI/Control

func _ready() -> void:

	DatosJugador.jugador.permitir_movimiento()

	Logs.log_debug("Enemigos encontrados: %d" % get_tree().get_nodes_in_group("enemigos").size())
	Logs.log_debug("Level complete UI listo")
	DatosJugador.emociones_recolectadas.clear()
	DatosJugador.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)
	
	DatosJugador.jugador.sin_vidas.connect(_on_jugador_sin_vidas)

func _on_todas_las_emociones_recolectadas() -> void:
	
	DatosJugador.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	Logs.log_debug("Nivel completado")
	AudioManager.play_sfx(SFX_NIVEL_COMPLETADO)
	
	DatosJugador.jugador.nivel_terminado = true
	DatosJugador.jugador.terminar_emocion()
	DatosJugador.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	level_complete_ui.mostrar(
		DatosJugador.emociones_recolectadas,
		DatosJugador.jugador.vidas_actuales
	)

func _on_jugador_sin_vidas() -> void:
	AudioManager.play_sfx(SFX_GAME_OVER)
	DatosJugador.jugador.bloquear_movimiento()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	game_over_ui.mostrar()
