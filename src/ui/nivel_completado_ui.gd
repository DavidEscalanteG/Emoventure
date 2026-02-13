extends Control

# ==================================================
# CONFIG
# ==================================================
@export var escena_cuestionario: PackedScene
@export var escena_siguiente: PackedScene
@export var numero_mision_cuestionario: int = 1

# ==================================================
# REFERENCIAS
# ==================================================
@onready var emociones: Array[Node] = $Panel/VBoxContainer/Emociones.get_children()
@onready var corazones: Array[Node] = $Panel/VBoxContainer/Vidas.get_children()
@onready var jugador_grande: Control = $Panel/VBoxContainer/ControlJugador
@onready var boton: Button = $Panel/VBoxContainer/ControlBoton/BotonContinuar


# ==================================================
 # CICLO DE VIDA
 # ==================================================
func _ready() -> void:
	hide()
	boton.visible = false
	boton.disabled = true
	boton.pressed.connect(_continuar)
 
 
 # ==================================================
 # MOSTRAR RESULTADOS
 # ==================================================
func mostrar(emociones_recolectadas: Array[String], vidas_restantes: int) -> void:
	show()
 
	# Ocultar todo
	for e in emociones:
		e.visible = false
	for c in corazones:
		c.visible = false
 
	jugador_grande.visible = false
	boton.visible = false
	boton.disabled = true
 
	await _mostrar_emociones(emociones_recolectadas)
	await _mostrar_vidas(vidas_restantes)
	await _mostrar_jugador()
 
	boton.visible = true
	boton.disabled = false
	Logs.log_debug("✅ Listo para continuar")
 
 
func _mostrar_emociones(lista: Array[String]) -> void:
	for emocion in emociones:
		if emocion.name.to_lower() in lista:
			emocion.visible = true
			emocion.scale = Vector2(0.5, 0.5)
 
			var tween: Tween = create_tween()
			tween.tween_property(emocion, "scale", Vector2.ONE, 0.25)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
 
			await get_tree().create_timer(0.3).timeout
 
 
func _mostrar_vidas(vidas_restantes: int) -> void:
	for i in range(vidas_restantes):
		corazones[i].visible = true
		await get_tree().create_timer(0.25).timeout
 
 
func _mostrar_jugador() -> void:
	jugador_grande.visible = true
	jugador_grande.scale = Vector2(0.8, 0.8)
 
	var tween: Tween = create_tween()
	tween.tween_property(jugador_grande, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
 
	await tween.finished
 
 
 # ==================================================
 # CONTINUAR → CUESTIONARIO
 # ==================================================
func _continuar() -> void:
	Logs.log_debug("[DEBUG] Ir al cuestionario")
 
	if escena_cuestionario == null:
		push_error("No se asignó escena_cuestionario")
		return
 	
	if not Cuestionarios.validar_mision(numero_mision_cuestionario):
		return
		
	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
	var dimension: String = Cuestionarios.obtener_dimension_para_mision(numero_mision_cuestionario)

	# Inyectar datos
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_dimension(dimension)
	cuestionario.dimension = dimension
	cuestionario.escena_siguiente = escena_siguiente
 
	# Reemplazar escena actual
	var root: Window = get_tree().root
	var escena_actual: Node = get_tree().current_scene

	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
