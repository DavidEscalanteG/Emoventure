extends Node2D

const SFX_NIVEL_COMPLETADO := "res://audios/sfx/nivel_completado.mp3"
const SFX_GAME_OVER := "res://audios/sfx/game_over.mp3"

const FUEGO_SCENE: PackedScene = preload("res://assets/enemigos/fuego/Fuego.tscn")
const FUEGO_INDICADOR_SCENE: PackedScene = preload("res://assets/enemigos/fuego/FuegoIndicador.tscn")

# --- LISTA FIJA CON LOS 5 MAPAS (Inmune a cambios en el Inspector) ---
const MAPAS_MISION: Array[String] = [
	"res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn",
	"res://scenes/mision_1_recoleccion/mapa_2/mapa2.tscn",
	"res://scenes/mision_1_recoleccion/mapa_3/mapa3.tscn",
	"res://scenes/mision_1_recoleccion/mapa_4/mapa4.tscn",
	"res://scenes/mision_1_recoleccion/mapa_5/mapa5.tscn"
]

# --- VARIABLES ESTÁTICAS PARA LA BOLSA TIPO TETRIS ---
static var _bolsa_mapas: Array[String] = []
static var _primera_bolsa_inicializada: bool = false

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
var _partida_finalizada: bool = false

func _ready() -> void:
	_inicializar_bolsa_si_es_necesario()
	_crear_fondo_ambiente()

	# COMPROBACIÓN 1: ¿El jugador puede moverse?
	if DatosJugador.jugador.has_method("permitir_movimiento"):
		DatosJugador.jugador.permitir_movimiento()

	Logs.log_debug("Enemigos encontrados: %d" % get_tree().get_nodes_in_group("enemigos").size())
	Logs.log_debug("Level complete UI listo")
	DatosJugador.emociones_recolectadas.clear()
	DatosJugador.todas_las_emociones_recolectadas.connect(_on_todas_las_emociones_recolectadas)

	# COMPROBACIÓN 2: ¿El jugador tiene la señal de vidas?
	if DatosJugador.jugador.has_signal("sin_vidas"):
		DatosJugador.jugador.sin_vidas.connect(_on_jugador_sin_vidas)
		
	_inicializar_fuego_dinamico()


func _on_todas_las_emociones_recolectadas() -> void:
	if _partida_finalizada:
		return
	_partida_finalizada = true

	DatosJugador.todas_las_emociones_recolectadas.disconnect(_on_todas_las_emociones_recolectadas)
	Logs.log_debug("Nivel completado")
	AudioManager.play_sfx(SFX_NIVEL_COMPLETADO)

	# Reiniciamos la bolsa al completar el nivel
	_bolsa_mapas.clear()
	_primera_bolsa_inicializada = false

	# COMPROBACIONES: Solo ejecutamos esto si es el jugador real
	if "nivel_terminado" in DatosJugador.jugador:
		DatosJugador.jugador.nivel_terminado = true
	if DatosJugador.jugador.has_method("terminar_emocion"):
		DatosJugador.jugador.terminar_emocion()
	if DatosJugador.jugador.has_method("bloquear_movimiento"):
		DatosJugador.jugador.bloquear_movimiento()

	_detener_fuego_dinamico()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.bloquear_movimiento()

	# Valor por defecto en caso de que sea el actor del diálogo
	var vidas = 3 
	if "vidas_actuales" in DatosJugador.jugador:
		vidas = DatosJugador.jugador.vidas_actuales

	level_complete_ui.mostrar(
		DatosJugador.emociones_recolectadas,
		vidas
	)


func _on_jugador_sin_vidas() -> void:
	if _partida_finalizada:
		return
	_partida_finalizada = true
	AudioManager.play_sfx(SFX_GAME_OVER)
	
	if DatosJugador.jugador.has_method("bloquear_movimiento"):
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
	if DatosJugador.jugador == null or DatosJugador.jugador.get("nivel_terminado") == true:
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
	indicador.set("duracion", tiempo_indicador_fuego)
	indicador.set("intervalo_parpadeo", intervalo_parpadeo_indicador)

	add_child(indicador)
	var espera := create_tween()
	espera.tween_interval(tiempo_indicador_fuego)
	espera.tween_callback(_crear_fuego.bind(interseccion))


func _crear_fuego(interseccion: Node2D) -> void:
	if DatosJugador.jugador == null or DatosJugador.jugador.get("nivel_terminado") == true:
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


func _crear_fondo_ambiente() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "FondoAmbiente"
	canvas.layer = -100
	add_child(canvas)

	var fondo := ColorRect.new()
	fondo.name = "CieloPixelado"
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;
		render_mode unshaded;
		void fragment() {
			vec2 cell = floor(UV * vec2(30.0, 17.0));
			float checker = mod(cell.x + cell.y, 2.0);
			float vignette = 1.0 - smoothstep(0.25, 0.82, distance(UV, vec2(0.5)));
			vec3 base = mix(vec3(0.025, 0.055, 0.115), vec3(0.04, 0.10, 0.18), checker * 0.32);
			base += vec3(0.015, 0.04, 0.07) * vignette;
			COLOR = vec4(base, 1.0);
		}
	"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	fondo.material = shader_material
	canvas.add_child(fondo)


# ==========================================
# SISTEMA DE BOLSA DE MAPAS (ESTILO TETRIS)
# ==========================================
func _obtener_mapas_validos() -> Array[String]:
	var validos: Array[String] = []
	for ruta in MAPAS_MISION:
		if ResourceLoader.exists(ruta):
			validos.append(ruta)
		else:
			push_warning("⚠ No se encontró el mapa en la ruta: %s" % ruta)
	return validos


func _inicializar_bolsa_si_es_necesario() -> void:
	if _primera_bolsa_inicializada:
		return

	var validos: Array[String] = _obtener_mapas_validos()
	if validos.size() <= 1:
		return

	_primera_bolsa_inicializada = true
	var ruta_actual: String = scene_file_path
	if ruta_actual.is_empty() and get_tree().current_scene != null:
		ruta_actual = get_tree().current_scene.scene_file_path

	_bolsa_mapas = validos.duplicate()
	# Quitamos el mapa con el que arrancó la partida para no repetirlo antes que los otros 4
	_bolsa_mapas.erase(ruta_actual)
	_bolsa_mapas.shuffle()


func cargar_mapa_aleatorio() -> void:
	var validos: Array[String] = _obtener_mapas_validos()
	if validos.size() <= 1:
		get_tree().reload_current_scene()
		return

	var ruta_actual: String = scene_file_path
	if ruta_actual.is_empty() and get_tree().current_scene != null:
		ruta_actual = get_tree().current_scene.scene_file_path

	# Cuando ya salieron los 4 mapas restantes, se rellena la bolsa con los 5 mapas (incluido el Mapa 1)
	if _bolsa_mapas.is_empty():
		_bolsa_mapas = validos.duplicate()
		_bolsa_mapas.shuffle()

		# Si por azar el primero que va a salir de la bolsa nueva es el mismo donde acabas de morir, lo intercambiamos
		if _bolsa_mapas.size() > 1 and _bolsa_mapas.back() == ruta_actual:
			var temp: String = _bolsa_mapas[0]
			_bolsa_mapas[0] = _bolsa_mapas[_bolsa_mapas.size() - 1]
			_bolsa_mapas[_bolsa_mapas.size() - 1] = temp

	var mapa_elegido: String = _bolsa_mapas.pop_back()
	Logs.log_debug("Cargando mapa: %s (Restantes en la bolsa actual: %d)" % [mapa_elegido, _bolsa_mapas.size()])

	var nueva_escena: PackedScene = load(mapa_elegido) as PackedScene
	if nueva_escena != null:
		get_tree().change_scene_to_packed(nueva_escena)
	else:
		get_tree().change_scene_to_file(mapa_elegido)
