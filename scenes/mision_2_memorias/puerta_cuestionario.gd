extends TextureButton

const GUIA_VISUAL: GDScript = preload("res://scenes/mision_2_memorias/guia_visual_puerta.gd")

@export var escena_cuestionario: PackedScene
@export var escena_siguiente: PackedScene
@export var numero_mision_cuestionario: int = 2

var _guia: GUIA_VISUAL
var _revelada: bool = false
var _en_transicion: bool = false
var _zona_visible: Rect2
var _tween_resaltado: Tween


func _ready() -> void:
	tooltip_text = "Continuar al cuestionario"
	accessibility_name = "Puerta para continuar al cuestionario"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# El PNG tiene amplios márgenes transparentes: solo la puerta recibe clics.
	var mascara: BitMap = BitMap.new()
	mascara.create_from_image_alpha(texture_normal.get_image(), 0.1)
	texture_click_mask = mascara
	_zona_visible = Rect2(texture_normal.get_image().get_used_rect())
	pivot_offset = _zona_visible.get_center()
	_guia = GUIA_VISUAL.new()
	_guia.name = "GuiaVisual"
	add_child(_guia)
	mouse_entered.connect(_actualizar_resaltado)
	mouse_exited.connect(_actualizar_resaltado)
	focus_entered.connect(_actualizar_resaltado)
	focus_exited.connect(_actualizar_resaltado)


func revelar() -> void:
	if _revelada:
		return
	_revelada = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	tween.tween_callback(func() -> void:
		disabled = false
		_guia.iniciar(_zona_visible)
		_actualizar_resaltado()
	)


func _actualizar_resaltado() -> void:
	if disabled or _en_transicion:
		return
	var resaltada: bool = is_hovered() or has_focus()
	_guia.resaltar(resaltada)
	if _tween_resaltado != null:
		_tween_resaltado.kill()
	_tween_resaltado = create_tween()
	_tween_resaltado.set_trans(Tween.TRANS_SINE)
	_tween_resaltado.tween_property(self, "scale", Vector2.ONE * (1.025 if resaltada else 1.0), 0.18)
	_tween_resaltado.parallel().tween_property(self, "self_modulate",
		Color(1.16, 1.1, 1.0) if resaltada else Color.WHITE, 0.18)


func _on_pressed() -> void:
	if disabled or _en_transicion:
		return
	var es_rejugabilidad: bool = GameManager.consumir_modo_rejugabilidad()
	if not es_rejugabilidad:
		if escena_cuestionario == null:
			push_error("No se asignó escena_cuestionario")
			return
		if not Cuestionarios.validar_mision(numero_mision_cuestionario):
			return
	_en_transicion = true
	disabled = true
	_guia.detener()
	if _tween_resaltado != null:
		_tween_resaltado.kill()
	AudioManager.play_ui_click()
	# La capa pertenece a la puerta y se libera también al cambiar de escena.
	var capa: CanvasLayer = CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	var luz: ColorRect = ColorRect.new()
	luz.color = Color("#fff5d9")
	luz.modulate.a = 0.0
	luz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa.add_child(luz)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ONE * 1.14, 0.45)
	tween.parallel().tween_property(luz, "modulate:a", 1.0, 0.45)
	await tween.finished
	if es_rejugabilidad:
		get_tree().change_scene_to_file(GameManager.ESCENA_MAPA_REJUGABILIDAD)
		return

	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
	var dimension: String = Cuestionarios.obtener_dimension_para_mision(numero_mision_cuestionario)
	
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_mision(numero_mision_cuestionario)
	cuestionario.dimension = dimension
	cuestionario.escena_siguiente = escena_siguiente

	var root := get_tree().root
	var escena_actual := get_tree().current_scene

	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
