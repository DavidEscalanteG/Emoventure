extends Node

@export var objetivo_path: NodePath
@export var etiqueta_hover_path: NodePath
@export var aplicar_a_todos_los_botones: bool = false
@export var contenedor_path: NodePath
@export var nombre_etiqueta_hover: StringName = &"Nombre"
@export_range(1.01, 1.3, 0.01) var escala_hover: float = 1.05
@export_range(0.1, 2.0, 0.01) var duracion_media_pulso: float = 0.6
@export var restaurar_suave_al_salir: bool = true

var _escalas_base: Dictionary = {}
var _tweens_pulso: Dictionary = {}
var _etiquetas_hover: Dictionary = {}


func _ready() -> void:
	if aplicar_a_todos_los_botones:
		_configurar_modo_grupal()
		return

	var objetivo := get_node_or_null(objetivo_path) as Control
	if objetivo == null:
		push_warning("[hover_pulse_button] Falta asignar 'objetivo_path' válido.")
		return

	var etiqueta_hover := get_node_or_null(etiqueta_hover_path) as Label
	_registrar_objetivo(objetivo, etiqueta_hover)


func _configurar_modo_grupal() -> void:
	var contenedor := get_node_or_null(contenedor_path)
	if contenedor == null:
		contenedor = get_parent()

	if contenedor == null:
		push_warning("[hover_pulse_button] Falta asignar 'contenedor_path' válido.")
		return

	for nodo in contenedor.find_children("*", "BaseButton", true, false):
		var boton := nodo as Control
		if boton == null:
			continue

		var etiqueta_hover := boton.get_node_or_null(String(nombre_etiqueta_hover)) as Label
		_registrar_objetivo(boton, etiqueta_hover)


func _registrar_objetivo(objetivo: Control, etiqueta_hover: Label) -> void:
	var id_objetivo := objetivo.get_instance_id()
	_escalas_base[id_objetivo] = objetivo.scale
	_etiquetas_hover[id_objetivo] = etiqueta_hover

	_actualizar_pivote(objetivo)
	objetivo.resized.connect(_actualizar_pivote.bind(objetivo))
	objetivo.mouse_entered.connect(_on_mouse_entered.bind(objetivo))
	objetivo.mouse_exited.connect(_on_mouse_exited.bind(objetivo))

	if etiqueta_hover != null:
		etiqueta_hover.visible = false


func _on_mouse_entered(objetivo: Control) -> void:
	var etiqueta_hover := _etiquetas_hover.get(objetivo.get_instance_id()) as Label
	if etiqueta_hover != null:
		etiqueta_hover.visible = true
	_iniciar_pulso(objetivo)


func _on_mouse_exited(objetivo: Control) -> void:
	var etiqueta_hover := _etiquetas_hover.get(objetivo.get_instance_id()) as Label
	if etiqueta_hover != null:
		etiqueta_hover.visible = false
	_detener_pulso(objetivo)


func _iniciar_pulso(objetivo: Control) -> void:
	_detener_tween_pulso(objetivo)

	var escala_base := _escalas_base.get(objetivo.get_instance_id(), objetivo.scale) as Vector2
	var escala_objetivo: Vector2 = escala_base * escala_hover
	var tween_pulso := create_tween()
	_tweens_pulso[objetivo.get_instance_id()] = tween_pulso
	tween_pulso.set_loops()
	tween_pulso.set_trans(Tween.TRANS_SINE)
	tween_pulso.set_ease(Tween.EASE_IN_OUT)
	tween_pulso.tween_property(objetivo, "scale", escala_objetivo, duracion_media_pulso)
	tween_pulso.tween_property(objetivo, "scale", escala_base, duracion_media_pulso)


func _detener_pulso(objetivo: Control) -> void:
	_detener_tween_pulso(objetivo)
	var escala_base := _escalas_base.get(objetivo.get_instance_id(), objetivo.scale) as Vector2

	if restaurar_suave_al_salir:
		var tween_pulso := create_tween()
		_tweens_pulso[objetivo.get_instance_id()] = tween_pulso
		tween_pulso.set_trans(Tween.TRANS_SINE)
		tween_pulso.set_ease(Tween.EASE_OUT)
		tween_pulso.tween_property(objetivo, "scale", escala_base, duracion_media_pulso * 0.45)
		return

	objetivo.scale = escala_base


func _detener_tween_pulso(objetivo: Control) -> void:
	var id_objetivo := objetivo.get_instance_id()
	var tween_pulso := _tweens_pulso.get(id_objetivo) as Tween
	if tween_pulso != null and tween_pulso.is_running():
		tween_pulso.kill()


func _actualizar_pivote(objetivo: Control) -> void:
	objetivo.pivot_offset = objetivo.size / 2.0
