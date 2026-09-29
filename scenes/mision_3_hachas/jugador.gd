extends CharacterBody2D

const MOBILE_CONTROLS_SCENE := preload("res://src/ui/mobile_controls.tscn")
@export var coyote_time_duration = 0.15 # Cuánto tiempo dura el "perdón" (0.15s es ideal)

const SPEED = 480.0
const JUMP_VELOCITY = -760.0
const GRAVITY_SCALE = 1.6

var wall_jump_timer = 0.0  # Temporizador para bloquear el movimiento lateral un instante
var input_dir = 0 # Guardará la dirección según el orden de pulsación
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _reiniciando: bool = false
var coyote_timer = 0.0                 # El contador real

func _ready() -> void:
	_ensure_mobile_controls()
	# Al nacer/revivir, verificamos inmediatamente qué teclas están pulsadas físicamente
	if Input.is_action_pressed("ui_right"):
		input_dir = 1
	elif Input.is_action_pressed("ui_left"):
		input_dir = -1
	else:
		input_dir = 0

func _input(event):
	# Si presionas una tecla, esa se vuelve la prioridad
	if event.is_action_pressed("ui_right"):
		input_dir = 1
	elif event.is_action_pressed("ui_left"):
		input_dir = -1
	
	# Al soltar, revisamos si la otra tecla sigue presionada
	if event.is_action_released("ui_right"):
		if Input.is_action_pressed("ui_left"):
			input_dir = -1
		else:
			input_dir = 0
	elif event.is_action_released("ui_left"):
		if Input.is_action_pressed("ui_right"):
			input_dir = 1
		else:
			input_dir = 0
			
func _physics_process(delta: float) -> void:
	if _reiniciando:
		return
	# Input.action_press (controles táctiles) no emite eventos _input.
	var left := Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right")
	if left != right:
		input_dir = -1 if left else 1
	elif not left:
		input_dir = 0
	var jump_pressed := Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("move_up")
	var jump_released := Input.is_action_just_released("ui_accept") or Input.is_action_just_released("move_up")
	# 1. GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_SCALE

	# 2. PROCESAR EL TIMER
	# Restamos el tiempo que pasa en cada frame
	if wall_jump_timer > 0:
		wall_jump_timer -= delta

	# Manejo del Coyote Time
	if is_on_floor():
		coyote_timer = coyote_time_duration # Si toca el suelo, el timer se reinicia
	else:
		coyote_timer -= delta # Si está en el aire, el tiempo empieza a correr
		
	# 3. SALTO NORMAL (Ahora con Coyote Time)
	if jump_pressed and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 # Importante: gastamos el tiempo para no saltar doble en el aire

	# 4. SALTO VARIABLE (Saltar poco si sueltas rápido)
	if jump_released and velocity.y < 0:
		velocity.y = velocity.y * 0.5

	# 5. LÓGICA DE WALL JUMP
	if is_on_wall() and not is_on_floor():
		if jump_pressed:
			var wall_normal = get_wall_normal()
			
			velocity.y = JUMP_VELOCITY
			# Multiplicamos por 1.5 para un impulso extra hacia afuera
			velocity.x = wall_normal.x * (SPEED * 1.5)
			
			# Bloqueamos el control por 0.15 segundos para que el impulso funcione
			wall_jump_timer = 0.1

	# 6. MOVIMIENTO HORIZONTAL (Instantáneo y con Prioridad)
	if wall_jump_timer <= 0:
		# Asignamos la velocidad de golpe: o es SPEED, o es -SPEED, o es 0.
		velocity.x = input_dir * SPEED
		
		# VOLTEAR EL SPRITE (Flip) según la dirección que camina
		if animated_sprite != null and input_dir > 0:
			animated_sprite.flip_h = false # Mira a la derecha
		elif animated_sprite != null and input_dir < 0:
			animated_sprite.flip_h = true  # Voltea a la izquierda

	# 7. EJECUTAR MOVIMIENTO
	move_and_slide()
	_detectar_trampas()
	if global_position.y > 1200.0:
		morir()
	
	if animated_sprite == null:
		return

	# CONTROL DE LAS ANIMACIONES (Ejecutadas tras mover al personaje)
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump") # Subiendo
		else:
			animated_sprite.play("fall") # Bajando
	else:
		if velocity.x != 0:
			animated_sprite.play("run")  # Corriendo
		else:
			animated_sprite.play("iddle") # Quieto

func _ensure_mobile_controls() -> void:
	if not OS.has_feature("mobile"):
		return
	if get_tree().root.has_node("MobileControls"):
		return
	var controls := MOBILE_CONTROLS_SCENE.instantiate()
	controls.name = "MobileControls"
	get_tree().root.add_child.call_deferred(controls)
	
func _detectar_trampas() -> void:
	# 8. DETECCIÓN DE TRAMPAS
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_tocado = colision.get_collider()
		
		if objeto_tocado is TileMapLayer:
			var rid = colision.get_collider_rid()
			var capas = PhysicsServer2D.body_get_collision_layer(rid)
			
			if capas & 2:
				morir()

# Función para reiniciar el nivel
func morir() -> void:
	if _reiniciando:
		return
	_reiniciando = true
	get_tree().reload_current_scene.call_deferred()
