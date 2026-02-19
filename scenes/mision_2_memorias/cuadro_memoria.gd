class_name CuadroMemoria
extends TextureButton

@export var imagen_color: Texture2D
@export var imagen_bn: Texture2D
@export var id_cuadro: int = -1

var emocion_asignada: String = ""
var completado: bool = false

signal cuadro_seleccionado(cuadro: CuadroMemoria)
signal cuadro_completado(cuadro: CuadroMemoria, emocion: String)

var hover_tween: Tween = null
var click_tween: Tween = null
var estela_tween: Tween = null
var emisores_borde: Array[GPUParticles2D] = []

@onready var estela: Node2D = $Estela
@onready var emoji_animado: AnimatedSprite2D = $EmojiAnimado


func _ready() -> void:
	if imagen_bn != null:
		texture_normal = imagen_bn

	scale = Vector2.ONE
	pivot_offset = size / 2.0
	_update_layout_overlays()
	resized.connect(_on_resized)
	_configurar_estela_inicial()


func _on_mouse_entered() -> void:
	if completado:
		return
	_iniciar_pulso()


func _on_mouse_exited() -> void:
	_detener_pulso()


func _on_pressed() -> void:
	AudioManager.play_ui_click()
	if completado:
		return

	_detener_pulso()
	_animar_click()


func _animar_click() -> void:
	if click_tween != null:
		click_tween.kill()

	click_tween = create_tween()
	click_tween.set_trans(Tween.TRANS_SINE)
	click_tween.set_ease(Tween.EASE_IN_OUT)
	click_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.35)
	click_tween.tween_callback(func() -> void:
		cuadro_seleccionado.emit(self)
	)


func _iniciar_pulso() -> void:
	_detener_pulso()

	hover_tween = create_tween()
	hover_tween.set_loops()
	hover_tween.set_trans(Tween.TRANS_SINE)
	hover_tween.set_ease(Tween.EASE_IN_OUT)
	hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.6)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.6)


func _detener_pulso() -> void:
	if hover_tween != null:
		hover_tween.kill()

	scale = Vector2.ONE


func marcar_completado(color_estela: Color) -> void:
	completado = true
	texture_normal = imagen_color

	estela.visible = true
	estela.modulate = color_estela
	estela.modulate.a = 0.95
	#_animar_estela_neon()

	scale = Vector2.ONE
	cuadro_completado.emit(self, emocion_asignada)

	if has_node("JugadorCinematico"):
		$JugadorCinematico.set_emocion(emocion_asignada)
	elif emoji_animado != null:
		emoji_animado.play(emocion_asignada)


func _configurar_estela_inicial() -> void:
	estela.visible = true
	estela.modulate = Color(0.66, 0.66, 0.66, 0.9)
	estela.position = Vector2.ZERO
	estela.scale = Vector2.ONE
	_crear_o_recuperar_emisores_borde()
	_actualizar_borde_particulas()


#func _animar_estela_neon() -> void:
	#if estela_tween != null:
		#estela_tween.kill()
#
	#estela.position = Vector2.ZERO
	#estela_tween = create_tween()
	#estela_tween.set_loops()
	#estela_tween.set_trans(Tween.TRANS_SINE)
	#estela_tween.set_ease(Tween.EASE_IN_OUT)
#
	#estela_tween.tween_property(estela, "position", Vector2(5.0, -3.0), 0.6)
	#estela_tween.parallel().tween_property(estela, "scale", Vector2(1.03, 1.02), 0.6)
	#estela_tween.parallel().tween_property(estela, "modulate:a", 0.82, 0.6)
#
	#estela_tween.tween_property(estela, "position", Vector2(-4.0, 4.0), 0.6)
	#estela_tween.parallel().tween_property(estela, "scale", Vector2(1.01, 1.04), 0.6)
	#estela_tween.parallel().tween_property(estela, "modulate:a", 0.98, 0.6)
#
	#estela_tween.tween_property(estela, "position", Vector2.ZERO, 0.7)
	#estela_tween.parallel().tween_property(estela, "scale", Vector2.ONE, 0.7)
	#estela_tween.parallel().tween_property(estela, "modulate:a", 0.9, 0.7)


func _on_resized() -> void:
	_update_layout_overlays()


func _update_layout_overlays() -> void:
	pivot_offset = size / 2.0

	var padding: float = max(min(size.x, size.y) * 0.08, 10.0)
	estela.position = Vector2(-padding, -padding)
	_actualizar_borde_particulas()

	if emoji_animado == null:
		return

	emoji_animado.position = size / 2.0
	var referencia: float = max(min(size.x, size.y), 1.0)
	var escala_base: float = referencia / 56.0
	emoji_animado.scale = Vector2.ONE * clamp(escala_base, 1.8, 3.4)
	emoji_animado.play("neutro")


func _crear_o_recuperar_emisores_borde() -> void:
	emisores_borde.clear()
	for nombre_emisor in ["Top", "Bottom", "Left", "Right"]:
		var nodo_existente: Node = estela.get_node_or_null(nombre_emisor)
		var emisor: GPUParticles2D
		if nodo_existente is GPUParticles2D:
			emisor = nodo_existente
		else:
			emisor = GPUParticles2D.new()
			emisor.name = nombre_emisor
			estela.add_child(emisor)

		emisor.top_level = false
		emisor.one_shot = false
		emisor.explosiveness = 0.2
		emisor.amount = 56
		emisor.lifetime = 1.4
		emisor.preprocess = 1.4
		emisor.local_coords = true
		emisor.show_behind_parent = true

		var proceso_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
		proceso_material.gravity = Vector3.ZERO
		proceso_material.initial_velocity_min = 10.0
		proceso_material.initial_velocity_max = 28.0
		proceso_material.scale_min = 5
		proceso_material.scale_max = 10
		proceso_material.spread = 28.0
		proceso_material.angular_velocity_min = -50.0
		proceso_material.angular_velocity_max = 50.0
		proceso_material.color = Color(1, 1, 1, 0.95)
		emisor.process_material = proceso_material
		emisor.emitting = true

		emisores_borde.append(emisor)


func _actualizar_borde_particulas() -> void:
	if emisores_borde.is_empty():
		return

	var half_size: Vector2 = size / 2.0
	var grosor: float = max(min(size.x, size.y) * 0.09, 10.0)

	for emisor in emisores_borde:
		var proceso_material: ParticleProcessMaterial = emisor.process_material as ParticleProcessMaterial
		if proceso_material == null:
			continue

		if emisor.name == "Top":
			emisor.position = Vector2(half_size.x, 0.0)
			proceso_material.direction = Vector3(0.0, -1.0, 0.0)
			proceso_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			proceso_material.emission_box_extents = Vector3(half_size.x, grosor * 0.5, 1.0)
		elif emisor.name == "Bottom":
			emisor.position = Vector2(half_size.x, size.y)
			proceso_material.direction = Vector3(0.0, 1.0, 0.0)
			proceso_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			proceso_material.emission_box_extents = Vector3(half_size.x, grosor * 0.5, 1.0)
		elif emisor.name == "Left":
			emisor.position = Vector2(0.0, half_size.y)
			proceso_material.direction = Vector3(-1.0, 0.0, 0.0)
			proceso_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			proceso_material.emission_box_extents = Vector3(grosor * 0.5, half_size.y, 1.0)
		else:
			emisor.position = Vector2(size.x, half_size.y)
			proceso_material.direction = Vector3(1.0, 0.0, 0.0)
			proceso_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			proceso_material.emission_box_extents = Vector3(grosor * 0.5, half_size.y, 1.0)
