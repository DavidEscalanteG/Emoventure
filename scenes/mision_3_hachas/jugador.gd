extends CharacterBody2D

@export var coyote_time_duration = 0.15 # Cuánto tiempo dura el "perdón" (0.15s es ideal)


const SPEED = 300.0
const JUMP_VELOCITY = -444.0

var wall_jump_timer = 0.0  # Temporizador para bloquear el movimiento lateral un instante
var input_dir = 0 # Guardará la dirección según el orden de pulsación
var coyote_timer = 0.0                 # El contador real

func _ready():
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
	# 1. GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

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
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 # Importante: gastamos el tiempo para no saltar doble en el aire

	# 4. SALTO VARIABLE (Saltar poco si sueltas rápido)
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = velocity.y * 0.5

	# 5. LÓGICA DE WALL JUMP
	if is_on_wall() and not is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
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

	# 7. EJECUTAR MOVIMIENTO
	move_and_slide()

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
func morir():
	get_tree().reload_current_scene()
