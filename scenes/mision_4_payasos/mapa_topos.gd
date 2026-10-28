extends Node2D

var cursor_normal: Texture2D = load("res://assets/assets_escena_payaso/martillo.png")
var cursor_golpe: Texture2D = load("res://assets/assets_escena_payaso/martillo_pegando.png")
@onready var cursor_martillo: Sprite2D = $CursorMartillo

@export var escena_cuestionario: PackedScene = preload("res://scenes/cuestionarios/EscenaCuestionario.tscn")
@export var escena_cierre: PackedScene = preload("res://scenes/intro_dialogo_10/intro_dialogo_10.tscn")
@export var numero_mision_cuestionario: int = 2

@export var umbral_puntos_victoria: int = 40
@export_range(0.0, 1.0, 0.01) var umbral_porcentaje_aciertos_victoria: float = 0.50
@export var puntos_maximos_derrota: int = 20
@export_range(0.0, 1.0, 0.01) var umbral_porcentaje_aciertos_derrota: float = 0.20

@export var boton_saltar_hud: Button
# Variable estática para conservar el conteo entre reinicios
static var intentos_mision_4: int = 0

var puntos: int = 0
var topos_jugables: Array[Node] = []
var total_topos_aparecidos: int = 0
var mision_finalizada: bool = false

enum EstadoResultado {
	NINGUNO,
	VICTORIA,
	DERROTA
}
var estado_resultado_actual: EstadoResultado = EstadoResultado.NINGUNO

var dificultad: float = 1.0
var velocidad_minima: float = 0.8 

@onready var pantalla_resultado: PanelContainer = %PantallaResultado
@onready var titulo_resultado: Label = %TituloResultado
@onready var detalle_resultado: Label = %DetalleResultado
@onready var boton_principal: Button = %BotonPrincipalResultado
@onready var boton_secundario: Button = %BotonSecundarioResultado
@onready var marcador_puntos: Label = %MarcadorPuntos

func _ready() -> void:
	randomize()
	
	# --- NUEVO: Sumar el primer intento al entrar a la escena ---
	intentos_mision_4 += 1 

	for topo in get_children():
		if topo.has_method("aparecer") or topo.has_signal("golpe_recibido"):
			topos_jugables.append(topo)

	for topo in topos_jugables:
		if topo.has_signal("golpe_recibido"):
			topo.golpe_recibido.connect(_al_sumar_punto)

	boton_principal.pressed.connect(_on_boton_principal_presionado)
	boton_secundario.pressed.connect(_on_boton_secundario_presionado)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if cursor_martillo:
		cursor_martillo.texture = cursor_normal
		cursor_martillo.visible = true
		
	# --- LÓGICA DEL BOTÓN DE SALTO DEL HUD ---
	if boton_saltar_hud != null:
		boton_saltar_hud.visible = (intentos_mision_4 >= 4)
		if not boton_saltar_hud.pressed.is_connected(_on_boton_saltar_hud_pressed):
			boton_saltar_hud.pressed.connect(_on_boton_saltar_hud_pressed)
	# -----------------------------------------
	
	_actualizar_marcador()

func _exit_tree() -> void:
	_restaurar_cursor_predeterminado()

func _process(_delta: float) -> void:
	if not mision_finalizada and cursor_martillo:
		cursor_martillo.global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if mision_finalizada:
		return
		
	# Detectar clic izquierdo en PC
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if cursor_martillo:
				cursor_martillo.texture = cursor_golpe
		else:
			if cursor_martillo:
				cursor_martillo.texture = cursor_normal
				
	# Detectar toque directo en pantalla de celular
	elif event is InputEventScreenTouch:
		if event.pressed:
			if cursor_martillo:
				cursor_martillo.texture = cursor_golpe
		else:
			if cursor_martillo:
				cursor_martillo.texture = cursor_normal

func _al_sumar_punto() -> void:
	if mision_finalizada:
		return

	puntos += 1
	_actualizar_marcador()

func _actualizar_marcador() -> void:
	marcador_puntos.text = "Puntos: " + str(puntos)

func _on_spawn_timer_timeout() -> void:
	if mision_finalizada or topos_jugables.is_empty():
		return

	var disponibles: Array = topos_jugables.filter(func(topo: Node) -> bool: return topo.has_method("aparecer"))
	if disponibles.is_empty():
		return
	var cantidad_a_salir: int = min(int(dificultad), disponibles.size())
	for i in range(cantidad_a_salir):
		var indice_aleatorio: int = randi() % disponibles.size()
		var topo_aleatorio: Node = disponibles[indice_aleatorio]
		topo_aleatorio.aparecer()
		total_topos_aparecidos += 1
		disponibles.remove_at(indice_aleatorio)

	if $SpawnTimer.wait_time > velocidad_minima:
		$SpawnTimer.wait_time -= 0.05
	if dificultad < 3: 
		dificultad += 0.1

func _on_timer_juego_timeout() -> void:
	_finalizar_mision()

func _finalizar_mision() -> void:
	if mision_finalizada:
		return

	mision_finalizada = true
	$SpawnTimer.stop()
	$TimerJuego.stop()
	_restaurar_cursor_predeterminado()

	for topo in topos_jugables:
		if topo.has_method("reset_estado"):
			topo.reset_estado()
		elif topo is CanvasItem:
			(topo as CanvasItem).hide()

	var resultado: Dictionary = _evaluar_resultado()
	if resultado.victoria:
		_mostrar_victoria(resultado)
	else:
		_mostrar_derrota(resultado)

func _evaluar_resultado() -> Dictionary:
	var total_intentos: int = max(total_topos_aparecidos, 1)
	var porcentaje_aciertos: float = float(puntos) / float(total_intentos)

	var cumple_victoria: bool = puntos >= umbral_puntos_victoria or porcentaje_aciertos >= umbral_porcentaje_aciertos_victoria
	var cumple_derrota: bool = puntos <= puntos_maximos_derrota or porcentaje_aciertos <= umbral_porcentaje_aciertos_derrota

	if cumple_victoria:
		cumple_derrota = false

	return {
		"victoria": cumple_victoria and not cumple_derrota,
		"porcentaje_aciertos": porcentaje_aciertos,
		"total_aparecidos": total_topos_aparecidos
	}

func _mostrar_victoria(resultado: Dictionary) -> void:
	var porcentaje: float = resultado.porcentaje_aciertos * 100.0
	estado_resultado_actual = EstadoResultado.VICTORIA
	titulo_resultado.text = "Misión completada"
	detalle_resultado.text = "Puntos: %d | Aciertos: %.0f%%" % [puntos, porcentaje]
	boton_principal.text = "Ir al cuestionario"
	boton_secundario.visible = false
	pantalla_resultado.visible = true

func _mostrar_derrota(resultado: Dictionary) -> void:
	var porcentaje: float = resultado.porcentaje_aciertos * 100.0
	estado_resultado_actual = EstadoResultado.DERROTA
	titulo_resultado.text = "Misión fallida"
	detalle_resultado.text = "Puntos: %d | Aciertos: %.0f%%\nNecesitas mejorar tu precisión para continuar." % [puntos, porcentaje]
	boton_principal.text = "Reintentar misión"
	boton_secundario.visible = false
	pantalla_resultado.visible = true

func _on_boton_principal_presionado() -> void:
	match estado_resultado_actual:
		EstadoResultado.VICTORIA:
			_iniciar_cuestionario()
		EstadoResultado.DERROTA:
			_reiniciar_mision()
		_:
			push_warning("Estado de resultado no definido al presionar botón principal")

func _on_boton_secundario_presionado() -> void:
	pantalla_resultado.visible = false

func _reiniciar_mision() -> void:
	# --- NUEVO: Sumar un intento cada vez que le dan a "Reintentar" ---
	intentos_mision_4 += 1
	
	mision_finalizada = false
	puntos = 0
	total_topos_aparecidos = 0
	estado_resultado_actual = EstadoResultado.NINGUNO
	dificultad = 1.0
	$SpawnTimer.wait_time = 1.5
	for topo in topos_jugables:
		if topo.has_method("reset_estado"):
			topo.reset_estado()
	_actualizar_marcador()
	pantalla_resultado.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if cursor_martillo:
		cursor_martillo.visible = true
		cursor_martillo.texture = cursor_normal
	$SpawnTimer.start()
	$TimerJuego.start()
	Logs.log_debug("Misión de topos reiniciada. Intento actual: " + str(intentos_mision_4))
	
	# --- NUEVO: Mostrar el botón del HUD instantáneamente si ya estamos en el intento 4 ---
	if boton_saltar_hud != null:
		boton_saltar_hud.visible = (intentos_mision_4 >= 4)

func _iniciar_cuestionario() -> void:
	# --- NUEVO: Reseteamos los intentos a 0 por si el jugador vuelve a jugar este nivel después ---
	intentos_mision_4 = 0
	
	if GameManager.consumir_modo_rejugabilidad():
		_restaurar_cursor_predeterminado()
		get_tree().change_scene_to_file(GameManager.ESCENA_MAPA_REJUGABILIDAD)
		return
	if escena_cuestionario == null:
		push_error("No se asignó escena_cuestionario")
		return

	if not Cuestionarios.validar_mision(numero_mision_cuestionario):
		return

	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
	var dimension: String = Cuestionarios.obtener_dimension_para_mision(numero_mision_cuestionario)

	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_mision(numero_mision_cuestionario)
	cuestionario.dimension = dimension
	cuestionario.escena_siguiente = escena_cierre

	var root: Window = get_tree().root
	var escena_actual: Node = get_tree().current_scene
	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario

func _restaurar_cursor_predeterminado() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if cursor_martillo:
		cursor_martillo.visible = false
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		# Al pausar el juego, mostramos el cursor real de la computadora y ocultamos el sprite del martillo
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if cursor_martillo:
			cursor_martillo.visible = false
			
	elif what == NOTIFICATION_UNPAUSED:
		# Al quitar la pausa, si la misión sigue activa, volvemos a ocultar el cursor y mostramos el martillo
		if not mision_finalizada:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			if cursor_martillo:
				cursor_martillo.visible = true

func _on_boton_saltar_hud_pressed() -> void:
	if AudioManager:
		AudioManager.play_ui_click()
	
	# Ocultamos el botón al hacer clic para que el jugador no lo presione dos veces
	boton_saltar_hud.visible = false
	
	# Llamamos directo a la función que finaliza el nivel y carga el cuestionario
	_iniciar_cuestionario()
