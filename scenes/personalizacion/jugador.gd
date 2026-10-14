extends CharacterBody2D

const MOBILE_CONTROLS_SCENE := preload("res://src/ui/mobile_controls.tscn")

# --------------------------------------------------
# SEÑALES
# --------------------------------------------------
signal sin_vidas


# --------------------------------------------------
# CONFIGURACIÓN
# --------------------------------------------------
@export var speed: int = 300
@export var vidas_maximas: int = 3
@export var duracion_invulnerabilidad: float = 1.2


# --------------------------------------------------
# ESTADO
# --------------------------------------------------
var ultima_direccion: Vector2 = Vector2.DOWN
var puede_moverse: bool = false
var emocion_actual: String = ""
var controles_invertidos: bool = false
var congelando: bool = false
var invulnerable: bool = false
var nivel_terminado: bool = false

var vidas_actuales: int = 0
var velocidad_base: int = 0


# --------------------------------------------------
# TIMERS
# --------------------------------------------------
var timer_emocion: Timer
var timer_congelar: Timer
var _duracion_emocion: float = 0.0
var _color_emocion: Color = Color.WHITE
var _ultimo_estado_indicador: bool = false


# --------------------------------------------------
# REFERENCIAS
# --------------------------------------------------
@onready var apariencia: Node = $PlayerAppearance


# --------------------------------------------------
# CICLO DE VIDA
# --------------------------------------------------
func _ready() -> void:
	_ensure_mobile_controls()
	velocidad_base = speed
	vidas_actuales = vidas_maximas

	DatosJugador.jugador = self

	# Apariencia inicial
	apariencia.aplicar_apariencia_desde_global()
	apariencia.establecer_direccion("down")
	apariencia.establecer_estado_movimiento("idle")

	# Timer emoción
	timer_emocion = Timer.new()
	timer_emocion.one_shot = true
	add_child(timer_emocion)
	timer_emocion.timeout.connect(terminar_emocion)

	# Timer congelamiento
	timer_congelar = Timer.new()
	timer_congelar.wait_time = 0.6
	timer_congelar.one_shot = false
	add_child(timer_congelar)
	timer_congelar.timeout.connect(_alternar_congelamiento)


# --------------------------------------------------
# VIDA / DAÑO
# --------------------------------------------------
func recibir_danio() -> void:
	if invulnerable:
		return

	vidas_actuales -= 1

	if DatosJugador.lives_ui:
		DatosJugador.lives_ui.actualizar_vidas(vidas_actuales)

	if vidas_actuales <= 0:
		_morir()
		sin_vidas.emit()
		return

	_activar_invulnerabilidad()


func _activar_invulnerabilidad() -> void:
	invulnerable = true
	speed = velocidad_base + 150

	var duracion_paso: float = 0.1
	var pasos_totales: int = max(1, int(round(duracion_invulnerabilidad / (duracion_paso * 2.0))))

	var tween: Tween = create_tween()
	tween.set_loops(pasos_totales)
	tween.tween_property(self, "modulate:a", 0.2, duracion_paso)
	tween.tween_property(self, "modulate:a", 1.0, duracion_paso)

	await tween.finished

	speed = velocidad_base
	invulnerable = false


func _morir() -> void:
	bloquear_movimiento()
	Logs.log_debug("☠️ Jugador muerto")


# --------------------------------------------------
# EMOCIONES
# --------------------------------------------------
func aplicar_emocion(tipo: String, color: Color, duracion: float) -> void:
	terminar_emocion()

	emocion_actual = tipo
	_duracion_emocion = maxf(duracion, 0.01)
	_color_emocion = color
	_aplicar_efecto(tipo)

	DatosJugador.registrar_emocion(tipo)

	if DatosJugador.emotions_ui:
		DatosJugador.emotions_ui.unlock_emotion(tipo)

	apariencia.aplicar_color_emocion(color)
	timer_emocion.start(duracion)


func _aplicar_efecto(tipo: String) -> void:
	match tipo:
		"alegria":
			speed = 400
		"tristeza":
			speed = 200
		"enojo":
			controles_invertidos = true
		"desagrado":
			congelando = true
			timer_congelar.start()
		"sorpresa":
			speed = 450


func _alternar_congelamiento() -> void:
	puede_moverse = not puede_moverse


func _terminar_emocion() -> void:
	terminar_emocion()


func terminar_emocion() -> void:
	emocion_actual = ""
	_duracion_emocion = 0.0
	speed = velocidad_base
	controles_invertidos = false

	congelando = false
	timer_congelar.stop()

	puede_moverse = not nivel_terminado
	apariencia.modulate.a = 1.0
	apariencia.restaurar_colores()
	queue_redraw()


# --------------------------------------------------
# MOVIMIENTO
# --------------------------------------------------
func _physics_process(delta: float) -> void:
	_actualizar_indicador_emocion(delta)
	if not puede_moverse:
		velocity = Vector2.ZERO
		move_and_slide()
		apariencia.establecer_estado_movimiento("idle")
		return

	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	direction = direction.normalized()

	if controles_invertidos:
		direction = -direction

	velocity = direction * speed
	move_and_slide()

	_actualizar_apariencia(direction)


func _actualizar_indicador_emocion(_delta: float) -> void:
	var efecto_activo := emocion_actual != "" and timer_emocion != null and not timer_emocion.is_stopped()
	if efecto_activo:
		var restante := timer_emocion.time_left
		if restante <= minf(1.5, _duracion_emocion * 0.35):
			# El pulso se acelera al acercarse el final del efecto.
			apariencia.modulate.a = 0.4 if fmod(restante, 0.24) < 0.12 else 1.0
		else:
			apariencia.modulate.a = 1.0
		queue_redraw()
	elif _ultimo_estado_indicador:
		apariencia.modulate.a = 1.0
		queue_redraw()
	_ultimo_estado_indicador = efecto_activo


func _draw() -> void:
	if emocion_actual == "" or timer_emocion == null or timer_emocion.is_stopped():
		return
	var progreso := clampf(timer_emocion.time_left / maxf(_duracion_emocion, 0.01), 0.0, 1.0)
	var barra := Rect2(Vector2(-25, -53), Vector2(50, 7))
	draw_rect(barra.grow(2.0), Color("#08101ddd"), true)
	draw_rect(barra, Color("#273548"), true)
	draw_rect(Rect2(barra.position, Vector2(barra.size.x * progreso, barra.size.y)), _color_emocion, true)
	draw_rect(barra.grow(1.0), Color("#eaf2ff"), false, 1.0)
	# Tres marcas convierten la barra en un temporizador legible de un vistazo.
	for marca in [0.25, 0.5, 0.75]:
		var x: float = barra.position.x + barra.size.x * float(marca)
		draw_line(Vector2(x, barra.position.y), Vector2(x, barra.end.y), Color(0.05, 0.08, 0.12, 0.65), 1.0)


func _actualizar_apariencia(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		ultima_direccion = direction
		apariencia.establecer_direccion(_vector_a_dir(direction))
		apariencia.establecer_estado_movimiento("walk")
	else:
		apariencia.establecer_estado_movimiento("idle")


func _vector_a_dir(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"


# --------------------------------------------------
# CONTROL EXTERNO
# --------------------------------------------------
func bloquear_movimiento() -> void:
	puede_moverse = false
	velocity = Vector2.ZERO
	apariencia.establecer_estado_movimiento("idle")


func permitir_movimiento() -> void:
	puede_moverse = true


func _ensure_mobile_controls() -> void:
	if not MobileControlsSettings.is_touch_device():
		return
	var scene := get_tree().current_scene
	if scene == null or scene.has_node("MobileControls"):
		return
	var controls := MOBILE_CONTROLS_SCENE.instantiate()
	controls.name = "MobileControls"
	scene.add_child.call_deferred(controls)
