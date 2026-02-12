extends Control

# ==================================================
# CONFIG
# ==================================================
@export var escena_cuestionario: PackedScene
@export var escena_siguiente: PackedScene

# ==================================================
# REFERENCIAS
# ==================================================
@onready var emociones: Array = $Panel/VBoxContainer/Emociones.get_children()
@onready var corazones: Array = $Panel/VBoxContainer/Vidas.get_children()
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
func mostrar(emociones_recolectadas: Array, vidas_restantes: int) -> void:
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
 
 
func _mostrar_emociones(lista: Array) -> void:
	for emocion in emociones:
		if emocion.name.to_lower() in lista:
			emocion.visible = true
			emocion.scale = Vector2(0.5, 0.5)
 
			var tween := create_tween()
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
 
	var tween := create_tween()
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
 
	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
 
 	# Inyectar datos
	cuestionario.preguntas = [
		"Presto mucha atención a los sentimientos.",
		"Normalmente me preocupo mucho por lo que siento.",
		"Normalmente dedico tiempo a pensar en mis emociones.",
		"Pienso que merece la pena prestar atención a mis emociones.",
		"Dejo que mis sentimientos afecten a mis pensamientos.",
		"Pienso en mi estado de ánimo constantemente.",
		"A menudo pienso en mis sentimientos.",
		"Presto mucha atención a cómo me siento."
	]
 
	cuestionario.dimension = "atencion"
	cuestionario.escena_siguiente = escena_siguiente
 
	# Reemplazar escena actual
	var root := get_tree().root
	var escena_actual := get_tree().current_scene

	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
