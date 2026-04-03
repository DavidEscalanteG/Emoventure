extends Node2D

var cursor_normal: Texture2D = load("res://assets/assets_escena_payaso/martillo.png")
var cursor_golpe: Texture2D = load("res://assets/assets_escena_payaso/martillo_pegando.png")

@export var escena_cuestionario: PackedScene = preload("res://scenes/cuestionarios/EscenaCuestionario.tscn")
@export var escena_cierre: PackedScene
@export var numero_mision_cuestionario: int = 2

@export var umbral_puntos_victoria: int = 20
@export_range(0.0, 1.0, 0.01) var umbral_porcentaje_aciertos_victoria: float = 0.45
@export var puntos_maximos_derrota: int = 5
@export_range(0.0, 1.0, 0.01) var umbral_porcentaje_aciertos_derrota: float = 0.20

@export_multiline var narrativa_previa_rescate: String = "¡Misión completada! Escuchaste las emociones del entorno y encontraste la pista de tu mascota. Antes de rescatarla, responde el cuestionario para estabilizar tus emociones."
@export_multiline var narrativa_posterior_rescate: String = "¡Lo lograste! Gracias a tus respuestas, recuperaste la calma y rescataste a tu mascota. Es momento de continuar la aventura."

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
var velocidad_minima: float = 0.4

@onready var pantalla_resultado: PanelContainer = %PantallaResultado
@onready var titulo_resultado: Label = %TituloResultado
@onready var detalle_resultado: Label = %DetalleResultado
@onready var boton_principal: Button = %BotonPrincipalResultado
@onready var boton_secundario: Button = %BotonSecundarioResultado
@onready var marcador_puntos: Label = %MarcadorPuntos

func _ready() -> void:
	randomize()

	for topo in get_children():
		if topo.has_method("aparecer") or topo.has_signal("golpe_recibido"):
			topos_jugables.append(topo)

	for topo in topos_jugables:
		if topo.has_signal("golpe_recibido"):
			topo.golpe_recibido.connect(_al_sumar_punto)

	boton_principal.pressed.connect(_on_boton_principal_presionado)
	boton_secundario.pressed.connect(_on_boton_secundario_presionado)
	Input.set_custom_mouse_cursor(cursor_normal)
	_actualizar_marcador()

func _exit_tree() -> void:
	_restaurar_cursor_predeterminado()

func _input(event: InputEvent) -> void:
	if mision_finalizada:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(cursor_golpe)
		else:
			Input.set_custom_mouse_cursor(cursor_normal)

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
	
	if dificultad < 5:
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
	detalle_resultado.text = "Puntos: %d | Aciertos: %.0f%%\n\n%s" % [puntos, porcentaje, narrativa_previa_rescate]
	boton_principal.text = "Ir al cuestionario"
	boton_secundario.visible = false
	pantalla_resultado.visible = true

func _mostrar_derrota(resultado: Dictionary) -> void:
	var porcentaje: float = resultado.porcentaje_aciertos * 100.0
	estado_resultado_actual = EstadoResultado.DERROTA
	titulo_resultado.text = "Misión fallida"
	detalle_resultado.text = "Puntos: %d | Aciertos: %.0f%%\nNecesitas mejorar tu precisión para rescatar a tu mascota." % [puntos, porcentaje]
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
	$SpawnTimer.start()
	$TimerJuego.start()
	Input.set_custom_mouse_cursor(cursor_normal)
	Logs.log_debug("Misión de topos reiniciada")

func _iniciar_cuestionario() -> void:
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
	cuestionario.narrativa_post_cuestionario = narrativa_posterior_rescate
	cuestionario.titulo_narrativa_post = "Rescate de mascota completado"

	var root: Window = get_tree().root
	var escena_actual: Node = get_tree().current_scene
	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario

func _restaurar_cursor_predeterminado() -> void:
	Input.set_custom_mouse_cursor(null)
