extends RefCounted
class_name InteractiveButtonFX

const ESCALA_PULSO_HOVER: float = 1.06
const ESCALA_PRESION_BOTON: float = 0.94
const DURACION_PULSO_HOVER: float = 0.18
const OSCURECIMIENTO_PRESION_BOTON: float = 0.82

const META_CLAVE_APLICADO: StringName = &"ibfx_aplicado"
const META_CLAVE_ESCALA_BASE: StringName = &"ibfx_escala_base"
const META_CLAVE_MODULATE_BASE: StringName = &"ibfx_modulate_base"
const META_CLAVE_PRESIONADO: StringName = &"ibfx_presionado"
const META_CLAVE_TWEEN: StringName = &"ibfx_tween"


static func aplicar_a_botones_en(raiz: Node) -> void:
	if raiz == null:
		return

	for nodo in raiz.find_children("*", "BaseButton", true, false):
		var boton: BaseButton = nodo as BaseButton
		if boton == null:
			continue
		aplicar_a_boton(boton)


static func aplicar_a_boton(boton: BaseButton) -> void:
	var control: Control = boton as Control
	if control == null:
		return
	if control.has_meta(META_CLAVE_APLICADO) and bool(control.get_meta(META_CLAVE_APLICADO)):
		return

	control.set_meta(META_CLAVE_APLICADO, true)
	control.set_meta(META_CLAVE_ESCALA_BASE, control.scale)
	control.set_meta(META_CLAVE_MODULATE_BASE, control.modulate)
	control.set_meta(META_CLAVE_PRESIONADO, false)
	control.pivot_offset = control.size / 2.0

	control.resized.connect(func() -> void:
		if is_instance_valid(control):
			control.pivot_offset = control.size / 2.0
	)
	control.mouse_entered.connect(func() -> void:
		_on_boton_hover_in(control)
	)
	control.mouse_exited.connect(func() -> void:
		_on_boton_hover_out(control)
	)
	control.focus_entered.connect(func() -> void:
		_on_boton_hover_in(control)
	)
	control.focus_exited.connect(func() -> void:
		_on_boton_hover_out(control)
	)
	boton.button_down.connect(func() -> void:
		_on_boton_button_down(control)
	)
	boton.button_up.connect(func() -> void:
		_on_boton_button_up(control)
	)


static func _on_boton_hover_in(boton: Control) -> void:
	if _esta_presionado(boton):
		return
	_detener_tween(boton)

	var escala_base: Vector2 = _obtener_escala_base(boton)
	var tween: Tween = boton.create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(boton, "scale", escala_base * ESCALA_PULSO_HOVER, DURACION_PULSO_HOVER)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER)
	boton.set_meta(META_CLAVE_TWEEN, tween)


static func _on_boton_hover_out(boton: Control) -> void:
	if _esta_presionado(boton):
		return
	_detener_tween(boton)

	var escala_base: Vector2 = _obtener_escala_base(boton)
	var tween: Tween = boton.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER)
	boton.set_meta(META_CLAVE_TWEEN, tween)


static func _on_boton_button_down(boton: Control) -> void:
	boton.set_meta(META_CLAVE_PRESIONADO, true)
	_detener_tween(boton)

	var escala_base: Vector2 = _obtener_escala_base(boton)
	var modulate_base: Color = _obtener_modulate_base(boton)
	var modulate_presionado := Color(
		modulate_base.r * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.g * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.b * OSCURECIMIENTO_PRESION_BOTON,
		modulate_base.a
	)

	var tween: Tween = boton.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base * ESCALA_PRESION_BOTON, DURACION_PULSO_HOVER * 0.45)
	tween.parallel().tween_property(boton, "modulate", modulate_presionado, DURACION_PULSO_HOVER * 0.45)
	boton.set_meta(META_CLAVE_TWEEN, tween)


static func _on_boton_button_up(boton: Control) -> void:
	boton.set_meta(META_CLAVE_PRESIONADO, false)
	_detener_tween(boton)

	var escala_base: Vector2 = _obtener_escala_base(boton)
	var modulate_base: Color = _obtener_modulate_base(boton)
	var tween: Tween = boton.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", escala_base, DURACION_PULSO_HOVER * 0.5)
	tween.parallel().tween_property(boton, "modulate", modulate_base, DURACION_PULSO_HOVER * 0.5)
	boton.set_meta(META_CLAVE_TWEEN, tween)

	if boton.get_global_rect().has_point(boton.get_global_mouse_position()) or boton.has_focus():
		_on_boton_hover_in(boton)


static func _esta_presionado(boton: Control) -> bool:
	if not boton.has_meta(META_CLAVE_PRESIONADO):
		return false
	return bool(boton.get_meta(META_CLAVE_PRESIONADO))


static func _obtener_escala_base(boton: Control) -> Vector2:
	if boton.has_meta(META_CLAVE_ESCALA_BASE):
		return boton.get_meta(META_CLAVE_ESCALA_BASE) as Vector2
	return boton.scale


static func _obtener_modulate_base(boton: Control) -> Color:
	if boton.has_meta(META_CLAVE_MODULATE_BASE):
		return boton.get_meta(META_CLAVE_MODULATE_BASE) as Color
	return boton.modulate

static func _detener_tween(boton: Control) -> void:
	if not boton.has_meta(META_CLAVE_TWEEN):
		return

	var tween_variant: Variant = boton.get_meta(META_CLAVE_TWEEN)
	if tween_variant is Tween:
		var tween: Tween = tween_variant as Tween
		if tween != null and tween.is_running():
			tween.kill()
