extends Node2D

const SFX_NIVEL_COMPLETADO := "res://audios/sfx/nivel_completado.mp3"
const SFX_GAME_OVER := "res://audios/sfx/game_over.mp3"

const FUEGO_SCENE: PackedScene = preload("res://assets/enemigos/fuego/Fuego.tscn")
const FUEGO_INDICADOR_SCENE: PackedScene = preload("res://assets/enemigos/fuego/FuegoIndicador.tscn")

@export_group("Fuego dinámico")
@export var intervalo_generacion_fuego: float = 6.9
@export var cantidad_fuegos_por_oleada: int = 10
@export var tiempo_indicador_fuego: float = 1.4
@export var tiempo_activo_fuego: float = 3.5
@export var tiempo_parpadeo_fuego: float = 0.9
@export var intervalo_parpadeo_fuego: float = 0.1
@export var intervalo_parpadeo_indicador: float = 0.12

@onready var level_complete_ui: Control = $NivelCompletadoUI/Control
@onready var game_over_ui: Control = $GameOverUI/Control

var _intersecciones_disponibles: Array[Node2D] = []
var _fuegos_activos: Dictionary = {}
var _intersecciones_reservadas: Dictionary = {}
var _timer_generacion_fuego: Timer

func _ready() -> void:

	DatosJugador.jugador.permitir_movimiento()

	Logs.log_debug("Enemigos encontrados: %d" % get_tree().get_nodes_in_group("enemigos").size())
	Logs.log_debug("Level complete UI listo")
	DatosJugador.emociones_recolectadas.clear()
	DatosJugador.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)

	DatosJugador.jugador.sin_vidas.connect(_on_jugador_sin_vidas)
	_inicializar_fuego_dinamico()

func _on_todas_las_emociones_recolectadas() -> void:

	DatosJugador.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	Logs.log_debug("Nivel completado")
	AudioManager.play_sfx(SFX_NIVEL_COMPLETADO)

	DatosJugador.jugador.nivel_terminado = true
	DatosJugador.jugador.terminar_emocion()
	DatosJugador.jugador.bloquear_movimiento()

	_detener_fuego_dinamico()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	level_complete_ui.mostrar(
		DatosJugador.emociones_recolectadas,
		DatosJugador.jugador.vidas_actuales
	)

func _on_jugador_sin_vidas() -> void:
	AudioManager.play_sfx(SFX_GAME_OVER)
	DatosJugador.jugador.bloquear_movimiento()

	_detener_fuego_dinamico()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	game_over_ui.mostrar()


func _inicializar_fuego_dinamico() -> void:
	var nodo_intersecciones: Node = get_node_or_null("Intersecciones")
	if nodo_intersecciones == null:
		Logs.log_debug("⚠ No se encontró nodo Intersecciones para fuego dinámico")
		return

	for hijo in nodo_intersecciones.get_children():
		if hijo is Node2D:
			_intersecciones_disponibles.append(hijo)

	if _intersecciones_disponibles.is_empty():
		Logs.log_debug("⚠ No hay intersecciones disponibles para fuego dinámico")
		return

	_timer_generacion_fuego = Timer.new()
	_timer_generacion_fuego.one_shot = false
	_timer_generacion_fuego.wait_time = max(intervalo_generacion_fuego, 0.1)
	add_child(_timer_generacion_fuego)
	_timer_generacion_fuego.timeout.connect(_intentar_generar_fuegos)
	_timer_generacion_fuego.start()


func _detener_fuego_dinamico() -> void:
	if _timer_generacion_fuego and is_instance_valid(_timer_generacion_fuego):
		_timer_generacion_fuego.stop()


func _intentar_generar_fuegos() -> void:
	if DatosJugador.jugador == null or DatosJugador.jugador.nivel_terminado:
		return

	var candidatas: Array[Node2D] = []
	for interseccion in _intersecciones_disponibles:
		if _fuegos_activos.has(interseccion):
			continue
		if _intersecciones_reservadas.has(interseccion):
			continue
		candidatas.append(interseccion)

	if candidatas.is_empty():
		return

	candidatas.shuffle()
	var cantidad_objetivo: int = min(cantidad_fuegos_por_oleada, candidatas.size())
	for i in range(cantidad_objetivo):
		var interseccion: Node2D = candidatas[i]
		_intersecciones_reservadas[interseccion] = true
		_crear_indicador_y_programar_fuego(interseccion)


func _crear_indicador_y_programar_fuego(interseccion: Node2D) -> void:
	var indicador = FUEGO_INDICADOR_SCENE.instantiate()
	indicador.global_position = interseccion.global_position
	add_child(indicador)
	indicador.set("duracion", tiempo_indicador_fuego)
	indicador.set("intervalo_parpadeo", intervalo_parpadeo_indicador)

	await get_tree().create_timer(tiempo_indicador_fuego).timeout

	if DatosJugador.jugador == null or DatosJugador.jugador.nivel_terminado:
		_intersecciones_reservadas.erase(interseccion)
		return

	if _fuegos_activos.has(interseccion):
		_intersecciones_reservadas.erase(interseccion)
		return

	var fuego = FUEGO_SCENE.instantiate()
	fuego.global_position = interseccion.global_position
	fuego.set("tiempo_activo", tiempo_activo_fuego)
	fuego.set("tiempo_parpadeo_final", tiempo_parpadeo_fuego)
	fuego.set("intervalo_parpadeo", intervalo_parpadeo_fuego)
	add_child(fuego)
	fuego.configurar_interseccion(interseccion)
	fuego.fuego_extinguido.connect(_on_fuego_extinguido)

	_fuegos_activos[interseccion] = fuego
	_intersecciones_reservadas.erase(interseccion)


func _on_fuego_extinguido(interseccion: Node2D) -> void:
	if _fuegos_activos.has(interseccion):
		_fuegos_activos.erase(interseccion)
		
