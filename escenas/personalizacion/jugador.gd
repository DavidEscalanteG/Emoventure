extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var speed: int = 300
@export var vidas_maximas: int = 3

# --- ESTADO ---
var puede_moverse: bool = false
var emocion_actual: String = ""
var controles_invertidos: bool = false
var congelando: bool = false
var invulnerable: bool = false
var nivel_terminado: bool = false

var vidas_actuales: int = 0
var velocidad_base: int = 0

# --- TIMERS ---
var timer_emocion: Timer
var timer_congelar: Timer

# --- REFERENCIAS ---
@onready var apariencia: Node = $PlayerAppearance

func _ready() -> void:
	velocidad_base = speed
	vidas_actuales = vidas_maximas

	Global.jugador = self

	# Aplicar apariencia inicial
	apariencia.aplicar_apariencia_desde_global()

	# Timer emoción
	timer_emocion = Timer.new()
	timer_emocion.one_shot = true
	add_child(timer_emocion)
	timer_emocion.timeout.connect(_terminar_emocion)

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

	if Global.lives_ui:
		Global.lives_ui.actualizar_vidas(vidas_actuales)

	if vidas_actuales <= 0:
		_morir()
		return

	_activar_invulnerabilidad()

func _activar_invulnerabilidad() -> void:
	invulnerable = true
	speed = velocidad_base + 150

	var tween: Tween = create_tween()
	tween.set_loops(6)
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)

	await tween.finished

	speed = velocidad_base
	invulnerable = false

func _morir() -> void:
	bloquear_movimiento()
	print("☠️ Jugador muerto")

# --------------------------------------------------
# EMOCIONES
# --------------------------------------------------
func aplicar_emocion(tipo: String, color: Color, duracion: float) -> void:
	_terminar_emocion()

	emocion_actual = tipo
	_aplicar_efecto(tipo)

	Global.registrar_emocion(tipo)

	if Global.emotions_ui:
		Global.emotions_ui.unlock_emotion(tipo)

	apariencia.aplicar_color_emocion(color)
	timer_emocion.start(duracion)

func _aplicar_efecto(tipo: String) -> void:
	match tipo:
		"alegria":
			speed = 400
		"tristeza":
			speed = 200
		"enojo":
			speed = 300
			controles_invertidos = true
		"desagrado":
			congelando = true
			timer_congelar.start()
		"sorpresa":
			speed = 450

func _alternar_congelamiento() -> void:
	puede_moverse = not puede_moverse

func _terminar_emocion() -> void:
	emocion_actual = ""
	speed = velocidad_base
	controles_invertidos = false

	congelando = false
	timer_congelar.stop()

	puede_moverse = not nivel_terminado
	apariencia.restaurar_colores()

# --------------------------------------------------
# MOVIMIENTO
# --------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not puede_moverse:
		velocity = Vector2.ZERO
		move_and_slide()
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
	
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			$PlayerAppearance.set_direccion(
				"right" if direction.x > 0 else "left"
			)
		else:
			$PlayerAppearance.set_direccion(
				"down" if direction.y > 0 else "up"
			)

	move_and_slide()

# --------------------------------------------------
# CONTROL EXTERNO
# --------------------------------------------------
func bloquear_movimiento() -> void:
	puede_moverse = false
	velocity = Vector2.ZERO

func permitir_movimiento() -> void:
	puede_moverse = true
