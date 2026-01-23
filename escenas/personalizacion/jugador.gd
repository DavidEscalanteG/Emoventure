extends CharacterBody2D

@export var speed := 300
var puede_moverse := false

var emocion_actual := ""
var timer_emocion: Timer

var controles_invertidos := false

var timer_congelar: Timer
var congelando := false

@export var vidas_maximas := 3
var vidas_actuales := 3

var velocidad_base := 300
var invulnerable := false

var nivel_terminado := false

# --- REFERENCIAS (Asegúrate de tener los mismos nombres de nodos en esta escena) ---
@onready var sprite_cabello = $Node2D/Cabello
@onready var sprite_ojos = $Node2D/Ojos
@onready var sprite_boca = $Node2D/Boca
@onready var sprite_cuerpo = $Node2D/Cuerpo
@onready var sprite_nariz = $Node2D/Nariz
@onready var sprite_cabeza = $Node2D/Cabeza

# --- INVENTARIO (Copia y pega las mismas listas del otro script en el inspector) ---
@export var coleccion_cabellos: Array[Texture2D]
@export var coleccion_ojos: Array[Texture2D]
@export var coleccion_boca: Array[Texture2D]
@export var coleccion_cuerpo: Array[Texture2D]
@export var coleccion_nariz: Array[Texture2D]
@export var coleccion_cabeza: Array[Texture2D]

# Diccionario para expresiones (Opcional, para diálogos)
@export var expresiones_ojos: Dictionary 

func _ready():
	
	velocidad_base = speed
	vidas_actuales = vidas_maximas
	
	Global.jugador = self
	cargar_apariencia_desde_global()

	timer_emocion = Timer.new()
	
	timer_congelar = Timer.new()
	timer_congelar.wait_time = 0.6
	timer_congelar.one_shot = false
	add_child(timer_congelar)
	timer_congelar.timeout.connect(_alternar_congelamiento)

	timer_emocion.one_shot = true
	add_child(timer_emocion)
	timer_emocion.timeout.connect(_terminar_emocion)

func recibir_danio():
	print("💀​💀​ Danio recibido")
	if invulnerable:
		return

	vidas_actuales -= 1
	print("Vidas restantes:", vidas_actuales)

	# Actualizar UI
	if Global.lives_ui:
		Global.lives_ui.actualizar_vidas(vidas_actuales)

	if vidas_actuales <= 0:
		_morir()
		return

	_activar_invulnerabilidad()

func _activar_invulnerabilidad():
	invulnerable = true

	# Boost de velocidad
	speed = velocidad_base + 150

	# Parpadeo
	var tween := create_tween()
	tween.set_loops(6)
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)

	await tween.finished

	# Restaurar estado
	speed = velocidad_base
	invulnerable = false

func _morir():
	print("​☠️​ Jugador muerto")
	bloquear_movimiento()

	# Aquí el nivel decide:
	# get_tree().reload_current_scene()
	# o emitir señal

func aplicar_emocion(tipo: String, color: Color, duracion: float):
	_terminar_emocion()

	emocion_actual = tipo
	_aplicar_color(color)
	_aplicar_efecto(tipo)
	
	# 📌 Registrar emoción
	Global.registrar_emocion(tipo)
	
	# 🔔 Avisar al UI
	if Global.emotions_ui:
		Global.emotions_ui.unlock_emotion(tipo)
	
	# 🏁 ¿Ya están todas?
#	if Global.tiene_todas_las_emociones():
#		_on_todas_las_emociones_recolectadas()
		
	timer_emocion.start(duracion)

func _aplicar_color(color: Color):
	sprite_cuerpo.self_modulate = color
	sprite_cabeza.self_modulate = color

func _aplicar_efecto(tipo: String):
	match tipo:
		"alegria":
			speed = 400
		"tristeza":
			speed = 200
		"enojo":
			speed = 300
			_invertir_controles()
		"desagrado":
			_congelar_intermitente()
		"sorpresa":
			speed = 450

func _invertir_controles():
	controles_invertidos = true

func _congelar_intermitente():
	congelando = true
	timer_congelar.start()

func _alternar_congelamiento():
	puede_moverse = not puede_moverse

func _terminar_emocion():
	emocion_actual = ""
	speed = velocidad_base
	controles_invertidos = false

	congelando = false
	timer_congelar.stop()
	
	if not nivel_terminado:
		puede_moverse = true
	else:
		puede_moverse = false

	_restablecer_color()

func _restablecer_color():
	sprite_cuerpo.self_modulate = Global.apariencia.color_cuerpo
	sprite_cabeza.self_modulate = Global.apariencia.color_cabeza

func cargar_apariencia_desde_global():
	# RECONSTRUCCIÓN: Usamos los datos guardados en "Global"
	
	# 1. Texturas
	if coleccion_cabellos.size() > 0:
		sprite_cabello.texture = coleccion_cabellos[Global.apariencia.indice_cabello]
	if coleccion_cabeza.size() > 0:
		sprite_cabeza.texture = coleccion_cabeza[Global.apariencia.indice_cabeza]
	if coleccion_ojos.size() > 0:
		sprite_ojos.texture = coleccion_ojos[Global.apariencia.indice_ojos]
	if coleccion_boca.size() > 0:
		sprite_boca.texture = coleccion_boca[Global.apariencia.indice_boca]
	if coleccion_nariz.size() > 0:
		sprite_nariz.texture = coleccion_nariz[Global.apariencia.indice_nariz]
	if coleccion_cuerpo.size() > 0:
		sprite_cuerpo.texture = coleccion_cuerpo[Global.apariencia.indice_cuerpo]
		
	# 2. Colores
	sprite_cabello.self_modulate = Global.apariencia.color_cabello
	sprite_cabeza.self_modulate = Global.apariencia.color_cabeza
	sprite_ojos.self_modulate = Global.apariencia.color_ojos
	sprite_boca.self_modulate = Global.apariencia.color_boca
	sprite_nariz.self_modulate = Global.apariencia.color_nariz
	sprite_cuerpo.self_modulate = Global.apariencia.color_cuerpo

# Función para diálogos (Mantiene el color de ojos original)
func cambiar_gesto(nombre_emocion: String):
	if expresiones_ojos.has(nombre_emocion):
		sprite_ojos.texture = expresiones_ojos[nombre_emocion]
		# IMPORTANTE: Re-aplicar el color guardado, o la expresión saldrá blanca
		sprite_ojos.self_modulate = Global.apariencia.color_ojos

func _physics_process(_delta):
	if not puede_moverse:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Vector2.ZERO

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


func bloquear_movimiento():
	puede_moverse = false
	velocity = Vector2.ZERO

func permitir_movimiento():
	puede_moverse = true
