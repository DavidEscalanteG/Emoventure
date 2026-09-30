extends CharacterBody2D

@export var velocidad_avance: float = 300.0
@export var fuerza_salto: float = -450.0
@export var desplazamiento_camara: float = 250.0

var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var esta_muerto: bool = false
var tocando_pantalla: bool = false # NUEVO: Control manual de pantalla táctil

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var camara: Camera2D = $Camera2D

const SFX_MUERTE = "res://audios/sfx/Taco Bell Bong SFX_160k.mp3"

func _ready() -> void:
	var altura_inicial = camara.global_position.y
	camara.top_level = true 
	camara.global_position.y = altura_inicial 

# NUEVO: Detecta directamente si hay un dedo tocando la pantalla
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		tocando_pantalla = event.pressed

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return

	if Input.is_action_just_pressed("ui_accept"):
		print("Pon un pincho en la posición X: ", global_position.x/48)
		
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta

	# 2. El Salto (Mantenido)
	if is_on_floor():
		# Se añadió tocando_pantalla a las condiciones de salto
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up") or tocando_pantalla:
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

func morir() -> void:
	if esta_muerto:
		return
		
	esta_muerto = true
	
	get_tree().call_group("musica_nivel", "stop")
	AudioManager.play_sfx(SFX_MUERTE)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "rotation", 15.0, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	
	get_tree().call_deferred("reload_current_scene")
