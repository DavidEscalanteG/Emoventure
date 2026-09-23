extends CharacterBody2D

@export var velocidad_avance: float = 300.0
@export var fuerza_salto: float = -450.0
@export var desplazamiento_camara: float = 250.0

var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var esta_muerto: bool = false

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var camara: Camera2D = $Camera2D

const SFX_MUERTE = "res://audios/sfx/Taco Bell Bong SFX_160k.mp3"

func _ready() -> void:
	var altura_inicial = camara.global_position.y
	camara.top_level = true 
	camara.global_position.y = altura_inicial 

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
		

	if Input.is_action_just_pressed("ui_accept"):
		print("Pon un pincho en la posición X: ", global_position.x/48)
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta

	# 2. El Salto
	# 2. El Salto (Mantenido)
	if is_on_floor():
		# Usamos "is_action_pressed" para detectar si el botón sigue apretado
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up"):
			velocity.y = fuerza_salto

	# 3. Avance Automático
	velocity.x = velocidad_avance

	# 4. Aplicar el movimiento
	move_and_slide()
	
	# 5. La cámara sigue al jugador
	camara.global_position.x = global_position.x + desplazamiento_camara

	# ==========================================
	# 6. LÓGICA DE MUERTE MEJORADA (Rampas)
	# ==========================================
	
	# A. Si choca horizontalmente (Filtrando rampas)
	if is_on_wall():
		var direccion_pared = get_wall_normal()
		# Si la pared apunta casi totalmente hacia la izquierda (-1) o derecha (1)
		if direccion_pared.x <= -0.9 or direccion_pared.x >= 0.9:
			morir()
			
	# B. Si pisa o toca un bloque que pertenece al TileMapLayer "Trampas"
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_chocado = colision.get_collider()
		
		if objeto_chocado != null and objeto_chocado.is_in_group("trampas"):
			morir()
	# ==========================================

	# 7. Controlador de Animaciones
	_actualizar_animaciones()
	
	

func _actualizar_animaciones() -> void:
	if is_on_floor():
		animacion.play("correr")
	else:
		if velocity.y < 0:
			animacion.play("saltar")
		else:
			animacion.play("caer")

# NUEVO: Función que reinicia el nivel actual
func morir() -> void:
	# Evitamos que la función se ejecute varias veces si toca dos pinchos a la vez
	if esta_muerto:
		return
		
	esta_muerto = true
	
	# 1. Detener la música del nivel usando el grupo que creamos
	get_tree().call_group("musica_nivel", "stop")
	
	# 2. Reproducir tu sonido de muerte
	AudioManager.play_sfx(SFX_MUERTE)
	
	# 3. Animación improvisada: El personaje gira rápidamente y se encoge a tamaño 0
	var tween = create_tween()
	# Encogerlo en 0.5 segundos
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	# Girarlo al mismo tiempo (parallel)
	tween.parallel().tween_property(self, "rotation", 15.0, 0.5)
	
	# 4. Pausa de 1 segundo para que el Tween y el audio terminen
	await get_tree().create_timer(1.0).timeout
	
	
	# 5. Reiniciar el nivel
	get_tree().call_deferred("reload_current_scene")
	
	
