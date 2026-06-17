extends Node

@export var objetivo_path: NodePath
@export var etiqueta_hover_path: NodePath
@export_range(1.01, 1.3, 0.01) var escala_hover: float = 1.05
@export_range(0.1, 2.0, 0.01) var duracion_media_pulso: float = 0.6
@export var restaurar_suave_al_salir: bool = true

var objetivo: Control
var etiqueta_hover: Label
var _escala_base: Vector2 = Vector2.ONE
var _tween_pulso: Tween


func _ready() -> void:
	objetivo = get_node_or_null(objetivo_path) as Control
	etiqueta_hover = get_node_or_null(etiqueta_hover_path) as Label

	if objetivo == null:
		push_warning("[hover_pulse_button] Falta asignar 'objetivo_path' válido.")
		return

	_escala_base = objetivo.scale
	_actualizar_pivote()
	objetivo.resized.connect(_actualizar_pivote)
	objetivo.mouse_entered.connect(_on_mouse_entered)
	objetivo.mouse_exited.connect(_on_mouse_exited)

	if etiqueta_hover != null:
		etiqueta_hover.visible = false


func _on_mouse_entered() -> void:
	if etiqueta_hover != null:
		etiqueta_hover.visible = true
	_iniciar_pulso()


func _on_mouse_exited() -> void:
	if etiqueta_hover != null:
		etiqueta_hover.visible = false
	_detener_pulso()


func _iniciar_pulso() -> void:
	_detener_tween_pulso()

	var escala_objetivo: Vector2 = _escala_base * escala_hover
	_tween_pulso = create_tween()
	_tween_pulso.set_loops()
	_tween_pulso.set_trans(Tween.TRANS_SINE)
	_tween_pulso.set_ease(Tween.EASE_IN_OUT)
	_tween_pulso.tween_property(objetivo, "scale", escala_objetivo, duracion_media_pulso)
	_tween_pulso.tween_property(objetivo, "scale", _escala_base, duracion_media_pulso)


func _detener_pulso() -> void:
	_detener_tween_pulso()

	if restaurar_suave_al_salir:
		_tween_pulso = create_tween()
		_tween_pulso.set_trans(Tween.TRANS_SINE)
		_tween_pulso.set_ease(Tween.EASE_OUT)
		_tween_pulso.tween_property(objetivo, "scale", _escala_base, duracion_media_pulso * 0.45)
		return

	objetivo.scale = _escala_base


func _detener_tween_pulso() -> void:
	if _tween_pulso != null and _tween_pulso.is_running():
		_tween_pulso.kill()


func _actualizar_pivote() -> void:
	if objetivo == null:
		return
	objetivo.pivot_offset = objetivo.size / 2.0
