extends CharacterBody2D

const MOBILE_CONTROLS_SCENE := preload("res://src/ui/mobile_controls.tscn")

@export var velocidad_avance: float = 300.0
@export var fuerza_salto: float = -450.0
@export var desplazamiento_camara: float = 250.0
# --- NUEVAS VARIABLES PARA SALTAR EL NIVEL ---
@export var boton_saltar: Button
@export var meta_del_nivel: Area2D # Conectaremos la meta para lanzar el cuestionario directamente
static var contador_muertes: int = 0
# --- VARIABLES PARA COYOTE TIME ---
@export var coyote_time_maximo: float = 0.15 # 0.15 segundos es el estándar en muchos juegos
var temporizador_coyote: float = 0.0
# ---------------------------------------------

var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var esta_muerto: bool = false
var tocando_pantalla: bool = false 
var altura_inicial: float

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var camara: Camera2D = $Camera2D

const SFX_MUERTE = "res://audios/sfx/Taco Bell Bong SFX_160k.mp3"

func _ready() -> void:
	_ensure_mobile_controls()
	MusicManager.reproducir_clave("mision_3", 0.0, 0.0, true)
	altura_inicial = camara.global_position.y
	camara.top_level = true 
	
	# Forzamos la posición inicial exacta
	camara.global_position = Vector2(global_position.x + desplazamiento_camara, altura_inicial)
	camara.make_current()

	# --- LÓGICA DEL BOTÓN DE SALTO ---
	if boton_saltar != null:
		# Solo se hace visible si el contador llega a 10 o más
		boton_saltar.visible = (contador_muertes >= 10)
		
		# Conectamos el clic del botón por código
		if not boton_saltar.pressed.is_connected(_on_boton_saltar_pressed):
			boton_saltar.pressed.connect(_on_boton_saltar_pressed)
	# ---------------------------------

func _unhandled_input(event: InputEvent) -> void:
	# Usamos _unhandled_input para que si presionas el botón de pausa, la UI consuma el clic primero
	# y NUNCA active el estado de tocando_pantalla para el salto.
	if get_tree().paused or esta_muerto:
		tocando_pantalla = false
		return

	if event is InputEventScreenTouch:
		tocando_pantalla = event.pressed

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return

	# Si el juego se pausa en este frame, reseteamos el toque para evitar saltos fantasma
	if get_tree().paused:
		tocando_pantalla = false
		return

	# --- LÓGICA DE COYOTE TIME Y GRAVEDAD ---
	if is_on_floor():
		# Mientras toques el piso, el temporizador está lleno
		temporizador_coyote = coyote_time_maximo
	else:
		# Si caes del borde, el tiempo se agota progresivamente
		temporizador_coyote -= delta
		# Aplicamos gravedad normal porque estamos en el aire
		velocity.y += gravedad * delta 

	# --- LÓGICA DE SALTO ---
	if temporizador_coyote > 0.0 and not get_tree().paused:
		var quiere_saltar := Input.is_action_pressed("ui_accept") \
			or Input.is_action_pressed("ui_up") \
			or tocando_pantalla \
			or (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _clic_es_en_ui())

		if quiere_saltar:
			velocity.y = fuerza_salto
			# IMPORTANTE: Vaciamos el temporizador al saltar para evitar que 
			# el jugador haga un "doble salto" en el aire usando el tiempo restante.
			temporizador_coyote = 0.0 

	velocity.x = velocidad_avance
	move_and_slide()
	
	camara.global_position.x = global_position.x + desplazamiento_camara

	if is_on_wall():
		var direccion_pared = get_wall_normal()
		if direccion_pared.x <= -0.9 or direccion_pared.x >= 0.9:
			morir()
			
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_chocado = colision.get_collider()
		
		if objeto_chocado != null and objeto_chocado.is_in_group("trampas"):
			morir()

	_actualizar_animaciones()


# Función auxiliar para saber si el clic del mouse cayó sobre algún elemento de UI (como el botón de Pausa)
func _clic_es_en_ui() -> bool:
	var control_enfocado := get_viewport().gui_get_hovered_control()
	return control_enfocado != null


func _ensure_mobile_controls() -> void:
	if not MobileControlsSettings.is_mobile_device():
		return
	var scene := get_tree().current_scene
	if scene == null or scene.has_node("MobileControls"):
		return
	var controls := MOBILE_CONTROLS_SCENE.instantiate()
	controls.name = "MobileControls"
	scene.add_child.call_deferred(controls)

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
	
	# --- NUEVO: SOLUCIÓN A LA CÁMARA QUE SE SACUDE ---
	# Desvinculamos la cámara del jugador dejándola "suelta" en el nivel.
	# Así es físicamente imposible que herede los temblores o giros de la muerte.
	if camara.get_parent() == self:
		camara.reparent(get_tree().current_scene)
	# --------------------------------------------------
	
	contador_muertes += 1
	print("Muertes actuales: ", contador_muertes)
	
	MusicManager.detener()
	AudioManager.play_sfx(SFX_MUERTE)
	
	var tween = create_tween()
	# Encogemos a 0.01 en lugar de ZERO para evitar que Godot rompa las matemáticas
	tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.5)
	tween.parallel().tween_property(self, "rotation", 15.0, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().call_deferred("reload_current_scene")

# --- FUNCIÓN QUE SE EJECUTA AL PRESIONAR EL BOTÓN ---
func _on_boton_saltar_pressed() -> void:
	if AudioManager.has_method("play_ui_click"):
		AudioManager.play_ui_click()
		
	# Reiniciamos el contador por si rejugamos el nivel después
	contador_muertes = 0 
	
	if meta_del_nivel != null and meta_del_nivel.has_method("_iniciar_cuestionario"):
		# Usamos la misma función de tu meta para que siga el flujo normal de la historia
		meta_del_nivel._iniciar_cuestionario()
	else:
		push_warning("Falta asignar la meta_del_nivel en el Inspector del jugador")
