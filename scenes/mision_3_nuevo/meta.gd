extends Area2D

@export var escena_cuestionario: PackedScene = preload("res://scenes/cuestionarios/EscenaCuestionario.tscn")
# Aquí arrastrarás la escena donde consigues la llave
@export var escena_llave: PackedScene 
@export var numero_mision_cuestionario: int = 3 # Asegúrate de poner el número de misión correcto (3 o el que toque)

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		
		# --- NUEVO: LIMPIEZA DE CHECKPOINTS Y MUERTES ---
		# Verificamos que el jugador tenga estas variables antes de cambiarlas
		if "hay_checkpoint" in body:
			body.hay_checkpoint = false
			body.tiempo_musica_checkpoint = 0.0
		
		if "contador_muertes" in body:
			body.contador_muertes = 0
		# ------------------------------------------------
		
		call_deferred("_iniciar_cuestionario")

func _iniciar_cuestionario() -> void:
	# Verificamos si estamos en modo rejugabilidad (opcional, según tu sistema)
	if GameManager.has_method("consumir_modo_rejugabilidad") and GameManager.consumir_modo_rejugabilidad():
		get_tree().change_scene_to_file(GameManager.ESCENA_MAPA_REJUGABILIDAD)
		return
		
	if escena_cuestionario == null:
		push_error("No se asignó escena_cuestionario en la Meta")
		return

	if not Cuestionarios.validar_mision(numero_mision_cuestionario):
		push_warning("Misión de cuestionario no válida")
		return

	# Instanciamos el cuestionario
	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
	var dimension: String = Cuestionarios.obtener_dimension_para_mision(numero_mision_cuestionario)

	# Configuramos los datos del cuestionario
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_mision(numero_mision_cuestionario)
	cuestionario.dimension = dimension
	
	# La escena que sigue después del cuestionario será la de la LLAVE
	cuestionario.escena_siguiente = escena_llave

	# Cambiamos la escena actual por el cuestionario de forma segura
	var root: Window = get_tree().root
	var escena_actual: Node = get_tree().current_scene

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario

	if escena_actual:
		escena_actual.queue_free()
